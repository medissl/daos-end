# Dao's End — simplify the game interface and finish its visual design

Implement this brief in the existing Godot project. The user finds the current game messy, complicated and visually unfinished. This task requires a real player-flow and composition redesign, not another density fix, border adjustment or additional icon pack. Preserve the implemented game systems, balance and existing saves.

## Read and inspect

Read applicable AGENTS.md, the global DESIGN.md and root project DESIGN.md. Then read `docs/audits/2026-10-24/LIVE_UX_AUDIT.md` and inspect its captured live-game screenshots. Also read the latest Jade Road delivery and icon/text research. Inspect the current source before editing; it may contain newer work from another chat. Check Git state, preserve unrelated changes and create a safe checkpoint. Do not invent Git history where none exists.

The audit actually opened the browser, started Stone Steps, completed its first encounter, requested a safe camp and inspected Arts/Gear at phone and desktop sizes. It found real usability failures despite the reported density and layout checks. Do not reinterpret those findings as a request to increase padding everywhere.

This brief supersedes the earlier fixed composition and separate Arts/Gear navigation when they conflict with the following task-based design. It does not authorize new realms, currencies, combat rules, resource costs or a save reset.

## 1. Give the interface a simpler mental model

Use three primary destinations, with short visible labels:

- **Cultivate:** scenic home, cultivation method, useful retreat summary and next goal.
- **Explore:** locations, route preparation, active journey and camp/encounter results.
- **Build:** equipped techniques and equipment, with clear internal Techniques / Equipment sections.

Keep settings, sound, credits and extended help in Menu. Retain all actual existing functions, but stop exposing every subsection as a separate equally weighted destination. Keep the player's selected destination and current journey recoverable when moving between them. Do not hide an active camp or require restarting a route to find Continue.

Show one state-derived next objective: for example clear Stone Steps, equip a newly earned art, or collect a genuinely missing Core requirement. Use factual rules and actual progression, not invented quests or generic advice. The long-term realm checklist remains available in a secondary view. Do not force a cinematic/tutorial dialogue.

## 2. Use different compositions for different tasks

Cultivate can remain atmospheric with the prominent seated character. Build needs a compact character/status header and useful comparison space. Explore needs region/route information and an obvious departure action. Battle needs the actual encounter scene and readable current combat state. Do not reserve the same large portrait and six-line resource header above every task.

Keep ink landscapes visible through intentional framing and quiet local contrast protection. A protected reading surface is allowed; one enormous framed cream sheet around every view is not the required solution. On desktop, use the available width for loadout/item comparisons rather than an identical narrow phone column beside oversized decorative art.

Main tasks must remain usable at 320×640 without shrinking text or hit targets. Use compact rows, sensible details and independent scrolling. Keep primary actions outside scrolling detail regions and above bottom navigation/safe margins. Do not use a fixed illustration-height percentage across all views.

## 3. Route preview, encounters and camp

The initial route preview should show route name, primary reward, a short useful hazard/counter summary, and one persistent **Depart** action. The four-enemy list and defense arithmetic are expandable inspection information. Players must not scroll through four enemy descriptions to find Depart. Do not fabricate a recommended power score or victory prediction without a real calculation.

During combat, prioritize enemy/player HP, visible skill readiness, one salient current threat and **Camp**. Full armor/resistance/barrier numbers live in enemy inspection unless immediately relevant. Keep essential hazard/counter meaning available without a wall of formulas. Show restrained real attack/skill/reward cues; no new battle simulation or decorative fake actions.

At safe camp, use a compact reward band and discovery item treatment rather than a large nested reward frame. **Continue journey** is the persistent primary action, **Adjust build** is secondary, and Return to cultivate is a clearly quieter option. None requires scrolling past rewards. For a newly discovered combat art, offer an explicit Equip into empty slot action when available; if replacing, show the target slot. Preserve legal commitment boundaries and keep equip separate from spending.

After finishing a route, offer the next relevant route or return choice. Do not retain a disabled Continue as if it were the next task. Do not reset scroll unpredictably or overlay feedback on primary controls.

## 4. Build without a wall of controls

Show the current equipped skills first as a small loadout with readable names, order and empty-slot affordances. Selecting a known art offers **Equip** directly into a suitable empty slot. If replacement is needed, let the player choose explicitly. Do not require an unexplained hidden global slot-selection mode. Keep reorder and remove accessible but secondary; a global Clear control should not compete with the main task.

Each technique row needs an emblem, short name, one concise mechanical role, equipped/queued state and access to Improve. Show current mastery, exact price and before/after result in the improvement context. Keep Equip/Replace, Improve and Details visually and behaviorally distinct. Retain meaningful comparisons without placing focus cost, cooldown, mastery code, destination, potency, training cost and full stat math in one compressed line.

