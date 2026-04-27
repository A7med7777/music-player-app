import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/search/data/datasources/search_history_datasource.dart';
import 'package:music_player_app/features/search/data/datasources/search_local_datasource.dart';
import 'package:music_player_app/features/search/domain/entities/search_results.dart';
import 'package:music_player_app/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._local, this._history);
  final SearchLocalDatasource _local;
  final SearchHistoryDatasource _history;

  @override
  Stream<Either<Failure, SearchResults>> search(String query) =>
      _local
          .search(query)
          .map<Either<Failure, SearchResults>>(Right.new)
          .handleError((_) => const Left(NetworkFailure()));

  @override
  Future<Either<Failure, List<SearchQuery>>> recentQueries({
    int limit = 20,
  }) async {
    try {
      final queries = await _history.getRecentQueries(limit: limit);
      return Right(queries);
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> recordQuery(String query) async {
    try {
      await _history.recordQuery(query);
      return const Right(null);
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearRecentQueries() async {
    try {
      await _history.clearAll();
      return const Right(null);
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }
}
