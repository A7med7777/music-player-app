---
description: "Task list for Comprehensive Music Player Application"
---

# Tasks: Comprehensive Music Player Application

**Input**: Design documents from `/specs/001-music-player-app/`
**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ ✅ | quickstart.md ✅

**Stack**: Flutter 3.22+ / Dart 3.4+ | Firebase (Auth, Firestore, Storage, Analytics, Crashlytics) | Provider (MVVM) | just_audio + audio_service + audio_session | Clean Architecture | Optional: Spotify Web API

**Organization**: Tasks grouped by user story for independent implementation and testing. Tests are included per the Clean Architecture discipline required by the constitution (Principle II).

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Exact file paths are included in every task description

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Flutter project scaffolding, toolchain, and cross-cutting infrastructure

- [ ] T001 Run `flutter create music_player_app --org com.example` at the repo root and restructure `lib/` to match the plan.md directory tree
- [ ] T002 Add all dependencies to `pubspec.yaml`: `provider`, `just_audio`, `audio_service`, `audio_session`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_analytics`, `firebase_crashlytics`, `cached_network_image`, `flutter_cache_manager`, `get_it`, `equatable`, `dartz`, `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`, `hive`, `hive_flutter`, `shared_preferences`, `go_router`, `flutter_localizations`, `intl`, `flutter_secure_storage`; dev deps: `build_runner`, `mocktail`, `integration_test`
- [ ] T003 Run `flutterfire configure` to generate `lib/firebase_options.dart`; commit `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- [ ] T004 [P] Create `analysis_options.yaml` extending `flutter_lints` with custom rules forbidding hard-coded `Color`, `EdgeInsets`, and string literals in `lib/features/*/presentation/`
- [ ] T005 [P] Create `lib/core/theme/app_tokens.dart` — `AppTokens` class extending `ThemeExtension<AppTokens>` with semantic color, spacing (4 px grid), radius, elevation, and motion-duration slots; register on both light and dark `ThemeData` in `lib/app.dart`
- [ ] T006 [P] Create `assets/translations/en.arb` and `assets/translations/es.arb` with all app-level string keys; run `flutter gen-l10n` to produce `lib/core/l10n/` bindings
- [ ] T007 [P] Create `lib/core/error/failures.dart` — sealed `Failure` hierarchy: `NetworkFailure`, `NotFoundFailure`, `PermissionFailure`, `ValidationFailure`, `PlaybackFailure`, `IntegrationFailure`, `UnknownFailure`
- [ ] T008 [P] Create `lib/core/di/injection.dart` — `get_it` registration module; wire all repositories once concrete impls exist (will be filled out as each feature is implemented)
- [ ] T009 [P] Create `lib/core/routing/app_router.dart` — `GoRouter` with `StatefulShellRoute.indexedStack` for Library, Search, Favorites, Playlists, Profile tabs; include route definitions for Now Playing screen and playlist detail
- [ ] T010 [P] Create `lib/shared/widgets/empty_state.dart`, `lib/shared/widgets/error_state.dart`, `lib/shared/widgets/offline_indicator.dart` — reusable state widgets using `AppTokens`
- [ ] T011 [P] Create `lib/shared/navigation/app_shell.dart` — bottom navigation bar host with mini-player slot; integrates with `StatefulShellRoute.indexedStack`
- [ ] T012 Configure Firestore offline persistence in `lib/main.dart`: `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED)`
- [ ] T013 Initialize Hive in `lib/main.dart`: `await Hive.initFlutter()` and open the queue-snapshot box
- [ ] T014 Deploy Firestore security rules (`firestore.rules`) and composite indexes (`firestore.indexes.json`) per `contracts/firestore-schema.md` via `firebase deploy --only firestore`
- [ ] T015 Create `tool/check_coverage.sh` — shell script that runs `flutter test --coverage` and uses `lcov` to fail if any module under `lib/features/*/domain/` or `lib/shared/audio/` drops below 80 %, or any `lib/features/*/presentation/` drops below 60 %

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Auth, settings, and the shared audio engine — ALL user stories depend on these.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T016 Create `lib/features/profile/domain/repositories/auth_repository.dart` — abstract `AuthRepository` interface from `contracts/repositories.md`
- [ ] T017 Create `lib/features/profile/data/datasources/firebase_auth_datasource.dart` — `FirebaseAuth` wrapper for anonymous and Google sign-in
- [ ] T018 Create `lib/features/profile/data/repositories/auth_repository_impl.dart` — `AuthRepositoryImpl` implementing `AuthRepository`; call `signInAnonymously()` on first launch
- [ ] T019 [P] Create domain entity `lib/features/profile/domain/entities/user_profile.dart` and Firestore model `lib/features/profile/data/models/user_profile_model.dart` with `fromJson` / `toJson`
- [ ] T020 [P] Create domain entity `lib/features/profile/domain/entities/app_settings.dart` (enums: `ThemeMode`, `AudioQuality`) and model `lib/features/profile/data/models/app_settings_model.dart`
- [ ] T021 Create `lib/features/profile/domain/repositories/settings_repository.dart` — abstract `SettingsRepository` interface
- [ ] T022 Create `lib/features/profile/data/repositories/settings_repository_impl.dart` — Firestore-backed `SettingsRepositoryImpl`; emit updates synchronously after write
- [ ] T023 Create `lib/features/profile/presentation/viewmodels/settings_viewmodel.dart` — `ChangeNotifier` that exposes `AppSettings` stream and `setTheme()`, `setCrossfade()`, `setEqualizerPreset()`, etc.; listen to `SettingsRepository.watchSettings()`
- [ ] T024 Wire `SettingsViewModel` into the root `MultiProvider` in `lib/main.dart` so theme changes from any screen re-theme the entire app (FR-028)
- [ ] T025 Create `lib/shared/audio/playback_state.dart` — immutable `PlaybackState` + `Queue` + `RepeatMode` enum
- [ ] T026 Create `lib/shared/audio/audio_handler.dart` — `BaseAudioHandler` subclass using `just_audio`; handles `ConcatenatingAudioSource` for gapless + crossfade, audio focus interruptions (headphone unplug → pause), and platform media-session commands
- [ ] T027 Create `lib/shared/audio/playback_controller.dart` — façade over `audio_handler.dart`; exposes `Stream<PlaybackState>` and `Stream<Queue>`; persists queue snapshot to Hive on every change; restores on cold start
- [ ] T028 Create `lib/features/now_playing/domain/repositories/playback_repository.dart` — abstract `PlaybackRepository` interface from `contracts/repositories.md`
- [ ] T029 Create `lib/features/now_playing/data/repositories/playback_repository_impl.dart` — delegates to `PlaybackController`; all latency contracts from `contracts/repositories.md` must be honoured
- [ ] T030 Register `AudioHandler`, `PlaybackController`, `AuthRepository`, and `SettingsRepository` in `lib/core/di/injection.dart`
- [ ] T031 Create `test/unit/shared/audio/playback_controller_test.dart` — unit tests for queue persistence, crossfade setting, and the "track missing → auto-skip" edge case using a mock `AudioHandler`

