import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/profile/data/models/user_profile_model.dart';
import 'package:music_player_app/features/profile/domain/entities/user_profile.dart';

class ProfileDatasource {
  ProfileDatasource(this._db, this._uid);
  final FirebaseFirestore _db;
  final String Function() _uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.doc('users/${_uid()}');

  Stream<UserProfileModel> watchProfile() =>
      _userDoc.snapshots().asyncMap((snap) async {
        if (!snap.exists) {
          await _userDoc.set({
            'displayName': 'Listener',
            'createdAt': FieldValue.serverTimestamp(),
          });
          return UserProfileModel(
            uid: _uid(),
            displayName: 'Listener',
            avatarUrl: null,
            createdAt: DateTime.now(),
          );
        }
        return UserProfileModel.fromFirestore(snap);
      });

  Future<void> updateDisplayName(String name) =>
      _userDoc.set({'displayName': name}, SetOptions(merge: true));

  Future<void> updateAvatar(String avatarUrl) =>
      _userDoc.set({'avatarUrl': avatarUrl}, SetOptions(merge: true));

  Stream<ProfileSummary> watchSummary() => _userDoc.snapshots().asyncMap(
    (_) async {
      final results = await Future.wait([
        _db.collection('catalog/tracks/items').count().get(),
        _db.collection('users/${_uid()}/likes').count().get(),
        _db.collection('users/${_uid()}/playlists').count().get(),
      ]);
      return ProfileSummary(
        totalTracks: results[0].count ?? 0,
        totalLiked: results[1].count ?? 0,
        totalPlaylists: results[2].count ?? 0,
      );
    },
  );
}
