# Implementation Plan: Comprehensive Music Player Application

**Branch**: `001-music-player-app` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-music-player-app/spec.md`

## Summary

Build a six-screen Flutter music player (Library, Now Playing, Search,
Favorites, Playlists, Profile/Settings) backed by Firebase, using Provider for
MVVM-style state management, `just_audio` for the audio engine, and Clean
Architecture for layering. Firebase Firestore stores user-curated data (likes,
playlists, profile, settings, search history) with offline persistence so the
app stays usable without a network. Optional bonus: a Spotify Web API
integration that enriches Library/Search with the public catalog and a 30-second
preview stream.

## Technical Context

**Language/Version**: Dart 3.4+ on Flutter 3.22+ (stable channel)

**Primary Dependencies**:

- `flutter`, `flutter_localizations`, `intl`
- `provider` (state management, MVVM glue)
- `just_audio` (audio engine), `audio_service` (background playback &
  lock-screen / media-session integration), `audio_session` (audio focus &
  interruption handling)
- `firebase_core`, `firebase_auth`, `cloud_firestore`,
  `firebase_storage`, `firebase_analytics`, `firebase_crashlytics`
- `cached_network_image` (artwork), `flutter_cache_manager`
- `get_it` (DI), `equatable`, `dartz` (`Either` for use-case results),
  `freezed` + `json_serializable` (immutable models)
- `flutter_lints`, `mocktail`, `flutter_test`, `integration_test`
- *Optional bonus*: `http` + `oauth2` for Spotify Web API access

**Storage**:

- **Firestore** (cloud, with local persistence enabled) — user profile,
  likes, playlists, recent queries, settings
- **Firebase Storage** (optional, if hosting user-uploaded or seed audio) —
  audio files and artwork
- **Local device storage** — cached artwork, downloaded tracks, queue
  snapshot (via `shared_preferences` for small key/value state, `hive` for
  the queue snapshot that must survive offline cold starts)

**Testing**:

- `flutter_test` — unit tests (use cases, view models) and widget tests
- `integration_test` — end-to-end including real `just_audio` against
  bundled fixture media files
- `mocktail` — mocks for repository interfaces in unit tests
- `flutter test --coverage` + `lcov` for the Principle II coverage gate

**Target Platform**: Android 8.0 (API 26) and iOS 14+ as v1 mobile targets;
Flutter web/desktop are out of scope for v1.

**Project Type**: Mobile app (Flutter, single repository, single `lib/`).

**Performance Goals** (inherited from constitution Principle IV and spec
Success Criteria):

- Local play tap → first audio frame ≤ 300 ms (p95)
- Streamed (Spotify preview) → first audio frame ≤ 1000 ms (p95) on
  10 Mbps
- Sustained 60 fps (≤ 16.6 ms/frame) on Library, Favorites, Search lists
- Cold start ≤ 2.0 s on lowest-tier device
- Resident memory ≤ 250 MB during 1-hour session
- Background playback ≤ 4 % battery/hour (screen off)

**Constraints**:

- App MUST remain fully usable offline for any locally cached content
  (FR-034 sub-clause); Firestore persistence + a local audio cache covers
  this.
- All visual styling MUST resolve to design tokens (constitution III, FR-032).
- All user-facing strings MUST go through the `intl` localization layer
  (constitution III, FR-031).
- WCAG 2.1 AA must be met for every interactive control (constitution III,
  FR-033, SC-011).

**Scale/Scope**:

- 6 user-facing screens + 1 mini-player + navigation shell
- Library sized for up to ~10,000 tracks per user without scroll
  degradation
- 5 prioritized user stories; ~34 functional requirements
- Single platform family per release (mobile)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Gate | Status (initial) | Notes |
| --- | --- | --- | --- |
| I. Code Quality | Lint + format + complexity ≤ 10 + no dead code | PASS | `flutter_lints` + `dart format`; CI runs `flutter analyze`. |
| II. Testing Standards | ≥ 80 % coverage on playback/queue/persistence; ≥ 60 % on UI glue; deterministic; integration tests hit real audio | PASS | `flutter_test` + `integration_test` with fixture audio files; `mocktail` for repo doubles. |
| III. UX Consistency | Design tokens, localization, WCAG 2.1 AA, designed loading/empty/error/offline states | PASS | `ThemeData` + custom `AppTokens` `ThemeExtension`; `intl` + `.arb`; per-screen state widgets. |
| IV. Performance | Audio start ≤ 300 ms, 60 fps, ≤ 250 MB, ≤ 4 % batt/hr, before/after measurements on perf-sensitive PRs | PASS | `just_audio` warm pipeline; `ListView.builder`; `cached_network_image`; `audio_service` for efficient background. |

**Performance & Quality Standards check** (constitution Section 2):

- Reference device: Android Pixel 4a (lowest Android) and iPhone SE 2nd-gen
  (lowest iOS) — placeholder, to be confirmed and recorded in
  `docs/quickstart.md` before first perf measurement.
- Telemetry: Firebase Analytics + Firebase Crashlytics provide crash-free
  session rate and event funnel. Custom playback events instrument start
  latency, dropout count, and frame timing.
- Crash-free target: ≥ 99.5 % per release, alert configured in Crashlytics.
- Dependency hygiene: every new Pub dependency reviewed for license,
  maintenance status, and APK/IPA size impact in PR.

**Development Workflow & Quality Gates check** (constitution Section 3):

- CI gates: `flutter analyze`, `flutter test --coverage`, coverage
  threshold check, integration tests on a CI emulator/simulator.
- Performance gate: PRs touching `lib/shared/audio/`, `lib/features/*/presentation/`
  with > 50 LOC, or any list rendering change MUST attach before/after
  measurements per Principle IV.
- UX gate: PRs touching `lib/features/*/presentation/` MUST link the design
  tokens used and screenshots/recordings of loading, empty, error, and
  offline states.
- Code review: at least one non-author approval, constitution compliance
  verified.

**Result**: PASS. No violations. Complexity Tracking section below is empty.

## Project Structure

### Documentation (this feature)

```text
specs/001-music-player-app/
├── plan.md              # This file (/speckit-plan output)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── repositories.md  # Domain repository interfaces (Dart abstract API)
│   ├── firestore-schema.md
│   └── spotify-api.md   # Optional bonus surface
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