**Checkpoint**: Auth, Settings, and the audio engine are functional. User story implementation can now begin in parallel.

---

## Phase 3: User Story 1 — Browse Library and Play a Song (Priority: P1) 🎯 MVP

**Goal**: Library screen (Songs/Albums/Artists), Now Playing screen (full controls + mini-player), and persistent playback across screen navigation.

**Independent Test**: Seed library → tap track → audio starts ≤ 300 ms → pause/resume ≤ 100 ms → navigate to Search tab → mini-player visible, music still playing → return to Now Playing → state intact.

### Tests for User Story 1

> **Write these tests FIRST. Confirm they FAIL before implementation.**

- [ ] T032 [P] [US1] `test/unit/features/library/domain/usecases/get_tracks_test.dart` — unit test `GetTracks` use case with a mock `LibraryRepository`
- [ ] T033 [P] [US1] `test/widget/features/library/library_screen_test.dart` — widget test asserting track-list renders, empty state shows when list is empty, and tapping a row calls `PlaybackRepository.playTrack()`
- [ ] T034 [P] [US1] `test/widget/features/now_playing/now_playing_screen_test.dart` — widget test asserting all controls render and pause/skip trigger the correct view-model methods
- [ ] T035 [P] [US1] `test/integration/us1_library_playback_test.dart` — integration test: seed library → tap track → assert `PlaybackState.playing == true` within 300 ms → tap pause → assert `PlaybackState.playing == false` within 100 ms (uses real `just_audio` + fixture audio from `test/fixtures/audio/`)

