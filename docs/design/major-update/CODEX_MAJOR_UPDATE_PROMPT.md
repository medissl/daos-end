# Send to the implementation Codex: The Living Dao update

You are implementing a substantial playable update to Dao's End. The user rejects the current static, button-heavy experience despite passing regression/layout checks. Deliver a connected content expansion and a coherent animated game presentation. Do not stop at research, mockups, a design document, a new font or a reskin of the same forms.

## Start from the actual project

Read applicable AGENTS.md, the global `~/.codex/DESIGN.md`, root `DESIGN.md`, latest source, current task status and these documents:

- `docs/design/major-update/INTERACTION_REVIEW.md`
- `docs/design/major-update/FUN_AND_PROGRESSION_RESEARCH.md`
- `docs/design/major-update/MOTION_AND_ASSET_RESEARCH.md`
- `docs/ux-reset/DELIVERY.md` and `docs/jade-road/PACING.md`
- Existing art/audio production guides, source manifests and save migration tests.

Research notes contain source findings and proposed adaptations. The implementation scope below resolves their proposals for this milestone. Earlier 300-hour catalogs remain future planning, not a demand to implement all systems now. Update project design/status records with final decisions; preserve existing completed-task evidence.

Inspect Git state. If metadata is absent, say so and use safe local file checkpoints; do not initialize a replacement repository. Keep Godot/GDScript, deterministic simulation, centralized state and existing persistence. This is not permission for an engine migration or unrelated architecture rewrite. Do not erase player saves, push, deploy or purchase assets.

The user authorizes image generation/editing for actual character pieces, scenery layers, icons, effect art and appropriate UI materials, and downloading free compatible art/audio with recorded licenses. Use applicable installed skills. Generate, integrate and inspect assets when needed; do not hand back prompts for the user to run. Paid licenses need separate authorization. Keep source files and provenance in the project.

## Product contract

The experience is: choose an interesting goal, prepare a small build, see the cultivator undertake a living illustrated journey, discover a useful interaction, and earn a visibly changed realm. Ordinary administration should happen automatically. The game stays peaceful and readable between meaningful encounters.

Retain Chinese ink contours, mineral jade/blue-grey washes, warm paper and restrained cinnabar. Contemporary responsiveness, deliberate motion and strong composition belong within this identity. Do not interpret professional as neon, glossy gold, a dashboard, tiny text, or a dense mobile gacha lobby.

Keep Cultivate / Explore / Build as the primary destinations. Add depth inside the existing surfaces, not more permanent navigation tabs. Make all shipped content use the same interaction and visual language.

## Work sequence and completion boundary

Implement the following four phases, keeping a playable build at each checkpoint. Inspect a representative slice before multiplying assets. Routine implementation decisions are yours; do not stop to request approval already granted by this brief. If a tool or asset pipeline fails, choose a viable scoped alternative and disclose it. Do not label a required missing feature complete.

### Phase 1 — remove chores and repair the underlying choices

