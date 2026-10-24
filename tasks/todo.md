# The Jade Road — implementation task list

Historical completed chapter. The current Living Dao update through Nascent
Soul is tracked in `tasks/living-dao.md`, with evidence in
`docs/living-dao/DELIVERY.md`. Preserve the completed checks below as history.

This list tracks the implemented Jade Road boundary. Evidence is in
`docs/jade-road/DELIVERY.md`; unchecked work and known limits remain explicit.

## Foundation

- [x] **1. Audit and checkpoint current behavior.**
  - Acceptance: inspect latest UI work; preserve current files; isolate v1/v2 save fixtures and report baseline checks.
  - Verify: existing rule and milestone-two suites; actual current browser scene.
  - Dependencies: none. Likely scope: handoff/checkpoint records and targeted fixtures, no broad rewrite.
- [x] **2. Add versioned chapter definitions and migration.**
  - Acceptance: new stable IDs/defaults; old resources/absence preserved; Azure refund applied once.
  - Verify: valid/invalid v1/v2 migrations, backup recovery and repeated loading.
  - Dependencies: 1. Likely scope: progression/state/save files and focused migration test.
- [x] **3. Resolve one deterministic encounter.**
  - Acceptance: basic attack, focus/cooldowns, one enemy and safe defeat/timeout independent of rendering.
  - Verify: step-size/event-order equivalence and bounded HP/focus.
  - Dependencies: 2. Likely scope: combat definitions/resolver and focused test.
- [x] **4. Play one route node with a real result.**
  - Acceptance: select/start, see actual action, receive a persisted one-time first-clear reward.
  - Verify: pointer-driven play, reload and reward deduplication.
  - Dependencies: 3. Likely scope: route/state/presentation and integration test.

## Builds and rewards

- [x] **5. Implement the four distinct combat arts.**
  - Acceptance: specified damage/guard/cleanse behavior and ordered slots; free between-attempt changes.
  - Verify: relevant trait counters, caps and no mid-hit loadout exploits.
  - Dependencies: 3. Likely scope: definitions/resolver/stat evaluation and tests.
- [x] **6. Give Azure and Iron useful combat roles.**
  - Acceptance: focus versus endurance matters; existing resonance weights apply; mastery outcomes are visible.
  - Verify: contrasting encounters/policies and queue/commitment tests.
  - Dependencies: 5. Likely scope: stat/technique evaluation, UI readout and tests.
- [x] **7. Add weapon equipment and refinement.**
  - Acceptance: three weapon definitions, slot rules, previews and exact Qi/stone costs.
  - Verify: stat changes, insufficient-resource rejection, persistence and no duplicate awards.
  - Dependencies: 4, 5. Likely scope: item definitions/state/UI and tests.
- [x] **8. Add robe and artifact equipment.**
  - Acceptance: all nine named items have distinct defined effects and acquisition paths.
  - Verify: shield/heal/DOT/focus interactions; no unexpected scaling of secondary effects.
  - Dependencies: 7. Likely scope: item/stat definitions, equipment view and tests.

## Playable chapter

- [x] **9. Author Misty Mountain's three routes.**
  - Acceptance: twelve concrete nodes with different traits, guaranteed rewards and understandable finales.
  - Verify: reachable counters, first-clear history and actual route play.
  - Dependencies: 4–8. Likely scope: route/enemy data, reward mappings and simulation fixtures.
- [x] **10. Author Spirit River's three routes.**
  - Acceptance: twelve concrete nodes with poison/flow/recovery problems and appropriate unlocks.
  - Verify: at least two useful approaches and no required rare drop.
  - Dependencies: 9. Likely scope: route/enemy data, reward mappings and simulation fixtures.
- [x] **11. Add six optional objective trials.**
  - Acceptance: distinct visible conditions and deterministic rewards; no recolor-only content claims.
  - Verify: legal solutions, failed-attempt safety and permanent claim tracking.
  - Dependencies: 10. Likely scope: trial definitions/state and tests.
- [x] **12. Complete Golden Core advancement.**
  - Acceptance: requirements/preparation/Core Trial work; third combat slot and preset become usable; persistent visual change.
  - Verify: ordinary successful route, insufficient requirements, repeated advancement rejection and save round trip.
  - Dependencies: 9–11. Likely scope: progression/state, preset/UI and tests.