### Implementation for User Story 1

- [ ] T036 [P] [US1] Create domain entities in `lib/features/library/domain/entities/`: `track.dart`, `album.dart`, `artist.dart` (pure Dart, `Equatable`)
- [ ] T037 [P] [US1] Create Firestore models in `lib/features/library/data/models/`: `track_model.dart`, `album_model.dart`, `artist_model.dart` with `fromJson`/`toJson` and `toDomain()` converters
- [ ] T038 [P] [US1] Create abstract `LibraryRepository` in `lib/features/library/domain/repositories/library_repository.dart` per `contracts/repositories.md`
- [ ] T039 [P] [US1] Create use cases `lib/features/library/domain/usecases/`: `get_tracks.dart`, `get_albums.dart`, `get_artists.dart`, `get_album_detail.dart`, `get_artist_detail.dart` — each wraps a single repository call, returns `Either<Failure, T>`
- [ ] T040 [US1] Create `lib/features/library/data/datasources/library_local_datasource.dart` — reads from local asset manifest / bundled seed library
- [ ] T041 [US1] Create `lib/features/library/data/datasources/library_remote_datasource.dart` — reads from Firestore `/catalog/tracks`, `/catalog/albums`, `/catalog/artists` with offline persistence active
- [ ] T042 [US1] Create `lib/features/library/data/repositories/library_repository_impl.dart` — merges local and remote sources; applies `TrackSort`
- [ ] T043 [US1] Create `lib/features/library/presentation/viewmodels/library_viewmodel.dart` — `ChangeNotifier`; exposes tracks, albums, artists streams, loading/error/empty states, and sort selection; calls `PlaybackRepository.playTrack()` on tap
- [ ] T044 [US1] Create `lib/features/library/presentation/widgets/track_row.dart` — list tile showing artwork, title, artist, duration, heart icon, overflow menu ("Add to playlist"); reads liked state from `FavoritesRepository.watchLikedTrackIds()` via `Selector`
- [ ] T045 [US1] Create `lib/features/library/presentation/views/library_screen.dart` — tabbed view (Songs / Albums / Artists) backed by `LibraryViewModel`; uses `ListView.builder`; shows `EmptyState`, `ErrorState`, `OfflineIndicator` from shared widgets; all strings from `AppLocalizations`; all styles from `AppTokens`
- [ ] T046 [US1] Create `lib/features/now_playing/presentation/viewmodels/now_playing_viewmodel.dart` — `ChangeNotifier` wrapping `PlaybackRepository` streams; exposes current track, position, queue, shuffle, repeat
- [ ] T047 [US1] Create `lib/features/now_playing/presentation/views/now_playing_screen.dart` — album art, title, artist, progress bar (scrubbable), play/pause, skip next/prev, shuffle toggle, repeat cycle, volume slider, queue button; all from `AppTokens`; all strings from `AppLocalizations`
- [ ] T048 [US1] Create `lib/shared/widgets/mini_player.dart` — compact player (artwork thumbnail, title, artist, play/pause, skip-next); tapping opens Now Playing; uses `Selector` on `PlaybackState` for efficient rebuilds; never visible when no track is loaded
- [ ] T049 [US1] Wire `MiniPlayer` into `AppShell` (`lib/shared/navigation/app_shell.dart`) above the bottom nav bar
- [ ] T050 [US1] Register `LibraryRepository` and `PlaybackRepository` in `lib/core/di/injection.dart`; add `LibraryViewModel` and `NowPlayingViewModel` to `MultiProvider`

**Checkpoint**: US1 fully testable. Open Library → tap track → Now Playing opens → audio plays → mini-player visible on every tab → pause/resume/skip all work.

---

## Phase 4: User Story 2 — Find Specific Music via Search (Priority: P2)

**Goal**: Search screen with incremental results grouped by Songs / Albums / Artists / Playlists, recent query history, play directly from results.

**Independent Test**: Seed 50+ tracks → open Search → type partial query → results appear ≤ 500 ms grouped by category → tap song result → playback starts → re-open Search → recent query appears.

### Tests for User Story 2

> **Write these tests FIRST. Confirm they FAIL before implementation.**

