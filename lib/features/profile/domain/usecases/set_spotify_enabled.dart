import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/repositories/settings_repository.dart';

class SetSpotifyEnabled {
  SetSpotifyEnabled(this._repository);
  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(bool enabled) =>
      _repository.setSpotifyEnabled(enabled);
}
