import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';
import 'package:music_player_app/features/playlists/presentation/viewmodels/playlists_viewmodel.dart';
import 'package:music_player_app/shared/widgets/empty_state.dart';
import 'package:music_player_app/shared/widgets/error_state.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        tooltip: 'New playlist',
        child: const Icon(Icons.add),
      ),
      body: Consumer<PlaylistsViewModel>(
        builder: (context, vm, _) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.failure != null) {
            return const ErrorState(message: 'Could not load playlists');
          }
          if (vm.playlists.isEmpty) {
            return const EmptyState(
              icon: Icons.queue_music_outlined,
              message: 'No playlists yet.\nTap + to create one.',
            );
          }
          return ListView.builder(
            itemCount: vm.playlists.length,
            itemBuilder: (_, i) {
              final p = vm.playlists[i];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: tokens.spacing16,
                  vertical: tokens.spacing4,
                ),
                leading: Container(
                  width: tokens.artworkSizeMini,
                  height: tokens.artworkSizeMini,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(tokens.radiusSmall),
                  ),
                  child: const Icon(Icons.queue_music),
                ),
                title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${p.trackCount} songs'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'rename') _showRenameDialog(context, vm, p.id, p.name);
                    if (v == 'delete') vm.delete(p.id);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () => context.push('/playlists/${p.id}'),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
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
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<PlaylistsViewModel>().create(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    PlaylistsViewModel vm,
    String id,
    String current,
  ) {
    final controller = TextEditingController(text: current);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                vm.rename(id, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
