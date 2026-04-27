import 'package:equatable/equatable.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';

enum RepeatMode { off, all, one }

class PlaybackState extends Equatable {
  const PlaybackState({
    this.currentTrack,
    this.playing = false,
    this.positionMs = 0,
    this.bufferedMs = 0,
    this.durationMs = 0,
    this.volume = 1.0,
    this.shuffle = false,
    this.repeatMode = RepeatMode.off,
    this.error,
    this.loading = false,
  });

  final Track? currentTrack;
  final bool playing;
  final int positionMs;
  final int bufferedMs;
  final int durationMs;
  final double volume;
  final bool shuffle;
  final RepeatMode repeatMode;
  final PlaybackFailure? error;
  final bool loading;

  static const empty = PlaybackState();

  PlaybackState copyWith({
    Track? currentTrack,
    bool? playing,
    int? positionMs,
    int? bufferedMs,
    int? durationMs,
    double? volume,
    bool? shuffle,
    RepeatMode? repeatMode,
    PlaybackFailure? error,
    bool? loading,
    bool clearTrack = false,
    bool clearError = false,
  }) => PlaybackState(
    currentTrack: clearTrack ? null : (currentTrack ?? this.currentTrack),
    playing: playing ?? this.playing,
    positionMs: positionMs ?? this.positionMs,
    bufferedMs: bufferedMs ?? this.bufferedMs,
    durationMs: durationMs ?? this.durationMs,
    volume: volume ?? this.volume,
    shuffle: shuffle ?? this.shuffle,
    repeatMode: repeatMode ?? this.repeatMode,
    error: clearError ? null : (error ?? this.error),
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [
    currentTrack,
    playing,
    positionMs,
    bufferedMs,
    durationMs,
    volume,
    shuffle,
    repeatMode,
    error,
    loading,
  ];
}

class Queue extends Equatable {
  const Queue({
    this.trackIds = const [],
    this.cursor = 0,
    this.shuffle = false,
    this.repeatMode = RepeatMode.off,
    this.positionMs = 0,
  });

  final List<String> trackIds;
  final int cursor;
  final bool shuffle;
  final RepeatMode repeatMode;
  final int positionMs;

  static const empty = Queue();

  bool get isEmpty => trackIds.isEmpty;
  String? get currentId =>
      trackIds.isEmpty ? null : trackIds[cursor.clamp(0, trackIds.length - 1)];

  Queue copyWith({
    List<String>? trackIds,
    int? cursor,
    bool? shuffle,
    RepeatMode? repeatMode,
    int? positionMs,
  }) => Queue(
    trackIds: trackIds ?? this.trackIds,
    cursor: cursor ?? this.cursor,
    shuffle: shuffle ?? this.shuffle,
    repeatMode: repeatMode ?? this.repeatMode,
    positionMs: positionMs ?? this.positionMs,
  );

  @override
  List<Object?> get props => [trackIds, cursor, shuffle, repeatMode, positionMs];
}
