# Implement Milestone 2: A Cultivator's First Journey

You are the implementing Codex chat for Dao's End. Deliver a playable gameplay expansion AND a coherent graphic overhaul. Work through the stages below and stop at this milestone. A plan or a new mockup alone is insufficient.

## Context and outcome

Read applicable AGENTS.md instructions and `~/.codex/DESIGN.md`. Inspect the current source, tests, running build and Git state before changing anything. The planning chat found no local Git metadata; do not invent synchronization or a commit history. Preserve unrelated work and existing player saves.

Read these project documents:
- `docs/design/IDLE_CULTIVATION_RESEARCH.md`
- `docs/art-direction/GAMEPLAY_AND_ART_REVIEW_2026-10-23.md`
- `docs/art-direction/VISUAL_REDESIGN_DELIVERY.md`

Inspect the existing after screenshots and artwork. The user still finds the art visibly generated and the gameplay too shallow. The generated first-breath visual target is a composition reference, not accepted final artwork.

Goal: players choose between cultivation and gathering efficiency, spend useful expedition rewards in competing ways, and reach a new realm that changes how their techniques work. All of this must remain useful while away. No repeated tapping, short login chores, or extensive new menus.

Explicit user requirement: this is an illustrated cultivation GAME, not a text RPG or novel simulator. Gameplay must be communicated through matching illustrated icons, readable visual states, progression cues and responsive interactions. Generate and integrate a coherent icon/asset set for the implemented systems. A beautiful background above another long text form does not satisfy this milestone.

These rules deliberately extend and rebalance milestone one. Implement them as written; keep constants configurable. Record proposed improvements separately instead of silently inventing systems.

## Stage 1: Connected gameplay

### Opening and realms

Retain current upgrade costs, effects and caps. Explicitly change Mortal breakthrough requirements from 4,000/3,000 Qi to **1,200 Qi normally / 800 Qi after Settle the Mind**. Settle the Mind still costs 200 Qi. This is an intentional pacing change: expose the new loop sooner. Update descriptions and affected assertions accordingly.

Retain realm production multipliers Mortal=1 and Qi Refining=2. Add Foundation Establishment=4. Retain purchased upgrades on both breakthroughs; both are guaranteed and manually triggered. No automatic advancement.

Qi Refining unlocks two techniques and Bamboo Forest. Before that, explain this next unlock concisely without displaying a screen full of locked buttons.

Foundation breakthrough requires **10,000 stored Qi and 12 Spirit Herbs**. A one-time action, Prepare Foundation, spends **12 additional herbs** and reduces the Qi requirement to **7,000**. It does not remove the 12-herb breakthrough requirement. Preparation persists until advancement. Clearly distinguish preparation's price from the advancement price. Settle the Mind applies only to the Mortal breakthrough.

Foundation unlocks Technique Resonance, defined below. Do not add another realm after Foundation in this milestone.

### Two cultivation techniques

These are separate from the existing Deep Breathing and Meridian Circulation upgrades:

- **Azure Cloud Meditation:** +20% Qi production at mastery 0; +30% at mastery 1; +40% at mastery 2.
- **Iron Body Sutra:** Bamboo Forest returns +2 herbs at mastery 0; +4 at mastery 1; +6 at mastery 2. Its benefit represents being able to gather farther into the forest; no separate HP/combat system is needed.

Both techniques become known for free at Qi Refining. The player chooses one primary technique; neither is automatically equipped on first advancement or migration. Until selected, the primary technique is None and provides no bonus. There is no benefit to None, and selecting a method should be clearly encouraged.

Each technique starts at mastery 0, capped at 2. Increasing a technique from 0 to 1 costs **8 herbs**; 1 to 2 costs **16 herbs**. Costs are per technique. This makes herbs useful for specialization as well as breakthrough preparation.

