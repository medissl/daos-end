# Implement Dao's End: The Jade Road

You are the implementing Codex chat. This is authorization for a substantial connected content expansion, a usable illustrated UI kit, and music/ambience/SFX. Complete working results, not just a plan, another border cleanup or a generated mockup.

The long-term target is **300 hours of active play**. The user explicitly means engaged play, not offline account age. This chapter is the first production slice toward that target, not a claim to finish 300 active hours in one session. Build verified slices and preserve a clear continuation plan.

## Required context

Read applicable AGENTS.md, the global `~/.codex/DESIGN.md`, then:

1. Root `DESIGN.md` — product/art direction and status.
2. `docs/design/CONTENT_300H_BLUEPRINT.md` — long-term systems and content envelope.
3. `docs/design/ART_ASSET_PRODUCTION_GUIDE.md`.
4. `docs/design/AUDIO_PRODUCTION_GUIDE.md`.
5. `docs/design/MILESTONE_2_PACING.md` — existing dominance/surplus-Qi problem.
6. `tasks/plan.md` and `tasks/todo.md` — build sequence and verification.

Research notes are references, not mandatory novel reading. Current source is authoritative. Inspect Git state, actual game, latest UI finish changes and test commands first. Do not overwrite another session's work. No local Git metadata was present during design inspection; do not claim a checkpoint commit or GitHub synchronization unless verified.

This brief supersedes old restrictions to styling-only or no combat/equipment. It authorizes the features below, not every future system in the blueprint. Preserve old saves and the current game while extending it.

## 1. Deliver a real chapter

Expand from Foundation to Golden Core. Add two regions, **Misty Mountain** and **Spirit River**, with three finite four-encounter routes each: **24 authored encounter nodes**, not 24 renamed progress bars. Bamboo Forest remains gathering. Aim for a first chapter containing several hours of engaged exploration/build experimentation; optional challenges extend it. Treat estimates as targets and report actual play duration without inflating timers.

Six routes:

| Region/route | Encounter sequence | Finale behavior |
|---|---|---|
| Misty / Stone Steps | scout, plated, channeler, Stone Gate Guardian | Armor plus telegraphed burst |
| Misty / Cloud Bridge | warded, plated, mist-veiled, Cloud Sentry | Barrier layers plus phased defense |
| Misty / Hermit's Cleft | thorned, warded, channeler, Cleft Keeper | Reflection plus protection |
| River / Reed Shallows | scout, venomous, healer, Reed Guardian | Poison plus recovery |
| River / Broken Ford | plated, venomous, channeler, Ford Watcher | Burst plus poison |
| River / Lotus Pools | warded, mist-veiled, healer, Lotus Warden | Barrier plus recovery |

Author concrete stats/rewards and descriptions for these stable IDs in configurable data. Reuse eight understandable archetypes; final encounters combine traits. Scout teaches baseline; plated rewards alternate damage; warded loses barrier layers per hit; thorned reflects direct hits but not DOT ticks; venomous applies a cleanseable DOT; channeler telegraphs a burst; healer restores periodically; mist-veiled alternates protected intervals. Bound every effect. No unexplained immunity or unavoidable permanent loss.

Unlock Misty at Foundation; unlock River after one Misty route finale. The player selects a route, reviews hazards/rewards, prepares a build, and starts a finite journey. Encounters proceed automatically; stop at route end or before an unchosen branch. Safe camps permit free build changes. Defeat ends the current attempt with a concise reason, retaining long-term progress and previously earned node rewards. No repeated tapping, mandatory reaction controls or novel-style log.

Ordinary encounters should resolve in roughly 15–45 seconds and bosses in 45–90 seconds when reasonably prepared. These are provisional readability targets, not timers to fill. Never inflate HP solely to fill the active-hours estimate.

Add six short optional illustrated trials using different constraints: ward-breaking, poison survival, burst defense, limited focus, reflected damage, and a mixed sequence. Define a distinct objective and reliable reward for each. Do not represent six recolored opponents as six unique problems.

Golden Core requires **75,000 Qi**, **3 Core Seals** from distinct first-clear route finales, at least two route completions in each new region, and victory in a separate Core Trial. Seals are guaranteed, one per distinct finale. Optional preparation spends **24 herbs** to reduce incoming Core Trial damage by 10%; it does not replace skill/gear preparation or the seals. Present all requirements before commitment. Production realm multiplier becomes 8. Golden Core unlocks a third combat skill slot and a free loadout preset. Stop content there for this chapter; future realms remain design scope.

## 2. Small deterministic combat and real builds

Use automatic timed actions with two ordered combat slots at Foundation. A basic strike occurs when available; skills use focus and cooldowns. No RNG is required for this slice. Keep simulation independent of rendering and deterministic across time-step sizes. Show temporary HP, shield, focus, skill readiness, enemy traits and visible action feedback.

