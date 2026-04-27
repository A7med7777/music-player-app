import 'package:equatable/equatable.dart';
import 'package:music_player_app/features/library/domain/entities/album.dart';
import 'package:music_player_app/features/library/domain/entities/artist.dart';
import 'package:music_player_app/features/library/domain/entities/track.dart';
import 'package:music_player_app/features/playlists/domain/entities/playlist.dart';

class SearchResults extends Equatable {
  const SearchResults({
    this.tracks = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
  });

  final List<Track> tracks;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;

  bool get isEmpty =>
      tracks.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty;

  @override
  List<Object> get props => [tracks, albums, artists, playlists];
}

class SearchQuery extends Equatable {
  const SearchQuery({
    required this.query,
    required this.lastUsedAt,
  });

  final String query;
  final DateTime lastUsedAt;

  @override
  List<Object> get props => [query, lastUsedAt];
}
