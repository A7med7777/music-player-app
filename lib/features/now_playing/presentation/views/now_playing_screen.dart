import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';
import 'package:music_player_app/features/favorites/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:music_player_app/features/now_playing/presentation/viewmodels/now_playing_viewmodel.dart';
import 'package:music_player_app/shared/audio/playback_state.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.maybePop(context),
          tooltip: 'Close',
        ),
        title: const Text('Now Playing'),
        actions: [
          Consumer<NowPlayingViewModel>(
            builder: (_, vm, __) {
              final track = vm.state.currentTrack;
              if (track == null) return const SizedBox.shrink();
              return Selector<FavoritesViewModel, bool>(
                selector: (_, fvm) => fvm.isLiked(track.id),
                builder: (ctx, liked, _) => IconButton(
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_outline,
                    color: liked ? tokens.colorPrimary : null,
                  ),
                  onPressed: () =>
                      ctx.read<FavoritesViewModel>().toggleLike(track.id),
                  tooltip: liked ? 'Unlike' : 'Like',
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NowPlayingViewModel>(
        builder: (context, vm, _) {
          final state = vm.state;
          final track = state.currentTrack;
          if (track == null) {
            return const Center(child: Text('Nothing playing'));
          }
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spacing32),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(tokens.radiusMedium),
                        child: track.artworkUrl != null
                            ? Image.network(
                                track.artworkUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.music_note, size: 80),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.spacing4),
                    Text(
                      track.artistName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: tokens.colorOnSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.spacing16),
                    _ProgressBar(vm: vm, tokens: tokens),
                    SizedBox(height: tokens.spacing8),
                    _Controls(vm: vm, tokens: tokens),
                    SizedBox(height: tokens.spacing16),
                    _VolumeSlider(vm: vm, tokens: tokens),
                    SizedBox(height: tokens.spacing24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.vm, required this.tokens});
  final NowPlayingViewModel vm;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final durationMs = vm.state.durationMs;
    final positionMs = vm.state.positionMs;
    final ratio = durationMs > 0 ? positionMs / durationMs : 0.0;

    return Column(
      children: [
        Slider(
          value: ratio.clamp(0.0, 1.0),
          onChanged: (v) => vm.seekTo(
            Duration(milliseconds: (v * durationMs).round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatMs(positionMs),
                style: Theme.of(context).textTheme.bodySmall),
            Text(_formatMs(durationMs),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  String _formatMs(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.vm, required this.tokens});
  final NowPlayingViewModel vm;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final state = vm.state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Semantics(
          label: 'Shuffle ${state.shuffle ? "on" : "off"}',
          button: true,
          child: IconButton(
            icon: Icon(
              Icons.shuffle,
              color: state.shuffle ? tokens.colorPrimary : null,
            ),
            onPressed: () => vm.setShuffle(!state.shuffle),
          ),
        ),
        Semantics(
          label: 'Previous track',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.skip_previous),
            iconSize: 40,
            onPressed: vm.skipPrevious,
          ),
        ),
        Semantics(
          label: state.playing ? 'Pause' : 'Play',
          button: true,
          child: FilledButton(
            onPressed: state.playing ? vm.pause : vm.resume,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.all(tokens.spacing16),
            ),
            child: Icon(
              state.playing ? Icons.pause : Icons.play_arrow,
              size: 36,
            ),
          ),
        ),
        Semantics(
          label: 'Next track',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.skip_next),
            iconSize: 40,
            onPressed: vm.skipNext,
          ),
        ),
        Semantics(
          label: 'Repeat mode: ${state.repeatMode.name}',
          button: true,
          child: IconButton(
            icon: Icon(
              state.repeatMode == RepeatMode.one
                  ? Icons.repeat_one
                  : Icons.repeat,
              color: state.repeatMode != RepeatMode.off
                  ? tokens.colorPrimary
                  : null,
            ),
            onPressed: () {
              final next = switch (state.repeatMode) {
                RepeatMode.off => RepeatMode.all,
                RepeatMode.all => RepeatMode.one,
                RepeatMode.one => RepeatMode.off,
              };
              vm.setRepeatMode(next);
            },
          ),
        ),
      ],
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider({required this.vm, required this.tokens});
  final NowPlayingViewModel vm;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.volume_down, color: tokens.colorOnSurfaceVariant),
        Expanded(
          child: Slider(
            value: vm.state.volume,
            onChanged: vm.setVolume,
          ),
        ),
        Icon(Icons.volume_up, color: tokens.colorOnSurfaceVariant),
      ],
    );
  }
}
