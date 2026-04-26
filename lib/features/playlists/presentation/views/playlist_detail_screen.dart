import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';
import 'package:music_player_app/features/library/presentation/viewmodels/library_viewmodel.dart';
import 'package:music_player_app/features/playlists/presentation/viewmodels/playlist_detail_viewmodel.dart';
import 'package:music_player_app/shared/widgets/empty_state.dart';
import 'package:music_player_app/shared/widgets/error_state.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Consumer<PlaylistDetailViewModel>(
      builder: (context, vm, _) {
        final playlist = vm.playlist;
        return Scaffold(
          appBar: AppBar(
            title: Text(playlist?.name ?? 'Playlist'),
            actions: [
              if (playlist != null && playlist.trackCount > 0) ...[
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => vm.play(),
                  tooltip: 'Play',
                ),
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  onPressed: () => vm.play(shuffle: true),
                  tooltip: 'Shuffle',
                ),
              ],
            ],
          ),
          body: () {
            if (vm.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.failure != null) {
              return const ErrorState(message: 'Could not load playlist');
            }
            if (playlist == null || playlist.trackIds.isEmpty) {
              return const EmptyState(
                icon: Icons.queue_music_outlined,
                message:
                    'No tracks yet.\nAdd songs from Library or Search.',
              );
            }
            final libraryVm = context.read<LibraryViewModel>();
            final tracksById = {
              for (final t in libraryVm.tracks) t.id: t,
            };
            return ReorderableListView.builder(
              itemCount: playlist.trackIds.length,
              onReorder: vm.reorder,
              itemBuilder: (_, i) {
                final trackId = playlist.trackIds[i];
                final track = tracksById[trackId];
                return Dismissible(
                  key: ValueKey(trackId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: tokens.spacing16),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                  onDismissed: (_) => vm.removeTrack(trackId),
                  child: ListTile(
                    key: ValueKey('tile_$trackId'),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing16,
                    ),
                    leading: Text(
                      '${i + 1}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    title: Text(
                      track?.title ?? trackId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: track != null
                        ? Text(track.artistName, maxLines: 1)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (track != null)
                          Text(
                            track.durationLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                    onTap: () => vm.play(startIndex: i),
                  ),
                );
              },
            );
          }(),
        );
      },
    );
  }
}
