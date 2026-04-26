import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/playlists/data/datasources/playlist_datasource.dart';
import 'package:music_player_app/features/playlists/domain/entities/playlist.dart';
import 'package:music_player_app/features/playlists/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  PlaylistRepositoryImpl(this._datasource);
  final PlaylistDatasource _datasource;

  @override
  Stream<Either<Failure, List<Playlist>>> watchPlaylists() =>
      _datasource.watchPlaylists().map<Either<Failure, List<Playlist>>>(
        (models) => Right(models.map((m) => m.toDomain()).toList()),
      ).handleError((_) => const Left(NetworkFailure()));

  @override
  Stream<Either<Failure, Playlist>> watchPlaylist(String playlistId) =>
      _datasource.watchPlaylist(playlistId).map<Either<Failure, Playlist>>(
        (model) => model != null
            ? Right(model.toDomain())
            : Left(const NotFoundFailure()),
      ).handleError((_) => const Left(NetworkFailure()));

  @override
  Future<Either<Failure, Playlist>> create(String name) async {
    try {
      final model = await _datasource.create(name);
      return Right(model.toDomain());
    } catch (_) {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> rename(
    String playlistId,
    String newName,
  ) async {
    try {
      await _datasource.rename(playlistId, newName);
      return const Right(null);
    } catch (_) {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> delete(String playlistId) async {
    try {
      await _datasource.delete(playlistId);
      return const Right(null);
    } catch (_) {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addTrack(
    String playlistId,
    String trackId,
  ) async {
    try {
      await _datasource.addTrack(playlistId, trackId);
      return const Right(null);
    } catch (_) {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeTrack(
    String playlistId,
    String trackId,
  ) async {
    try {
      await _datasource.removeTrack(playlistId, trackId);
      return const Right(null);
    } catch (_) {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> reorder(
    String playlistId,
    int from,
    int to,
  ) async {
    try {
      await _datasource.reorder(playlistId, from, to);
      return const Right(null);
    } catch (_) {
      return Left(const NetworkFailure());
    }
  }
}