- [ ] T051 [P] [US2] `test/unit/features/search/domain/usecases/search_test.dart` — unit test search debounce, grouping, empty-results handling with mock `SearchRepository`
- [ ] T052 [P] [US2] `test/widget/features/search/search_screen_test.dart` — widget test: type query → grouped results render; empty query → recent history shows; no results → empty state shows
- [ ] T053 [P] [US2] `test/integration/us2_search_test.dart` — integration test against Firebase emulator: 50-track seed → search "the" → results appear within 500 ms

### Implementation for User Story 2

- [ ] T054 [P] [US2] Create `lib/features/search/domain/entities/search_results.dart` (`SearchResults` with `tracks`, `albums`, `artists`, `playlists`) and `lib/features/search/domain/entities/search_query.dart`
- [ ] T055 [P] [US2] Create `lib/features/search/domain/repositories/search_repository.dart` — abstract `SearchRepository` interface per `contracts/repositories.md`
- [ ] T056 [P] [US2] Create use cases: `lib/features/search/domain/usecases/search_catalog.dart` (stream, debounced 150 ms), `get_recent_queries.dart`, `record_query.dart`, `clear_recent_queries.dart`
- [ ] T057 [US2] Create `lib/features/search/data/datasources/search_local_datasource.dart` — in-memory search over the cached Firestore catalog using `Firestore.collection.where` with `isGreaterThanOrEqualTo`/`isLessThan` for prefix matching
- [ ] T058 [US2] Create `lib/features/search/data/datasources/search_history_datasource.dart` — reads/writes `/users/{uid}/searchHistory` (cap 20, evict oldest); `queryHash` = sha1 of trimmed lowercase query
- [ ] T059 [US2] Create `lib/features/search/data/repositories/search_repository_impl.dart` — merges local catalog search with search history; deduplicates; when `AppSettings.spotifyEnabled == true`, fans out to `SpotifyApiDatasource.search()` and merges results
- [ ] T060 [US2] Create `lib/features/search/presentation/viewmodels/search_viewmodel.dart` — `ChangeNotifier`; debounces query changes; calls `SearchCatalog` use case; exposes `SearchResults`, loading, empty, and error states; plays on track tap
- [ ] T061 [US2] Create `lib/features/search/presentation/views/search_screen.dart` — search input field, grouped result sections (Songs, Albums, Artists, Playlists), recent queries chips, empty state, error state, offline indicator; `ListView.builder` per section; all strings/styles from `AppLocalizations`/`AppTokens`
- [ ] T062 [US2] Register `SearchRepository` in `lib/core/di/injection.dart` and add `SearchViewModel` to `MultiProvider`

**Checkpoint**: US1 + US2 both independently testable and functional.

---

## Phase 5: User Story 3 — Like Tracks and Revisit Them in Favorites (Priority: P2)

**Goal**: One-tap like/unlike from any surface, Favorites screen (most-recently-liked first), Play all / Shuffle all, consistent heart state everywhere.

**Independent Test**: Tap heart on Library row → open Favorites → track appears at top → un-like from Favorites → track gone, heart clears on Library row → Play all from Favorites → full liked queue plays.

### Tests for User Story 3

> **Write these tests FIRST. Confirm they FAIL before implementation.**

- [ ] T063 [P] [US3] `test/unit/features/favorites/domain/usecases/like_track_test.dart` and `unlike_track_test.dart` — unit tests with mock `FavoritesRepository`; verify `watchLikedTrackIds` set updates
- [ ] T064 [P] [US3] `test/widget/features/favorites/favorites_screen_test.dart` — widget test: liked tracks render in correct order; "Play all" fires `playAllLiked()`; empty state on zero likes
- [ ] T065 [P] [US3] `test/integration/us3_favorites_test.dart` — integration test against Firebase emulator: like a track → read `/users/{uid}/likes/{trackId}` → confirm doc exists; unlike → confirm doc deleted; open Favorites → track absent

### Implementation for User Story 3

