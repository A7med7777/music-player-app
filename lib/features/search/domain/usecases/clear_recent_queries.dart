import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/search/domain/repositories/search_repository.dart';

class ClearRecentQueries {
  ClearRecentQueries(this._repository);
  final SearchRepository _repository;

  Future<Either<Failure, void>> call() => _repository.clearRecentQueries();
}
