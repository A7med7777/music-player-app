import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/playlists/domain/entities/playlist.dart';

class PlaylistModel {
  const PlaylistModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.trackIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerUid;
  final String name;
  final List<String> trackIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PlaylistModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String ownerUid,
  ) {
    final d = doc.data()!;
    return PlaylistModel(
      id: doc.id,
      ownerUid: ownerUid,
      name: d['name'] as String,
      trackIds: List<String>.from(d['trackIds'] as List? ?? []),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'trackIds': trackIds,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  Playlist toDomain() => Playlist(
    id: id,
    ownerUid: ownerUid,
    name: name,
    trackIds: trackIds,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
