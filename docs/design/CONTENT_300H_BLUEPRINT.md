# Dao's End — long-form gameplay blueprint

Draft: 2026-10-23. User target: **300 hours of active play**, with reduced offline growth. This is a proposed production design, not a claim of implemented content or measured duration. Read the root DESIGN.md and research notes. The first implementation boundary is the next-content prompt.

## 1. What the duration means

Engaged time includes planning, comparing, exploring, learning encounters, trying builds, choosing an inheritance and resolving meaningful challenges. Foreground waiting, offline elapsed time, repeated clicking without a decision and leaving a tab running are not evidence of engaged content.

Target approximately 300 active hours for broad completion across the campaign, inheritance challenges, different life conditions and ascension trials. The first campaign ending should be substantially earlier, provisionally 60–90 engaged hours. Do not force every player through 300 hours before any satisfying ending.

The following is an **authoring allocation**, not additive evidence from completed content:

| Completion strand | Planning allocation | What must differ |
|---|---:|---|
| First ascent campaign | 70 active hours | New regions, hazards, capabilities and prepared trials |
| Inheritance expeditions | 60 | Fixed branching objectives with build-specific solutions |
| Distinct reincarnation contracts | 90 | New life conditions, restricted tools and retained understanding |
| Mastery/ascension challenge collection | 80 | Explicit counter-build and resource-efficiency problems |
| Target | 300 | No double-counting an activity in two strands |

If real players finish the authored problems sooner, report that result. Additional solved farming or a longer cooldown does not fill a content deficit. No simulation or generated content count can certify this target.

## 2. Capability map and sequence

| Capability | Responsibility | Build after |
|---|---|---|
| Definitions and stats | Stable technique/item/encounter IDs, costs, stat evaluation | Existing state inspection |
| Journey combat | Deterministic short encounters and interpretable results | Definitions/stats |
| Expedition routes | Player-selected finite routes, first clears and retreat farming | Combat |
| Equipment | Small fixed item sets and useful Qi refinement | Definitions/stats; integrate with routes |
| Alchemy | Few recipes serving hazards, preparation and builds | Routes and equipment |
| Inheritance trials | Authored objective/constraint sets and law unlocks | Combat, routes, alchemy |
| Reincarnation | Explicit retention rules and distinct life contracts | A proven multi-region campaign |
| Ascension | Synthesis encounters and a finite completion goal | Prior proven strands |

State orchestrates these capabilities; presentation reads state. Do not introduce an online backend or replace working architecture wholesale. Define providers and consumers before adding modules; avoid dependency cycles and all-purpose managers.

## 3. Player loop

Choose a cultivation approach → select a frontier route → prepare techniques and gear → watch brief readable automatic encounters → inspect a clear result → spend rewards on a competing improvement → learn a new interaction → overcome the realm's trial.

Decisions live in preparation, route choice, skill priority and allocation, not fast reaction input. The scene shows action and reward. Narrative is optional flavor in brief discovery captions, not the mechanism that carries hours of play.

Existing herb farming remains useful, but a herb timer no longer supplies the entire game. Azure should enable skill-heavy approaches and efficient cultivation. Iron should support survival and gathering. Sword, flame, ward and cleansing skills then answer actual encounter properties.

## 4. Realms change capabilities

| Realm | Main new capability | New player problem |
|---|---|---|
| Mortal | Basic cultivation and visible investments | Learn production and opportunity cost |
| Qi Refining | Methods and gathering | Choose cultivation versus resources |
| Foundation | Method resonance; first combat loadout and equipment in the next chapter | Counter a hazard and fund preparation |
| Golden Core | A third combat slot and an affordable loadout preset | Build a three-part interaction |
| Nascent Soul | A chosen law augment and first inheritance branches | Commit to a useful rule modification |
| Soul Formation | Short multi-encounter formations and basic alchemy planning | Preserve resources across a sequence |
| Void Refinement | Reincarnation contracts and improved automation | Rebuild intelligently under changed conditions |
| Mahayana | Combined region hazards and advanced law trials | Solve multiple competing constraints |
| Ascension | A final multi-stage trial and new-life completion options | Demonstrate mastery with several viable builds |

