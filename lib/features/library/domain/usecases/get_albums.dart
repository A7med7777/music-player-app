import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';

class GetAlbums {
  const GetAlbums(this._repository);
  final LibraryRepository _repository;

  Stream<Either<Failure, List<Album>>> call() => _repository.watchAlbums();
}