- [ ] T066 [P] [US3] Create `lib/features/favorites/domain/entities/liked_track.dart` (trackId, likedAt)
- [ ] T067 [P] [US3] Create `lib/features/favorites/domain/repositories/favorites_repository.dart` — abstract `FavoritesRepository` per `contracts/repositories.md`
- [ ] T068 [P] [US3] Create use cases: `lib/features/favorites/domain/usecases/like_track.dart`, `unlike_track.dart`, `watch_favorites.dart`, `watch_liked_track_ids.dart`, `play_all_liked.dart`
- [ ] T069 [US3] Create `lib/features/favorites/data/datasources/favorites_datasource.dart` — reads/writes `/users/{uid}/likes/{trackId}` ordered by `likedAt desc`; streams a `Set<String>` of liked IDs for O(1) heart state
- [ ] T070 [US3] Create `lib/features/favorites/data/repositories/favorites_repository_impl.dart`
- [ ] T071 [US3] Update `lib/features/library/presentation/widgets/track_row.dart` — wire heart icon to `LikeTrack`/`UnlikeTrack` via `context.read<FavoritesViewModel>()`; use `Selector` on `watchLikedTrackIds` so only the affected row rebuilds (not the entire list)
- [ ] T072 [US3] Update `lib/features/now_playing/presentation/views/now_playing_screen.dart` — add heart icon wired to like/unlike; same `Selector`-based rebuild
- [ ] T073 [US3] Update `lib/features/search/presentation/views/search_screen.dart` — add heart icon to song result rows
- [ ] T074 [US3] Create `lib/features/favorites/presentation/viewmodels/favorites_viewmodel.dart` — `ChangeNotifier`; exposes liked track list, liked-ID set, and `playAll(shuffle)` action
- [ ] T075 [US3] Create `lib/features/favorites/presentation/views/favorites_screen.dart` — track list sorted most-recently-liked first; "Play all" and "Shuffle all" buttons; `EmptyState` when no likes; `ListView.builder`; all strings/styles from l10n/tokens
- [ ] T076 [US3] Register `FavoritesRepository` in DI; add `FavoritesViewModel` to root `MultiProvider`

**Checkpoint**: US1 + US2 + US3 all independently testable. Heart state is consistent across all surfaces.

---

## Phase 6: User Story 4 — Organize Music with Playlists (Priority: P3)

**Goal**: Create / rename / delete playlists; add tracks from any surface; reorder and remove tracks within a playlist; play from any position or shuffled.

**Independent Test**: Create playlist → add 3 tracks from Library and Search → drag to reorder → rename → play from track 2 → delete playlist → verify gone everywhere.

### Tests for User Story 4

> **Write these tests FIRST. Confirm they FAIL before implementation.**

- [ ] T077 [P] [US4] `test/unit/features/playlists/domain/usecases/playlist_usecases_test.dart` — unit tests for `CreatePlaylist`, `RenamePlaylist`, `DeletePlaylist`, `AddTrack`, `RemoveTrack`, `ReorderTracks` with mock `PlaylistRepository`
- [ ] T078 [P] [US4] `test/widget/features/playlists/playlists_screen_test.dart` — widget test: list renders; "Create playlist" dialog opens on tap; empty state when no playlists
- [ ] T079 [P] [US4] `test/widget/features/playlists/playlist_detail_screen_test.dart` — widget test: tracks listed; reorder fires correct view-model method; "Play" and "Shuffle" trigger `PlaybackRepository`
- [ ] T080 [P] [US4] `test/integration/us4_playlists_test.dart` — integration test: create playlist → add track → read Firestore → confirm `trackIds` contains track; reorder → confirm new order; delete → confirm doc gone

### Implementation for User Story 4

