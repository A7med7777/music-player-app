import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Stream<Either<Failure, AppSettings>> watchSettings();
  Future<Either<Failure, void>> setTheme(ThemeMode mode);
  Future<Either<Failure, void>> setAudioQuality(AudioQuality quality);
  Future<Either<Failure, void>> setCrossfade(int milliseconds);
  Future<Either<Failure, void>> setEqualizerPreset(String presetId);
  Future<Either<Failure, void>> setShowExplicit(bool show);
  Future<Either<Failure, void>> setCloudSyncEnabled(bool enabled);
  Future<Either<Failure, void>> setSpotifyEnabled(bool enabled);
}
