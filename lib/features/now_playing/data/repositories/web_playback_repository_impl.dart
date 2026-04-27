import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/data/models/track_model.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';
import 'package:music_player_app/shared/audio/playback_state.dart';

/// Web-only playback repository. Uses just_audio directly (no audio_service)
/// since audio_service background features are unsupported on web.
class WebPlaybackRepository implements PlaybackRepository {
  WebPlaybackRepository(this._db, this._uid) {
    _setupListeners();
  }

  final FirebaseFirestore _db;
  final String Function() _uid;
  final _player = AudioPlayer();
  var _playlist = ConcatenatingAudioSource(children: []);

  final _stateController = StreamController<PlaybackState>.broadcast();
  final _queueController = StreamController<Queue>.broadcast();

  PlaybackState _state = PlaybackState.empty;
  Queue _queue = Queue.empty;
  List<Track> _tracks = [];

  @override
  Stream<PlaybackState> get state => _stateController.stream;

  @override
  Stream<Queue> get queue => _queueController.stream;

  void _setupListeners() {
    _player.positionStream.listen((pos) {
      _state = _state.copyWith(positionMs: pos.inMilliseconds);
      _stateController.add(_state);
    });

    _player.playingStream.listen((playing) {
      _state = _state.copyWith(playing: playing);
      _stateController.add(_state);
    });

    _player.processingStateStream.listen((ps) {
      final loading =
          ps == ProcessingState.loading || ps == ProcessingState.buffering;
      _state = _state.copyWith(loading: loading);
      _stateController.add(_state);
    });

    _player.currentIndexStream.listen((index) {
      if (index != null && index < _tracks.length) {
        _state = _state.copyWith(currentTrack: _tracks[index]);
        _queue = _queue.copyWith(cursor: index);
        _stateController.add(_state);
        _queueController.add(_queue);
      }
    });
  }

  Future<void> _playTracks(
    List<Track> tracks, {
    int startIndex = 0,
    bool shuffle = false,
  }) async {
    _tracks = tracks;
    final ids = tracks.map((t) => t.id).toList();
    _queue = Queue(
      trackIds: ids,
      cursor: startIndex.clamp(0, ids.isEmpty ? 0 : ids.length - 1),
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

    _playlist = ConcatenatingAudioSource(
      children: tracks
          .map((t) => AudioSource.uri(Uri.parse(t.sourceUri)))
          .toList(),
    );
    final clampedIndex = startIndex.clamp(0, tracks.length - 1);
    await _player.setAudioSource(_playlist, initialIndex: clampedIndex);
    if (shuffle) await _player.setShuffleModeEnabled(true);
    await _player.play();
  }

  @override
  Future<Either<Failure, void>> playTrack(
    String trackId, {
    List<String>? queue,
    int startIndex = 0,
  }) async {
    try {
      final ids = queue ?? [trackId];
      final tracks = await _fetchTracks(ids);
      if (tracks.isEmpty) return const Left(NotFoundFailure());
      await _playTracks(tracks, startIndex: startIndex);
      return const Right(null);
    } catch (_) {
      return const Left(PlaybackFailure());
    }
  }

  @override
  Future<Either<Failure, void>> playPlaylist(
    String playlistId, {
    int startIndex = 0,
    bool shuffle = false,
  }) async {
    try {
      final doc =
          await _db.doc('users/${_uid()}/playlists/$playlistId').get();
      if (!doc.exists) return const Left(NotFoundFailure());
      final ids = List<String>.from(doc.data()?['trackIds'] as List? ?? []);
      if (ids.isEmpty) return const Left(NotFoundFailure());
      final tracks = await _fetchTracks(ids);
      await _playTracks(tracks, startIndex: startIndex, shuffle: shuffle);
      return const Right(null);
    } catch (_) {
      return const Left(PlaybackFailure());
    }
  }

  @override
  Future<Either<Failure, void>> playAllLiked({bool shuffle = false}) async {
    try {
      final snap = await _db
          .collection('users/${_uid()}/likes')
          .orderBy('likedAt', descending: true)
          .get();
      final ids = snap.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return const Left(NotFoundFailure());
      final tracks = await _fetchTracks(ids);
      await _playTracks(tracks, shuffle: shuffle);
      return const Right(null);
    } catch (_) {
      return const Left(PlaybackFailure());
    }
  }

  @override
  Future<Either<Failure, void>> pause() async {
    await _player.pause();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resume() async {
    await _player.play();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> skipNext() async {
    if (_player.hasNext) await _player.seekToNext();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> skipPrevious() async {
    if (_player.hasPrevious) await _player.seekToPrevious();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> seekTo(Duration position) async {
    await _player.seek(position);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setVolume(double volume) async {
    await _player.setVolume(volume);
    _state = _state.copyWith(volume: volume);
    _stateController.add(_state);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
    _state = _state.copyWith(shuffle: enabled);
    _stateController.add(_state);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setRepeatMode(RepeatMode mode) async {
    final loopMode = switch (mode) {
      RepeatMode.off => LoopMode.off,
      RepeatMode.one => LoopMode.one,
      RepeatMode.all => LoopMode.all,
    };
    await _player.setLoopMode(loopMode);
    _state = _state.copyWith(repeatMode: mode);
    _stateController.add(_state);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> reorderQueue(int from, int to) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> removeFromQueue(int index) async =>
      const Right(null);

  Future<List<Track>> _fetchTracks(List<String> ids) async {
    final results = <Track>[];
    for (final id in ids) {
      try {
        final doc = await _db.doc('catalog/tracks/items/$id').get();
        if (doc.exists) {
          results.add(
            TrackModel.fromFirestore(
              doc,
            ).toDomain(),
          );
        }
      } catch (_) {}
    }
    return results;
  }
}