Starting combat numbers: HP = 30 × realm multiplier, attack = 3 × multiplier, armor = floor(log2(multiplier)), focus cap 10, starting focus 5, base recovery 0.5 focus/s. Basic strike: 1 × attack every 2 seconds. Allow at most one selected skill action per second; order determines eligible skill priority. No cost/cooldown is spent on an ineligible action. Prevent simultaneous event ordering from changing results.

Physical hit = max(1, raw damage - armor), then shield absorption. Magical/DOT damage uses an explicit displayed resistance capped at 50%; do not invent crit/dodge randomness. State when DOTs tick, refresh or expire. All healing is capped by maximum HP, shields do not stack without a defined limit, and a 90-second timeout safely ends a failed attempt.

There are **six total techniques** in this chapter: existing Azure and Iron plus:

| Combat art | Starting behavior | Cost/cooldown |
|---|---|---|
| Flowing Sword | Two physical hits, each 0.8 × attack | 3 focus / 6s |
| Crimson Flame | 0.6 × attack magic hit, then 0.4 × attack magic damage each second for 4s; refresh, no stacking | 4 focus / 8s |
| Jade Ward | Shield worth 30% maximum HP for up to 6s; replace weaker remainder, do not add indefinitely | 3 focus / 10s |
| River Confluence | Remove damaging poison/burn effects and heal 20% maximum HP | 3 focus / 10s |

Flowing Sword is known at Foundation. Earn Flame on the first Misty node, Ward from the first Misty finale, and River Confluence on the first River node. All are deterministic acquisition paths. Their mastery levels 1/2 cost 1,000 Qi + 4 herbs / 3,000 Qi + 8 herbs; increase potency 15% per level, not cooldown speed. Keep this limited and documented.

Retain existing Azure Qi and Iron herb effects. Add combat roles: Azure contributes +0.5 focus/s, plus +0.125 per mastery; Iron contributes +25% maximum HP, plus +5 percentage points per mastery. Existing Foundation resonance halves the inactive method's contributions. Snapshot combat equipment/methods at attempt start; queued changes apply at the next safe boundary, not mid-hit.

Explicitly reduce Azure's existing herb-only mastery costs to 4 and 8 herbs. Keep Iron at 8 and 16. Credit migrated players the difference already spent on Azure (4 herbs at mastery 1, 12 at mastery 2), once. Do not rebalance by deleting resources. The added focus role, cheaper mastery and useful Qi refinement must be tested against actual encounters rather than declared balanced.

These numbers are starting configuration. Tune enemy stats and, when evidence requires it, the new chapter's provisional costs/coefficients to ensure at least a focus-heavy and a guard-heavy route work. Record exact changes and reasons. Preserve old formulas except the explicitly authorized new behavior; do not weaken assertions to hide a regression.

## 3. Nine useful equipment items and a Qi sink

Three slots: weapon, robe, artifact. Fixed named items, no random affix system. Author first-clear rewards for the six routes and six optional trials so every item has a discoverable deterministic path. First-time equipment cannot be lost through defeat. Item details show the slot, effect and acquisition source.

| Item | Base effect before refinement |
|---|---|
| Pinewood Sword | +3 attack; Flowing Sword potency +10% |
| Cinnabar Blade | +2 attack; Flame DOT duration +1s |
| River Needle | +2 attack; direct physical hits ignore 2 armor |
| Traveller's Robe | +30 HP |
| Stoneweave Robe | +15 HP and +2 armor |
| River Silk | +15 HP; incoming DOT damage reduced 50% |
| Jade Pendant | +5 HP; +0.25 focus/s |
| Mystic Gourd | +10 HP; healing received +25% |
| Beast Bone Ring | +1 attack; shields granted +25% |

Introduce **Spirit Stones**, with visible deterministic encounter rewards. Refinement levels 1–3 cost 2,500/7,500/22,500 Qi and 15/30/60 stones. Increase the item's flat stat contributions by 20% per level (1 + 0.2 × level); named secondary effects do not also compound. Preview the real before/after result. Show herb/Qi tradeoffs clearly. No salvage, item rarity ladder or inventory-grid framework yet.

## 4. Retreat/offline model and persistence

Follow the blueprint's explicit modes. Keep the existing Mortal-to-Foundation tutorial timeline for this slice. At Foundation, new **Retreat** production/farming runs at 30% ordinary simulation speed whether visible or closed. A player-started finite **Journey** runs at full ordinary speed in the foreground, stops at its boundary, and cannot repeat frontier content unattended.

Offline uses the eight-hour wall cap × 0.3 effective simulation. It may resolve the already-authorized finite segment, then fall back to authorized retreat farming; it never picks a new branch/route, upgrades, resets or advances. Show effective rates, retain partial progress and checkpoint all rewards once. Do not detect attention via arbitrary clicking, add energy systems, or reward merely keeping the tab visible. A user can walk away from one finite journey; do not count that as active engagement.

