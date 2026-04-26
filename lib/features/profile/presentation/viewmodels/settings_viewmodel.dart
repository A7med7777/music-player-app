import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/entities/app_settings.dart';
import 'package:music_player_app/features/profile/domain/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repository) {
    _sub = _repository.watchSettings().listen((result) {
      result.fold(
        (failure) => _failure = failure,
        (settings) {
          _settings = settings;
          _failure = null;
        },
      );
      notifyListeners();
    });
  }

  final SettingsRepository _repository;
  late final StreamSubscription _sub;

  AppSettings _settings = AppSettings.defaults;
  Failure? _failure;

  AppSettings get settings => _settings;
  Failure? get failure => _failure;
  ThemeMode get themeMode => _settings.themeMode;

  Future<void> setTheme(ThemeMode mode) async {
    await _repository.setTheme(mode);
  }

  Future<void> setAudioQuality(AudioQuality quality) async {
    await _repository.setAudioQuality(quality);
  }

  Future<void> setCrossfade(int milliseconds) async {
    await _repository.setCrossfade(milliseconds);
  }

  Future<void> setEqualizerPreset(String presetId) async {
    await _repository.setEqualizerPreset(presetId);
  }

  Future<void> setShowExplicit(bool show) async {
    await _repository.setShowExplicit(show);
  }

  Future<void> setCloudSyncEnabled(bool enabled) async {
    await _repository.setCloudSyncEnabled(enabled);
  }

  Future<void> setSpotifyEnabled(bool enabled) async {
    await _repository.setSpotifyEnabled(enabled);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
