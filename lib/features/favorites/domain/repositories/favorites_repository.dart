import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';

abstract class FavoritesRepository {
  Stream<Either<Failure, List<Track>>> watchFavorites();
  Stream<Set<String>> watchLikedTrackIds();
  Future<Either<Failure, void>> like(String trackId);
  Future<Either<Failure, void>> unlike(String trackId);
}
