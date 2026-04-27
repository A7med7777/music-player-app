# Contract — Firestore Schema & Security Rules

**Feature**: 001-music-player-app
**Date**: 2026-04-25

This is the on-disk shape of every Firestore document the app writes or
reads, plus the security rules that enforce ownership.

---

## Document paths

```text
/catalog/tracks/{trackId}
/catalog/albums/{albumId}
/catalog/artists/{artistId}

/users/{uid}
/users/{uid}/settings/app
/users/{uid}/playlists/{playlistId}
/users/{uid}/likes/{trackId}
/users/{uid}/searchHistory/{queryHash}
```

---

## Document shapes (JSON)

### `/catalog/tracks/{trackId}`

```json
{
  "title": "string",
  "artistId": "string",
  "artistName": "string",
  "albumId": "string|null",
  "albumName": "string|null",
  "durationMs": 0,
  "artworkUrl": "string|null",
  "source": "local|firebaseStorage|spotifyPreview",
  "sourceUri": "string",
  "explicit": false
}
```

### `/catalog/albums/{albumId}`

```json
{
  "title": "string",
  "primaryArtistId": "string",
  "primaryArtistName": "string",
  "artworkUrl": "string|null",
  "trackCount": 0,
  "releaseYear": 0
}
```

### `/catalog/artists/{artistId}`

```json
{
  "name": "string",
  "artworkUrl": "string|null"
}
```

### `/users/{uid}`

```json
{
  "displayName": "string",
  "avatarUrl": "string|null",
  "createdAt": "Timestamp"
}
```

### `/users/{uid}/settings/app`

```json
{
  "theme": "system|light|dark",
  "audioQuality": "auto|low|normal|high",
  "crossfadeMs": 0,
  "equalizerPreset": "string",
  "showExplicit": true,
  "cloudSyncEnabled": true,
  "spotifyEnabled": false
}
```

### `/users/{uid}/playlists/{playlistId}`

```json
{
  "name": "string",
  "trackIds": ["trackId1", "trackId2"],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `/users/{uid}/likes/{trackId}`

```json
{ "likedAt": "Timestamp" }
```

Document id is the `trackId`; the existence of the doc is the like.

### `/users/{uid}/searchHistory/{queryHash}`

```json
{
  "query": "string",
  "lastUsedAt": "Timestamp"
}
```

`queryHash` = sha1 of `query.trim().toLowerCase()` so re-searching a
query updates the existing entry rather than creating duplicates.

---

## Required indexes

| Collection | Fields | Order | Reason |
| --- | --- | --- | --- |
| `users/{uid}/likes` | `likedAt` | desc | Favorites screen ordering |
| `users/{uid}/searchHistory` | `lastUsedAt` | desc | Recent queries chip list |
| `users/{uid}/playlists` | `updatedAt` | desc | Playlists screen ordering |
| `catalog/tracks` | `albumId` asc, `trackNumber` asc | composite | Album detail view |
| `catalog/tracks` | `artistId` asc, `title` asc | composite | Artist detail view |

The single-field indexes are auto-created. The composite indexes must be
declared in `firestore.indexes.json` and deployed via the Firebase CLI.

---

## Security rules (`firestore.rules`)

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Catalog is global, read-only to clients. Writes happen via admin SDK
    // (e.g. seeding script, Cloud Function on Spotify import).
    match /catalog/{kind=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Per-user data: owner only.
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;

      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }
  }
}
```

**Notes**:

- `request.auth != null` covers anonymous Auth (the default sign-in
  state) — anonymous users still get a UID, so the rules work.
- Catalog writes are blocked from clients: the seeding pipeline and the
  optional Spotify-import Cloud Function use the Admin SDK with a
  service account.

---

## Field-level validation rules (defense in depth)

Add the following to `users/{uid}/playlists/{playlistId}` create/update:

```rules
allow create, update: if
  request.auth != null
  && request.auth.uid == uid
  && request.resource.data.name is string
  && request.resource.data.name.size() >= 1
  && request.resource.data.name.size() <= 80
  && request.resource.data.trackIds is list
  && request.resource.data.trackIds.size() <= 5000;
```

And for `users/{uid}/settings/app`:

```rules
allow update: if
  request.auth != null
  && request.auth.uid == uid
  && request.resource.data.crossfadeMs is int
  && request.resource.data.crossfadeMs >= 0
  && request.resource.data.crossfadeMs <= 12000
  && request.resource.data.theme in ['system', 'light', 'dark'];
```

These mirror the domain validation in `data-model.md` so the server
rejects malformed input even if a buggy client tries to write it.

---

## Offline persistence

Initialize Firestore at app start with:

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

This guarantees that once a user has read a document while online, it is
served from the local cache while offline — directly satisfying the
"app remains fully usable offline" sub-clause of FR-034.