Existing Foundation resonance is retained. Reincarnation may be previewed earlier but does not become mandatory before its system is ready. Intermediate phases may structure a realm only when they offer a useful objective; do not multiply nine identical cost gates by default. Exact numerical realm costs beyond the next chapter remain tuning work.

## 5. Shared economy

Expose resources only when their use exists:

- **Qi:** cultivation, advancement and refining equipment/techniques. Provide real spending choices after Foundation so production remains useful.
- **Spirit Herbs:** mastery and preparation, later a small alchemy recipe set.
- **Spirit Stones:** encounter rewards and equipment refinement. Introduced with combat.
- **Refining Essence:** later equipment adaptation, introduced only when that feature exists.
- **Law Fragments:** later trial unlocks and law changes; never a second continuously ticking Qi bar.
- **Dao Insight:** selected persistent legacy improvements, awarded for novel accomplishments on reincarnation.

Named quest seals are objective items, not another row of currencies. Keep most rewards deterministic. Rare treasure can provide excitement but never be the only path to an essential technique, required recipe or advancement material. First-clear treasures have fixed acquisition paths; duplicates should have an understandable use when duplicates are actually introduced.

Keep production formulas and rounding documented. Exact item counts, affordability and reward IDs require stable arithmetic. Simulate numerical scale before adding a large-number library. No non-finite resource values or save fields are acceptable.

## 6. Builds and combat

Three overlapping approaches: sword (tempo and armor interaction), body (endurance and shields), spirit (focus, elemental effects and utility). These are tools the player can mix, not irreversible character classes.

Use deterministic automatic combat with visible enemy traits, a small ordered skill loadout, cooldowns and a temporary battle focus pool. No click-to-attack requirement. Show why the attempt failed: damage source, shield/poison interaction, focus shortage or timeout. Retry with a different build is inexpensive; defeat does not erase realm, gear or hours of cultivation.

The first slice uses one enemy at a time, two combat skill slots and four combat techniques. Golden Core opens the third slot. Later complexity comes from interactions and sequences before larger parties or enemy counts.

**Full-release content envelope:** 24 distinct techniques, not 24 renamed multipliers. Suggested families:

| Family | Signature behaviors to author |
|---|---|
| Cultivation/support | Azure focus economy; still-water burst reserve; soul sensing route information; star breathing resonance |
| Body/guard | Iron endurance; stone-vein damage smoothing; phoenix recovery after burn; void-skin one-hit protection with cooldown |
| Combat foundation | Flowing Sword multi-hit; Crimson Flame damage over time; Jade Ward timed shielding; River Confluence cleanse/heal |
| Combat interaction | Mirror Counter after a block; Thunder Step tempo window; Root Binding interruption; Silent Needle barrier penetration |
| Advanced support | Lotus Pact healing conversion; Ember Seed delayed ignition; Returning Blade resource refund with a strict cap; Mountain Oath slow high protection |
| Advanced mastery | Rainthread persistent marks; Broken Bell channel disruption; Hollow Moon short phase defense; Unwritten Stroke a constrained flexible skill |

Names are original working labels. Each advanced definition needs costs, timing, exclusions and a test proving its interaction before implementation. This table is not permission to create placeholder skills with identical effects.

Use six law themes later: Wood/regeneration, Fire/conversion, Metal/penetration, Water/cleanse, Earth/protection, Void/timing. Equip one law initially; switching is affordable outside an attempt. Avoid universal best combinations and unrestricted cooldown loops.

## 7. Regions and authored encounters

