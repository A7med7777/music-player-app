import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/search/domain/entities/search_results.dart';
import 'package:music_player_app/features/search/domain/repositories/search_repository.dart';

class SearchCatalog {
  SearchCatalog(this._repository);
  final SearchRepository _repository;

  Stream<Either<Failure, SearchResults>> call(String query) =>
      _repository.search(query);
}
