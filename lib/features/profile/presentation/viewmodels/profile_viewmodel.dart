import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_player_app/core/error/failures.dart';
import 'package:music_player_app/features/profile/domain/entities/user_profile.dart';
import 'package:music_player_app/features/profile/domain/usecases/update_avatar.dart';
import 'package:music_player_app/features/profile/domain/usecases/update_display_name.dart';
import 'package:music_player_app/features/profile/domain/usecases/watch_profile.dart';
import 'package:music_player_app/features/profile/domain/usecases/watch_profile_summary.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required WatchProfile watchProfile,
    required WatchProfileSummary watchSummary,
    required UpdateDisplayName updateDisplayName,
    required UpdateAvatar updateAvatar,
  })  : _watchProfile = watchProfile,
        _watchSummary = watchSummary,
        _updateDisplayName = updateDisplayName,
        _updateAvatar = updateAvatar {
    _profileSub = _watchProfile().listen((result) {
      result.fold((f) => failure = f, (p) {
        profile = p;
        failure = null;
      });
      loading = false;
      notifyListeners();
    });
    _summarySub = _watchSummary().listen((result) {
      result.fold((_) {}, (s) => summary = s);
      notifyListeners();
    });
  }

  final WatchProfile _watchProfile;
  final WatchProfileSummary _watchSummary;
  final UpdateDisplayName _updateDisplayName;
  final UpdateAvatar _updateAvatar;

  late final StreamSubscription _profileSub;
  late final StreamSubscription _summarySub;

  UserProfile? profile;
  ProfileSummary? summary;
  bool loading = true;
  Failure? failure;
  bool saving = false;

  Future<void> updateName(String name) async {
    saving = true;
    notifyListeners();
    await _updateDisplayName(name);
    saving = false;
    notifyListeners();
  }

  Future<void> updateAvatarUrl(String url) async {
    saving = true;
    notifyListeners();
    await _updateAvatar(url);
    saving = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _profileSub.cancel();
    _summarySub.cancel();
    super.dispose();
  }
}
