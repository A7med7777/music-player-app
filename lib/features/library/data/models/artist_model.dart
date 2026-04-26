import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/library/domain/entities/artist.dart';

class ArtistModel {
  const ArtistModel({
    required this.id,
    required this.name,
    this.artworkUrl,
  });

  final String id;
  final String name;
  final String? artworkUrl;

  factory ArtistModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return ArtistModel(
      id: doc.id,
      name: d['name'] as String,
      artworkUrl: d['artworkUrl'] as String?,
    );
  }

  Artist toDomain() => Artist(id: id, name: name, artworkUrl: artworkUrl);
}
