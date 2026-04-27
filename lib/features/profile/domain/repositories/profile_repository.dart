import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Stream<Either<Failure, UserProfile>> watchProfile();
  Future<Either<Failure, void>> updateDisplayName(String name);
  Future<Either<Failure, void>> updateAvatar(String avatarUrl);
  Stream<Either<Failure, ProfileSummary>> watchSummary();
}
