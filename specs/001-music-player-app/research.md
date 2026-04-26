# Phase 0 — Research: Comprehensive Music Player Application

**Feature**: 001-music-player-app
**Date**: 2026-04-25
**Inputs**: [spec.md](spec.md), [plan.md](plan.md), [`.specify/memory/constitution.md`](../../.specify/memory/constitution.md)

This document records the research decisions that close every
"NEEDS CLARIFICATION" implied by the Technical Context and the optional
bonus integration. Each entry follows the `Decision / Rationale /
Alternatives` shape.

---

## R1 — State management for MVVM in Flutter

**Decision**: Use `provider` (the Provider package) with `ChangeNotifier`-based
view models per screen. Cross-cutting state (`PlaybackState`, current
`UserSession`, `AppSettings`) is exposed as singletons via `get_it` and
selected into the widget tree with `Provider.value` / `MultiProvider` at the
app shell level.

**Rationale**:

- Required by the user's stack choice.
- `ChangeNotifier` + `provider` maps cleanly to MVVM: the view model is the
  `ChangeNotifier`, `notifyListeners()` is the binding, `Consumer` /
  `context.watch` / `Selector` are the bindings on the View side.
- `Selector` lets the Library, Search, Favorites, and Playlist lists rebuild
  only when their slice changes — this is how we keep the 60 fps budget on
  long lists (constitution Principle IV).
- Provider has no codegen and small surface area, which keeps cold-start
  fast (≤ 2.0 s budget).

**Alternatives considered**:

- `flutter_bloc` — heavier ceremony, less direct mapping to MVVM.
- `riverpod` — excellent, but the user explicitly chose Provider.
- `setState` only — fails cross-screen state sharing (mini-player on every
  screen) and offline persistence handoff.

---

## R2 — Audio engine and background playback

**Decision**: Use `just_audio` for the audio pipeline, wrapped by an
`AudioHandler` from the `audio_service` package, with `audio_session`
configured at app start to participate in platform audio focus.

**Rationale**:

- `just_audio` exposes a single API for local files, asset files, and HTTP
  streams (covers local seed tracks and Spotify previews) and supports
  gapless concatenation via `ConcatenatingAudioSource` — needed for FR-012.
- `audio_service` provides the OS-level media session, lock-screen
  controls, and background isolate so playback continues when the UI is
  backgrounded — needed for SC-008 (background battery budget).
- `audio_session` handles "headphones unplugged → pause" and
  "incoming call → pause then resume" without us having to write per-
  platform code — directly closes two edge cases listed in the spec.

**Alternatives considered**:

- `audioplayers` — simpler API but no first-class queue / gapless / lock-
  screen story; would force us to write more glue.
- Platform-channel wrappers around AVPlayer / ExoPlayer — maximum control
  but ~2-3× the code; Principle IV's measurement requirements are
  achievable with `just_audio` already.

---

## R3 — Backend choice and offline strategy

**Decision**: Firebase, specifically:

- **Firebase Auth** (anonymous by default, optional Google sign-in for
  cross-device sync)
- **Cloud Firestore** with `Settings(persistenceEnabled: true)` for
  user-curated data (likes, playlists, profile, settings, search history)
- **Firebase Storage** for any user-uploaded artwork or audio files
- **Firebase Analytics + Crashlytics** for telemetry required by the
  constitution Section 2

A **local audio cache** sits in front of remote audio sources via
`flutter_cache_manager` so playback works offline for any track the user
has streamed at least once.

**Rationale**:

- Required by the user's stack choice.
- Firestore offline persistence directly satisfies the "remain fully usable
  offline" constraint in FR-034.
- Anonymous Auth lets the app work with no sign-in step (matches the spec
  assumption "no mandatory authentication") while still giving every user a
  stable UID that Firestore documents can be keyed on.
- Crashlytics is the cheapest way to hit the ≥ 99.5 % crash-free target.

**Alternatives considered**:

- Local SQLite only (no backend) — disqualifies the bonus and loses
  cross-device sync.
- Supabase / PocketBase — viable but the user chose Firebase.

---

## R4 — Clean Architecture layering and dependency direction