1. **Inventory every visible action.** Record whether it makes a decision, spends something, navigates, or merely acknowledges a result. Delete redundant acknowledgements and duplicate navigation. Keep exact effects/costs available before commitment. Do not just rename buttons, replace all words with icons, or hide the same work behind extra sheets.
2. **Continuous journeys.** Preserve existing automatic progression between ordinary nodes. Credit ordinary rewards and discovered arts/items once without stopping play. Show a short nonblocking discovery strip and retain discoveries in Build. Pause for requested camp, an actual new branch/constraint decision, defeat, or route completion. Existing trial stages with no new decision should transition automatically as well. Never auto-replace a nonempty equipment/technique slot. A requested camp must reliably stop at the next safe boundary.
3. **Direct tasks.** Route selection and its meaningful preview belong in one composition; remove a separate View route step where it adds no information. One Depart starts the displayed route. On route completion, show a compact summary in place, with the next meaningful destination available. No Claim → Confirm → Return sequence. The player need not immediately acknowledge a discovery to keep earning already authorized rewards.
4. **One object, one management sheet.** A technique/item row shows illustration, name, role and current/equipped state. Selecting it opens a single sheet with exact effect, slot/replacement selection, free Equip and an improvement action with precise cost/outcome. Merge redundant global Details/Discover controls into relevant collection/filter/help affordances. Do not remove item comparison or make an Equip tap secretly purchase refinement.
5. **Safe presets.** Save/restore method, ordered arts, equipped gear and law together where unlocked. Restore only owned/legal selections; explain omissions. No universal auto-equip based on a misleading power score. Auto-fill an empty slot only through a visible opt-in policy; otherwise let the player equip deliberately.
6. **Mastered supply assignment.** After clearing a route, allow one explicitly selected background supply assignment, using the existing 30% retreat speed and eight-hour credited absence cap, identical open/closed. It supplies ordinary eligible resources, never first-clear rewards, new frontier clears or unique seals. Reuse deterministic encounter/retreat calculations; provide exact stop/defeat handling and prevent double-counting with an active journey. Prefer a single exclusive activity model over two concurrent reward engines. Define event-boundary accounting before code. No repeated Claim or Depart is needed for the selected solved work. No charged consumables are silently repeated. This is a targeted change to the old no-repeat policy, requiring explicit save migration and documented economy comparisons.
7. **Fix current build dominance and dead waiting.** Use the existing Ward/Flame dominance and Core funding gap as starting evidence. Adjust threat timings, conditional technique behavior, first-clear funding and costs together. At least offense, protection and recovery must each have an understandable useful niche. Do not make defense useless, give every enemy immunity, or inflate HP/timers to force new tools. Preserve earned wealth. Present a short useful defeat reason and one available counter, not the combat log.

Phase acceptance: an ordinary unbranched authorized route plays through without mandatory intermediate taps. A new discovery credits safely without stopping it. Camp, replacement, spending and defeat remain deliberate. Show earned-state comparisons and measured click paths; a smaller button count alone is insufficient.

### Phase 2 — create and integrate a moving visual production sample

Build one polished sanctuary → departure → encounter → discovery → return sequence before expanding the new chapter. This sample is production code/assets, not a video laid over a noninteractive game.

**Character:** use one approved identity with aligned transparent parts and painted overlap. A modest cutout rig is appropriate. Keep the seat/ground contact fixed; animate breathing through torso/cloth response, hair and sleeve lag. Include a deliberate technique gesture and anticipation/impact/recovery. Hands and anatomy remain coherent. Whole-image bobbing, stretching a face, flashing an aura or sliding an item icon alone does not satisfy this requirement. Fixed anatomy plus well-painted cloth animation is preferable to a broken puppet. Use occasional cel variants where they improve a gesture.

**Combat:** the cultivator visibly acts and the guardian visibly anticipates, receives, blocks or releases a recognizable attack. Sword, flame, protection and cleanse have distinct effects tied to actual events. Enemy HP, player HP, imminent threat and equipped-ability readiness form a compact HUD. Add a status/focus detail only when relevant; do not turn telemetry into the main scene. No tapping each attack, QTE, or compulsory manual defense.

**Places:** separate near/far scenery and purposeful atmosphere. Mountain mist/cloud drift, river surface/reeds, tomb dust/lamps and storm wind should feel like different places. Avoid a universal particle cloud over every background. Use tightly bounded layers, selective effects and coherent ink density. Character and guardian scale, seat/contact, foreground and light direction must fit the location.

**Continuity:** immediate pressed response; short interruptible destination transitions; a legible departure/arrival; readable reward settlement; a special breakthrough sequence. Starting timing ranges: 70–120 ms press response, 160–220 ms navigation, 300–600 ms encounter handoff, 1.5–2.5 s skippable major breakthrough. Tune in context; these are design starting points, not scientific limits. Repeated actions must not wait through full-screen ink wipes. Cancel/replace an interrupted transition cleanly. Commit gameplay state independently of animation completion, so skip/reload/reduced motion cannot duplicate or lose a reward.