Before Foundation, only the primary technique contributes. At Foundation, the other known technique contributes **half its normal bonus** automatically. For example, primary Azure at mastery 1 grants +30% Qi; secondary Iron at mastery 1 grants +2 herbs. Primary Iron at mastery 1 grants +4 herbs; secondary Azure at mastery 1 grants +15% Qi. Bonuses do not compound with themselves.

Qi production = existing production formula × (1 + effective Azure bonus). Herb reward = 4 + effective Iron bonus. Show calculated current effects, not just opaque power scores.

### One repeatable expedition

**Bamboo Forest:** 120 seconds per trip, guaranteed base reward **4 Spirit Herbs**, no entry cost, no random failure, no rare loot or equipment. Cultivation continues concurrently; the selected method determines which activity benefits.

The player explicitly starts their first trip. Repeat is available from the start and defaults on. Stop means finish the current trip and then stop. Do not delete earned progress or force manual claiming between trips.

Commit the chosen method and effective technique bonuses for each trip at departure. That commitment governs both the trip's herb reward and its Azure production bonus during the trip. This prevents equipping Iron for one instant and receiving both methods' full benefits. Display the committed current method.

Method changes, mastery improvements and newly unlocked resonance apply to the next departure while a trip is active. Let the player queue their next primary method without having to watch a timer. Outside an active trip, method/mastery changes apply immediately. The base realm multiplier changes immediately on breakthrough, even if the current trip's technique bonuses remain committed until it ends. Make pending effects understandable with short text.

Resolve each trip once, award herbs, apply queued choices, and start another trip only if repeat remains enabled. A stop-after-current request must survive reload. Exact boundary behavior must be deterministic.

### Offline behavior

Use the existing single owner of time and eight-hour absence cap. Advance cultivation and expedition progress through the SAME credited interval; do not award a separate full Qi payout and then simulate it again.

Handle completed trips, repeat, queued techniques, committed bonuses and leftover partial progress. With repeating disabled, only an already-started trip may finish. Absence must never start an expedition the player did not authorize. No automatic mastery spending, preparation, technique choices or breakthroughs.

Resolve time by meaningful event boundaries rather than replaying every frame/second. An eight-hour interval contains at most 240 trips. Keep active and offline results equivalent for identical actions and elapsed time. Backward time credits zero; duplicate lifecycle events must not duplicate rewards. Offline feedback should summarize Qi, herbs, trips and credited duration.

### Persistence

Inspect the existing version-1 validation before modifying it. It stores a calculated `rate` and checks equality against the legacy formula; validate v1 data against its old schema, not new technique effects.

Add an explicit version-1 to version-2 migration. Preserve Qi, realm, upgrade levels and timestamps. New herbs, mastery, preparation and expedition progress start at zero/false; no trip is running; techniques are unlocked according to existing realm but primary remains None. Preserve legitimate legacy absence using the legacy rate and existing cap, without double-crediting or retroactively inventing expedition rewards.

Persist new resources, mastery, primary/pending choices, preparation, active trip progress, committed bonuses, repeat/stop intent, and timestamps. Validate finite values, integer quantities/caps, known IDs, realm unlock restrictions and consistent trip state. Retain recovery and interrupted-save handling. Test with isolated fixtures; never reset a real player to demonstrate the new opening.

## Stage 2: Graphic overhaul and game interface

Keep the Chinese ink-wash fantasy identity and the cultivator as the focal point. The user has specifically rejected the current generic generated look. Recoloring the current assets or increasing texture is insufficient.

Before integration, establish one coherent small style sample: the character, a landscape crop and representative live-UI styling. Inspect it at phone scale. Choose a restrained illustrated line-and-wash direction: deliberate contours, two or three broad robe value groups, selective dry-brush accents, quiet atmospheric distance, mineral jade/blue-grey, warm ivory and limited cinnabar.

### Required matching icons and visual assets