**Decision**: Three layers per feature folder (`data/`, `domain/`,
`presentation/`) with strict dependency direction `presentation → domain ←
data`. Domain has zero Flutter or Firebase imports. Data implements domain
abstractions and is the only layer that imports `cloud_firestore`,
`firebase_storage`, `just_audio`, etc. Presentation imports domain (use
cases and entities) and `provider`, never `data` directly.

**Rationale**:

- Lets us swap Firestore for a mock or for an alternative backend without
  touching view models or screens — directly enables Principle II's
  unit-test discipline (use cases and view models are tested with mocked
  repositories).
- Maps cleanly onto the Flutter package layout the user requested.

**Alternatives considered**:

- Two-layer (data + presentation) — faster to write but use cases become
  buried in view models, which makes them hard to unit-test.
- Hexagonal with separate `application/` layer — overkill for a six-screen
  app.

---

## R5 — Routing and navigation shell

**Decision**: Use the Flutter `Navigator 2.0` API via `go_router` with a
`StatefulShellRoute.indexedStack` so the bottom navigation bar preserves
each tab's stack and the persistent mini-player lives in the shell scaffold.

**Rationale**:

- `IndexedStack` preserves screen state per tab so navigating away from
  Search and back does not re-issue queries (helps SC-005).
- The mini-player is a sibling of the shell `IndexedStack`, so navigating
  between tabs cannot cause it to flicker, restart, or duplicate (closes
  the "rapid navigation" edge case).

**Alternatives considered**:

- `Navigator 1.0` named routes — works but does not give per-tab stacks
  out of the box.
- Custom shell + manual `IndexedStack` — possible but reinvents `go_router`'s
  shell route.

---

## R6 — Theming and design tokens (UX consistency, FR-032)

**Decision**: Define a `ThemeExtension<AppTokens>` that holds spacing,
radius, motion durations, semantic colors, and text styles. Register it on
both the light and dark `ThemeData`. Every widget reads tokens via
`Theme.of(context).extension<AppTokens>()!` — no `Colors.x`, no magic
numbers, no `EdgeInsets.all(16)` literals in feature code. A custom
`flutter_lints` rule (configured in `analysis_options.yaml`) flags
hard-coded color and `EdgeInsets` literals in `lib/features/`.

**Rationale**:

- Directly satisfies constitution Principle III, FR-032, and SC-012.
- Lint rule makes the gate enforceable in CI rather than relying on
  reviewer vigilance.

**Alternatives considered**:

- Plain `ThemeData` only — usable but mixes design tokens with Material's
  semantic slots; harder to extend with motion / radius.
- A separate "tokens" package — premature for v1; revisit if tokens are
  shared across multiple apps.

---

## R7 — Localization (FR-031)

**Decision**: Use `flutter_localizations` + `intl` with ARB files under
`assets/translations/`. Generated bindings (`AppLocalizations`) are imported
by every UI widget. English (`en.arb`) is the source-of-truth locale; one
additional locale is included from day one (`es.arb`) so the pipeline is
proven before strings accumulate. A lint check forbids string literals in
`lib/features/*/presentation/views/` and `widgets/` directories.

**Rationale**:

- `intl` is the canonical Flutter localization stack; no third-party risk.
- Including a second locale on day one prevents "we'll add l10n later"
  drift, which historically results in hard-coded strings everywhere.

**Alternatives considered**:

- `easy_localization` — simpler but lock-in to a non-standard API.
- English-only with a placeholder — violates the spec on day one and is
  almost always painful to retrofit.

---

## R8 — Performance instrumentation

**Decision**: Wrap the playback controller with a thin instrumentation
layer that emits four custom Firebase Analytics events:

- `playback_start_latency_ms` — time from `play()` call to first frame
- `playback_dropout` — emitted on `ProcessingState.buffering` mid-track
- `frame_jank_ms` — sampled via `SchedulerBinding.addTimingsCallback`
- `cold_start_to_interactive_ms` — recorded in `main()` and on first
  navigator frame

Crashlytics records non-fatal exceptions from repository failures so we
can correlate UX issues with backend problems.

**Rationale**:

