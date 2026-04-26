import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/now_playing/domain/repositories/playback_repository.dart';

class PlayPlaylist {
  PlayPlaylist(this._repository);
  final PlaybackRepository _repository;

  Future<Either<Failure, void>> call(
    String playlistId, {
    int startIndex = 0,
    bool shuffle = false,
  }) => _repository.playPlaylist(
    playlistId,
    startIndex: startIndex,
    shuffle: shuffle,
  );
}
