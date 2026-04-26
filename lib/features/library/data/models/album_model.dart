import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';

class AlbumModel {
  const AlbumModel({
    required this.id,
    required this.title,
    required this.primaryArtistId,
    required this.primaryArtistName,
    this.artworkUrl,
    required this.trackCount,
    this.releaseYear,
  });

  final String id;
  final String title;
  final String primaryArtistId;
  final String primaryArtistName;
  final String? artworkUrl;
  final int trackCount;
  final int? releaseYear;

  factory AlbumModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return AlbumModel(
      id: doc.id,
      title: d['title'] as String,
      primaryArtistId: d['primaryArtistId'] as String,
      primaryArtistName: d['primaryArtistName'] as String,
      artworkUrl: d['artworkUrl'] as String?,
      trackCount: (d['trackCount'] as num).toInt(),
      releaseYear: (d['releaseYear'] as num?)?.toInt(),
    );
  }

  Album toDomain() => Album(
    id: id,
    title: title,
    primaryArtistId: primaryArtistId,
    primaryArtistName: primaryArtistName,
    artworkUrl: artworkUrl,
    trackCount: trackCount,
    releaseYear: releaseYear,
  );
}
