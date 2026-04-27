import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:music_player_app/features/favorites/domain/usecases/like_track.dart';
import 'package:music_player_app/features/favorites/domain/usecases/unlike_track.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  FavoritesViewModel({
    required FavoritesRepository favoritesRepository,
    required LikeTrack likeTrack,
    required UnlikeTrack unlikeTrack,
    required PlaybackRepository playbackRepository,
  })  : _repository = favoritesRepository,
        _likeTrack = likeTrack,
        _unlikeTrack = unlikeTrack,
        _playback = playbackRepository {
    _tracksSub = _repository.watchFavorites().listen((result) {
      result.fold((f) => failure = f, (t) {
        tracks = t;
        failure = null;
      });
      loading = false;
      notifyListeners();
    });
    _idsSub = _repository.watchLikedTrackIds().listen((ids) {
      likedIds = ids;
      notifyListeners();
    });
  }

  final FavoritesRepository _repository;
  final LikeTrack _likeTrack;
  final UnlikeTrack _unlikeTrack;
  final PlaybackRepository _playback;

  late final StreamSubscription _tracksSub;
  late final StreamSubscription _idsSub;

  List<Track> tracks = [];
  Set<String> likedIds = {};
  bool loading = true;
  Failure? failure;

  bool isLiked(String trackId) => likedIds.contains(trackId);

  Future<void> like(String trackId) => _likeTrack(trackId);
  Future<void> unlike(String trackId) => _unlikeTrack(trackId);

  Future<void> toggleLike(String trackId) async {
    if (isLiked(trackId)) {
      await unlike(trackId);
    } else {
      await like(trackId);
    }
  }

  Future<void> playAll({bool shuffle = false}) async {
    await _playback.playAllLiked(shuffle: shuffle);
  }

  @override
  void dispose() {
    _tracksSub.cancel();
    _idsSub.cancel();
    super.dispose();
  }
}
