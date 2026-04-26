import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/repositories/settings_repository.dart';

class SetTheme {
  const SetTheme(this._repository);
  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(ThemeMode mode) =>
      _repository.setTheme(mode);
}
