import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/favorites/domain/repositories/favorites_repository.dart';

class UnlikeTrack {
  const UnlikeTrack(this._repository);
  final FavoritesRepository _repository;

  Future<Either<Failure, void>> call(String trackId) =>
      _repository.unlike(trackId);
}
