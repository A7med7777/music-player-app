import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/library/domain/repositories/library_repository.dart';

class GetTracks {
  const GetTracks(this._repository);
  final LibraryRepository _repository;

  Stream<Either<Failure, List<Track>>> call({
    TrackSort sort = TrackSort.title,
  }) => _repository.watchTracks(sort: sort);
}