- [x] **13. Implement retreat/offline transition behavior.**
  - Acceptance: post-Foundation 30% visible/closed retreat; finite journeys; cap/partial progress without duplicate earnings.
  - Verify: active/unattended/absent policy comparison, focus cycles, completed/failed segment boundaries and reload.
  - Dependencies: 4, 12. Likely scope: session/timeline/state/save and integration test.

## Actual asset production, integrated with the relevant features

- [x] **14. Integrate the material/UI sample.**
  - Acceptance: one real methods-scroll skin, action plaque, progress instrument and selection treatment work in-game.
  - Verify: slice margins, smallest/widest labels, state affordances and live text at 320×640, 390×844, 430×932 and 1280×800.
  - Dependencies: 1; integrate before scaling the rest of the UI. Scope: small reusable skin families and consumer controls.
- [x] **15. Complete required region/guardian art.**
  - Acceptance: two new places and the needed coherent guardian families/traits are actual runtime assets.
  - Verify: silhouettes, palette, edge quality and encounter readability at phone scale.
  - Dependencies: 9, 10, 14. Split production into small asset-family batches; preserve sources and provenance.
- [x] **16. Complete skill/item/resource art and realm effects.**
  - Acceptance: all new actual systems have readable consistent symbols; Golden Core transformation is persistent.
  - Verify: 32/48/64-pixel review, labels/counters, input pass-through and reduced motion.
  - Dependencies: 5–8, 12, 14. Work in skill, equipment-slot and effect batches rather than one giant regeneration.
- [x] **17. Download/select and integrate licensed audio.**
  - Acceptance: music, ambience and meaningful SFX fit one palette; credits and persisted mix/mute controls exist.
  - Verify: browser gesture unlock, bus controls, loop seams, focus/resume and audible inspection when available.
  - Dependencies: real input/combat/reward events; can source candidates while data is authored. Keep asset selection and routing focused.

## Verification and delivery

- [x] **18. Compare builds, economy and timing.**
  - Acceptance: focus/guard/mixed/naive approaches tested; each has useful situations; waiting and dominance documented.
  - Verify: deterministic chapter simulations and actual ordinary-speed samples, never a fabricated 300-hour claim.
  - Dependencies: 12, 13. Likely scope: simulation/tests, tuning configuration and pacing report.
- [x] **19. Finish browser presentation and full-flow review.**
  - Acceptance: phone-first 320×640, 390×844, 430×932, then 1280×800 input, readable controls and coherent art/audio; major defects refined.
  - Verify: real finger swipes, purchase-drag cancellation, pointer/touch/keyboard, start-to-Core journey, offline/reload, audio settings and screenshot comparison.
  - Dependencies: 14–18. Keep behavior assertions; update obsolete layout coordinates legitimately.
- [x] **20. Deliver and record the next content boundary.**
  - Acceptance: working build, source/asset manifests, results, honest duration/art/audio/device limitations and handoff.
  - Verify: all claimed evidence exists; unfinished work stays unchecked; future systems remain identified as planned.
  - Dependencies: 19. Stop after this chapter, without pushing or deploying.

## Next review boundary (not additional content)

- [ ] Human listening on headphones/speakers and actual Android/device review.
- [ ] Human pacing/build review: guard dominance, weak limited-focus/mixed trials,
  repetitive stone farming and the short chapter. The automated earned path is
  about 45 minutes including 28 minutes retreat waiting; engaged hours are unmeasured.

Implementation checks and caveats: `docs/jade-road/DELIVERY.md`. Audio routing and
signal are verified; the unavailable listening test is explicitly unperformed.

2026-10-24 mobile finish: complete main frame and safe text insets; compact
phone controls, bottom navigation, above-fold Camp and consistent action art.
Fixed physical/logical-pixel scaling after reproducing the failure at DPR 3.
Verified actual DPR 2/2.625/3, touch scrolling, purchase cancellation and live
viewport resizing. Ordinary-speed DPR 3 route/Core play and reload passed.
Eight balance/combat/save source files match their pre-finish hashes.