- [ ] T081 [P] [US4] Create `lib/features/playlists/domain/entities/playlist.dart` (id, name, trackIds, createdAt, updatedAt)
- [ ] T082 [P] [US4] Create `lib/features/playlists/domain/repositories/playlist_repository.dart` — abstract `PlaylistRepository` per `contracts/repositories.md`
- [ ] T083 [P] [US4] Create use cases in `lib/features/playlists/domain/usecases/`: `create_playlist.dart`, `rename_playlist.dart`, `delete_playlist.dart`, `add_track_to_playlist.dart`, `remove_track_from_playlist.dart`, `reorder_playlist_tracks.dart`, `watch_playlists.dart`, `watch_playlist.dart`, `play_playlist.dart`
- [ ] T084 [US4] Create `lib/features/playlists/data/models/playlist_model.dart` with `fromJson`/`toJson`/`toDomain()`
- [ ] T085 [US4] Create `lib/features/playlists/data/datasources/playlist_datasource.dart` — Firestore CRUD on `/users/{uid}/playlists/{playlistId}`; reorder = full `trackIds` array replace in a single write; `updatedAt` stamped on every mutation
- [ ] T086 [US4] Create `lib/features/playlists/data/repositories/playlist_repository_impl.dart`
- [ ] T087 [US4] Update `lib/features/library/presentation/widgets/track_row.dart` overflow menu — "Add to playlist" opens a bottom sheet listing existing playlists and a "New playlist" option; calls `AddTrackToPlaylist` use case
- [ ] T088 [US4] Update `lib/features/search/presentation/views/search_screen.dart` — same "Add to playlist" overflow on song rows
- [ ] T089 [US4] Update `lib/features/now_playing/presentation/views/now_playing_screen.dart` — "Add to playlist" action in the overflow menu
- [ ] T090 [US4] Create `lib/features/playlists/presentation/viewmodels/playlists_viewmodel.dart` — `ChangeNotifier`; list of playlists; create/rename/delete actions
- [ ] T091 [US4] Create `lib/features/playlists/presentation/viewmodels/playlist_detail_viewmodel.dart` — `ChangeNotifier`; single playlist with tracks; reorder/remove/play actions
- [ ] T092 [US4] Create `lib/features/playlists/presentation/views/playlists_screen.dart` — list of playlists (name, track count, artwork mosaic); "Create playlist" FAB; `EmptyState`; `ListView.builder`; all from l10n/tokens
- [ ] T093 [US4] Create `lib/features/playlists/presentation/views/playlist_detail_screen.dart` — ordered track list with `ReorderableListView`; "Play" and "Shuffle" buttons; per-track swipe-to-remove; `EmptyState`; all from l10n/tokens
- [ ] T094 [US4] Register `PlaylistRepository` in DI; add `PlaylistsViewModel` and `PlaylistDetailViewModel` to `MultiProvider`

**Checkpoint**: US1–US4 all independently testable. Playlists can be created, edited, and played from any surface.

---

## Phase 7: User Story 5 — Personalize the Experience via Profile & Settings (Priority: P3)

**Goal**: Profile screen (name, avatar, activity summary), Settings (theme, audio quality, crossfade, EQ preset, explicit content toggle); all changes take effect immediately and persist.

**Independent Test**: Open Profile/Settings → change theme to dark → entire app re-themes instantly → enable crossfade → play next track transition → crossfade honored → restart app → settings still applied.

### Tests for User Story 5

> **Write these tests FIRST. Confirm they FAIL before implementation.**

- [ ] T095 [P] [US5] `test/unit/features/profile/domain/usecases/settings_usecases_test.dart` — unit tests for `SetTheme`, `SetCrossfade`, `SetEqualizerPreset`, `SetShowExplicit` with mock `SettingsRepository`
- [ ] T096 [P] [US5] `test/widget/features/profile/profile_screen_test.dart` — widget test: display name, avatar, summary counts render; changing theme triggers a `MaterialApp` rebuild with the new `ThemeMode`
- [ ] T097 [P] [US5] `test/integration/us5_settings_persistence_test.dart` — integration test: write theme=dark to Firestore → cold restart (navigator pop all + re-push) → assert ThemeMode is dark

### Implementation for User Story 5

- [ ] T098 [P] [US5] Create use cases in `lib/features/profile/domain/usecases/`: `watch_profile.dart`, `update_display_name.dart`, `update_avatar.dart`, `watch_profile_summary.dart`
- [ ] T099 [P] [US5] Create use cases in `lib/features/profile/domain/usecases/`: `set_theme.dart`, `set_audio_quality.dart`, `set_crossfade.dart`, `set_equalizer_preset.dart`, `set_show_explicit.dart`, `set_spotify_enabled.dart`
- [ ] T100 [US5] Create `lib/features/profile/data/datasources/profile_datasource.dart` — reads/writes `/users/{uid}` and derives summary from subcollection counts (`likes`, `playlists`); reads catalog `tracks` count
- [ ] T101 [US5] Create `lib/features/profile/data/repositories/profile_repository_impl.dart`
- [ ] T102 [US5] Update `lib/features/profile/data/repositories/settings_repository_impl.dart` (already created in Phase 2) — ensure immediate in-memory emit after Firestore write so `SettingsViewModel` propagates changes synchronously (FR-028)
- [ ] T103 [US5] Create `lib/features/profile/presentation/viewmodels/profile_viewmodel.dart` — `ChangeNotifier`; exposes `UserProfile`, `ProfileSummary`, `AppSettings`; delegates to use cases
- [ ] T104 [US5] Create `lib/features/profile/presentation/views/profile_screen.dart` — avatar, display name (editable inline), summary chips (tracks / liked / playlists); Settings section with theme picker (light/dark/system), audio quality picker, crossfade slider (0–12 s), EQ preset picker, explicit content toggle, Spotify connect tile; all from l10n/tokens; all changes call use cases immediately

