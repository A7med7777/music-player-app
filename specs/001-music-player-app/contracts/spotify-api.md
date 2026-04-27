# Contract — Spotify Web API (Optional Bonus)

**Feature**: 001-music-player-app
**Date**: 2026-04-25
**Spec reference**: FR-034, [research.md](../research.md) §R10

This contract is **optional**. The app MUST function fully without it
when `AppSettings.spotifyEnabled == false`. When enabled, the app uses
only the public-catalog and preview portions of the Spotify Web API.

---

## OAuth flow

**Flow**: Authorization Code with PKCE (mobile, no client secret).

**Endpoints**:

- Authorization: `https://accounts.spotify.com/authorize`
- Token: `https://accounts.spotify.com/api/token`

**Scopes requested**: none beyond the implicit catalog access. We do not
ask for `user-read-private`, `user-library-modify`, or any playlist
scopes — curation stays in Firestore.

**Redirect URI**: `com.example.musicplayer://spotify-callback` (registered
in `AndroidManifest.xml` as an intent filter, in `Info.plist` as a URL
scheme).

**Token storage**: refresh token saved to `flutter_secure_storage`; access
token kept in memory only.

---

## Endpoints used

### `GET /v1/search`

Used to power the Search screen when the Spotify toggle is on.

**Request**:

```http
GET https://api.spotify.com/v1/search?q={query}&type=track,album,artist&limit=20
Authorization: Bearer {access_token}
```

**Response (relevant subset)**:

```json
{
  "tracks": {
    "items": [
      {
        "id": "string",
        "name": "string",
        "duration_ms": 0,
        "preview_url": "https://...mp3 | null",
        "explicit": false,
        "artists": [{ "id": "string", "name": "string" }],
        "album": {
          "id": "string",
          "name": "string",
          "images": [{ "url": "string", "width": 0, "height": 0 }]
        }
      }
    ]
  },
  "albums": { "items": [...] },
  "artists": { "items": [...] }
}
```

**Mapping** to domain `Track`:

| Domain field | Spotify source |
| --- | --- |
| `id` | `"spotify:track:" + items[].id` |
| `title` | `items[].name` |
| `artistId` | `"spotify:artist:" + items[].artists[0].id` |
| `artistName` | `items[].artists[0].name` |
| `albumId` | `"spotify:album:" + items[].album.id` |
| `albumName` | `items[].album.name` |
| `durationMs` | `min(items[].duration_ms, 30000)` |
| `artworkUrl` | `items[].album.images[0].url` |
| `source` | `TrackSource.spotifyPreview` |
| `sourceUri` | `items[].preview_url` (skip the result if `null`) |
| `explicit` | `items[].explicit` |

**Filtering**: results without a `preview_url` are dropped before the
view model receives them — the user must always be able to tap-to-play.

---

### `GET /v1/tracks/{id}`, `GET /v1/albums/{id}`, `GET /v1/artists/{id}`

Used for metadata enrichment when opening an album or artist detail view
sourced from a Spotify search result. Mappings follow the same shape as
`GET /v1/search`.

---

## Rate limiting and error handling

| Spotify response | Mapping |
| --- | --- |
| `200` | success |
| `401` | refresh access token; if refresh also fails → `PermissionFailure` |
| `403` | `PermissionFailure` (e.g., user revoked auth) |
| `429` | back off per `Retry-After` header; surface `IntegrationFailure` only after 3 attempts |
| `5xx` | `IntegrationFailure` after 1 retry |
| Timeout > 8 s | `NetworkFailure` |

All Spotify errors fall through to a `IntegrationFailure` displayed as a
non-blocking banner on the Search screen; the local Firestore catalog
remains the search source.

---

## Behaviour when `spotifyEnabled == false`

- The Spotify settings tile shows "Connect to Spotify".
- The Search screen searches only the local Firestore catalog.
- No tokens are present in secure storage, no network calls are made to
  spotify.com.

## Behaviour when `spotifyEnabled == true` but offline

- Spotify sections of search results show an inline "Spotify unavailable
  offline" notice; local results still appear.
- Liked Spotify tracks remain visible in Favorites with their cached
  artwork, but tapping play surfaces a `NetworkFailure` notice (preview
  URLs require network).
