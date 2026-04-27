import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/shared/audio/audio_handler.dart';
import 'package:music_player_app/shared/audio/playback_state.dart'
    as app_state;

const _queueBoxKey = 'queue_snapshot';

class PlaybackController {
  PlaybackController(this._handler);
  final MusicAudioHandler _handler;

  final _stateController =
      StreamController<app_state.PlaybackState>.broadcast();
  final _queueController = StreamController<app_state.Queue>.broadcast();

  app_state.PlaybackState _state = app_state.PlaybackState.empty;
  app_state.Queue _queue = app_state.Queue.empty;

  Stream<app_state.PlaybackState> get stateStream => _stateController.stream;
  Stream<app_state.Queue> get queueStream => _queueController.stream;
  app_state.PlaybackState get currentState => _state;
  app_state.Queue get currentQueue => _queue;

  Future<void> initialize() async {
    _handler.positionStream.listen((pos) {
      _state = _state.copyWith(positionMs: pos.inMilliseconds);
      _stateController.add(_state);
    });

    _handler.playbackState.listen((ps) {
      final playing = ps.playing;
      final loading =
          ps.processingState == AudioProcessingState.loading ||
          ps.processingState == AudioProcessingState.buffering;
      _state = _state.copyWith(playing: playing, loading: loading);
      _stateController.add(_state);
    });

    await _restoreFromDisk();
  }

  Future<void> playTracks(
    List<Track> tracks, {
    int startIndex = 0,
    bool shuffle = false,
  }) async {
    final ids = tracks.map((t) => t.id).toList();
    _queue = app_state.Queue(
      trackIds: ids,
      cursor: startIndex.clamp(0, ids.length - 1),
      shuffle: shuffle,
    );
    _state = _state.copyWith(
      currentTrack: tracks[startIndex.clamp(0, tracks.length - 1)],
      playing: true,
      loading: true,
      positionMs: 0,
    );
    _queueController.add(_queue);
    _stateController.add(_state);

    await _handler.initQueue(tracks, initialIndex: startIndex);
    await _handler.play();
    await _persistToDisk();
  }

  Future<void> pause() async {
    await _handler.pause();
    _state = _state.copyWith(playing: false);
    _stateController.add(_state);
  }

  Future<void> resume() async {
    await _handler.play();
    _state = _state.copyWith(playing: true);
    _stateController.add(_state);
  }

  Future<void> skipNext() => _handler.skipToNext();
  Future<void> skipPrevious() => _handler.skipToPrevious();
  Future<void> seekTo(Duration position) => _handler.seek(position);

  Future<void> setVolume(double volume) async {
    await _handler.setVolume(volume);
    _state = _state.copyWith(volume: volume);
    _stateController.add(_state);
  }

  Future<void> setShuffle(bool enabled) async {
    _queue = _queue.copyWith(shuffle: enabled);
    _state = _state.copyWith(shuffle: enabled);
    _queueController.add(_queue);
    _stateController.add(_state);
    await _persistToDisk();
  }

  Future<void> setRepeatMode(app_state.RepeatMode mode) async {
    _queue = _queue.copyWith(repeatMode: mode);
    _state = _state.copyWith(repeatMode: mode);
    _queueController.add(_queue);
    _stateController.add(_state);
    await _persistToDisk();
  }

  Future<void> _persistToDisk() async {
    final box = await Hive.openBox<dynamic>(_queueBoxKey);
    await box.put('trackIds', _queue.trackIds);
    await box.put('cursor', _queue.cursor);
    await box.put('shuffle', _queue.shuffle);
    await box.put('repeatMode', _queue.repeatMode.index);
    await box.put('positionMs', _state.positionMs);
  }

  Future<void> _restoreFromDisk() async {
    try {
      final box = await Hive.openBox<dynamic>(_queueBoxKey);
      final ids = (box.get('trackIds') as List?)?.cast<String>() ?? [];
      if (ids.isEmpty) return;
      final cursor = (box.get('cursor') as int?) ?? 0;
      final shuffle = (box.get('shuffle') as bool?) ?? false;
      final repeatIndex = (box.get('repeatMode') as int?) ?? 0;
      _queue = app_state.Queue(
        trackIds: ids,
        cursor: cursor,
        shuffle: shuffle,
        repeatMode: app_state.RepeatMode.values[repeatIndex],
      );
      _queueController.add(_queue);
    } catch (_) {
      // Graceful degradation: start fresh if restore fails
    }
  }

  Future<void> dispose() async {
    await _stateController.close();
    await _queueController.close();
  }
}
