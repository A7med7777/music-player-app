import 'package:dartz/dartz.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/entities/app_settings.dart';
import 'package:music_player_app/features/profile/domain/repositories/settings_repository.dart';

class SetAudioQuality {
  SetAudioQuality(this._repository);
  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(AudioQuality quality) =>
      _repository.setAudioQuality(quality);
}
