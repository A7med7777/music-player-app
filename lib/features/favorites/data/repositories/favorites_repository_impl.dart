import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/favorites/data/datasources/favorites_datasource.dart';
import 'package:music_player_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._datasource);
  final FavoritesDatasource _datasource;

  @override
  Stream<Either<Failure, List<Track>>> watchFavorites() =>
      _datasource.watchFavorites().map<Either<Failure, List<Track>>>(
        (tracks) => Right(tracks),
      ).handleError((_) => const Left(NetworkFailure()));

  @override
  Stream<Set<String>> watchLikedTrackIds() =>
      _datasource.watchLikedTrackIds().handleError((_) => <String>{});

  @override
  Future<Either<Failure, void>> like(String trackId) async {
    try {
      await _datasource.like(trackId);
      return const Right(null);
    } catch (_) {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> unlike(String trackId) async {
    try {
      await _datasource.unlike(trackId);
      return const Right(null);
    } catch (_) {
      return Left(const NetworkFailure());
    }
  }
}
