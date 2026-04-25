<!--
SYNC IMPACT REPORT
==================
Version change: TEMPLATE (uninitialized) → 1.0.0
Bump rationale: Initial ratification. Constitution moves from placeholder template to
                first concrete adopted version, so MAJOR baseline is established.

Modified principles:
  - [PRINCIPLE_1_NAME] → I. Code Quality (NON-NEGOTIABLE)
  - [PRINCIPLE_2_NAME] → II. Testing Standards (NON-NEGOTIABLE)
  - [PRINCIPLE_3_NAME] → III. User Experience Consistency
  - [PRINCIPLE_4_NAME] → IV. Performance Requirements
  - [PRINCIPLE_5_NAME] → REMOVED (user requested 4 principles only)

Added sections:
  - Performance & Quality Standards (replaces [SECTION_2_NAME])
  - Development Workflow & Quality Gates (replaces [SECTION_3_NAME])

Removed sections:
  - None beyond the 5th principle slot.

Templates requiring updates:
  - ✅ .specify/templates/plan-template.md — "Constitution Check" section will be
       populated by /speckit-plan against principles I–IV; no structural edit needed.
  - ✅ .specify/templates/spec-template.md — already includes Success Criteria
       (aligns with Principle IV) and User Scenarios (aligns with Principle III).
  - ✅ .specify/templates/tasks-template.md — task categorization (Setup, Foundational,
       per-Story, Polish) accommodates testing, UX, and performance tasks under
       principles I–IV; no structural edit needed.
  - ✅ .claude/skills/speckit-*/  command files — no agent-specific or principle-specific
       references that conflict with the new constitution.

Follow-up TODOs:
  - None. All placeholders resolved.
-->

# Music Player App Constitution

## Core Principles

### I. Code Quality (NON-NEGOTIABLE)

All production code MUST meet a defined quality bar before it is merged. This means:

- Every change MUST pass linting and formatting checks configured for the project
  (no `// eslint-disable`, `# noqa`, or analogous suppressions without an inline
  justification comment).
- Public functions, modules, and exported types MUST have names that describe
  intent; abbreviations and single-letter identifiers are disallowed outside of
  conventional loop indices.
- Cyclomatic complexity per function SHOULD remain ≤ 10; any function exceeding
  this MUST include a written justification in the PR description.
- Dead code, commented-out code, and TODO comments without an owner or tracking
  issue MUST be removed before merge.
- Code duplication that would be eliminated by a clear abstraction MUST be
  refactored once it appears in three or more places (rule of three).

**Rationale**: A music player is a long-lived consumer product where bugs surface
as audible glitches and crashes during playback. Sustained code quality keeps the
audio pipeline, playback state machine, and UI layer debuggable as the codebase
grows.

### II. Testing Standards (NON-NEGOTIABLE)

Testing is a first-class deliverable, not an afterthought:

- Every feature MUST ship with automated tests that cover its acceptance
  scenarios. Pure UI changes MUST include at least one component or
  integration test asserting the rendered behavior.
- Unit test coverage MUST be ≥ 80% for any module containing playback,
  queue management, audio decoding, or persistence logic. Coverage on UI
  glue code SHOULD be ≥ 60%.
- Tests MUST be deterministic. Flaky tests are treated as failing tests and
  MUST be fixed or quarantined with a tracking issue within one working day.
- Integration tests MUST exercise real audio I/O paths against fixture media
  files; mocking the audio output device is permitted only when the host
  environment cannot provide one (e.g., headless CI).
- Regression tests MUST be added for every fixed bug, and the failing test
  MUST be committed in the same PR as the fix.

**Rationale**: Audio playback bugs are hard to reproduce manually and easy to
re-introduce. A strong, deterministic test suite is the only practical safeguard
against silent regressions in the playback pipeline.

### III. User Experience Consistency

The product MUST present a single, coherent experience across screens, states,
and platforms:

- All visual elements (typography, spacing, color, iconography, motion) MUST
  draw from the shared design tokens / theme system. Hard-coded style values
  in feature code are disallowed.
- Common interactions (play, pause, seek, skip, queue, like) MUST behave
  identically wherever they appear (mini-player, full player, lock-screen
  controls, media-session integration).
- All user-facing strings MUST go through the localization layer; raw
  string literals in UI components are disallowed.
- Every interactive surface MUST meet WCAG 2.1 AA: keyboard reachable,
  screen-reader labeled, ≥ 4.5:1 contrast for text, and visible focus state.
- Loading, empty, error, and offline states MUST be designed and implemented
  for every screen — never left as default platform behavior.

**Rationale**: A music player is used in short, attention-light interactions
(running, driving, cooking). Consistency is what lets users operate the app
without looking at it, and it is what makes the app feel finished.

### IV. Performance Requirements

The app MUST meet hard performance budgets that protect the listening
experience:

- **Audio**: Time from user-initiated play to first audio frame MUST be
  ≤ 300 ms for locally cached tracks and ≤ 1000 ms (p95) for streamed
  tracks on a 10 Mbps connection. Underruns/dropouts during steady-state
  playback MUST be 0 over a 30-minute test on target hardware.
- **UI**: Sustained 60 fps (≤ 16.6 ms/frame) during scroll, transitions,
  and album-art animation on the lowest-tier supported device. No frame
  may exceed 50 ms.
- **Startup**: Cold start to interactive home screen MUST be ≤ 2.0 s on
  the lowest-tier supported device; warm start MUST be ≤ 800 ms.
- **Memory**: Resident memory MUST stay ≤ 250 MB during a 1-hour playback
  session with the queue, library, and now-playing screens all visited.
- **Battery**: Background-audio playback MUST consume ≤ 4% battery per
  hour on the reference device with the screen off.
- Every PR that touches the playback pipeline, rendering, or data layer
  MUST include before/after measurements against the relevant budget. A
  regression in any budget MUST be either reverted or justified in the
  Complexity Tracking section of the plan.

**Rationale**: Performance is a feature in audio software. Users notice a
200 ms delay before a track starts and a single dropout ends trust in the
app. Hard, measurable budgets make performance regressions impossible to
ship by accident.

## Performance & Quality Standards

The following standards apply to every feature and every release:

- **Reference hardware**: The "lowest-tier supported device" referenced in
  Principle IV MUST be defined in `docs/quickstart.md` (or equivalent) and
  reviewed each release. Performance budgets are validated against that
  device, not against developer machines.
- **Telemetry**: Playback start latency, frame timing, crash-free session
  rate, and audio underrun count MUST be instrumented and reported. A
  feature without instrumentation that lets us observe its impact on these
  metrics is considered incomplete.
- **Crash & error budget**: Crash-free sessions MUST be ≥ 99.5% per release.
  Any release that drops below this threshold MUST trigger a hotfix branch
  before further feature work.
- **Dependencies**: New runtime dependencies MUST be reviewed for license,
  maintenance status, and binary-size impact. Net binary-size growth from
  a single PR MUST stay ≤ 250 KB unless explicitly justified.

## Development Workflow & Quality Gates

The following gates MUST pass before any PR is merged:

1. **Automated checks**: Lint, format, type-check, unit tests, and
   integration tests pass in CI.
2. **Coverage gate**: Test coverage thresholds from Principle II are met
   for changed modules.
3. **Performance gate**: For PRs touching playback, rendering, or data
   layers, the required before/after measurements (Principle IV) are
   attached to the PR.
4. **UX gate**: For PRs introducing or modifying user-facing surfaces, the
   PR description references the relevant design tokens, includes
   accessibility notes, and links a screenshot or screen recording of the
   loading, empty, error, and offline states.
5. **Code review**: At least one reviewer other than the author MUST
   approve. Reviews MUST explicitly verify constitution compliance.
6. **Constitution Check**: Every implementation plan MUST complete the
   "Constitution Check" gate against principles I–IV before Phase 0 and
   re-check after Phase 1 design.

Violations of any gate MUST be either resolved or documented in the
plan's Complexity Tracking table with an explicit, reviewer-approved
justification.

## Governance

This constitution supersedes all other development practices, style
guides, and ad-hoc conventions in this repository. Where another document
conflicts with this constitution, this constitution wins until the other
document is updated or this constitution is amended.

**Amendment procedure**:

1. Amendments MUST be proposed as a PR that edits
   `.specify/memory/constitution.md` and includes a Sync Impact Report
   (as an HTML comment at the top of the file).
2. The PR MUST update every dependent template
   (`.specify/templates/plan-template.md`, `spec-template.md`,
   `tasks-template.md`) and any runtime guidance docs that reference the
   amended principles.
3. Amendments require approval from at least one project maintainer.
4. After merge, the new version MUST be announced in the project's
   changelog or release notes.

**Versioning policy** (semantic versioning applied to governance):

- **MAJOR**: Backward-incompatible changes — principle removed or
  redefined in a way that invalidates prior compliance.
- **MINOR**: A new principle or section is added, or an existing
  principle's guidance is materially expanded.
- **PATCH**: Clarifications, wording, typo fixes, and non-semantic
  refinements that do not change required behavior.

**Compliance review**: All PRs MUST verify compliance with this
constitution as part of code review. Plans MUST pass the Constitution
Check gate before Phase 0 and again after Phase 1. Complexity that
violates a principle MUST be justified in the plan's Complexity Tracking
table; unjustified violations are merge blockers.

Use `CLAUDE.md` (and any future `docs/quickstart.md`) for runtime
development guidance; both MUST stay consistent with this constitution.

**Version**: 1.0.0 | **Ratified**: 2026-04-25 | **Last Amended**: 2026-04-25