| Region | Distinctive pressure | Useful preparation |
|---|---|---|
| Bamboo Forest | Gathering and endurance | Basic cultivation/body choice |
| Misty Mountain | Plated and warded guardians | Damage type, repeated hits, focus |
| Spirit River | Poison, healing enemies, changing flow | Cleanse, sustained damage, timing |
| Beast Ridge | Limited multi-target pressure | Guard, target order, efficient burst |
| Cinnabar Marsh | Burning ground and toxic flora | Recovery, controlled damage-over-time use |
| Ancient Tomb | Reflections and lingering curses | Indirect damage, cleansing, careful tempo |
| Jade Quarry | Layered shields and resource strain | Barrier tools and focus economy |
| Thunder Peak | Telegraphable burst sequences | Timed protection and interruption |
| Moon Lake | Phased defenses | Alternate damage channels and delayed effects |
| Sunken Pavilion | Sequences with limited replenishment | Efficient builds and optional supplies |
| Silent Void | Restrictions on repeated actions | Diverse skills and cooldown discipline |
| Heavenly Ruins | Combined learned rules | A flexible, understood build |

Production target: up to 12 regions with three distinct authored routes each, four encounters per route: **144 encounter definitions including 36 route finales**. Do not treat these counts as delivered content or hours. Each route needs a different useful reward or problem, not four repeated enemies with rising HP.

Reuse coherent enemy art where a readable trait/phase variation makes sense, but do not claim palette swaps are new enemy families. Plan roughly 12–18 base guardian illustrations and recognizable trait overlays across the full release. The immediate chapter creates only its required art.

Add up to 12 inheritance sets later, each with a short branching sequence and a specific reward. Trial objectives may involve survival, efficient focus use, cleansing a sequence, defeating reflected damage, minimal supplies or alternate paths. Hand-author and test each constraint. A Cartesian product of modifiers is not automatically worthwhile content.

## 8. Equipment and alchemy

Three equipment slots: weapon, robe, artifact. Full-release target roughly 18–24 distinct fixed items, each with a named acquisition path and identifiable role. Prefer a small curated collection to hundreds of random-stat items. Refinement improves a known item; later adaptation changes a limited property without destroying the base item. Preview every cost/effect.

Alchemy starts later with three recipes, growing to approximately ten if they serve different challenges. Examples: protection against a specific hazard, recovery between encounters, and preparation for a known tribulation. Do not require stocking generic consumables for every routine farm. Offline farming may not consume rare player-selected preparation without explicit consent.

Guard against the current economic issue: mastery competes with advancement for herbs, while surplus Qi has no use. Equipment refinement adds Qi spending; encounter focus gives Azure a capability; mastery prices still require a new strategy comparison. Adding a sink that is never worth buying does not solve the issue.

## 9. Reincarnation contract — design before implementation

This system is future scope. Proposed rules:

- Unlock voluntary reincarnation after a meaningful later campaign milestone. Provide a full reset/retention preview and a recoverable pre-reset snapshot.
- Reset current realm, temporary Qi/herbs/stones, ordinary gear and this life's route progress. Retain discovered recipes, codex knowledge, completed legacy accomplishments, unlocked quality-of-life tools and permanent Dao Insight choices.
- A selected heirloom retention option preserves one item in a realm-scaled form; it must not trivialize the opening or confiscate an item silently.
- Earn pending Dao Insight from a finite catalog of unique legacy marks: first major trial completion or a named life-condition challenge. Each mark is claimable once per account. Reincarnation banks pending marks; repeatedly resetting the same opening cannot generate unlimited Insight.
- Initial legacy catalog: eight small capped choices affecting access, retention, preparation or automation, not eight identical production multipliers. Define exact costs before implementing.
- Completed early sections gain optional automation and route shortcuts. Reaching genuinely new decisions should become faster in later lives.
- Named life contracts change constraints, such as restricted elements, a limited artifact slot, or unusual starting roots. They are optional visible challenges, not random permanent disadvantages.

These rules still require numeric validation and a concrete legacy-mark catalog. Do not implement prestige merely because the blueprint mentions it.

## 10. Reduced offline growth without a keep-open advantage

