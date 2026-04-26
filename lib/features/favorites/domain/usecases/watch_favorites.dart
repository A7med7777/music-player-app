import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';

class WatchFavorites {
  const WatchFavorites(this._repository);
  final FavoritesRepository _repository;

  Stream<Either<Failure, List<Track>>> call() =>
      _repository.watchFavorites();
}
