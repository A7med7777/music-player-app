# Contract — Domain Repository Interfaces

**Feature**: 001-music-player-app
**Date**: 2026-04-25

These are the abstract interfaces that the **domain layer** of every
feature exposes. The **data layer** provides the concrete implementations
(Firestore, local files, Spotify). The **presentation layer** (view models)
depends only on these interfaces — never on concrete data sources.

All methods return `Future<Either<Failure, T>>` (from the `dartz` package)
unless they are streams. `Failure` is the sealed domain error type.

---

## `LibraryRepository`

```dart
abstract class LibraryRepository {
  Stream<Either<Failure, List<Track>>> watchTracks({TrackSort sort = TrackSort.title});
  Stream<Either<Failure, List<Album>>> watchAlbums();
  Stream<Either<Failure, List<Artist>>> watchArtists();

  Future<Either<Failure, Album>> getAlbum(String albumId);
  Future<Either<Failure, List<Track>>> getTracksOfAlbum(String albumId);

  Future<Either<Failure, Artist>> getArtist(String artistId);
  Future<Either<Failure, List<Album>>> getAlbumsOfArtist(String artistId);
}
```

**Notes**:

- `watch*` methods are streams so the Library screen reflects new tracks
  the moment Firestore syncs (offline → online).
- `TrackSort` is a domain enum: `title | artist | album | recentlyAdded`.

---

## `PlaybackRepository`

```dart
abstract class PlaybackRepository {
  Stream<PlaybackState> get state;
  Stream<Queue> get queue;

  Future<Either<Failure, void>> playTrack(String trackId, {List<String>? queue, int startIndex = 0});
  Future<Either<Failure, void>> playPlaylist(String playlistId, {int startIndex = 0, bool shuffle = false});
  Future<Either<Failure, void>> playAllLiked({bool shuffle = false});

  Future<Either<Failure, void>> pause();
  Future<Either<Failure, void>> resume();
  Future<Either<Failure, void>> skipNext();
  Future<Either<Failure, void>> skipPrevious();
  Future<Either<Failure, void>> seekTo(Duration position);
  Future<Either<Failure, void>> setVolume(double volume); // 0.0–1.0

  Future<Either<Failure, void>> setShuffle(bool enabled);
  Future<Either<Failure, void>> setRepeatMode(RepeatMode mode);

  Future<Either<Failure, void>> reorderQueue(int from, int to);
  Future<Either<Failure, void>> removeFromQueue(int index);
}
```

**Performance contract**:

- `pause()` and `resume()` MUST take effect within 100 ms of the call
  (FR-011, SC-004).
- `playTrack()` for a `local` source MUST emit `state.playing == true`
  within 300 ms p95 (SC-002).
- `playTrack()` for a `spotifyPreview` source on a 10 Mbps connection
  MUST emit `state.playing == true` within 1000 ms p95.

---

## `SearchRepository`

```dart
abstract class SearchRepository {
  /// Streams as the user types; debounced 150 ms internally.
  Stream<Either<Failure, SearchResults>> search(String query);

  Future<Either<Failure, List<SearchQuery>>> recentQueries({int limit = 20});
  Future<Either<Failure, void>> recordQuery(String query);
  Future<Either<Failure, void>> clearRecentQueries();
}

class SearchResults {
  final List<Track> tracks;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;
}
```

**Performance contract**: `search()` MUST emit first results within 500 ms
p95 against a 1,000-track library (SC-003).

---

## `FavoritesRepository`

```dart
abstract class FavoritesRepository {
  /// Most-recently-liked first.
  Stream<Either<Failure, List<Track>>> watchFavorites();

  /// Cheap O(1) check used by every track row to render the heart icon.
  Stream<Set<String>> watchLikedTrackIds();

  Future<Either<Failure, void>> like(String trackId);
  Future<Either<Failure, void>> unlike(String trackId);
}
```

---

## `PlaylistRepository`

```dart
abstract class PlaylistRepository {
  Stream<Either<Failure, List<Playlist>>> watchPlaylists();
  Stream<Either<Failure, Playlist>> watchPlaylist(String playlistId);

  Future<Either<Failure, Playlist>> create(String name);
  Future<Either<Failure, void>> rename(String playlistId, String newName);
  Future<Either<Failure, void>> delete(String playlistId);

  Future<Either<Failure, void>> addTrack(String playlistId, String trackId);
  Future<Either<Failure, void>> removeTrack(String playlistId, String trackId);
  Future<Either<Failure, void>> reorder(String playlistId, int from, int to);
}
```

---

## `ProfileRepository`

```dart
abstract class ProfileRepository {
  Stream<Either<Failure, UserProfile>> watchProfile();
  Future<Either<Failure, void>> updateDisplayName(String name);
  Future<Either<Failure, void>> updateAvatar(String avatarUrl);

  /// Derived counts surfaced on the Profile screen.
  Stream<Either<Failure, ProfileSummary>> watchSummary();
}

class ProfileSummary {
  final int totalTracks;
  final int totalLiked;
  final int totalPlaylists;
}
```

---

## `SettingsRepository`

```dart
abstract class SettingsRepository {
  Stream<Either<Failure, AppSettings>> watchSettings();

  Future<Either<Failure, void>> setTheme(ThemeMode mode);
  Future<Either<Failure, void>> setAudioQuality(AudioQuality quality);
  Future<Either<Failure, void>> setCrossfade(int milliseconds);  // 0–12000
  Future<Either<Failure, void>> setEqualizerPreset(String presetId);
  Future<Either<Failure, void>> setShowExplicit(bool show);
  Future<Either<Failure, void>> setCloudSyncEnabled(bool enabled);
  Future<Either<Failure, void>> setSpotifyEnabled(bool enabled);
}
```

**Effect contract**: changes MUST take effect on the next relevant
playback event or rebuild (FR-028); the repository emits the updated
`AppSettings` synchronously after the write returns successfully.

---

## `AuthRepository`

```dart
abstract class AuthRepository {
  Stream<AuthState> get state;       // anonymous, signedIn, signedOut
  Future<Either<Failure, void>> signInAnonymously();
  Future<Either<Failure, void>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
}
```

`signInAnonymously()` is called automatically on first launch so the user
has a stable UID without any explicit step (matches spec assumption "no
mandatory authentication").

---

## `Failure` taxonomy

```dart
sealed class Failure {
  const Failure(this.code, this.message);
  final String code;
  final String message;
}

class NetworkFailure extends Failure { ... }       // No network or transient
class NotFoundFailure extends Failure { ... }      // Track/playlist/etc missing
class PermissionFailure extends Failure { ... }    // Auth required or denied
class ValidationFailure extends Failure { ... }    // Bad client input
class PlaybackFailure extends Failure { ... }      // Audio engine error
class IntegrationFailure extends Failure { ... }   // Spotify / Firebase outage
class UnknownFailure extends Failure { ... }
```

View models map each failure to a localized user-facing message via the
`l10n` layer; raw `Failure` types never reach widgets.
