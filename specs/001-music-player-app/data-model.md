# Phase 1 — Data Model: Comprehensive Music Player Application

**Feature**: 001-music-player-app
**Date**: 2026-04-25
**Inputs**: [spec.md](spec.md) (Key Entities), [research.md](research.md) (R3, R10)

This document defines the domain entities (pure Dart, no Flutter or
Firebase imports) and how each one is persisted in Firestore. Field types
are expressed in Dart for the domain layer and in JSON for Firestore.

---

## Conventions

- All IDs are non-empty strings. Locally generated IDs use `uuid v4`;
  Spotify-sourced records reuse the Spotify ID (prefixed with
  `spotify:track:`, `spotify:album:`, `spotify:artist:` to keep namespaces
  obvious).
- All timestamps are stored in Firestore as `Timestamp` and surfaced in
  the domain layer as `DateTime` (UTC).
- Soft-delete is not used; deletes are hard.
- All "user-owned" collections are nested under
  `/users/{uid}/...` so Firestore security rules can be a single
  "owner-only read/write" rule.

---

## Entities

### Track

A single playable audio item.

| Field | Type (domain) | Type (Firestore) | Required | Notes |
| --- | --- | --- | --- | --- |
| `id` | `String` | string (doc id) | yes | UUID or `spotify:track:<id>` |
| `title` | `String` | string | yes | Non-empty, ≤ 256 chars |
| `artistId` | `String` | string | yes | FK → `Artist.id` |
| `artistName` | `String` | string | yes | Denormalized for list views |
| `albumId` | `String?` | string | no | FK → `Album.id` |
| `albumName` | `String?` | string | no | Denormalized |
| `durationMs` | `int` | int | yes | > 0 |
| `artworkUrl` | `String?` | string | no | https URL or `asset://...` |
| `source` | `TrackSource` | string enum | yes | `local`, `firebaseStorage`, `spotifyPreview` |
| `sourceUri` | `String` | string | yes | `asset://`, `gs://`, or `https://` URL |
| `explicit` | `bool` | bool | yes | Default `false` |

**Validation rules**:

- `title`, `artistId`, `artistName`, `sourceUri` must be non-empty.
- `durationMs` must be > 0.
- `source = spotifyPreview` ⇒ `sourceUri` must be a Spotify
  `preview_url` (https) and `durationMs` is capped at 30,000.

### Album

| Field | Type (domain) | Type (Firestore) | Required | Notes |
| --- | --- | --- | --- | --- |
| `id` | `String` | string (doc id) | yes | |
| `title` | `String` | string | yes | |
| `primaryArtistId` | `String` | string | yes | FK → `Artist.id` |
| `primaryArtistName` | `String` | string | yes | Denormalized |
| `artworkUrl` | `String?` | string | no | |
| `trackCount` | `int` | int | yes | ≥ 0 |
| `releaseYear` | `int?` | int | no | |

### Artist

| Field | Type (domain) | Type (Firestore) | Required | Notes |
| --- | --- | --- | --- | --- |
| `id` | `String` | string (doc id) | yes | |
| `name` | `String` | string | yes | |
| `artworkUrl` | `String?` | string | no | |

### Playlist

User-curated, ordered.

| Field | Type (domain) | Type (Firestore) | Required | Notes |
| --- | --- | --- | --- | --- |
| `id` | `String` | string (doc id) | yes | UUID v4 |
| `ownerUid` | `String` | string | yes | Matches parent path `/users/{uid}` |
| `name` | `String` | string | yes | 1–80 chars |
| `trackIds` | `List<String>` | array<string> | yes | Ordered; max 5,000 |
| `createdAt` | `DateTime` | Timestamp | yes | UTC |
| `updatedAt` | `DateTime` | Timestamp | yes | UTC; update on any mutation |

**Validation rules**:

- `name` must be non-empty after trim.
- `trackIds` must contain no duplicates.
- Reordering = replace `trackIds` with the new order in a single write.

### LikedTrack (entry in Favorites)

The Favorites screen is materialized from this subcollection ordered by
`likedAt desc`.

| Field | Type (domain) | Type (Firestore) | Required | Notes |
| --- | --- | --- | --- | --- |
| `trackId` | `String` | string (doc id) | yes | Same as `Track.id` |
| `likedAt` | `DateTime` | Timestamp | yes | UTC |

### UserProfile

| Field | Type (domain) | Type (Firestore) | Required | Notes |
| --- | --- | --- | --- | --- |
| `uid` | `String` | string (doc id) | yes | From Firebase Auth |
| `displayName` | `String` | string | yes | 1–80 chars; default `"Listener"` |
| `avatarUrl` | `String?` | string | no | |
| `createdAt` | `DateTime` | Timestamp | yes | |

The "summary" surfaced on the Profile screen (`totalTracks`,
`totalLiked`, `totalPlaylists`) is **derived**, not stored — it is
computed from the relevant collections at read time.

### AppSettings

Single per-user document.

