import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';

class TrackModel {
  const TrackModel({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.albumId,
    this.albumName,
    required this.durationMs,
    this.artworkUrl,
    required this.source,
    required this.sourceUri,
    this.explicit = false,
  });

  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? albumId;
  final String? albumName;
  final int durationMs;
  final String? artworkUrl;
  final String source;
  final String sourceUri;
  final bool explicit;

  factory TrackModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return TrackModel(
      id: doc.id,
      title: d['title'] as String,
      artistId: d['artistId'] as String,
      artistName: d['artistName'] as String,
      albumId: d['albumId'] as String?,
      albumName: d['albumName'] as String?,
      durationMs: (d['durationMs'] as num).toInt(),
      artworkUrl: d['artworkUrl'] as String?,
      source: d['source'] as String,
      sourceUri: d['sourceUri'] as String,
      explicit: (d['explicit'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'artistId': artistId,
    'artistName': artistName,
    if (albumId != null) 'albumId': albumId,
    if (albumName != null) 'albumName': albumName,
    'durationMs': durationMs,
    if (artworkUrl != null) 'artworkUrl': artworkUrl,
    'source': source,
    'sourceUri': sourceUri,
    'explicit': explicit,
  };

  Track toDomain() => Track(
    id: id,
    title: title,
    artistId: artistId,
    artistName: artistName,
    albumId: albumId,
    albumName: albumName,
    durationMs: durationMs,
    artworkUrl: artworkUrl,
    source: _parseSource(source),
    sourceUri: sourceUri,
    explicit: explicit,
  );

  static TrackSource _parseSource(String value) => switch (value) {
    'firebaseStorage' => TrackSource.firebaseStorage,
    'spotifyPreview' => TrackSource.spotifyPreview,
    _ => TrackSource.local,
  };

  static String sourceToString(TrackSource s) => switch (s) {
    TrackSource.firebaseStorage => 'firebaseStorage',
    TrackSource.spotifyPreview => 'spotifyPreview',
    TrackSource.local => 'local',
  };
}