Flutter mobile app, Clean Architecture (data → domain → presentation) with
MVVM in the presentation layer (`ChangeNotifier`-based view models exposed
via `provider`):

```text
lib/
├── main.dart                          # composition root: DI + provider tree + app shell
├── app.dart                           # MaterialApp, routing, theming
├── core/
│   ├── constants/                     # spacing, durations, asset keys
│   ├── error/                         # Failure types, exceptions
│   ├── theme/                         # AppTokens (ThemeExtension), light/dark themes
│   ├── l10n/                          # generated intl bindings
│   ├── di/                            # get_it registration
│   ├── routing/                       # named routes / GoRouter config
│   └── utils/                         # pure helpers
├── shared/
│   ├── audio/
│   │   ├── audio_handler.dart         # AudioService BackgroundAudioHandler
│   │   ├── playback_controller.dart   # façade over just_audio + queue
│   │   └── playback_state.dart        # immutable state object
│   ├── widgets/
│   │   ├── mini_player.dart           # persistent across screens
│   │   ├── empty_state.dart
│   │   ├── error_state.dart
│   │   └── offline_indicator.dart
│   └── navigation/
│       └── app_shell.dart             # bottom nav + mini-player slot
├── features/
│   ├── library/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── library_local_datasource.dart
│   │   │   │   └── library_remote_datasource.dart   # Firestore
│   │   │   ├── models/
│   │   │   │   ├── track_model.dart
│   │   │   │   ├── album_model.dart
│   │   │   │   └── artist_model.dart
│   │   │   └── repositories/
│   │   │       └── library_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/              # Track, Album, Artist (pure Dart)
│   │   │   ├── repositories/          # LibraryRepository (abstract)
│   │   │   └── usecases/              # GetTracks, GetAlbums, GetArtists
│   │   └── presentation/
│   │       ├── viewmodels/library_viewmodel.dart   # ChangeNotifier
│   │       ├── views/library_screen.dart
│   │       └── widgets/track_row.dart
│   ├── now_playing/                   # data/domain/presentation/ — same layout
│   ├── search/                        # data/domain/presentation/
│   ├── favorites/                     # data/domain/presentation/
│   ├── playlists/                     # data/domain/presentation/
│   ├── profile/                       # data/domain/presentation/
│   └── spotify/                       # optional bonus
│       ├── data/
│       │   └── datasources/spotify_api_datasource.dart
│       └── domain/usecases/search_spotify_catalog.dart

assets/
├── audio/                             # bundled fixture/seed tracks
├── images/
└── translations/                      # *.arb files

test/
├── unit/                              # use cases + view models (mocktail repos)
├── widget/                            # per-screen widget tests
├── integration/                       # end-to-end via integration_test
│   └── playback_flow_test.dart        # uses real just_audio + fixture media
└── fixtures/
    └── audio/                         # short royalty-free clips for tests

android/
ios/
```

**Structure Decision**: Single Flutter project (`lib/`) organized by
**feature** at the top of the tree, with each feature internally split into
the three Clean Architecture layers (`data/`, `domain/`, `presentation/`).
This keeps cross-cutting code (`core/`, `shared/`) clearly separated from
feature code, lets each feature evolve and be tested in isolation, and gives
each user story (US1–US5) a natural home in exactly one feature folder. The
`spotify/` feature folder is the only optional addition for the bonus.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations. Constitution Check passed at both initial and post-design
re-evaluation. Section intentionally empty.*
