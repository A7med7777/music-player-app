import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';
import 'package:music_player_app/features/favorites/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/playlists/presentation/viewmodels/playlists_viewmodel.dart';

class TrackRow extends StatelessWidget {
  const TrackRow({
    super.key,
    required this.track,
    required this.onTap,
  });

  final Track track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Semantics(
      label: '${track.title} by ${track.artistName}',
      button: true,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing16,
          vertical: tokens.spacing4,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
          child: SizedBox(
            width: tokens.artworkSizeMini,
            height: tokens.artworkSizeMini,
            child: track.artworkUrl != null
                ? Image.network(
                    track.artworkUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _Placeholder(),
                  )
                : const _Placeholder(),
          ),
        ),
        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          track.artistName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: tokens.colorOnSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              track.durationLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.colorOnSurfaceVariant,
                  ),
            ),
            Selector<FavoritesViewModel, bool>(
              selector: (_, vm) => vm.isLiked(track.id),
              builder: (context, liked, _) => IconButton(
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_outline,
                  color: liked ? tokens.colorPrimary : null,
                ),
                onPressed: () =>
                    context.read<FavoritesViewModel>().toggleLike(track.id),
                tooltip: liked ? 'Unlike' : 'Like',
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _onMenuSelected(context, value, tokens),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'add_to_playlist',
                  child: Text('Add to playlist'),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _onMenuSelected(
    BuildContext context,
    String value,
    AppTokens tokens,
  ) {
    if (value == 'add_to_playlist') {
      _showAddToPlaylistSheet(context, tokens);
    }
  }

  void _showAddToPlaylistSheet(BuildContext context, AppTokens tokens) {
    final vm = context.read<PlaylistsViewModel>();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(tokens.spacing16),
              child: Text(
                'Add to playlist',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            ...vm.playlists.map(
              (p) => ListTile(
                title: Text(p.name),
                onTap: () {
                  Navigator.pop(ctx);
                  vm.create(p.id);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New playlist'),
              onTap: () {
                Navigator.pop(ctx);
                _showCreatePlaylistDialog(context, vm);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(
    BuildContext context,
    PlaylistsViewModel vm,
  ) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final playlist = await vm.create(name);
                if (ctx.mounted) Navigator.pop(ctx);
                if (playlist != null && context.mounted) {
                  final pvm = context.read<PlaylistsViewModel>();
                  await pvm.create(name);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.music_note),
      );
}