| Field | Type (domain) | Type (Firestore) | Required | Default |
| --- | --- | --- | --- | --- |
| `theme` | `ThemeMode` | string enum | yes | `system` |
| `audioQuality` | `AudioQuality` | string enum | yes | `auto` |
| `crossfadeMs` | `int` | int | yes | `0` (off); range 0–12,000 |
| `equalizerPreset` | `String` | string | yes | `flat` |
| `showExplicit` | `bool` | bool | yes | `true` |
| `cloudSyncEnabled` | `bool` | bool | yes | `true` |
| `spotifyEnabled` | `bool` | bool | yes | `false` |

### SearchQuery (history entry)

Per-device, per-user. Capped at 20 entries (oldest evicted).

| Field | Type (domain) | Type (Firestore) | Required | Notes |
| --- | --- | --- | --- | --- |
| `query` | `String` | string | yes | Non-empty after trim, lowercased for dedup |
| `lastUsedAt` | `DateTime` | Timestamp | yes | UTC; update if duplicate query |

### Queue (in-memory + on-disk snapshot)

Not stored in Firestore — the queue is a local concept owned by the
playback controller. A snapshot is persisted to Hive on every change so
playback resumes across cold starts.

| Field | Type (domain) | Notes |
| --- | --- | --- |
| `trackIds` | `List<String>` | Ordered |
| `cursor` | `int` | Index into `trackIds`; `0 ≤ cursor < length` |
| `shuffle` | `bool` | |
| `repeatMode` | `RepeatMode` | `off`, `all`, `one` |
| `positionMs` | `int` | Last persisted playhead |

### PlaybackState (in-memory only)

| Field | Type | Notes |
| --- | --- | --- |
| `currentTrack` | `Track?` | |
| `playing` | `bool` | |
| `positionMs` | `int` | |
| `bufferedMs` | `int` | |
| `volume` | `double` | 0.0–1.0 |
| `error` | `PlaybackFailure?` | Non-null surfaces user notice |

---

## Relationships

```text
Artist (1) ───< (N) Album ───< (N) Track
                                 │
        UserProfile (1) ─< (N) Playlist >─ (N) Track   (via Playlist.trackIds)
        UserProfile (1) ─< (N) LikedTrack >─ (1) Track
        UserProfile (1) ─< (1) AppSettings
        UserProfile (1) ─< (N) SearchQuery
```

---

## Firestore document layout

```text
/catalog/tracks/{trackId}                 # Track (shared catalog, may be empty if local-only)
/catalog/albums/{albumId}                 # Album
/catalog/artists/{artistId}               # Artist

/users/{uid}                              # UserProfile
/users/{uid}/settings/app                 # AppSettings (single doc id "app")
/users/{uid}/playlists/{playlistId}       # Playlist
/users/{uid}/likes/{trackId}              # LikedTrack
/users/{uid}/searchHistory/{queryHash}    # SearchQuery (doc id = sha1(lowercased query))
```

**Indexes** required (composite):

- `/users/{uid}/likes` — order by `likedAt desc` (single field, automatic)
- `/users/{uid}/searchHistory` — order by `lastUsedAt desc` (single field,
  automatic)
- `/catalog/tracks` — `where albumId == ? order by trackNumber asc` (composite,
  must be created)

---

## State transitions

### Playback state machine (Now Playing)

```text
       ┌──────────────┐
       │   IDLE       │
       └─────┬────────┘
             │ load(track)
             ▼
       ┌──────────────┐
       │  LOADING     │──── error ────► ERROR ──► (auto-skip to next)
       └─────┬────────┘
             │ ready
             ▼
       ┌──────────────┐ pause     ┌──────────────┐
       │  PLAYING     │ ◄────────►│  PAUSED      │
       └─────┬────────┘ play      └──────┬───────┘
             │ track end                 │
             ▼                           ▼
       ┌──────────────────────────────────────────┐
       │      QUEUE CONSULTATION                  │
       │  (advance, repeat-one, repeat-all, stop) │
       └──────────────────────────────────────────┘
```

### Like / unlike

```text
unliked ── tap heart ──► liked   (write LikedTrack with likedAt = now)
liked   ── tap heart ──► unliked (delete LikedTrack)
```

State is reflected by reading `/users/{uid}/likes/{trackId}` existence;
view models cache this in a `Set<String>` for O(1) heart rendering.

### Playlist mutation

```text
empty ── add(trackId) ──► non-empty
non-empty ── add(trackId) ──► non-empty (append)
non-empty ── reorder(from, to) ──► non-empty
non-empty ── remove(trackId) ──► (empty if last) | non-empty
any ── rename(name) ──► any
any ── delete ──► (gone)
```

Every mutation also updates `Playlist.updatedAt`.

---

## Validation summary

The following invariants are enforced both at the domain layer (use cases)
and at the Firestore-rules layer (server-side):

- A `LikedTrack` document MUST NOT exist unless its `Track.id` is known to
  the catalog (`/catalog/tracks/{trackId}` exists) **OR** the track is
  user-local (source = `local` / `firebaseStorage`).
- `Playlist.trackIds` MUST NOT contain duplicates and MUST NOT exceed
  5,000 entries.
- `AppSettings.crossfadeMs` MUST be in `[0, 12000]`.
- `SearchQuery.query` MUST be non-empty after trim.
- `UserProfile.displayName` MUST be 1–80 characters after trim.

Client-side validation rejects bad input before any Firestore write to
keep error surfaces local; server rules are the authoritative gate.
