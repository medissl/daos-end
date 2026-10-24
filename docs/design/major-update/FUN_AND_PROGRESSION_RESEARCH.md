# Fun and progression: a major-update research brief

Research date: 2026-10-24. Status: researched references plus original design proposals. This document adds no runtime implementation and certifies no playtime target.

## What the present evidence says

The local [Jade Road pacing report](../../jade-road/PACING.md) records 34 policy decisions, 1,009 simulated seconds through its route/trial content, and another 1,700 seconds of retreat before purchasing Golden Core. It explicitly acknowledges that Ward/Flame is practically dominant on ordinary routes and repeating solved routes for stones is repetitive. These are simulation results, not human enjoyment measures. That report predates the latest UI reset; it remains relevant to unchanged balance, not proof that the new navigation still has the old usability faults.

The user's latest complaint is about unnecessary operation itself: too many buttons, reading, and abrupt changes. Reducing nine administrative taps to five does not establish that any of those five represents an interesting choice. The next chapter should remove routine acknowledgements while making a smaller number of preparations visibly affect what happens. Current `cultivation_state.gd` already credits ordinary encounter rewards and automatically starts an unbranched next encounter when there is no new discovery, requested camp, or multistage trial pause. Preserve those working behaviors; target unnecessary discovery/trial pauses and repeated route administration rather than claiming auto-advance is entirely missing.

## Source findings and limits

All external evidence below comes from developers, publishers, an interviewee speaking about his own game, or an original research paper. Store descriptions establish advertised features; they do not establish quality or actual completion time. No referenced game was personally playtested for this research. Claims of being addictive in marketing are not treated as scientific evidence.

### Automation can carry the fantasy of becoming capable

