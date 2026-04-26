import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/profile/domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  factory UserProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return UserProfileModel(
      uid: doc.id,
      displayName: (d['displayName'] as String?) ?? 'Listener',
      avatarUrl: d['avatarUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'displayName': displayName,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserProfile toDomain() => UserProfile(
    uid: uid,
    displayName: displayName,
    avatarUrl: avatarUrl,
    createdAt: createdAt,
  );
}
