# Dao's End — staged long-form production plan

Created 2026-10-23. Current implementation is the Living Dao release candidate through Nascent Soul. Current evidence and limitations are in `docs/living-dao/DELIVERY.md`; `tasks/living-dao.md` tracks remaining release gates. The Jade Road plan below is retained as historical implementation context. No local Git metadata is present.

## Source of truth

- `DESIGN.md`: established requirements, art direction and evidence limits.
- `docs/design/CONTENT_300H_BLUEPRINT.md`: proposed long-form content and mechanics.
- User-provided `CODEX_MAJOR_UPDATE_PROMPT.md`: current Living Dao boundary through Nascent Soul; older next-content prompts are historical.
- `docs/design/ART_ASSET_PRODUCTION_GUIDE.md` and `AUDIO_PRODUCTION_GUIDE.md`: production deliverables, not optional polish.
- `tasks/living-dao.md`: current implementation and release gates.
- `tasks/todo.md`: preserved Jade Road completion evidence.

## Objective

Build toward 300 engaged hours across a finite campaign and optional completion strands. First establish a substantially richer playable chapter through Golden Core, including illustrated UI materials and audio. This plan does not assert any existing or planned playtime is validated.

## Architecture and dependency order

Inspect and preserve existing progression/state/session/save boundaries. Introduce stable definitions/stat evaluation, then deterministic combat, finite routes, equipment and chapter gates. Presentation consumes state; asset generation does not own calculation. Audio responds to meaningful state/input events and owns separate preferences.

Persistence changes must be explicit migrations before the new state is saved. Combat/reward logic must exist before its interface claims to work. Runtime art is integrated and inspected per feature, not saved for a final cosmetic-only stage. All time advances through one simulation timeline; no second offline resource loop.

Build order:

1. Current-state audit, safe checkpoint and legacy fixtures.
2. Schema/definitions and one playable combat encounter.
3. One finite route with native result/first-clear behavior and a usable illustrated control sample.
4. Four combat techniques and equipment/refinement integrated with route rewards.
5. Remaining routes and optional trials, Foundation-to-Golden-Core progression.
6. New retreat/offline transitions, expanded migration and exploit checks.
7. Completed UI kit, region/guardian/item art and audio, integrated throughout the above steps.
8. Strategy simulation, real ordinary-speed play, browser input/render/audio review and delivery.

If a foundation task reveals the current architecture needs a small refactor, do that focused change and verify it. Do not rebuild the entire project in anticipation of every future realm.

## Checkpoints

**Playable foundation:** one encounter, one route and one first-clear reward persist safely; a real control uses the style sample. Existing tutorial still works.

**Connected chapter:** all techniques/items/routes are real, resources have competing uses, Golden Core is reachable and both focus/guard approaches solve useful problems.

**Presentation complete:** actual scroll/plaque/meter/seal assets are integrated, encounter scenes explain action, audio is selected/licensed/routed, and all screen sizes remain operable.

**Delivery:** focused suites and long-boundary simulations pass; representative ordinary-speed browser play and rendered/audio inspection are reported separately; remaining balance/art/device limitations are explicit.

Checkpoints are verification boundaries, not permission to declare the whole chapter complete after one subtask. The sender's instruction to execute the brief authorizes the specified routine work. Stop only at the chapter boundary or a genuine external blocker, and record exact unfinished tasks.

## Known commands

From the project root, using the actual installed binary if `godot` is not on PATH:

```powershell
godot --headless --path . --script tests/run_tests.gd
godot --headless --path . --script tests/milestone_two.gd
godot --headless --path . --script tests/simulate_pacing.gd
godot --path . --script tests/verify_milestone_two_ui.gd
godot --headless --path . --export-release Web builds/web/index.html
node tests/browser_milestone_two.cjs
```

Add appropriately focused new suites and record their exact commands. Existing presentation fixtures/coordinates must be updated when the UI intentionally changes; preserve the behavior assertions. Do not treat unavailable tools as passed checks.

## Risks and mitigation

| Risk | Mitigation |
|---|---|
| 300-hour ambition becomes timer padding | Treat it as a completion-content budget; observe engagement and report shorter results honestly |
| Content breadth hides identical choices | Author each route's rule/counter/reward; demonstrate useful different builds |
| Offline nerf rewards unattended open clients | Explicit finite journeys and equal-rate visible/closed retreat; no activity policing |
| Generated assets remain inconsistent or unusable | Shared runtime-size style sample, isolated assets, slice specifications, targeted edits and actual integration review |
| Music/SFX do not work on web | Real interaction unlock, actual bus/stream checks, focus/resume and listening verification |
| Existing saves lose progress | Frozen legacy validators, isolated fixtures, one-time refund markers and recoverable snapshots |
| Work expands into an engine rewrite | Small complete feature paths and existing module boundaries |

## Later stages

The next coherent milestone is a gameplay review of this delivered chapter:
reduce Ward/Flame guard dominance, strengthen the limited-focus and mixed
trials, and assess human engagement before adding content. The automated
earned path takes about 45 minutes including 28 minutes of retreat waiting.
Audio listening and physical Android review remain unperformed. Keep these
limits explicit; the roadmap does not prove 300 engaged hours.

After this chapter's gameplay review: inheritance/first law and a few recipes; tested reincarnation; expansion of authored regions and challenges; ascension and completion. These stages need their own concrete numerical/catalog specs and executable prompts. Do not mark their content implemented because this roadmap exists.

No account infrastructure, monetization, multiplayer, mandatory dailies, push or deployment is included.
