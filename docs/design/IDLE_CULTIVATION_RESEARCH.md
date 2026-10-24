# Idle cultivation research for Dao's End

Research date: **2026-10-23**. Purpose: compare progression structures and guide design discussion. This note adds no implementation requirements.

## Evidence and limits

Sources are the games' official storefront descriptions and, for Immortality Idle, its official open-source implementation. Storefront claims describe what publishers advertise; they do not establish pacing, fairness, enjoyment, or the quality of interactions. Source inspection establishes that mechanics exist in the inspected code, but does not establish their behavior in every deployed version. None of these games was playtested for this research. No player reviews or download statistics are used as evidence of design quality.

## Is this like Cookie Clicker?

There is a shared economic structure: collect a resource, reinvest it to increase future production, encounter larger requirements, and unlock another layer of progression. Cookie Clicker's official description includes producers such as farms and factories, upgrades, minigames, and permanent heavenly upgrades. Reducing the comparison to repeated tapping misses its automation and longer-term development. [Official Steam description](https://store.steampowered.com/app/1454400/Cookie_Clicker/)

For Dao's End, **idle** should describe how actions continue without constant input; **incremental** should describe how the player's productive capability develops. Those are working design definitions, not evidence that a game is deep. A timer followed by a bigger timer can satisfy both definitions while offering few interesting decisions.

## What actual cultivation games do

| Game | Supported progression structure | Player decisions | Offline / reincarnation evidence |
| --- | --- | --- | --- |
| Immortality Idle | Activities develop attributes; repeated lives improve aptitude; further reset layers change future growth | Arrange activity loops and allocate time among activities | Banked simulation time and reincarnation are present in official source |
| xiuzhen idle | Cultivation realms unlock production and management systems | Develop cultivation skills, crafting, and later a sect | Publisher describes lifespan and rebirth talent bonuses; exact offline rules unverified |
| Overmortal | Cultivation paths, tribulations, equipment production, expeditions | Magicka, Corporia, or both; techniques and crafted items | Publisher claims offline simulation of battles, production, and interactions; reset prestige unverified |
| Immortal Taoists | Cultivation, techniques, discoveries, equipment and elixir crafting | Exploration and sect choices | Listing establishes the advertised idle RPG identity, not exact offline rules or prestige |

The following sections supply the sources for this table.

### Immortality Idle: improve what a lifetime can accomplish

The official repository describes progression across reincarnations. Its activity service processes a configurable loop with repeated entries, resource use, recovery, and exhaustion. This supports a time-allocation interpretation: the player organizes activities rather than generating every action with a click. [Official README](https://github.com/immortalityidle/immortalityidle.github.io/blob/main/README.md), [activity implementation](https://github.com/immortalityidle/immortalityidle.github.io/blob/main/src/app/game-state/activity.service.ts)

The character service converts attribute gains into aptitude during reincarnation. Soul-core development improves aptitude gains on future reincarnations, while meridian development increases the benefit aptitude can provide; bloodline advancement affects what subsequent lives retain. This is more specific than one universal prestige multiplier: separate persistent improvements change future possibilities. Death and voluntary rebirth are also present. [Character implementation](https://github.com/immortalityidle/immortalityidle.github.io/blob/main/src/app/game-state/character.service.ts)

Offline elapsed time is converted into banked ticks that can accelerate subsequent simulation. It is not simply a direct payout of one currency at a saved rate. [Main-loop implementation](https://github.com/immortalityidle/immortalityidle.github.io/blob/main/src/app/game-state/main-loop.service.ts)

**Design inference:** repeated lives can create a sense of learning and mastery when preparation changes what becomes achievable. That does not imply Dao's End needs this game's lifespan, survival management, or activity scheduler.

### xiuzhen idle: progression can deepen without combat

The developer's Steam description explicitly presents a cultivation simulation without a combat system. It describes new systems unlocking through realm advancement, cultivation-related production skills, later sect management with disciples and facilities, and a still-later creation layer. It also describes finite lifespan and rebirth that awards talent bonuses from the preceding life's cultivation. The same page acknowledges that its promotional language exaggerates what is ultimately a simple progress-bar simulation. [Official Steam description](https://store.steampowered.com/app/1649730/xiuzhen_idle/)

**Design inference:** realm advancement can change the scale and type of decisions. Adding combat is not the only way to give the player something worthwhile to plan. Its breadth is a reference for structure, not a realistic next-milestone feature list for one independent developer.

### Overmortal: cultivate a path and automate surrounding activity

The SEA listing advertises Magicka, Corporia, or dual cultivation; tribulations; techniques; pill and weapon crafting; expeditions; and treasures. Its publisher specifically claims that offline progression simulates battles, production, and interactions. The listing also advertises substantial social systems, but those are outside Dao's End's current scope. It does not establish a classic reset-for-permanent-bonus prestige system. [Official Google Play listing](https://play.google.com/store/apps/details?id=com.ltgames.android.m71.sea&hl=en)

**Design inference:** a useful connection is that the chosen cultivation approach influences preparation and resource acquisition. Copying the number of systems would not automatically recreate that connection. Precise offline limits and differences between regional versions remain unverified.

### Immortal Taoists: discoveries broaden the cultivation fantasy

The publisher advertises techniques and spells, treasures and herbs, crafting equipment and elixirs, exploration choices, sects, and companions. These claims support a broad cultivation fantasy beyond buying production upgrades. However, the description does not specify exact offline calculations, a concrete early-game resource chain, or reincarnation reset rules. Those remain unverified rather than inferred from its genre. [Official Google Play listing](https://play.google.com/store/apps/details?id=com.immortaltaoists.en&hl=en)

**Design inference:** discoveries are most useful to Dao's End when they create a new approach to a problem. A larger inventory of interchangeable percentage bonuses would add collection work without proving meaningful depth.

## Implications for Dao's End — proposals only

The strongest common design pattern is **interacting progression layers**: production supports preparation; preparation reaches a milestone; the milestone expands productive capability or unlocks another decision. Reincarnation is one possible layer, not a requirement established for every cultivation idle game.

For the next small playable slice, consider connecting **one technique decision, one expedition, and the next breakthrough**. For example, a cultivation-focused method advances Qi quickly; an expedition-focused method improves resource yield. Expedition materials can buy an enduring cultivation improvement or make the next advancement easier. The player then has a reason to compare routes and to return after an absence.

This example needs balancing and testing. It is not an agreed specification. Make ordinary advancement achievable without a rare random drop, expose the useful effect before a choice, and avoid an optimal strategy that demands constant technique swapping. An offline plan should remain useful when the player closes the game.

Before adding another menu, answer: what does its reward change; which existing system uses it; what decision does it create; and when can the player notice the result? Evaluate playtests by whether players form a next goal, recognize a bottleneck, and can explain their choice. Automated save and UI checks cannot answer those questions.

The current milestone should therefore be treated as infrastructure and a first pacing experiment. A more complete experience needs reasons to choose, discover, and anticipate. That can be tested with a compact connected loop before committing to many realms, a large item catalog, or prestige.
