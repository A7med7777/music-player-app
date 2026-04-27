import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_player_app/core/services/spotify_token_service.dart';

// Fallback streams (SoundHelix) used when Spotify has no preview for a track.
const _fallbackUrls = [
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
];

const _trackList = [
  // The Weeknd — After Hours
  (
    id: 'track_blinding_lights',
    title: 'Blinding Lights',
    artist: 'The Weeknd',
    artistId: 'artist_weeknd',
    albumId: 'album_afterhours',
    albumName: 'After Hours',
    artwork: 'https://picsum.photos/seed/afterhours/400/400',
    durationMs: 200040,
  ),
  (
    id: 'track_save_your_tears',
    title: 'Save Your Tears',
    artist: 'The Weeknd',
    artistId: 'artist_weeknd',
    albumId: 'album_afterhours',
    albumName: 'After Hours',
    artwork: 'https://picsum.photos/seed/afterhours/400/400',
    durationMs: 215720,
  ),
  (
    id: 'track_after_hours',
    title: 'After Hours',
    artist: 'The Weeknd',
    artistId: 'artist_weeknd',
    albumId: 'album_afterhours',
    albumName: 'After Hours',
    artwork: 'https://picsum.photos/seed/afterhours/400/400',
    durationMs: 361000,
  ),
  (
    id: 'track_heartless',
    title: 'Heartless',
    artist: 'The Weeknd',
    artistId: 'artist_weeknd',
    albumId: 'album_afterhours',
    albumName: 'After Hours',
    artwork: 'https://picsum.photos/seed/afterhours/400/400',
    durationMs: 199520,
  ),
  // Taylor Swift — Midnights
  (
    id: 'track_anti_hero',
    title: 'Anti-Hero',
    artist: 'Taylor Swift',
    artistId: 'artist_swift',
    albumId: 'album_midnights',
    albumName: 'Midnights',
    artwork: 'https://picsum.photos/seed/midnights/400/400',
    durationMs: 200690,
  ),
  (
    id: 'track_lavender_haze',
    title: 'Lavender Haze',
    artist: 'Taylor Swift',
    artistId: 'artist_swift',
    albumId: 'album_midnights',
    albumName: 'Midnights',
    artwork: 'https://picsum.photos/seed/midnights/400/400',
    durationMs: 202400,
  ),
  (
    id: 'track_midnight_rain',
    title: 'Midnight Rain',
    artist: 'Taylor Swift',
    artistId: 'artist_swift',
    albumId: 'album_midnights',
    albumName: 'Midnights',
    artwork: 'https://picsum.photos/seed/midnights/400/400',
    durationMs: 174280,
  ),
  // Billie Eilish — Happier Than Ever
  (
    id: 'track_happier_than_ever',
    title: 'Happier Than Ever',
    artist: 'Billie Eilish',
    artistId: 'artist_billie',
    albumId: 'album_happier',
    albumName: 'Happier Than Ever',
    artwork: 'https://picsum.photos/seed/happierthanever/400/400',
    durationMs: 298853,
  ),
  (
    id: 'track_bad_guy',
    title: 'bad guy',
    artist: 'Billie Eilish',
    artistId: 'artist_billie',
    albumId: 'album_happier',
    albumName: 'Happier Than Ever',
    artwork: 'https://picsum.photos/seed/happierthanever/400/400',
    durationMs: 194088,
  ),
  (
    id: 'track_ocean_eyes',
    title: 'Ocean Eyes',
    artist: 'Billie Eilish',
    artistId: 'artist_billie',
    albumId: 'album_happier',
    albumName: 'Happier Than Ever',
    artwork: 'https://picsum.photos/seed/happierthanever/400/400',
    durationMs: 201600,
  ),
];

/// [spotifyToken] is optional. When provided, real 30-second Spotify preview
/// URLs are fetched for each track. Falls back to SoundHelix when null or when
/// Spotify has no preview for a track in the current region.
Future<void> seedSampleData(
  FirebaseFirestore db, {
  String? spotifyToken,
}) async {
  final batch = db.batch();

  // Artists
  final artistsCol = db.collection('catalog/artists/items');
  for (final a in [
    {
      'id': 'artist_weeknd',
      'name': 'The Weeknd',
      'nameLower': 'the weeknd',
      'artworkUrl': 'https://picsum.photos/seed/weeknd/400/400',
    },
    {
      'id': 'artist_swift',
      'name': 'Taylor Swift',
      'nameLower': 'taylor swift',
      'artworkUrl': 'https://picsum.photos/seed/taylorswift/400/400',
    },
    {
      'id': 'artist_billie',
      'name': 'Billie Eilish',
      'nameLower': 'billie eilish',
      'artworkUrl': 'https://picsum.photos/seed/billieeilish/400/400',
    },
  ]) {
    final id = a['id'] as String;
    batch.set(artistsCol.doc(id), Map<String, dynamic>.from(a)..remove('id'));
  }

  // Albums
  final albumsCol = db.collection('catalog/albums/items');
  for (final a in [
    {
      'id': 'album_afterhours',
      'title': 'After Hours',
      'nameLower': 'after hours',
      'primaryArtistId': 'artist_weeknd',
      'primaryArtistName': 'The Weeknd',
      'artworkUrl': 'https://picsum.photos/seed/afterhours/400/400',
      'releaseYear': 2020,
      'trackCount': 4,
    },
    {
      'id': 'album_midnights',
      'title': 'Midnights',
      'nameLower': 'midnights',
      'primaryArtistId': 'artist_swift',
      'primaryArtistName': 'Taylor Swift',
      'artworkUrl': 'https://picsum.photos/seed/midnights/400/400',
      'releaseYear': 2022,
      'trackCount': 3,
    },
    {
      'id': 'album_happier',
      'title': 'Happier Than Ever',
      'nameLower': 'happier than ever',
      'primaryArtistId': 'artist_billie',
      'primaryArtistName': 'Billie Eilish',
      'artworkUrl': 'https://picsum.photos/seed/happierthanever/400/400',
      'releaseYear': 2021,
      'trackCount': 3,
    },
  ]) {
    final id = a['id'] as String;
    batch.set(albumsCol.doc(id), Map<String, dynamic>.from(a)..remove('id'));
  }

  // Tracks — fetch Spotify previews when token available
  final tracksCol = db.collection('catalog/tracks/items');
  var fallbackIndex = 0;
  for (final t in _trackList) {
    String? previewUrl;
    String source = 'firebaseStorage';

    if (spotifyToken != null) {
      previewUrl = await SpotifyTokenService.getPreviewUrl(
        token: spotifyToken,
        trackName: t.title,
        artistName: t.artist,
      );
      if (previewUrl != null) source = 'spotifyPreview';
    }

    previewUrl ??= _fallbackUrls[fallbackIndex % _fallbackUrls.length];
    fallbackIndex++;

    batch.set(tracksCol.doc(t.id), {
      'title': t.title,
      'titleLower': t.title.toLowerCase(),
      'artistId': t.artistId,
      'artistName': t.artist,
      'albumId': t.albumId,
      'albumName': t.albumName,
      'durationMs': t.durationMs,
      'artworkUrl': t.artwork,
      'source': source,
      'sourceUri': previewUrl,
      'explicit': false,
    });
  }

  await batch.commit();
}
