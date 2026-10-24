# Dao's End — live player-flow and visual audit

Date: 2026-10-24, Asia/Jakarta. Request: personally try the delivered game, judge the confusing/unfinished interface, and prepare a concrete correction prompt.

## What I actually did

Opened the served browser export at `http://127.0.0.1:8765/?v=mobile-density-20261024` in the in-app browser. Used actual pointer/scroll/keyboard input on the Godot canvas. Inspected 430×932, 320×640 and 1280×800; checked the 430×932 DOM/canvas viewport dimensions. This review used DPR approximately 1, not a physical phone or an independently repeated high-DPR test.

Used an existing Foundation state with substantial stored resources; did not seed a new fixture or reset progress. Dismissed the offline summary, examined Retreat, opened Journey → Stone Steps, scrolled to Depart, fought the first encounter at ordinary speed, requested a safe camp, received Crimson Flame, opened Arts and Equipment, then returned to the camp. The review ended at a safe camp. Normal play earned rewards/discovery in that existing state.

This is a focused personal review, not a complete new-player playtest or a full chapter/Core completion. No audio listening, fresh-save onboarding, full pacing run, physical Android test or rerun of the claimed regression/layout suites occurred. Source inspection covered relevant `main.gd`, `chapter_ui.gd`, and `ui_materials.gd` presentation code plus the delivery/pacing reports.

## Evidence captured during this review

- `live-430-route-departure.png`: the scrolled preview where Depart finally appears.
- `live-430-combat.png`: actual first encounter; transient battle state may differ from the initial observed frame because the fight continued normally.
- `live-430-camp.png` and `live-430-camp-final.png`: reward panel and obscured continuation action.
- `live-430-camp-focus.png`: cropped main-panel evidence, not a redesigned mockup.
- `live-430-arts.png`: techniques, slots, raw stats and split training information.
- `live-430-equipment.png`, `live-320-equipment.png`, `live-1280-equipment.png`: equipment at three real viewport sizes.

## Main assessment

The game has actual connected systems now. The unresolved problem is how the interface explains and prioritizes them. It exposes much of the implementation state at once and reuses one scenic/large-paper composition for tasks with very different spatial needs. Generated skins and icons have been integrated, but the assembled interface still reads as an illustrated form rather than a finished cultivation game.

The reported density correction is a technical sizing improvement. It cannot establish that the player knows what to do, can compare options comfortably or sees the important action. Thousands of bounds assertions do not measure those outcomes. This review does not dispute the reported test results; it evaluates a different quality dimension.

## Findings, ordered by impact

### 1. Key actions are reachable but hidden

At 430×932, Stone Steps preview shows its title, reward and successive enemy rows. Depart is below the fold until the player scrolls. After the first fight, the reward tray occupies most of the content area; Build at camp is visible while Continue journey is clipped below the usable area. A sliver of the action skin is not a sufficient next-step cue.

**Correction:** fix the current task's primary action above the bottom navigation. Scroll the optional route/enemy/reward detail independently. At camp, Continue is primary and Build is secondary. Make both visible without scrolling the reward panel.

### 2. The screen shell consumes the decision area

At 430×932 the portrait illustration uses roughly the upper 360 pixels, followed by a large repeated realm/resource block. Equipment and other task content are consequently confined to a short scroll region. At 320×640 the first equipment item consumes most of the remaining meaningful content area. On desktop, the same narrow instrument remains beside a huge decorative portrait rather than using width to help comparison.

**Correction:** make the home sanctuary scenic, but use compact task headers in Build and Explore and a dedicated encounter composition in Battle. Maintain the ink environment without reserving an identical portrait block on every view. Give desktop comparison tasks deliberate width.

### 3. The useful next objective is absent from the hierarchy

Retreat initially shows current and next method effects, mastery, practices and a gathering link. The next effects are presented without enough immediate context, even when no useful change is pending. Huge stored Qi and several currencies do not tell the player whether to gather, prepare, train or travel.

**Correction:** show one factual next goal with a direct action, based on actual unmet progression requirements. Keep the long-term realm objective accessible. Show queued effects only when they differ and explain the actual application boundary.

### 4. Technique selection and improvement are mentally tangled

Arts presents a selected slot, a global Clear control, an HP/attack/armor/focus/resistance summary, a skill entry containing equip destination/mastery/focus/cooldown, then separate cost/potency and Train. The new Crimson Flame is lower in this stack. The user must learn a slot-first selection mode while also distinguishing training from equipping.

**Correction:** show a compact equipped loadout, then skill entries with name, one useful effect and explicit Equip/Replace versus Improve. Prefer direct placement into an empty slot; for replacement, open a clear slot choice. Keep detailed combat math secondary. At discovery, offer Equip in empty slot rather than a generic trip to a busy build menu. Preserve timing/commitment rules.

### 5. Equipment is presented like an unlock catalog

The inspected state had no chapter weapon yet. Equipment nevertheless listed unowned weapons with acquisition text and repeated first-clear assurances. At 320×640 only one substantial item row was readable before the lower edge. The initial screen did not give the same priority to what is equipped, the immediate practical improvement or a useful next route.

**Correction:** default to owned/equipped gear and short comparisons. Use an honest empty state with a direct route to the first known weapon. Put undiscovered gear in a secondary discoveries/catalog view. Keep acquisition information available without repeating the same assurance under every item.

### 6. Visual treatment has materials but little hierarchy

A large blue-edged cream sheet encloses every screen. Another framed tray encloses rewards. Rough jade plaques appear as both important actions and oversized faded Mastered blocks. Small icons vary in visual clarity. Large paper regions and blank spacing make modest content feel cumbersome rather than calm.

**Correction:** define distinct roles for unframed readouts, grouped choices, primary actions and temporary detail surfaces. Simplify the main frame and action artwork where necessary. Use quiet negative space deliberately; do not solve this by adding more textures, frames or icons. Keep ink character while making controls crisp and numbers easy to scan.

### 7. Combat has useful information, displayed as an implementation readout

The encounter visibly progresses and Camp works. The panel also gives trait names, armor/resistance/barrier numbers, enemy HP, player HP/shield, focus/regeneration, skill timing and raw strike/timeout status in a similar textual stack. It is mechanically informative but makes the battle feel more complicated than its immediate decisions.

**Correction:** prioritize the two health states, active technique readiness, a salient hazard and Camp. Put full defense arithmetic behind enemy inspection; keep the hazard's counter understandable. Tie restrained action cues to the real simulation rather than inventing decorative combat.

## What already works and should be retained

Actual automatic combat and discovery rewards exist. Pointer interaction, scrolling, safe camp requests, returning to camp from navigation and real resource changes worked in this sample. Short navigation labels are clearer than an all-icon bar. The core scenery and coherent character can remain useful assets. Settings are already consolidated under Menu. Do not discard those gains or wipe saves to redesign the interface.

## Gameplay length is a separate unresolved issue

The delivery's own `docs/jade-road/PACING.md` reports about 16.82 minutes of combat waiting and 45.15 minutes including retreat waiting for its earned policy. Those are report/simulation findings, not my measured active hours. This chapter does not establish the long-term engagement target. UI refinement should not silently change balance or extend timers to hide that issue.

## Required next result

Implement the companion `docs/design/CODEX_UX_RESET_PROMPT.md`: a real information-architecture and interaction redesign using the existing systems. Acceptance centers on completing useful tasks, visible next actions, meaningful comparisons and coherent rendered composition. Preserve balance/saves/audio and verify the actual browser. Do not claim completion solely from screenshots or layout assertion counts.
