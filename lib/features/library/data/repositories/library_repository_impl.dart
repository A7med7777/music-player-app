import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/data/datasources/library_remote_datasource.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/entities/artist.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl(this._remote);
  final LibraryRemoteDatasource _remote;

  @override
  Stream<Either<Failure, List<Track>>> watchTracks({
    TrackSort sort = TrackSort.title,
  }) => _remote.watchTracks(sort: sort).map<Either<Failure, List<Track>>>(
    (models) => Right(models.map((m) => m.toDomain()).toList()),
  ).handleError((_) => const Left(NetworkFailure()));

  @override
  Stream<Either<Failure, List<Album>>> watchAlbums() =>
      _remote.watchAlbums().map<Either<Failure, List<Album>>>(
        (models) => Right(models.map((m) => m.toDomain()).toList()),
      ).handleError((_) => const Left(NetworkFailure()));

  @override
  Stream<Either<Failure, List<Artist>>> watchArtists() =>
      _remote.watchArtists().map<Either<Failure, List<Artist>>>(
        (models) => Right(models.map((m) => m.toDomain()).toList()),
      ).handleError((_) => const Left(NetworkFailure()));

  @override
  Future<Either<Failure, Album>> getAlbum(String albumId) async {
    try {
      // Fetched as part of watchAlbums; direct fetch not wired to remote
      return const Left(NotFoundFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<Track>>> getTracksOfAlbum(
    String albumId,
  ) async {
    try {
      final models = await _remote.getTracksOfAlbum(albumId);
      return Right(models.map((m) => m.toDomain()).toList());
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Artist>> getArtist(String artistId) async =>
      const Left(NotFoundFailure());

  @override
  Future<Either<Failure, List<Album>>> getAlbumsOfArtist(
    String artistId,
  ) async {
    return const Right([]);
  }
}
