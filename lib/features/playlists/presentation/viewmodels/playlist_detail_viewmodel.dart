import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/playlists/domain/entities/playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/add_track_to_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/play_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/remove_track_from_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/reorder_playlist_tracks.dart';
import 'package:music_player_app/features/playlists/domain/usecases/watch_playlist.dart';

class PlaylistDetailViewModel extends ChangeNotifier {
  PlaylistDetailViewModel({
    required String playlistId,
    required WatchPlaylist watchPlaylist,
    required AddTrackToPlaylist addTrack,
    required RemoveTrackFromPlaylist removeTrack,
    required ReorderPlaylistTracks reorderTracks,
    required PlayPlaylist playPlaylist,
  })  : _playlistId = playlistId,
        _watchPlaylist = watchPlaylist,
        _addTrack = addTrack,
        _removeTrack = removeTrack,
        _reorderTracks = reorderTracks,
        _playPlaylist = playPlaylist {
    _sub = _watchPlaylist(_playlistId).listen((result) {
      result.fold((f) => failure = f, (p) {
        playlist = p;
        failure = null;
      });
      loading = false;
      notifyListeners();
    });
  }

  final String _playlistId;
  final WatchPlaylist _watchPlaylist;
  final AddTrackToPlaylist _addTrack;
  final RemoveTrackFromPlaylist _removeTrack;
  final ReorderPlaylistTracks _reorderTracks;
  final PlayPlaylist _playPlaylist;

  late final StreamSubscription _sub;

  Playlist? playlist;
  bool loading = true;
  Failure? failure;

  Future<void> addTrack(String trackId) =>
      _addTrack(_playlistId, trackId);

  Future<void> removeTrack(String trackId) =>
      _removeTrack(_playlistId, trackId);

  Future<void> reorder(int from, int to) =>
      _reorderTracks(_playlistId, from, to);

  Future<void> play({int startIndex = 0, bool shuffle = false}) =>
      _playPlaylist(_playlistId, startIndex: startIndex, shuffle: shuffle);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
