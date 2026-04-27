import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/search/domain/entities/search_results.dart';
import 'package:music_player_app/features/search/domain/repositories/search_repository.dart';

class GetRecentQueries {
  GetRecentQueries(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, List<SearchQuery>>> call({int limit = 20}) =>
      _repository.recentQueries(limit: limit);
}