Introduce a documented schema migration from existing v1/v2 saves to the next schema. Preserve current resources, realms, practices, mastery, equipment availability and prior earned progress. Set new systems to safe defaults; give legacy first-clear/gear history no invented completions. Honor legitimate pre-update absence once at its recorded policy before activating the new model. Apply the Azure refund exactly once. Keep recovery/backup/temp guarantees and isolated test fixtures. Do not reset real saves.

## 5. Generate and integrate actual interface artwork

Follow DESIGN.md and the asset guide. The user authorizes generating artwork **for buttons, frames, scrolls and interface objects**, not just background and icons. Produce a small shared kit: usable methods-scroll skin, dark jade action plaque, progress track/fill/end pieces, selection/preparation seals, mastery sockets and a quiet reward tray. Use textured/nine-slice assets with defined margins and clean transparent edges. Preserve ornaments outside stretched centers.

Reuse good existing art and icons. Add the four combat symbols, nine item icons, Core Seal, Spirit Stone, actual region/guardian art and the effects this chapter uses. Use one style reference, deliberate contours and broad washes. No unrelated generated styles, fake lettering, baked prices, screenshot-cropped controls, generic web boxes with a grain overlay or full-screen ornamental clutter.

All text and counters remain native Godot controls. Use images to communicate identity, place, action and state; retain short labels for unfamiliar concepts, exact costs and concise effects. Keep technique comparison readable on a phone. Separate equipment/select/train interactions so tapping art cannot accidentally spend resources. No text adventure log or all-icon mystery navigation.

Persistent Golden Core presentation must visibly differ from Foundation: localized core light plus one consistent robe/ornament enhancement and a new badge. Preserve character identity. Integrate actual encounter action, rewards and a short breakthrough sequence. Keep effects lightweight and reduced-motion safe.

## 6. Music, ambience and SFX — internet downloads authorized

Download suitable free licensed audio from primary creators/distributors; follow the audio guide. You may also download suitable licensed visual assets when they fit the art direction. No repeated permission is needed for these downloads. Record exact source, creator, license and credits. Do not extract music/art from commercial games or assume any website's whole catalog has one license.

Deliver a calm retreat music loop and compatible journey music, restrained mountain/river ambience, and coherent short UI, combat, collection, discovery and breakthrough sounds. Audition and edit selected assets; do not merely attach unrelated files. No sound on every Qi tick, constant battle cacophony, harsh beeps or placeholder tones sold as final music.

Provide persisted Master/Music/Ambience/SFX controls and mute. Unlock web playback after a real user gesture, prevent overlapping duplicate loops on reload/focus, rate-limit effects and test actual bus routing in the exported browser. Listen when tools allow; report an unperformed listening test explicitly. Screenshots and event assertions are not proof of audible quality.

## 7. Implementation, verification and delivery

Work through `tasks/plan.md` in connected vertical slices. Preserve a playable build between checkpoints. Extend the existing stat/state/session/save/presentation boundaries with small focused modules, not a speculative engine rewrite. Keep data and stable IDs separate from art/display names.

Known commands from the current project, when `godot` and Node are available:

    godot --headless --path . --script tests/run_tests.gd
    godot --headless --path . --script tests/milestone_two.gd
    godot --headless --path . --script tests/simulate_pacing.gd
    godot --path . --script tests/verify_milestone_two_ui.gd
    godot --headless --path . --export-release Web builds/web/index.html
    node tests/browser_milestone_two.cjs

Detect actual binary paths/presets and add focused new checks; do not claim these commands ran if unavailable. New tests must cover combat event ordering, cooldown/focus bounds, effects, equipment/refinement, deterministic first clears, progression, no reload-farmed rewards, migrations/refunds, active/offline transitions, cap/partial progress, defeat and safe route changes.

Simulate focus-heavy, guard-heavy and mixed policies plus a naive policy. Demonstrate that Azure and Iron each change a useful outcome and that refinement is worth its cost somewhere. Compare journey-active, retreat-visible, retreat-closed and overnight-return strategies. Keep foreground waiting distinct from engaged play. Record content that is practically dominated, too repetitive or unreachable; do not conceal it behind a duration estimate.

Exercise the real browser at 320×640, 430×932 and 1280×800: opening, methods, combat, equipment, routes, preparation, Golden Core, rewards, audio settings, focus/return and reload. Use actual pointer/touch-style interaction and keyboard focus. Verify a representative ordinary-speed journey; fixtures/simulation may cover long boundaries but must be labeled. Capture rendered before/after images and refine conspicuous defects.

Deliver working run/build instructions, final source/content manifest, actual rendered screenshots, audio provenance and listening evidence, checks run, strategy comparison, migration evidence, measured play observations and remaining limits. Record next chapter work in the plan. Do not say the game now has 300 active hours because the roadmap or a simulation reaches that number.

Do not add further regions, alchemy, laws, prestige, parties, gacha, accounts or online infrastructure during this slice. Those are staged future scope. Complete this actual chapter with its interface and audio, then stop for the next gameplay review. Do not stop after a cosmetic subtask while claiming this chapter is complete. No push or deployment.
