import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/entities/user_profile.dart';
import 'package:music_player_app/features/profile/domain/repositories/profile_repository.dart';

class WatchProfile {
  WatchProfile(this._repository);
  final ProfileRepository _repository;

  Stream<Either<Failure, UserProfile>> call() => _repository.watchProfile();
}
