import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/playlists/domain/entities/playlist.dart';
import 'package:music_player_app/features/playlists/domain/repositories/playlist_repository.dart';

class WatchPlaylists {
  WatchPlaylists(this._repository);
  final PlaylistRepository _repository;

  Stream<Either<Failure, List<Playlist>>> call() =>
      _repository.watchPlaylists();
}
