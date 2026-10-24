# Milestone 1 handoff — The First Breath

**Visual revision:** the presentation notes below record the original playable
milestone. The current illustrated presentation supersedes them; see
`art-direction/VISUAL_REDESIGN_DELIVERY.md` and `../assets/ART_SOURCES.md`.
The progression, save schema, and offline model remain unchanged.

Implemented October 23, 2026. Stop here for playable review; no further realms,
combat, expeditions, equipment, techniques, reincarnation, accounts, or monetization.

## Architecture and locations

| File | Responsibility |
| --- | --- |
| `scripts/progression.gd` | Provisional costs, caps, multipliers, offline limit |
| `scripts/cultivation_state.gd` | Pure production, spending, and advancement |
| `scripts/cultivation_session.gd` | Monotonic active time; capped absent wall time; idempotent lifecycle transitions |
| `scripts/save_store.gd` | Versioned validation, recovery copies, backup, temporary-file replacement |
| `scripts/main.gd` | Responsive controls, presentation, lifecycle/persistence coordination |
| `scripts/landscape.gd` | Original vector mountains and meditating silhouette |
| `scenes/main.tscn` | Playable entry point |
| `tests/` | Rule/save tests, pacing simulation, native interface and browser checks |
| `builds/web/` | Locally built browser result (ignored output) |
| `.verification/` | Rendered screenshots, isolated save fixtures, templates, browser report (ignored) |

Rules remain exactly as specified in the brief; see README for the complete
formula and costs. No separate lifetime cultivation requirement exists.
All purchases spend stored Qi. A breakthrough is guaranteed, costs 4,000 or
3,000 Qi, retains upgrades, and doubles production once.

Only one clock owner advances the state. Active play uses monotonic timestamps,
never frame count. Suspension settles active time once; subsequent frames stop
production until a single capped wall-clock award on return. Returning resets
the monotonic anchor and immediately checkpoints the credited state. Duplicate
focus/pause signals are harmless. Backward wall time earns zero offline Qi.
Browser visibility/page lifecycle callbacks share these same transitions.

## Design decisions

Considered an immersive overlay on scenery and a separated landscape/practice
composition. Chose the latter for number contrast and narrow-screen usability.
Parchment, muted jade mountains, dark ink controls, and a restrained breathing
ring support the peaceful setting with no downloaded or generated artwork.
The landscape and feedback stay fixed while the practice list scrolls. Desktop
uses two columns. Native display typography can use an installed serif; browser
uses Godot’s fallback font. Buttons have 48-pixel minimum touch height and
keyboard focus styling. Full screen-reader/device accessibility remains unverified.

Reference inspected: [GRIS interface collection](https://interfaceingame.com/games/gris/).
No reference assets were copied. Polygon scenery is deliberately placeholder art.

## Verification evidence

- Godot 4.7.2 official Windows build, Compatibility/OpenGL on Intel Iris Xe.
- Automated rules/save/session suite: **73 checks, 0 failures**.
- Native interface: **19 checks, 0 failures**; real rendered screenshots at **320 × 640**, **430 × 932**,
  and **1280 × 800**. Automated button-signal playthrough verifies purchase,
  preparation, breakthrough, retained upgrades, immediate label refresh,
  lifecycle deduplication, and persisted advancement.
- Web export built successfully with matching single-threaded templates.
- Browser test uses real WASM in isolated headless Edge, screenshots at the
  same three sizes, real pointer purchases for all three upgrades, breakthrough,
  disk-backed IndexedDB state checks, reload, focus changes, eight-hour cap,
  duplicate-credit prevention, and backward time. Results are saved as
  `.verification/browser-results.json` only after all assertions pass.
- Android export attempted: blocked by **missing Java SDK and Android SDK
  configuration**. Matching APK templates are present. No Android device,
  emulator, installation, or touch-device test was performed.
- No separate GDScript linter was installed; Godot parsed/compiled the scripts
  and the tests/export exercised them.

Rendered review corrected narrow title/level wrapping, moved feedback out of
the scrolling area, and replaced an unsupported browser arrow glyph with words.
The optional browser server handles favicon requests so its console check
does not mistake a test-server 404 for a game error.

## Pacing simulation

Strategy: immediately buy, in order, Deep Breathing, Deep Breathing, Meridian
Circulation, Deep Breathing, Settle the Mind, Deep Breathing, Meridian
Circulation; then save the full prepared breakthrough cost.

| Strategy | First upgrade | First breakthrough | Production afterward |
| --- | --- | --- | --- |
| Above sequence | 25.0 seconds | 719.4 seconds (11m 59.4s) | 15 Qi/s |
| Save without upgrades | None | 4,000 seconds (66m 40s) | 2 Qi/s |

Simulation uses exact affordability intervals with a one-microsecond tolerance
per step, solely to avoid floating-point boundary artifacts in the simulator.
The live game retains exact affordability checks. These timings do not establish
that the game is fun. No balance values were silently changed. Review saving
versus investing and Settle the Mind’s timing before proposing balance changes.

## Limitations and next boundary

- Browser storage depends on origin, profile, quota, and asynchronous IndexedDB
  flushing. Explicit write failures show a visible status. Use one active game
  tab/process; simultaneous writers are not coordinated.
- If storage remains unavailable, the current session remains playable but
  cannot promise durable progress. Recovery copies intentionally accumulate
  until the user decides whether to remove them.
- Time is local device time, not an authoritative clock; changing it forward
  can earn the capped absence. Clock reversal cannot generate negative rewards.
- No APK build/device proof, mobile safe-area/device-density proof, or human
  usability/fun validation is claimed. Browser checks are desktop headless Edge,
  not a physical Android browser or Safari test.
- `game-dev` CLI is not installed. Godot-native rendering and browser tools
  provided verification; no Game Development Studio capture receipt is claimed.
- This folder had no `.git` metadata. GitHub lists an empty
  `medissl/daos-end` repository; synchronization was not assumed or configured.
  Graphify lists only unrelated indexed repositories. No push or deployment.

Next recommended milestone is **reviewing this playable result and testing on
an Android device after configuring the SDKs**, before authorizing further
gameplay development. Preserve the milestone boundary.

Platform sources checked:
[Godot web export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
and [Android export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).
