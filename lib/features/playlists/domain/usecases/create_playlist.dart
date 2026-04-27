import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/playlists/domain/entities/playlist.dart';
import 'package:music_player_app/features/playlists/domain/repositories/playlist_repository.dart';

class CreatePlaylist {
  const CreatePlaylist(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, Playlist>> call(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Future.value(const Left(ValidationFailure('Name cannot be empty.')));
    }
    return _repository.create(trimmed);
  }
}
