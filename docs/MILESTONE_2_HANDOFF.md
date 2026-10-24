# Milestone two handoff

Implemented October 23, 2026: **A Cultivator’s First Journey**.
Stop at Foundation Establishment and Technique Resonance for gameplay review.
No push, deployment, Git initialization or additional gameplay systems.

Interface finish, also October 23: read
`docs/art-direction/milestone-2/ui-finish/DELIVERY.md` for the current UI and
matched browser evidence. Method units now consolidate equip/effect/mastery;
320-pixel views place equip and training side by side. Underlined tabs,
shared reading wash, adjacent preparation/advancement, passive travel and
Foundation attainment replace the repeated cream controls. There is one
practice review control and a smaller Effects link. Gameplay/save source
hashes are unchanged. Latest checks: 73 core, 96 milestone-two and 221 native
presentation assertions passed; final browser results are linked in that note.

## Current structure

- `progression.gd`: the specified realm costs, starter upgrades, mastery,
  expedition duration/rewards and technique/resonance calculations.
- `cultivation_state.gd`: purchases, primary/queued methods, preparation,
  advancement and event-boundary advancement of Qi and expeditions together.
- `cultivation_session.gd`: one clock owner; active monotonic time and capped
  absent wall time. Explicit legacy-rate restore for migrated saves.
- `save_store.gd`: frozen v1 validation, explicit v2 conversion, strict v2
  consistency checks and retained backup/temp/recovery behavior.
- `main.gd`: native controls, two compact illustrated views, lifecycle
  checkpoints, optional details, reduced motion and illustrated rewards.
- `landscape.gd`: independent environment and character/seat plus cheap
  realm arcs. `forest_route.gd` visualizes the existing timer only.

Schema 2 retains the original application name and save path. Migration copies
the source v1 file, preserves old fields/timestamp, starts new systems empty,
and credits legitimate absence at the old rate once. Player saves were never
reset for verification. All tests used isolated paths or browser profiles.

## Visual direction and assets

New cape-and-pouch novice, quieter broad robe washes, coherent terrace/valley,
13 generated matching ink icons and one illustrated forest vignette.
Techniques are selectable emblem tiles with current/queued frames and two
mastery pips; practice summaries retain illustrated access to effects. Costs,
preparation, route progress, rewards and realm badges reflect actual state.
No baked interface screenshot, corner branding or narrative banner in play.

Sources and candid inspection notes: `assets/ART_SOURCES.md`.
Individual icon mapping: `assets/icons/manifest.json`.
Generation directions: `docs/art-direction/milestone-2/PROMPTS.md`.

## Verification evidence

- 73 retained opening/save/clock checks passed.
- 96 milestone-two rule, migration, persistence and timeline checks passed.
- 165 native presentation/state checks passed across all three realms and
  320×640, 430×932 and 1280×800, including initial load, return panels,
  reachability, queued seals, reduced motion and save failure.
- Complete fresh ordinary-speed browser journey passed in approximately
  22 minutes, including stop/restart, mastery, preparation, Foundation,
  delayed resonance and real absence/reload. No acceleration or seeds.
- Final illustrated browser input/render flow uses explicitly labeled
  fixtures for progression and long boundaries. Real pointer, touch drag,
  selection, departure and keyboard detail dismissal are exercised.

Final browser results and screenshots are in
`docs/art-direction/milestone-2/screenshots/`; see its `browser-results.json`
and `normal-browser-results.json`. The delivery note identifies final captures
versus earlier ordinary-run captures. No Android-device result is claimed.

## Run and review boundary

Open Godot 4.7.2 and press F5, or serve `builds/web/` over local HTTP.
Full commands are in the README. Matching custom export templates are
currently in ignored `.verification/templates/`; configure local templates
when moving the project to another machine.

Read `docs/design/MILESTONE_2_PACING.md` before adjusting balance. In the tested
starting states, Iron plus preparation without mastery reaches Foundation
fastest; Azure mastery creates a significant herb bottleneck and surplus Qi.
No tuning was silently applied.

Known limits: generated stylized artwork remains open to human critique;
small screens require bounded scrolling; screen-reader/device accessibility
has not been independently tested; Android Java/SDK and physical-device
verification are unavailable. After Foundation and capped practices, Qi has
no new spending purpose at this intentional milestone boundary.

Next step: review this playable slice’s decisions, pacing and visual clarity.
Do not automatically add realms, combat, gear, crafting, prestige or accounts.
