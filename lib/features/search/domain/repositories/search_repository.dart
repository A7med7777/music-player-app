import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/search/domain/entities/search_results.dart';

abstract class SearchRepository {
  Stream<Either<Failure, SearchResults>> search(String query);
  Future<Either<Failure, List<SearchQuery>>> recentQueries({int limit = 20});
  Future<Either<Failure, void>> recordQuery(String query);
  Future<Either<Failure, void>> clearRecentQueries();
}