Use plain labels in the main UI: avoid unexplained `M0/2`, `Now`, `Next` and ambiguous Clear. When an effect is pending, say when it actually applies (next encounter versus next gathering departure). Hide duplicate current/next summaries when no change exists. Keep exact numbers where the player is deciding, with consistent units and precision.

Equipment defaults to **owned and equipped** items. Display the three equipped slots and useful replacement comparisons. In an empty inventory, give a concise empty state and a direct path to the first known item; do not display a long unowned catalog as if it were usable inventory. A Discover equipment view can show acquisition sources separately.

Show meaningful item effects before Equip, and show actual refinement costs/results in a dedicated small comparison/detail area. Do not repeat `first-clear reward · no random drops` under every item. Preserve all existing item definitions, costs, refunds, locked items and acquisition history.

## 5. Finish the visual language

Use a coherent restrained Chinese line-and-wash game style. Keep good character, landscape, icon and audio assets. Improve the assembled interface before commissioning/generating more unrelated art.

Establish distinct visual roles:

- Readouts: crisp typography, consistent alignment and local background protection, usually without their own border.
- Choices: illustrated technique/item identity, clear selected/queued states and a quiet coherent grouping.
- Primary actions: one deliberate jade/ink plaque treatment with comfortable blank center, clean silhouette and precise text padding.
- Secondary actions: simpler readable controls with obvious interaction/focus, not a competing heavy plaque.
- Details/rewards: bounded protected surfaces used where they focus attention, without a second ornate frame inside the main frame.

Replace or edit the current main-panel/action skins if needed. The dark smudged plaque and faded oversized Mastered blocks are not obligatory branding. Mastered/completed is a small state, not a giant disabled action. Reduce decorative edges that look like application-window chrome. Do not solve this by recoloring the same layout or adding paper noise to everything.

Use generation for specific usable replacements only: a shared paper-edge skin, a cleaner jade plaque, consistent state marks, or a clearer ambiguous icon. Follow image-generation skills, shared references, transparency and nine-slice constraints. No baked text/costs, cropped screenshot interfaces, fake symbols, oversized new art catalog or universal text/icon percentage. Keep short navigation/action labels, readable numbers and optional deeper explanations.

Keep existing fonts if they serve the new hierarchy, but apply them deliberately: restrained display lettering for identity, highly legible functional labels/numbers, consistent baselines and line spacing. A font swap alone does not meet this brief. Respect reduced motion, focus visibility, contrast and the density correction. Existing audio settings and routing remain intact.

## 6. Implement a complete slice of the new flow before scaling

First integrate the full route-preview → battle → camp → equip discovery → continue flow with its real native controls and real game state. Review its actual rendered output at 320×640 and 430×932. Refine it, then apply the same system to Cultivate, Equipment, Core requirements, results and desktop. Do not stop at a style sample or show only the best-looking idle scene.

Prefer focused changes to `main.gd`, `chapter_ui.gd`, reusable presentation helpers and UI assets. Keep calculation/state/session/save providers stable. Do not introduce a navigation framework or rewrite the entire game to create three destinations. Preserve current progress and use isolated test profiles for verification.

## 7. Acceptance is task completion and actual rendered clarity

Verify these real tasks without opening general Help:

1. Identify current goal and how to start it.
2. Open Stone Steps and use Depart without scrolling the enemy list.
3. Request Camp, understand the reward, and see Continue/Adjust build without scrolling rewards.
4. Equip the new Flame art into the empty slot without accidentally training or clearing another slot.
5. Identify equipped gear, compare one owned replacement and understand its refinement cost.
6. Return from Build to the paused journey and continue safely.

Record taps/scrolls, ambiguity and unnecessary detours; correct the major failures. Do not claim a human novice study unless people other than the implementing agent performed it. A fixture-based functional walkthrough is useful, but label it accurately.

Run existing relevant regression suites. Update layout tests for the intentional new composition while preserving behavior assertions. Do not make tests pass by hiding required prices, removing essential affordances or seeding away the empty state. Verify no purchase on drag, no double rewards, legal camp/queue behavior, settings persistence and no progression/save changes.

Inspect actual exported browser output at 320×640, 390×844, 430×932 and 1280×800, including the real high-DPR paths already supported. Verify initial load, resizing, visible actions, safe margins, touch/keyboard input and readable unavailable states. Android-device and listening evidence remain separate from browser emulation.

Deliver comparable before/after screenshots of Cultivate, route preview, battle, camp, Techniques, Equipment and the realm checklist. Include the exact routes/actions tested, regressions run, changed asset provenance and remaining defects. A large layout-check count is not the design acceptance statement.

Do not add content, nerf/extend timers, change balance, reset saves, push or deploy during this pass. The current approximately 45-minute including-waiting chapter and long-term content ambition remain separate design work. Complete this substantial UX/visual redesign, then stop for review.
