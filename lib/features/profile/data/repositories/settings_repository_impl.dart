import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/data/models/app_settings_model.dart';
import 'package:music_player_app/features/profile/domain/entities/app_settings.dart';
import 'package:music_player_app/features/profile/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db, this._uid);
  final FirebaseFirestore _db;
  final String Function() _uid;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.doc('users/${_uid()}/settings/app');

  @override
  Stream<Either<Failure, AppSettings>> watchSettings() => _doc
      .snapshots()
      .map<Either<Failure, AppSettings>>(
        (snap) => Right(AppSettingsModel.fromFirestore(snap).toDomain()),
      )
      .handleError((_) => const Left(NetworkFailure()));

  Future<Either<Failure, void>> _update(Map<String, dynamic> data) async {
    try {
      await _doc.set(data, SetOptions(merge: true));
      return const Right(null);
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setTheme(ThemeMode mode) =>
      _update({'theme': AppSettingsModel.themeToString(mode)});

  @override
  Future<Either<Failure, void>> setAudioQuality(AudioQuality quality) =>
      _update({'audioQuality': AppSettingsModel.qualityToString(quality)});

  @override
  Future<Either<Failure, void>> setCrossfade(int milliseconds) {
    final clamped = milliseconds.clamp(0, 12000);
    return _update({'crossfadeMs': clamped});
  }

  @override
  Future<Either<Failure, void>> setEqualizerPreset(String presetId) =>
      _update({'equalizerPreset': presetId});

  @override
  Future<Either<Failure, void>> setShowExplicit(bool show) =>
      _update({'showExplicit': show});

  @override
  Future<Either<Failure, void>> setCloudSyncEnabled(bool enabled) =>
      _update({'cloudSyncEnabled': enabled});

  @override
  Future<Either<Failure, void>> setSpotifyEnabled(bool enabled) =>
      _update({'spotifyEnabled': enabled});
}
