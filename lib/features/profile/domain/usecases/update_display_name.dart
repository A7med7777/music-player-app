import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateDisplayName {
  UpdateDisplayName(this._repository);
  final ProfileRepository _repository;

  Future<Either<Failure, void>> call(String name) =>
      _repository.updateDisplayName(name);
}
