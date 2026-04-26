import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateAvatar {
  UpdateAvatar(this._repository);
  final ProfileRepository _repository;

  Future<Either<Failure, void>> call(String avatarUrl) =>
      _repository.updateAvatar(avatarUrl);
}
