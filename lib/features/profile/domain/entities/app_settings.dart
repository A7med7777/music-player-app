import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AudioQuality { auto, low, normal, high }

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.audioQuality = AudioQuality.auto,
    this.crossfadeMs = 0,
    this.equalizerPreset = 'flat',
    this.showExplicit = true,
    this.cloudSyncEnabled = true,
    this.spotifyEnabled = false,
  });

  final ThemeMode themeMode;
  final AudioQuality audioQuality;
  final int crossfadeMs;
  final String equalizerPreset;
  final bool showExplicit;
  final bool cloudSyncEnabled;
  final bool spotifyEnabled;

  static const defaults = AppSettings();

  AppSettings copyWith({
    ThemeMode? themeMode,
    AudioQuality? audioQuality,
    int? crossfadeMs,
    String? equalizerPreset,
    bool? showExplicit,
    bool? cloudSyncEnabled,
    bool? spotifyEnabled,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    audioQuality: audioQuality ?? this.audioQuality,
    crossfadeMs: crossfadeMs ?? this.crossfadeMs,
    equalizerPreset: equalizerPreset ?? this.equalizerPreset,
    showExplicit: showExplicit ?? this.showExplicit,
    cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
    spotifyEnabled: spotifyEnabled ?? this.spotifyEnabled,
  );

  @override
  List<Object> get props => [
    themeMode,
    audioQuality,
    crossfadeMs,
    equalizerPreset,
    showExplicit,
    cloudSyncEnabled,
    spotifyEnabled,
  ];
}
