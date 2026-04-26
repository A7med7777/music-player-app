# Quickstart — Comprehensive Music Player Application

**Feature**: 001-music-player-app
**Date**: 2026-04-25
**Audience**: A developer joining the project who needs to clone, run,
test, and ship the app.

---

## 1. Prerequisites

| Tool | Version |
| --- | --- |
| Flutter SDK | 3.22+ (stable channel) |
| Dart | 3.4+ (bundled with Flutter) |
| Android Studio / Xcode | latest stable; iOS 14+ SDK, Android API 26+ |
| Firebase CLI | `npm i -g firebase-tools` |
| FlutterFire CLI | `dart pub global activate flutterfire_cli` |
| Java | 17 (for Android Gradle 8) |

---

## 2. First-time setup

```bash
# 1. Clone and fetch deps
git clone <repo-url>
cd music-player-app
flutter pub get

# 2. Configure Firebase (creates lib/firebase_options.dart)
firebase login
flutterfire configure --project=<your-firebase-project-id>

# 3. Deploy Firestore rules and indexes
firebase deploy --only firestore:rules,firestore:indexes

# 4. (Optional, for the bonus) Spotify
#    - Create an app at https://developer.spotify.com/dashboard
#    - Set the redirect URI to com.example.musicplayer://spotify-callback
#    - Drop the client id into lib/core/constants/secrets.dart (see template)
```

---

## 3. Run the app

```bash
# Android emulator or device
flutter run -d <device-id>

# iOS simulator (macOS only)
flutter run -d "iPhone 15"

# With the Firebase Emulator Suite (recommended for local dev)
firebase emulators:start --only firestore,auth &
flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

The app launches in **anonymous-auth mode** — no sign-in step. The local
seed library (`assets/audio/`) is automatically indexed on first launch
so the Library screen is never empty in dev.

---

## 4. Run the tests

```bash
# All unit + widget tests with coverage
flutter test --coverage

# Coverage gate (Principle II): 80 % on playback/queue/persistence,
# 60 % on UI glue. The script enforces both thresholds.
./tool/check_coverage.sh

# Integration tests (requires emulator/device + Firebase emulator running)
firebase emulators:exec --only firestore,auth \
  "flutter test integration_test/"
```

---

## 5. Reference devices (Constitution Principle IV)

Performance budgets in [plan.md](plan.md) and the Constitution are
validated on:

- **Android floor**: Pixel 4a (Snapdragon 730G, 6 GB RAM, Android 13)
- **iOS floor**: iPhone SE (2nd gen, A13 Bionic, 3 GB RAM, iOS 17)

Higher-end devices are tested for regressions but the budgets are
enforced against the floor devices. Update this list each release; if a
new floor is chosen, re-baseline and update the constitution's
"reference hardware" entry.

---

## 6. Performance measurement workflow

For any PR that touches `lib/shared/audio/`, `lib/features/*/presentation/`
with > 50 LOC, or list-rendering code:

```bash
# 1. Profile-mode timeline run on the floor device
flutter run --profile -d <floor-device>

# 2. In DevTools → Performance, capture:
#    - tap-to-first-frame time (audio): should ≤ 300 ms p95
#    - frame build/raster times during scroll: ≤ 16.6 ms each
#    - cold-start to home interactive: ≤ 2.0 s

# 3. Attach the captured numbers to the PR description as
#    "before / after" tables.
```

---

## 7. Verifying the smoke flow (US1 happy path)

A new contributor should be able to do this in under 5 minutes:

1. `flutter run` and let the app reach the Library screen.
2. Confirm the seed library lists at least 10 tracks.
3. Tap a track → audio starts within 300 ms (subjectively, "instantly")
   and the Now Playing screen opens.
4. Tap pause → silence within ~100 ms; tap play → resume.
5. Tap "skip next" → the next track in the queue plays.
6. Open the Search tab and type "the" → results appear within ~500 ms,
   grouped by Songs / Albums / Artists.
7. Tap the heart on the Now Playing screen → open the Favorites tab →
   the track is at the top.
8. Open Profile/Settings → switch theme to Dark → every screen reflects
   the change without a restart.

If any step fails, you have hit a Constitution gate (Principle IV
performance, or Principle III consistency) — open an issue before
submitting any PR.

---

## 8. Where things live

| You want to... | Look at... |
| --- | --- |
| Change a screen's UI | `lib/features/<feature>/presentation/views/` |
| Add a new playback feature | `lib/shared/audio/` + a use case in `lib/features/now_playing/domain/usecases/` |
| Add a new Firestore field | update `data-model.md` → update `lib/features/<f>/data/models/` → update `firestore.rules` → deploy |
| Tweak a design token | `lib/core/theme/app_tokens.dart` (single source of truth) |
| Add a translatable string | append to `assets/translations/en.arb` (then re-run `flutter gen-l10n`) |
| Touch the Spotify integration | `lib/features/spotify/` only (it MUST stay isolated so the toggle works) |

---

## 9. Definition of "done" for any PR

Before requesting review, verify:

- [ ] `flutter analyze` is clean
- [ ] `flutter test --coverage` passes and meets the coverage gate
- [ ] No hard-coded colors, spacings, or strings introduced in
      `lib/features/`
- [ ] If perf-sensitive: before/after measurements attached
- [ ] If UI-touching: screenshots of loading, empty, error, offline states
      attached
- [ ] PR description references the relevant FR-### and SC-### items
      from `spec.md`