**Proposed initial tuning:** eight-hour wall-time cap and **30% retreat simulation speed**. Eight absent hours credit 2.4 hours of ordinary simulation. This is a design experiment, not a researched genre standard.

For the immediate content slice, retain the existing Mortal → Foundation tutorial calculation/timing until the new journey modes unlock at Foundation. Introduce the new retreat model there rather than accidentally tripling an opening that currently has few decisions. The long-form rate policy below governs the new chapter and later chapters. Record this tutorial exception explicitly; do not claim one rate applies universally yet.

Use explicit modes rather than pretending to detect attention:

- **Journey:** a player-started finite route, full ordinary simulation speed, with visible encounters and first-clear objectives. It stops at the next unchosen branch or route end. It never repeats frontier routes indefinitely.
- **Retreat:** repeating previously cleared farming/cultivation at 30%, whether the client is visible or closed. A parked open client has the same steady farming rate as a closed one.
- **Offline:** complete only the already-authorized current encounter/route segment at retreat speed, stopping before any unchosen branch or new confirmation. Spend remaining credited time on authorized retreat activity. Never choose a build, advance, reset or spend scarce supplies automatically.

Starting a finite journey and walking away may earn that finite segment; this does not establish active engagement and must not count toward the 300-hour claim. Do not add activity-policing clicks, energy charges, anti-idle popups or focus-based reward multipliers. No online infrastructure is needed for this local design.

Keep fractional simulation progress; do not round away partial herbs or trips. Advance all systems through the same effective interval and checkpoint once. Failed encounters safely return to retreat without deleting long-term progress. Show the actual retreat rate in the HUD. Pause/unfocused behavior and transitions must be explicit and tested.

Migration preserves existing resources and legitimate prior absence once under its saved rules, then activates the new rate model. No retroactive confiscation. Compare active routes, retreat-open, retreat-closed, overnight returns and irregular returns before accepting 30%.

## 11. Roadmap and gates

| Stage | Deliverable | Evidence required |
|---|---|---|
| 3: The Jade Road | Finished material/UI kit, music/ambience/SFX, two new regions, first deterministic combat, six total techniques, nine gear items, Golden Core | Connected ordinary-speed chapter; useful Azure and Iron strategies; actual rendered art and audible mix |
| 4: An Inheritance | Next regions, three starting recipes, first law, three inheritance sets | Several challenge solutions, useful resource chains, no mandatory consumable chores |
| 5: Another Life | Explicit tested legacy catalog, migration and varied life contracts | Later lives reach new decisions sooner; reset preview is accurate |
| 6: World of Laws | Expand authored region/trial matrix and automation | Quality per challenge, diverse builds, measured active sessions |
| 7: Ascension and completion | Full finite campaign and optional mastery strands | Real end-to-end saves, long simulation, substantial human sessions; duration claim remains evidence-based |

Complete coherent slices rather than all menus first. Each stage includes new playable content and its actual illustrated presentation. Do not alternate endless cosmetic micro-passes with content postponed indefinitely. First-stage estimates are targets; do not stretch encounters to make a stopwatch agree.

## 12. Validation

For every region, record prerequisite, challenge property, viable counters, rewards and why returning is useful. For every technique/item, record at least one situation where it changes an outcome and at least one tradeoff. First-clear rewards cannot be farmed through reload or reset.

Compare at least cultivation/focus, body/guard and mixed approaches. Check win rates without randomness, attempts to understand a hazard, resource sufficiency, time spent waiting and practical dominance. Test naive as well as optimized policies. Do not raise enemy HP merely to equalize completion times.

A long simulation must check reachability, finite numbers, affordability, resource deadlocks, save size, capped absence and no required rare roll. Playtests must check understanding, desire to continue, repetitive sections and actual engaged time. Report them separately.

No backend, multiplayer, gacha, paid acceleration, mandatory dailies, elaborate narrative or graphically demanding 3D is part of this blueprint. Expand only the systems that support this game's cultivation decisions.