Create a cohesive set of original illustrated game icons. Use available image-generation tools for actual icon artwork, following their applicable skills, then inspect and clean the results. Carry the chosen brush language, palette and material treatment across the character, environment and icons. Do not generate every asset with unrelated style prompts. If generation is unavailable, use purpose-drawn original assets where feasible and report the limitation; do not silently substitute emojis or a generic web icon library.

The minimum useful set covers:
- Qi: a distinctive ink-and-jade energy motif.
- Spirit Herbs: a recognizable medicinal sprig.
- Deep Breathing, Meridian Circulation and Settle the Mind: three different readable practice motifs.
- Azure Cloud Meditation and Iron Body Sutra: two immediately distinguishable technique emblems.
- Bamboo Forest: an illustrated destination vignette and small destination emblem.
- Foundation preparation and breakthrough: distinct preparation/advancement emblems.
- Realm progression: a small coherent set of Mortal, Qi Refining and Foundation badges.

Simple technical controls such as close, repeat, play and stop may use purpose-drawn vector glyphs matched to the interface. Their touch behavior matters more than adding decorative pictures to them. Do not introduce icons for features outside this milestone.

Keep silhouettes and internal detail readable at 32–64 logical pixels; inspect icons at actual runtime sizes. Use a few clear value groups, consistent visual weight, limited accent colors and restrained brush texture. Avoid miniature detailed paintings, arbitrary gold frames, neon, glossy rendering and synthetic speckling. Important symbols must also differ in shape, not only color.

Generate/export artwork without letters, labels, prices or baked state indicators. Use genuine transparent backgrounds where needed; reject checkerboard backgrounds, clipping, edge halos and inconsistent padding. Keep individual reusable sources and a small asset manifest describing purpose, source and intended size. Pack a texture atlas only if it actually helps; do not build an unnecessary asset framework. Native Godot controls provide all text, counters, states and hit areas.

### Communicate the game visually

Use technique emblems as real selectable controls. Show selected and queued methods with clear frames/seals, and mastery with two visible pips or nodes. Pair the herb icon with mastery costs and use a concise numerical effect summary; detailed calculations belong in a tap/focus detail view.

Present Bamboo Forest as a small illustrated route/vignette with a progress marker or ring, remaining time, expected herb icons/counts, and an obvious repeat state. Represent the current expedition and results with this view instead of paragraphs describing a journey. This is a lightweight presentation of the specified timer, not authorization for a movement, battle or exploration simulation.

Show preparation as a persistent visual seal/state, and show both resource requirements on the breakthrough control with their matching icons and counts. Give purchases, herb awards, mastery and breakthroughs brief visible feedback tied to the actual state change. A new realm should visibly change its badge and a restrained aspect of the character's aura or sanctuary. Keep effects inexpensive and compatible with reduced motion.

Use a compact illustrated offline reward summary with Qi/herb icons, counts, trips and credited time. Do not make players read a narrative log to learn what they earned.

Keep concise names, important numbers, requirements and short action labels. Icons should reduce reading, not make newcomers guess. Preserve accessible names, keyboard focus and tap-accessible explanations. No hover-only help, icon-only mystery navigation, invented symbols without explanation, or essential information communicated only by color. Avoid large instructional paragraphs, repeated prose status lines, story panels and text adventure logs on the main play screen.

Overhaul the focal character and reconcile the scenery with it. Give the novice one recognizable original silhouette, believable garment construction and a few distinctive practical details. Avoid excess hair loops, speckled folds, ornamental armor and generic glossy fantasy faces. Match line weight, ink density, perspective and grounding across character, stone and environment. Reduce incidental detail so the face and pose read clearly.

Use suitable original illustration or generated-and-edited assets. If generating, reuse one character identity and edit specific weaknesses; do not repeatedly regenerate the whole interface and assume a negative prompt establishes quality. Inspect hands, crossed legs, seams, face, alpha edges and contact with the platform. Perform targeted repainting, simplification or replacement where needed. Report remaining quality limitations candidly. Keep source/provenance notes.

