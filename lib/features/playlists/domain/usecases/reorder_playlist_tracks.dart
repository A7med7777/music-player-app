import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/playlists/domain/repositories/playlist_repository.dart';

class ReorderPlaylistTracks {
  ReorderPlaylistTracks(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call(String playlistId, int from, int to) =>
      _repository.reorder(playlistId, from, to);
}
