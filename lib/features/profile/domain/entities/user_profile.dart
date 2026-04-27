import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
  }) => UserProfile(
    uid: uid ?? this.uid,
    displayName: displayName ?? this.displayName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [uid, displayName, avatarUrl, createdAt];
}

class ProfileSummary extends Equatable {
  const ProfileSummary({
    required this.totalTracks,
    required this.totalLiked,
    required this.totalPlaylists,
  });

  final int totalTracks;
  final int totalLiked;
  final int totalPlaylists;

  @override
  List<Object> get props => [totalTracks, totalLiked, totalPlaylists];
}
