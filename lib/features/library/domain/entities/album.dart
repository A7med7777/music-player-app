import 'package:equatable/equatable.dart';

class Album extends Equatable {
  const Album({
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

  @override
  List<Object?> get props => [
    id,
    title,
    primaryArtistId,
    primaryArtistName,
    artworkUrl,
    trackCount,
    releaseYear,
  ];
}