**Checkpoint**: All 5 user stories independently testable. Settings persist across restarts.

---

## Phase 8: Optional Bonus — Spotify Web API Integration

**Goal**: Enable the Spotify toggle to enrich Search with the public Spotify catalog (30-second previews), gated behind a settings switch; curation stays in Firestore.

**Independent Test**: Enable Spotify toggle → search a popular track title → Spotify results appear alongside local results → tap Spotify track → 30-s preview plays → disable toggle → only local results appear; no Spotify API calls are made.

### Implementation for Bonus

- [ ] T105 Add optional deps to `pubspec.yaml`: `http`, `oauth2`, `flutter_secure_storage` (may already be present), `crypto` (for PKCE code verifier)
- [ ] T106 Create `lib/features/spotify/data/datasources/spotify_auth_datasource.dart` — PKCE Authorization Code flow per `contracts/spotify-api.md`; store refresh token in `flutter_secure_storage`; keep access token in memory; auto-refresh on 401
- [ ] T107 Create `lib/features/spotify/data/datasources/spotify_api_datasource.dart` — typed `GET /v1/search`, `GET /v1/tracks/{id}`, `GET /v1/albums/{id}`, `GET /v1/artists/{id}` per `contracts/spotify-api.md`; maps responses to domain entities; drops results with null `preview_url`; handles 429 with `Retry-After` back-off
- [ ] T108 Create `lib/features/spotify/domain/usecases/search_spotify_catalog.dart` — wraps `SpotifyApiDatasource.search()`; returns `Either<Failure, SearchResults>`
- [ ] T109 Update `lib/features/search/data/repositories/search_repository_impl.dart` — when `AppSettings.spotifyEnabled == true`, fan out to `SearchSpotifyCatalog` in parallel with local search; merge results (local first, Spotify tracks appended, deduplicated by normalized title+artist); on `IntegrationFailure` from Spotify, return local results only with a non-blocking banner
- [ ] T110 Update `lib/features/search/presentation/views/search_screen.dart` — show "Spotify" badge on preview-sourced track rows; when Spotify is offline, show per-section inline notice instead of hiding the section
- [ ] T111 Update `lib/features/profile/presentation/views/profile_screen.dart` Spotify tile — trigger OAuth flow on "Connect to Spotify" tap; show "Connected" + "Disconnect" once authenticated

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Instrumentation, accessibility, performance hardening, and final QA pass.

- [ ] T112 [P] Add Firebase Analytics + Crashlytics instrumentation per `research.md` §R8: `playback_start_latency_ms`, `playback_dropout`, `frame_jank_ms` (via `SchedulerBinding.addTimingsCallback`), `cold_start_to_interactive_ms` events in `lib/shared/audio/playback_controller.dart` and `lib/main.dart`
- [ ] T113 [P] Audit all six screens for WCAG 2.1 AA: add `Semantics` / `MergeSemantics` wrappers to track rows, control buttons, and album art; verify 4.5:1 contrast ratios for all `AppTokens` text-on-background combinations (SC-011)
- [ ] T114 [P] Add visible focus indicators (keyboard navigation) to all tappable widgets using `FocusNode` + `DecoratedBox` or `Material` ink highlighting with `AppTokens.focusRing` color (FR-033)
- [ ] T115 [P] Run `flutter test --coverage` against the full suite; run `tool/check_coverage.sh`; fix any module falling below the 80 %/60 % thresholds (Principle II)
- [ ] T116 [P] Profile-mode run on Pixel 4a (Android floor) and iPhone SE 2nd-gen (iOS floor): measure cold-start time, Library scroll frame times, and audio start latency; record baseline numbers in `specs/001-music-player-app/quickstart.md` §5 (Principle IV)
- [ ] T117 Run the full smoke-test flow in `quickstart.md` §7 manually on both reference devices; document any failures as GitHub issues before sign-off
- [ ] T118 [P] Update `assets/translations/en.arb` and `es.arb` with any string keys added during implementation; re-run `flutter gen-l10n`; verify no untranslated keys at runtime

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Requires Phase 1 complete — **BLOCKS all user stories**
- **US1 (Phase 3)**: Requires Phase 2 (audio engine, auth, settings ready)
- **US2, US3 (Phases 4–5)**: Require Phase 2 + ideally US1 (library entities reused); can start in parallel after Phase 2 if entities are stubbed
- **US4, US5 (Phases 6–7)**: Require Phase 2; US4 depends on US1 (track entities); US5 depends on Phase 2 (settings already created)
- **Bonus (Phase 8)**: Requires US2 (Search integration point) and US5 (Spotify toggle in Settings)
- **Polish (Phase 9)**: Requires all desired user stories complete

