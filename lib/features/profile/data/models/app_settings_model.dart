import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_player_app/features/profile/domain/entities/app_settings.dart';

class AppSettingsModel {
  const AppSettingsModel({
    required this.themeMode,
    required this.audioQuality,
    required this.crossfadeMs,
    required this.equalizerPreset,
    required this.showExplicit,
    required this.cloudSyncEnabled,
    required this.spotifyEnabled,
  });

  final String themeMode;
  final String audioQuality;
  final int crossfadeMs;
  final String equalizerPreset;
  final bool showExplicit;
  final bool cloudSyncEnabled;
  final bool spotifyEnabled;

  factory AppSettingsModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return AppSettingsModel(
      themeMode: (d['theme'] as String?) ?? 'system',
      audioQuality: (d['audioQuality'] as String?) ?? 'auto',
      crossfadeMs: (d['crossfadeMs'] as num?)?.toInt() ?? 0,
      equalizerPreset: (d['equalizerPreset'] as String?) ?? 'flat',
      showExplicit: (d['showExplicit'] as bool?) ?? true,
      cloudSyncEnabled: (d['cloudSyncEnabled'] as bool?) ?? true,
      spotifyEnabled: (d['spotifyEnabled'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'theme': themeMode,
    'audioQuality': audioQuality,
    'crossfadeMs': crossfadeMs,
    'equalizerPreset': equalizerPreset,
    'showExplicit': showExplicit,
    'cloudSyncEnabled': cloudSyncEnabled,
    'spotifyEnabled': spotifyEnabled,
  };

  AppSettings toDomain() => AppSettings(
    themeMode: _parseTheme(themeMode),
    audioQuality: _parseQuality(audioQuality),
    crossfadeMs: crossfadeMs,
    equalizerPreset: equalizerPreset,
    showExplicit: showExplicit,
    cloudSyncEnabled: cloudSyncEnabled,
    spotifyEnabled: spotifyEnabled,
  );

  static ThemeMode _parseTheme(String v) => switch (v) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static String themeToString(ThemeMode m) => switch (m) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    _ => 'system',
  };

  static AudioQuality _parseQuality(String v) => switch (v) {
    'low' => AudioQuality.low,
    'normal' => AudioQuality.normal,
    'high' => AudioQuality.high,
    _ => AudioQuality.auto,
  };

  static String qualityToString(AudioQuality q) => switch (q) {
    AudioQuality.low => 'low',
    AudioQuality.normal => 'normal',
    AudioQuality.high => 'high',
    AudioQuality.auto => 'auto',
  };
}
