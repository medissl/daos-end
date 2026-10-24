# Living Dao verification record

Godot 4.7.2, Windows Intel Iris Xe. Full stdout logs and isolated saves remain
under `.verification/`. Machine-readable reports listed here are public.

| Check | Result | Evidence |
|---|---|---|
| Tutorial/core rules | 73 / 0 failures | `tests/run_tests.gd` |
| Existing milestone-two state | 96 / 0 | `tests/milestone_two.gd` |
| Expanded old/new encounter serialization | 327 / 0 | `tests/jade_road.gd` |
| Continuous discovery, trial/supply policy | 22 / 0 | `tests/living_phase_one.gd` |
| Caps, preparations, presets, migration, corruption | 56 / 0 | `SAFETY_RESULTS.json` |
| Derived-rate/save matrix | 1,622 / 0 | `RATE_SAVE_MATRIX.json` |
| Audio signal/routing | 15 / 0 | `tests/jade_audio.gd`; no listening claim |
| Four-size original/early/developed rendered geometry | 8,839 / 0 | `tests/verify_living_ui.gd` |
| Four-size frontier and Soul screens | 3,759 / 0 | `FRONTIER_LAYOUT_RESULTS.json` |
| Earned fixed-entry / fresh progression | 0 failures | `CHAPTER_REACHABILITY.json`, `SOUL_REACHABILITY.json`, `FRESH_*` |
| Original first-route real browser input | All four sizes pass | `RELEASE_BROWSER_RESULTS.json`, `RELEASE-DESKTOP_BROWSER_RESULTS.json` |
| New regions / earned Soul / preferences / interruptions | All four sizes pass | `FRONTIER_BROWSER_RESULTS.json` |
| 60 journeys and repeated detail/nav churn | Stable after lazy warmup | `RUNTIME_BUDGET.json` |
| Landing layout, keyboard, images, actual Play | Four sizes pass | `SITE_BROWSER_RESULTS.json` |
| Signed ARM64 APK | v2/v3, alignment and package pass | `APK_VERIFICATION.json` |

The browser scripts use ordinary time and isolated storage. Earned checkpoints
come from public-action progression, with no granted new-region gear/resources.
Native geometry assertions supplement real screenshot/motion review; they do
not replace it. The initial harness coordinate and IndexedDB timing failures
were fixed and rerun before recording passes.

The final web/APK exports additionally include the engine's actual license
notices. That packaging change does not modify simulation. Public-site checks
are recorded separately after deployment in `PUBLISHED_SITE_RESULTS.json` and
`PUBLICATION.json`, including release-asset digests.

Not passed/unavailable: physical Android installation/performance/lifecycle,
subjective speaker/headphone listening, and uncoached human comprehension/fun.
Measured browser hitches and payload remain listed in `DELIVERY.md`.