Magic Research creator Maticolotto identifies the ability to assign apprentices to broadly reusable spells as a turning point in the prototype. He also describes exploration, impactful discoveries, synergy, and a finite ending as design priorities. He criticizes random progression unlocks that encouraged frustrating AFKing and proposes bounded guarantees in hindsight. These are his design observations, not controlled evidence about every player. [Creator interview](https://www.incrementaldb.com/community/interview/1)

Magic Research 2 advertises wizards who automate spells and crafting, differentiated elements, equipment synergies, challenging bosses, rule-changing permanent discoveries, and retirement that compresses repeat content. Its advertised 60-plus hours is not a measured active-play benchmark for Dao's End. Its text-heavy interface is not this project's visual reference. [Publisher description](https://store.steampowered.com/app/2864890/Magic_Research_2/)

**Transfer:** the cultivator should become better at handling known work. Auto-advance through an unbranched journey, ordinary loot credit, and safe repeat farming support the fantasy more directly than making a powerful immortal keep approving routine actions.

### Build choices need an observable problem

Unnamed Space Idle's publisher describes weapons and defenses selected to counter enemy types, modules and shards that alter combinations, and progressively unfolding systems. Its mobile version history also records removing a purchase gate for shard auto-merge and making merging automatic. This is evidence that even an established incremental game can simplify a previously gated routine. It is not a reason to copy its menu count or premium economy. [Publisher description](https://store.steampowered.com/app/2471100/Unnamed_Space_Idle/), [Official mobile listing and version history](https://apps.apple.com/us/app/unnamed-space-idle/id6483933995?platform=mac)

**Transfer:** preserve a small combat vocabulary, make threats legible in the fight, and let builds counter them. A build that wins everything while the player changes nothing offers little reason to discover another tool.

### Interdependence is more useful than a large catalog

Melvor Idle explicitly presents production skills as benefiting other skills and combat. Its advertised equipment, skills, and monsters establish breadth, not the number of worthwhile decisions or active hours. [Publisher description](https://store.steampowered.com/app/1267910/Melvor_Idle/)

Orb of Creation describes spell setup, artifacts, and alchemy that combine, with new layers intertwining with previous ones. It calls itself a non-idle incremental puzzle game, so its active casting burden should not be assumed appropriate for Dao's End. [Developer description](https://store.steampowered.com/app/1910680/Orb_of_Creation/)

xiuzhen idle advertises realms unlocking further cultivation and production systems, eventually expanding the scale to sect management. That supports realm-driven changes in capability, not a requirement to implement its entire feature list. [Developer description](https://store.steampowered.com/app/1649730/xiuzhen_idle/)

**Transfer:** an expedition discovery should affect a technique or preparation; that altered build should reach a new challenge; the challenge should unlock a new operating rule. Avoid another independent currency bar whose only use is increasing itself.

### Perceived competence and choice are testable hypotheses

Ryan, Rigby, and Przybylski's four studies associate perceived autonomy and competence with enjoyment and preferences; the paper also connects intuitive controls with these experiences. It does not prescribe a button count, icon ratio, reward frequency, or 300-hour structure. Its results across the examined games are not proof of the proposed Dao's End mechanics. [Original research paper](https://selfdeterminationtheory.org/SDT/documents/2006_RyanRigbyPrzybylski_MandE.pdf)

**Transfer:** ask players whether they understood a failure and deliberately improved the next attempt. A win produced by an unexplained number increase may feel less like mastery. Build inspection and clear combat feedback should answer that question without exposing a debug transcript.

## Six transferable systems

The following are original proposals to test, not confirmed genre rules.

| System | The useful decision | Routine the game handles | Visible evidence of progress |
|---|---|---|---|
| One planned journey | Choose frontier and loadout; choose a real branch when one occurs | Unbranched encounter transitions and ordinary loot credit | Cultivator travels, fights, reaches the next landmark; route painting advances |
| Mastered retreat | Choose one cleared destination and optional stop target | Repeats cleared work at the existing reduced retreat rate, open or closed | A compact returning yield and completed target; no repeated claim ceremonies |
| Conditional combat arts | Choose a small compatible loadout against a readable threat | Triggers normal defensive/cleansing behavior automatically | A shield blocks the charged hit; poison disappears; a ward cracks |
| Guaranteed discoveries | Choose which named reward path to pursue | Awards essential first-clear discoveries once, without a rare roll | A technique or gear illustration visibly joins the build; ordinary resources credit silently |
| Inheritance laws | Choose one reversible rule modifier that changes an existing skill interaction | Applies its trigger and caps consistently | A recognizable effect signifies the trigger; a brief optional explanation shows why it fired |
| Realm transformation | Prepare for and initiate a meaningful breakthrough | Carries forward earned capability and unlocks its relevant controls | Character silhouette/robe detail, aura behavior, place response, and a new capability change together |

Basic usability belongs at introduction, not behind a grind. Optional mastered farming can unlock on a first clear because the player has demonstrated that activity; do not require ten identical repeats to earn relief from clicking. Mandatory branches remain decisions. Automatic progression stops on defeat, a new branch, route completion, or a configured stop target. Returning to a completed route need not display a blocking result dialog.

Combat should not require tapping defense at every telegraph. New conditional defensive behavior can operate from a small fixed set of authored skill rules. Do not add a visual scripting editor or dozens of per-skill toggles. A compact preset should hold the whole method/arts/gear/law setup, with an honest comparison before replacement. No automatic replacement of a nonempty slot based on one aggregate power number.

## A substantial bounded expansion: Golden Core to Nascent Soul

This is a candidate release slice, not a 300-hour promise. It deliberately extends the existing deterministic combat/data/save architecture. First implement the automation and combat fixes across the present chapter so the expansion does not multiply its chores.

### Content envelope

- Three illustrated regions, each with two genuinely different four-encounter routes: 24 new encounter definitions including six finales.
- Six short inheritance challenges built from those regions' mechanics, with distinct objectives and deterministic rewards. Reuse an arena when appropriate; do not describe reused encounters as extra unique enemy families.
- Three new combat arts, three selectable law augments, six curated gear pieces across the existing three slots, and three optional preparation recipes. Each must serve an authored problem.
- One Nascent Soul tribulation and an earned ending for this chapter, followed by explicit optional mastery goals. Reincarnation remains the next separately specified system, rather than an unfinished reset screen slipped into this release.

Exact prices, damage values, caps, cooldowns, reward amounts, and breakthrough requirements must be locked in data and simulated before implementation acceptance. Names and counts alone are not playable definitions. The candidate interactions below deliberately specify behavior and tradeoffs; their initial numerical values are tuning work, not claims of balance.

### Region and reward connections

| Region | Route problems | New tool and its cost | Reward connection |
|---|---|---|---|
| Thunder Peak | A predictable charged strike; a finale alternating that strike with shorter pressure | Thunder Step interrupts an eligible charge but spends focus and has a cooldown longer than an ordinary attack interval. It cannot stun-lock basic attacks or interrupt everything | A tempo weapon favors an offensive interruption build; an Earth inheritance offers an alternative shield-based solution |
| Ancient Tomb | Reflected direct hits; a barrier guardian protecting a vulnerable interval | Returning Blade refunds a strictly capped amount of focus only when it breaks a barrier. Multi-hit casts cannot generate repeated refunds from one break | A penetration artifact makes Sword viable in one route; a Fire inheritance creates a separate indirect-damage solution to reflection |
| Moon Lake | Alternating defenses; an endurance sequence with limited between-node recovery, disclosed at departure | Mirror Counter places a smaller temporary shield than Ward, then retaliates once if it blocks an eligible hit. It sacrifices Ward's larger safety margin | A counter robe supports precise defensive timing; a Water inheritance makes a recovery-oriented sequence solution possible |

Do not simply increase enemy HP to force these tools. Each region must have at least two understandable successful approaches from available equipment and arts. New arts should make an approach interesting or efficient; required tools have guaranteed paths reachable before their relevant gate. Old arts must retain useful roles.

The proposed endurance rule is route-specific. Existing routes continue to reset HP unless an explicit balance revision is documented. Show its limited recovery with a simple sequence indicator and an optional short explanation, not a permanent paragraph. Provide a safe retreat; failure cannot erase permanent progression.

### Laws, not another independent leveling screen

Use one equipped law. These are rule-change seeds requiring exact timing/caps and counterexample tests before shipping:

- **Earth:** blocking a charged strike grants one capped focus return. It rewards appropriate protection rather than stacking all generic defense, and cannot refund infinitely from damage-over-time ticks.
- **Fire:** a direct Sword cast against a burning target triggers a capped extra burn event once per cast. This creates a reason to combine Sword and Flame without rewarding every individual multi-hit or duplicating the whole burn duration.
- **Water:** a successful cleanse grants a small timed protection window. It supports River in poisoned pressure sequences and provides no free benefit on an enemy with nothing to cleanse.

The first law can be taught through a short trial with an illustrated before/after effect. Selecting it occurs in the existing build surface, not a fourth top-level destination. Switching outside an attempt is free; a player learning the system should not pay for a mistaken interpretation.

### Preparation without potion chores

Three recipes should address the new region pressures: one protective draught against a charged strike, one anti-curse preparation for tomb reflection, and one recovery preparation for the disclosed endurance sequence. Choose at most one preparation at departure. Show the effect and exact resource cost there, with ordinary materials routed from already unlocked regions. No separate crafting-claim-equip-depart chain.

Make each optional: a good build can clear without it, while a preparation can make a less specialized build succeed. Consent to repeat farming must not authorize spending these supplies repeatedly. If a recipe is never useful or becomes mandatory for every routine run, revise it rather than defend its presence as content.

### Economy and pacing changes required before the cap rises

The current Core report contains a large gap between winning the trial and affording the realm. Rebalance first-clear rewards, useful spending choices, and the advancement gate together. A remaining requirement can motivate preparation; 28 minutes with no new decision cannot substantiate engaged content.

Provide deterministic first-clear funding for an entry build in every new region. Preserve a reason to refine a selected item without making max refinement on all three slots mandatory. Existing owners may arrive with large savings; do not confiscate those savings or make every new enemy scale to invalidate them. Optional mastery challenges can constrain gear/realm in their own clearly disclosed rules while the main campaign preserves earned power.

Retain the current explicit retreat model during this slice unless a separately documented balance experiment justifies changing it. Reducing offline support further does not create meaningful active play. Nor does forcing 43 manual departures per hour. Earned first clears, discoveries, and challenge solutions supply the active advantage.

## What must be learned through play

| Question | Useful evidence | Unacceptable substitute |
|---|---|---|
| Does the player understand their next goal? | They identify a visible frontier or reward without being narrated through menus | A tooltip exists somewhere |
| Is preparation meaningful? | A player explains a threat and deliberately changes a tool, then recognizes the consequence | Every build wins after the same waiting time |
| Is automation sufficient? | A solved activity continues as authorized, and a returning player sees its result without a chain of acknowledgements | A claim button was renamed Continue |
| Are there several useful builds? | Earned-state comparisons show distinct situations where offense, protection, and recovery trade advantages | A seeded win-rate table where one build solves everything |
| Does discovery feel worthwhile? | Players use a new tool in a materially different attempt | A large inventory count or a rare sparkle |
| Is a session enjoyable? | Uncoached players choose to continue, can name an enjoyable moment, and identify dull stretches | Assertion count, foreground uptime, or developer stopwatch |

Record new problem-solving, build experimentation, waiting, and repeated administration separately. Observe both a new-player opening and the new chapter. Automated reachability remains necessary, but it cannot establish that content is fun.

## The 300-active-hour target remains unproven

Even a stronger expansion may be completed quickly by a player who understands its rules. Three regions and six trials do not become 20 or 300 active hours because simulation duration is long. The present full-release blueprint is an authoring plan, not evidence of duration.

A useful milestone is a coherent, finite release whose problems and discoveries make people want another session. Record actual engaged time with its limitations, then expand successful structures. A finite first ending can arrive much earlier than optional mastery completion. Longer timers, obligatory repeated clicks, random mandatory drops, and an open-tab requirement cannot make up a content deficit.

This brief supplies no claim that addiction is desirable or proven. The intended return motive is an understood opportunity: a new interaction to try, a reachable discovery, a build problem to solve, or a visible transformation to earn.