**Realm identity:** ship a coherent progression sheet and runtime treatments for Mortal, Qi Refining, Foundation, Golden Core and this update's Nascent Soul. Keep the same person. Mortal uses modest cloth/no supernatural display; Qi has inward breath strokes; Foundation gets a stable formation/robe-detail change; Golden Core gets an identifiable costume/ornament silhouette change and localized core response; Nascent Soul gets a deliberate pose/garment variant with a restrained spirit echo. Major variants must be visibly distinguishable at normal phone size after the celebration ends. Tie them to attained realm, not current Qi balance. Spending Qi must not strip the character's earned appearance.

**UI:** compose around the scene and task. Replace repetitive pale full-width rectangles with a clear hierarchy: one primary commitment, direct selection on objects, and quiet secondary actions. Do not frame every line or wrap an entire control list in ornate scroll art. Protect text locally where scenery is busy. Keep labels readable in selected, disabled, focus and pressed states. Fix the very pale selected navigation treatment observed in the live Build/Cultivate review.

As review targets, keep an ordinary task to one clear primary action and at most two visible contextual secondary actions, excluding the three main destinations. Inventory selections naturally differ; this is not a universal three-button law. Keep core threat/reward descriptions to one or two short lines, with optional fuller detail. Rewrite copy before layout; never solve overflow by cropping critical requirements/costs, shrinking targets, reducing contrast or showing an unexplained icon. Do not leave a giant empty panel while combat information is crowded elsewhere.

**Sound:** preserve the working audio controls/unlock/crossfades, then audition and improve the mix. Distinct dry press/confirm cues, readable attack/block/cleanse/impact sounds, restrained breakthrough sound, location ambience and optional music should agree with the visual timing. Keep the saved mute/music preference. No idle-tick sound spam. Download appropriate free licensed replacements if the current material fails; document the exact asset/license, not a site's general license statement.

Separate frame-paced visual animation from the existing 0.1-second UI refresh and deterministic simulation. Do not rebuild all labels at display refresh rate. Cache textures outside drawing paths. Extend reduced motion across character, scenery, navigation and combat; retain static telegraphs and realm distinction.

Phase acceptance: inspect real runtime motion at phone and desktop sizes, clean cutout seams/alpha, coherent anatomy, grounded contact, distinguishable actions, interruptible input, reduced motion and actual listening. Produce a short native-speed motion reel and stills. Fix the sample before scaling it.

### Phase 3 — a connected new chapter: Golden Core to Nascent Soul

Author **three new illustrated regions, two distinct four-encounter routes per region: 24 new encounter definitions including six finales**. Reusing a creature family is reasonable; recoloring the same fight is not a new problem. Bring existing regions up to the approved presentation standard too.

Use the proposed interactions in `FUN_AND_PROGRESSION_RESEARCH.md` as seeds:

| Region | Encounter identity | New combat art | Useful relationship |
|---|---|---|---|
| Thunder Peak | Telegraphs, charged attacks and pressure between charges | Thunder Step: bounded interrupt at a focus/cooldown cost | Interrupt offense versus protection that survives a charge |
| Ancient Tomb | Barriers, vulnerable windows and direct-hit reflection | Returning Blade: bounded focus refund on an actual barrier break | Sword/barrier timing versus indirect burn against reflection |
| Moon Lake | Alternating defenses; a disclosed endurance route with limited recovery | Mirror Counter: smaller temporary shield plus one eligible retaliation | Counter timing versus cleanse/recovery under prolonged pressure |

Add six curated gear pieces within the existing three slots, each tied to a named route and interaction. Add **three reversible law augments**, one equipped at a time: Earth rewards protecting a charged hit; Fire rewards Sword/burn combinations; Water rewards a real cleanse with short protection. Switching safely is free. Apply strict per-event caps to prevent infinite focus, repeated damage callbacks or DOT refund loops.

Add **three optional departure preparations**, targeting storm protection, tomb pressure and endurance recovery. Use existing resources where possible. Select one directly in departure preparation with exact effect/cost and explicit consumption timing; do not create craft → claim → equip chores. Essential progress must have a viable path without rare drops or repeated consumable use. Safely refund a reserved preparation if departure is cancelled before consumption.

