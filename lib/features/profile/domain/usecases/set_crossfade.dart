import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/repositories/settings_repository.dart';

class SetCrossfade {
  SetCrossfade(this._repository);
  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(int milliseconds) =>
      _repository.setCrossfade(milliseconds);
}
