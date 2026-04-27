import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/playlists/domain/repositories/playlist_repository.dart';

class DeletePlaylist {
  const DeletePlaylist(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call(String playlistId) =>
      _repository.delete(playlistId);
}