Maintain separate useful background, character and limited foreground/effect layers. No baked interface text, prices or buttons, no invisible hitboxes over a screenshot, no decorative assets that imitate nonexistent functions. Avoid a huge file set or demanding shaders. Preserve reduced motion and existing accessibility behaviors.

Design the interface around the new actual decisions. Cultivate and Bamboo Forest may be two compact views or a main view plus drawer. Keep Qi, herbs, realm and the next objective legible. Make selecting a method, seeing its current/pending effect, increasing mastery, starting/stopping repeat, and preparing/advancing discoverable on touch. Show remaining trip time, expected herbs and repeat status.

Completed starter upgrades should become a compact accessible illustrated summary instead of permanently occupying most of the screen. Use their matching practice icons with levels/pips and short labels; retain access to their exact effects. Keep the artwork visible, use actual bundled fonts and native controls, and avoid adding inventory, shop, sect or other fake/locked tabs. Detail panels must work on tap and keyboard, not hover alone. Use plain language with exact outcomes.

Inspect 320×640, 430×932 and 1280×800 layouts. Small screens may use a bounded scrolling region or drawer. Never shrink text/touch targets to force all content into one screenshot. Preserve at least 48-logical-pixel action targets, reachable advancement controls, contrast and focus visibility. No long-term status feedback covering the main actions.

## Stage 3: Verification and pacing review

Keep the current separation between progression, state, session, persistence and presentation. Extend those boundaries; avoid a speculative framework or routing the new economy entirely through UI callbacks.

Add focused automated checks for technique effects, mastery costs/caps, competing herb purchases, both breakthrough requirements, preparation, resonance, unlock restrictions, queued choices and committed trip bonuses. Check exact completion boundaries, partial trips, repeat-off, stop/reload, large elapsed steps versus small steps, and reward deduplication.

Test valid v1 Mortal and Qi Refining migrations, v2 round trips, invalid fields, truncated saves, interrupted writes, recovery, backward clocks and capped absence. Update legacy assertions only for intentional changes; retain coverage of old correctness and persistence behavior.

Simulate at least cultivation-first, gathering/preparation-first and mastery-first approaches. Report time to each realm, herb spending, purchases and production. Use both a fresh start and a representative migrated Qi Refining state. Identify whether an option is practically dominated; do not claim balance because two methods exist. Report suggested adjustments separately if the provisional numbers fail this comparison.

Run and exercise the complete flow normally: first upgrade, first breakthrough, method selection, forest trip, queued method change, mastery, stop/repeat, preparation, Foundation and resonance. Include a real short absence/reload check. Dev acceleration and isolated seeded test states may support verification but must not ship or masquerade as ordinary-speed playtesting.

Export and test actual browser output with pointer/touch-style input at the three sizes. Inspect the new art and panels in the running build, capture screenshots, critique and refine major issues. Compilation or automated layout assertions alone do not prove visual quality. Measure presentation performance where possible; distinguish desktop portrait emulation from actual Android-device evidence.

Also verify that icons identify the right resource/action, icon controls have real touch targets and accessible names, technique selection/queue/mastery states are distinguishable, and reward/progress visuals match actual calculations. Include screenshots of the integrated icon set and the forest activity. Treat a screen that still reads mainly as a stack of text rows as an unresolved visual requirement, even if every button works.

## Boundary and delivery

Do not add prestige, combat animation, HP, gear, random loot, crafting, pets, sects, more destinations, more realms, accounts or monetization. Do not push or deploy.

Deliver the working build/run instructions, a concise change report, screenshots of the actual rendered overhaul, source/provenance notes, test results, save-migration evidence, strategy comparison, known issues and an updated milestone handoff. Mark unavailable tools and Android verification accurately. Stop for gameplay review after completing this milestone; do not expand automatically.
