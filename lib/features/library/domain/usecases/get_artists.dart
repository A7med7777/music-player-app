import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/domain/entities/artist.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';

class GetArtists {
  const GetArtists(this._repository);
  final LibraryRepository _repository;

  Stream<Either<Failure, List<Artist>>> call() =>
      _repository.watchArtists();
}
