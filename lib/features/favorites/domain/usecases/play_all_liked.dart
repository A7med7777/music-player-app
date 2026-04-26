import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';

class PlayAllLiked {
  PlayAllLiked(this._repository);
  final PlaybackRepository _repository;

  Future<Either<Failure, void>> call({bool shuffle = false}) =>
      _repository.playAllLiked(shuffle: shuffle);
}