- Constitution Section 2 requires telemetry on these four signals; without
  this layer the Performance Gate in Section 3 cannot be enforced.
- These events are cheap (post-frame, sampled) and do not affect the
  budgets they measure.

**Alternatives considered**:

- Firebase Performance Monitoring's automatic traces — useful but does not
  capture audio-start latency or playback dropouts; we still need custom
  events.

---

## R9 — Testing strategy and coverage gates

**Decision**:

- **Unit tests** (`test/unit/`): every use case and every view model, with
  `mocktail` doubles for the repository ports. Coverage target ≥ 80 % for
  `lib/features/*/domain/` and `lib/shared/audio/`; ≥ 60 % for
  `lib/features/*/presentation/`.
- **Widget tests** (`test/widget/`): one per screen, asserting the empty,
  loading, error, and offline states render and that the primary action
  fires the expected view model method.
- **Integration tests** (`test/integration/`): one happy-path test per
  user story (US1–US5). The playback test exercises real `just_audio`
  against bundled fixture clips; the Firestore tests run against the
  Firebase emulator suite (started in CI).
- CI gate: `flutter test --coverage` followed by an `lcov`-based threshold
  check that fails the build if coverage on the changed files drops below
  the targets.

**Rationale**:

- Mirrors constitution Principle II exactly, and uses the Firebase
  emulator instead of mocking Firestore so we exercise real query
  behavior — closing the "burned by mocks" risk pattern called out by the
  constitution rationale.

**Alternatives considered**:

- Mocking Firestore with `fake_cloud_firestore` — fast but historically
  diverges from real Firestore's query semantics (`!=`, array-contains,
  composite indexes). Reserved for unit-level repository tests.

---

## R10 — Optional bonus: Spotify Web API integration

**Decision**: Implement Spotify integration as a strictly optional `spotify`
feature module, gated behind a settings toggle. Use the Spotify Web API's
**Authorization Code with PKCE** flow (no client secret, safe for mobile)
via the `oauth2` package, and call only public-catalog endpoints:

- `GET /v1/search` — power Search results when toggle is on
- `GET /v1/tracks/{id}`, `/albums/{id}`, `/artists/{id}` — metadata
  enrichment
- The 30-second `preview_url` returned on `Track` objects is the playable
  source via `just_audio`'s URL source

User-curated data (likes, playlists) **stays in Firestore** keyed by the
Spotify track ID (when applicable) plus our internal track ID. We never
write to a user's Spotify account.

**Rationale**:

- Authorization Code + PKCE is the only OAuth flow Spotify recommends for
  mobile; the user never sees a client secret.
- The 30-second preview is licensable for app use and keeps us out of
  full-track licensing complications.
- Storing curation in Firestore (not in Spotify) preserves the offline-
  first and Firestore-as-source-of-truth model from R3.

**Alternatives considered**:

- Implicit Grant — deprecated by Spotify, do not use.
- Backend proxy with client secret — adds infrastructure for no security
  gain over PKCE on mobile.
- Storing curation in Spotify playlists — locks the feature behind Spotify
  auth and breaks the offline-first guarantee.

---

## R11 — Reference device for performance budgets

**Decision**: Pixel 4a (Android 8 GB / 6 GB RAM, mid-range) for Android and
iPhone SE (2nd generation, A13, 3 GB RAM) for iOS. These are the lowest-tier
target devices against which all Principle IV budgets are validated. The
choice is recorded in `docs/quickstart.md` (created in Phase 1) and re-
confirmed each release.

**Rationale**:

- Both devices are widely available, still supported by their OS vendors,
  and represent the floor below which we are explicitly not targeting v1.
- Picking concrete devices closes an open variable in the constitution's
  Section 2 ("Reference hardware MUST be defined").

**Alternatives considered**:

- Highest-tier-only validation — would let regressions ship to mid-tier
  users; rejected by Principle IV.
- Emulator-only — emulator perf does not predict device perf for
  audio/graphics; rejected.

---

## Summary

All NEEDS CLARIFICATION items implied by the Technical Context are resolved
above. No open research items remain. Phase 1 (data model, contracts,
quickstart) can proceed.
