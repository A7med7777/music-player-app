import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';
import 'package:music_player_app/features/now_playing/presentation/viewmodels/now_playing_viewmodel.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Selector<NowPlayingViewModel, (String?, String?, String?, bool, bool)>(
      selector: (_, vm) => (
        vm.state.currentTrack?.title,
        vm.state.currentTrack?.artistName,
        vm.state.currentTrack?.artworkUrl,
        vm.state.playing,
        vm.state.currentTrack != null,
      ),
      builder: (context, data, _) {
        final (title, artist, artwork, playing, hasTrack) = data;
        if (!hasTrack) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.push('/now-playing'),
          child: Material(
            color: tokens.colorMiniPlayer,
            elevation: 8,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    SizedBox(
                      width: tokens.artworkSizeMini,
                      height: tokens.artworkSizeMini,
                      child: artwork != null
                          ? Image.network(
                              artwork,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const _ArtworkPlaceholder(),
                            )
                          : const _ArtworkPlaceholder(),
                    ),
                    SizedBox(width: tokens.spacing12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title ?? '',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            artist ?? '',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: tokens.colorOnSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      label: playing ? 'Pause' : 'Play',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () {
                          final vm = context.read<NowPlayingViewModel>();
                          if (playing) {
                            vm.pause();
                          } else {
                            vm.resume();
                          }
                        },
                      ),
                    ),
                    Semantics(
                      label: 'Skip next',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: () =>
                            context.read<NowPlayingViewModel>().skipNext(),
                      ),
                    ),
                    SizedBox(width: tokens.spacing4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.music_note, size: 32),
    );
  }
}