### User Story Dependencies

- **US1 (P1)**: Foundation only — no other story dependency
- **US2 (P2)**: Foundation + US1 track entities (reused); independently testable
- **US3 (P2)**: Foundation + US1 track entities (heart icon on track rows); independently testable
- **US4 (P3)**: Foundation + US1 (playlist plays use the same playback engine and track entities); US3 heart-icon update is a bonus integration
- **US5 (P3)**: Foundation only (settings created in Phase 2); independently testable

### Within Each User Story

- Tests MUST be written and confirmed FAILING before implementation begins
- Domain entities before data models before repositories before use cases before view models before screens
- Story complete + checkpoint validated before moving to next priority

### Parallel Opportunities

- All `[P]`-labelled tasks within the same phase can run in parallel (different files, no dependencies)
- US2 and US3 (both P2) can be developed in parallel after Phase 2 completes
- US4 and US5 (both P3) can be developed in parallel after Phase 2 and US1 complete
- Phase 9 polish tasks are all independent

---

## Parallel Example: User Story 1

```bash
# After Phase 2 completes, launch all US1 tests and entities in parallel:
Task: "T032 write test/unit/features/library/domain/usecases/get_tracks_test.dart"
Task: "T033 write test/widget/features/library/library_screen_test.dart"
Task: "T034 write test/widget/features/now_playing/now_playing_screen_test.dart"
Task: "T035 write test/integration/us1_library_playback_test.dart"
Task: "T036 create lib/features/library/domain/entities/ (Track, Album, Artist)"
Task: "T037 create lib/features/library/data/models/"
Task: "T038 create lib/features/library/domain/repositories/library_repository.dart"

# Then sequentially:
T039 → T040 → T041 → T042 → T043 (repo impl) → T044 (track row widget) → T045 (screen)
T046 (NP viewmodel) → T047 (NP screen) → T048 (mini-player) → T049 (wire to shell) → T050 (DI)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: User Story 1 (Library + Now Playing)
4. **STOP and VALIDATE**: Run `test/integration/us1_library_playback_test.dart`, do manual smoke flow from `quickstart.md` §7 steps 1–5
5. Ship MVP if ready; continue to US2 / US3 in parallel

### Incremental Delivery

1. Setup + Foundational → audio engine and settings live
2. US1 → Library + Now Playing → playback works → MVP ✅
3. US2 + US3 (parallel) → Search + Favorites → curation works
4. US4 + US5 (parallel) → Playlists + Profile → personalization works
5. Bonus (Phase 8) → Spotify integration → catalog enrichment ✅ (bonus)
6. Polish (Phase 9) → perf, a11y, coverage → production-ready

### Parallel Team Strategy

With 2+ developers after Phase 2:

- Dev A: US1 (Library + Now Playing)
- Dev B: can start US5 Settings domain layer immediately (settings repo is Foundation)
- After US1 complete: Dev A + Dev B: US2 / US3 in parallel
- After US2 + US3: Dev A + Dev B: US4 / US5 views in parallel

---

## Notes

- `[P]` tasks = different files, no blocking dependencies on incomplete tasks in the same phase
- `[US#]` label maps each task to a specific user story for traceability against `spec.md`
- Each user story phase is independently completable and testable — validate at every checkpoint before proceeding
- Tests MUST be written first and MUST fail before implementation begins (Principle II)
- Commit after each task or logical group; use `speckit-git-commit` after each phase
- No hard-coded colors, spacings, or string literals in `lib/features/` — the lint rule in `analysis_options.yaml` (T004) will fail CI if this is violated
- Before any PR: run `flutter analyze`, `flutter test --coverage`, `tool/check_coverage.sh`
- Performance-sensitive PRs: attach before/after DevTools profile captures