Author **six distinct inheritance challenges** and **one Nascent Soul tribulation**. Examples of objectives: answer a charged attack through two viable methods; exploit a barrier break while conserving focus; manage cleansing over an endurance sequence. They unlock/teach behavior rather than ask lore questions. Show the objective succinctly in play. At least two available approaches must solve each mandatory problem. A required tool must have a guaranteed reachable acquisition path before its gate.

Before balancing acceptance, write the actual content table: IDs/unlocks, HP/damage/armor/cadences, trait timing, focus/cooldowns, skill priorities, law caps, item effects/refine bounds, reward and first-clear amounts, preparation prices/consumption/refunds, and realm requirements. Implement those values in data. Names without rules, prices or reachability are unfinished content. Keep choices small in the UI even when the data is richer.

Nascent Soul must unlock an earned capability and persistent visual change, then provide a coherent chapter ending and optional mastery objectives. Do not add an inert reincarnation button. The earlier plan's reincarnation/late realms remain a separately specified later update; carry them forward explicitly rather than claiming completion.

Rebalance first-clear Qi, refinement and advancement so a demonstrated solution is not followed by a long featureless resource wait. Target a few satisfying sessions with genuine experimentation; measure the result. Do not promise a duration before observation. **300 active hours remains a long-term goal, not this release's acceptance claim.** More clicking, longer combat, impossible drops and an open-tab requirement cannot satisfy it.

Phase acceptance: earned-state reachability from an old Golden Core save and a fresh run; all new rewards used in meaningful interactions; varied solutions; finite safe journeys; no mandatory rare drops; ordinary-speed browser samples and honest pacing evidence separating experimentation, administration, combat watching, foreground waiting and offline time.

### Phase 4 — finish the release candidate, not just the feature list

Review every shipped screen with new, developed and long-value saves. Remove obsolete development prose, repeated state explanations, duplicated headings, irrelevant counters and unused controls. Retain context-specific costs and tradeoffs. The return summary should show what was earned and the next useful opportunity; policy/formula detail belongs in one secondary explanation.

Verify fresh start, old-save migration, corrupted-save recovery, repeated load, hidden-tab/resume, clock changes, capped absence, active versus closed supply accounting, cancel/refund, interrupted transitions, reward deduplication, defeat, safe retreat, queued build application, presets and attained visuals. Never spend/award from animation callbacks. Test double taps and rapid navigation while effects play.

Inspect 320×640, 390×844, 430×932 and 1280×800; actual phone DPR contexts including 3; touch scroll, keyboard focus, safe insets and resizing during a transition. No clipped essential text, selected-label disappearance, decorative input interception or inaccessible sheet close. Screenshots alone cannot verify motion.

Measure exported-web load, decoded texture memory, frame-time distribution, transition spikes and memory/node growth after repeated journeys. Aim for smooth 60 Hz on the documented desktop and stable 30 Hz on a representative ordinary Android device. Report actual device/build/DPR and measurements. Emulation does not prove Android performance. If no physical device is available, label that release check unverified and do not claim Android-ready.

Complete an audible review; confirm browser gesture unlock, saved settings, loops, crossfades and attack/impact timing. Include credits/licenses, usable settings, save/export recovery where supported, a clear end-of-content state and no broken links. Run relevant existing tests plus focused new state/integration tests. Hundreds of layout checks are not a replacement for looking at and playing the result.

Arrange short uncoached human sessions when available: can players identify the next goal, make one deliberate build improvement, recognize its combat effect, and name a moment they enjoyed? Track confusion and dull stretches. Do not fabricate testers or use an implementing agent's run as a novice study. If no human test occurs, report that gap explicitly. A clean automated run is not proof of fun.

## Delivery

Return a playable local build, concise before/after gallery, short motion reel, new content map, real balance/earned-route results, frame/audio evidence, asset provenance and remaining issues. Update DESIGN.md and task/status records to reflect actual implementation. Clearly distinguish passed release checks from unavailable ones.

Complete all feasible authorized phases. If a release gate remains unavailable, deliver the concrete candidate and a bounded remaining-check list. Call it a release candidate pending those checks; do not declare the game publishable because it exports. Do not substitute another documentation-only pass, one PNG replacement, more text, or a larger assertion count for the requested experience.
