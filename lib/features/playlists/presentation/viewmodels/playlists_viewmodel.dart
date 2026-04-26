import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/playlists/domain/entities/playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/create_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/delete_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/rename_playlist.dart';
import 'package:music_player_app/features/playlists/domain/usecases/watch_playlists.dart';

class PlaylistsViewModel extends ChangeNotifier {
  PlaylistsViewModel({
    required WatchPlaylists watchPlaylists,
    required CreatePlaylist createPlaylist,
    required RenamePlaylist renamePlaylist,
    required DeletePlaylist deletePlaylist,
  })  : _watchPlaylists = watchPlaylists,
        _createPlaylist = createPlaylist,
        _renamePlaylist = renamePlaylist,
        _deletePlaylist = deletePlaylist {
    _sub = _watchPlaylists().listen((result) {
      result.fold((f) => failure = f, (p) {
        playlists = p;
        failure = null;
      });
      loading = false;
      notifyListeners();
    });
  }

  final WatchPlaylists _watchPlaylists;
  final CreatePlaylist _createPlaylist;
  final RenamePlaylist _renamePlaylist;
  final DeletePlaylist _deletePlaylist;

  late final StreamSubscription _sub;

  List<Playlist> playlists = [];
  bool loading = true;
  Failure? failure;

  Future<Playlist?> create(String name) async {
    final result = await _createPlaylist(name);
    return result.fold((_) => null, (p) => p);
  }

  Future<void> rename(String playlistId, String newName) async {
    await _renamePlaylist(playlistId, newName);
  }

  Future<void> delete(String playlistId) async {
    await _deletePlaylist(playlistId);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
