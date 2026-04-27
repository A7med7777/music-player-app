import 'package:equatable/equatable.dart';

enum TrackSource { local, firebaseStorage, spotifyPreview }

class Track extends Equatable {
  const Track({
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
  final TrackSource source;
  final String sourceUri;
  final bool explicit;

  Duration get duration => Duration(milliseconds: durationMs);

  String get durationLabel {
    final d = duration;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$minutes:$seconds';
  }

  Track copyWith({
    String? id,
    String? title,
    String? artistId,
    String? artistName,
    String? albumId,
    String? albumName,
    int? durationMs,
    String? artworkUrl,
    TrackSource? source,
    String? sourceUri,
    bool? explicit,
  }) => Track(
    id: id ?? this.id,
    title: title ?? this.title,
    artistId: artistId ?? this.artistId,
    artistName: artistName ?? this.artistName,
    albumId: albumId ?? this.albumId,
    albumName: albumName ?? this.albumName,
    durationMs: durationMs ?? this.durationMs,
    artworkUrl: artworkUrl ?? this.artworkUrl,
    source: source ?? this.source,
    sourceUri: sourceUri ?? this.sourceUri,
    explicit: explicit ?? this.explicit,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    artistId,
    artistName,
    albumId,
    albumName,
    durationMs,
    artworkUrl,
    source,
    sourceUri,
    explicit,
  ];
}
