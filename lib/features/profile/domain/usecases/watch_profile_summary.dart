import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/entities/user_profile.dart';
import 'package:music_player_app/features/profile/domain/repositories/profile_repository.dart';

class WatchProfileSummary {
  WatchProfileSummary(this._repository);
  final ProfileRepository _repository;

  Stream<Either<Failure, ProfileSummary>> call() =>
      _repository.watchSummary();
}
