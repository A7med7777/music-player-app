import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/entities/artist.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';
import 'package:music_player_app/features/library/domain/usecases/get_albums.dart';
import 'package:music_player_app/features/library/domain/usecases/get_artists.dart';
import 'package:music_player_app/features/library/domain/usecases/get_tracks.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';

class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel({
    required GetTracks getTracks,
    required GetAlbums getAlbums,
    required GetArtists getArtists,
    required PlaybackRepository playbackRepository,
  })  : _getTracks = getTracks,
        _getAlbums = getAlbums,
        _getArtists = getArtists,
        _playback = playbackRepository {
    _init();
  }

  final GetTracks _getTracks;
  final GetAlbums _getAlbums;
  final GetArtists _getArtists;
  final PlaybackRepository _playback;

  List<Track> tracks = [];
  List<Album> albums = [];
  List<Artist> artists = [];
  bool loading = true;
  Failure? failure;
  TrackSort sort = TrackSort.title;

  final List<StreamSubscription> _subs = [];

  void _init() {
    _subs.add(
      _getTracks(sort: sort).listen((result) {
        result.fold((f) => failure = f, (t) => tracks = t);
        loading = false;
        notifyListeners();
      }),
    );
    _subs.add(
      _getAlbums().listen((result) {
        result.fold((f) {}, (a) => albums = a);
        notifyListeners();
      }),
    );
    _subs.add(
      _getArtists().listen((result) {
        result.fold((f) {}, (a) => artists = a);
        notifyListeners();
      }),
    );
  }

  void changeSort(TrackSort newSort) {
    sort = newSort;
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    loading = true;
    notifyListeners();
    _init();
  }

  Future<void> playTrack(String trackId, {int? indexInList}) async {
    await _playback.playTrack(
      trackId,
      queue: tracks.map((t) => t.id).toList(),
      startIndex: indexInList ?? 0,
    );
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
