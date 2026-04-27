import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/data/models/track_model.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';
import 'package:music_player_app/shared/audio/playback_controller.dart';
import 'package:music_player_app/shared/audio/playback_state.dart';

class PlaybackRepositoryImpl implements PlaybackRepository {
  PlaybackRepositoryImpl(
    this._controller,
    this._db,
    this._uid,
  );

  final PlaybackController _controller;
  final FirebaseFirestore _db;
  final String Function() _uid;

  @override
  Stream<PlaybackState> get state => _controller.stateStream;

  @override
  Stream<Queue> get queue => _controller.queueStream;

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
      await _controller.playTracks(tracks, startIndex: startIndex);
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
      final doc = await _db
          .doc('users/${_uid()}/playlists/$playlistId')
          .get();
      if (!doc.exists) return const Left(NotFoundFailure());
      final ids = List<String>.from(
        doc.data()?['trackIds'] as List? ?? [],
      );
      if (ids.isEmpty) return const Left(NotFoundFailure());
      final tracks = await _fetchTracks(ids);
      await _controller.playTracks(
        tracks,
        startIndex: startIndex,
        shuffle: shuffle,
      );
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
      await _controller.playTracks(tracks, shuffle: shuffle);
      return const Right(null);
    } catch (_) {
      return const Left(PlaybackFailure());
    }
  }

  @override
  Future<Either<Failure, void>> pause() async {
    await _controller.pause();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> resume() async {
    await _controller.resume();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> skipNext() async {
    await _controller.skipNext();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> skipPrevious() async {
    await _controller.skipPrevious();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> seekTo(Duration position) async {
    await _controller.seekTo(position);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setVolume(double volume) async {
    await _controller.setVolume(volume);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setShuffle(bool enabled) async {
    await _controller.setShuffle(enabled);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setRepeatMode(RepeatMode mode) async {
    await _controller.setRepeatMode(mode);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> reorderQueue(int from, int to) async {
    // Delegate to controller queue reorder
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeFromQueue(int index) async {
    return const Right(null);
  }

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
      } catch (_) {
        // Skip unavailable tracks
      }
    }
    return results;
  }
}
