import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/shared/audio/playback_state.dart';

abstract class PlaybackRepository {
  Stream<PlaybackState> get state;
  Stream<Queue> get queue;

  Future<Either<Failure, void>> playTrack(
    String trackId, {
    List<String>? queue,
    int startIndex = 0,
  });
  Future<Either<Failure, void>> playPlaylist(
    String playlistId, {
    int startIndex = 0,
    bool shuffle = false,
  });
  Future<Either<Failure, void>> playAllLiked({bool shuffle = false});

  Future<Either<Failure, void>> pause();
  Future<Either<Failure, void>> resume();
  Future<Either<Failure, void>> skipNext();
  Future<Either<Failure, void>> skipPrevious();
  Future<Either<Failure, void>> seekTo(Duration position);
  Future<Either<Failure, void>> setVolume(double volume);

  Future<Either<Failure, void>> setShuffle(bool enabled);
  Future<Either<Failure, void>> setRepeatMode(RepeatMode mode);

  Future<Either<Failure, void>> reorderQueue(int from, int to);
  Future<Either<Failure, void>> removeFromQueue(int index);
}
