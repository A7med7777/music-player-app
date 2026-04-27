import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';

class MusicAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  MusicAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) skipToNext();
    });
  }

  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  Future<void> initQueue(List<Track> tracks, {int initialIndex = 0}) async {
    final sources = tracks
        .map((t) => _buildSource(t))
        .whereType<AudioSource>()
        .toList();
    await _playlist.clear();
    await _playlist.addAll(sources);
    queue.add(
      tracks
          .map(
            (t) => MediaItem(
              id: t.id,
              title: t.title,
              artist: t.artistName,
              album: t.albumName,
              artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
              duration: Duration(milliseconds: t.durationMs),
            ),
          )
          .toList(),
    );
    await _player.setAudioSource(
      _playlist,
      initialIndex: initialIndex.clamp(0, sources.length - 1),
    );
  }

  AudioSource? _buildSource(Track track) {
    try {
      return switch (track.source) {
        TrackSource.local => AudioSource.asset(track.sourceUri),
        TrackSource.firebaseStorage ||
        TrackSource.spotifyPreview =>
          AudioSource.uri(Uri.parse(track.sourceUri)),
      };
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await _player.seek(Duration.zero, index: index);
  }

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> setCrossfade(Duration duration) async {
    // just_audio handles gapless via ConcatenatingAudioSource
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream =>
      _player.bufferedPositionStream;
  bool get playing => _player.playing;
  Duration get position => _player.position;
  int? get currentIndex => _player.currentIndex;

  void _broadcastState(PlaybackEvent event) {
    final isPlaying = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: isPlaying,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  Future<void> dispose() => _player.dispose();
}
