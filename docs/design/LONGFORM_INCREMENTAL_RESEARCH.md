# Long-form incremental research for Dao's End

Research date: **2026-10-23**. User target: **300 hours of active play**, with reduced offline growth. This is a long-term design ambition, not an implemented or validated duration. No gameplay code changed.

## Evidence boundaries

This note extends `IDLE_CULTIVATION_RESEARCH.md`. Evidence consists of official publisher descriptions and inspected official source. None of these games was playtested for this research. Store descriptions establish advertised features, not balance or enjoyment. Mutable `main` source establishes inspected behavior, not every deployed version. No reviews, session-time counters, or inferred completion times substantiate a 300-hour claim.

## Four useful references

### Immortality Idle: several kinds of persistent development

**Official source inspection:** reincarnation turns a life's attribute gains into aptitude. Soul-core upgrades improve future aptitude gain; meridian upgrades expand the aptitude benefit; bloodline rank affects what subsequent lives retain. These are separate interventions in future growth rather than one identical reset reward. [Character implementation](https://github.com/immortalityidle/immortalityidle.github.io/blob/main/src/app/game-state/character.service.ts)

Its loop loads elapsed time into banked ticks, then consumes them through accelerated simulation. It demonstrates an alternative to paying every offline activity immediately at full rate. [Main-loop implementation](https://github.com/immortalityidle/immortalityidle.github.io/blob/main/src/app/game-state/main-loop.service.ts)

**Design inference:** a new life should change the player's plan, retention rules, or access to builds. For Dao's End, one well-defined reincarnation system is enough initially; implementing several reset layers immediately would multiply balancing and migration work.

### xiuzhen idle: change the scale of decisions

**Publisher description:** realms progressively unlock production and cultivation activities, later sect management with disciples and facilities, and eventually world creation. Its lifespan/rebirth loop awards talent bonuses from cultivation. The developer explicitly describes the implementation as a simple progress-bar simulation and acknowledges promotional exaggeration. [Official Steam page](https://store.steampowered.com/app/1649730/xiuzhen_idle/)

**Design inference:** progression can move from improving oneself to arranging relationships between systems. This does not mean Dao's End should implement a sect simulator and world creation now. A realm should first change the available decisions in the existing loop.

### Your Chronicle: automate routine, retain composition and branching

**Publisher description:** the game advertises automated dungeon battles, summoned monsters with skills/equipment, routine upgrades, action/dungeon automation, branching endings, and offline bonuses. Its claimed thousands of story actions are not evidence of thousands of meaningful mechanical decisions. [Official Steam page](https://store.steampowered.com/app/1546320/Your_Chronicle/)

**Design inference:** useful structures include selecting a team/build and automating mastered tasks. Its text-based presentation and huge story-action catalog are unsuitable visual references for this project. Adapt system relationships, not its menu or narrative volume.

### Melvor Idle: resource dependencies make preparation matter

**Publisher description:** skills interact with each other; combat has multiple styles, monsters, bosses, and equipment supported by noncombat production. Its item and skill counts describe breadth, not active playtime. [Official Steam page](https://store.steampowered.com/app/1267910/Melvor_Idle/)

**Historical developer documentation:** version 0.21 introduced tick-based offline combat using online combat rules, including consumption, dynamic effects, and death. This illustrates the complexity of a simulation beyond awarding saved production multiplied by elapsed time. Its historical 12-hour cap must not be represented as the current cap. The current wiki offline page returned HTTP 403 during this research, so current cap details remain unverified. [Developer changelog](https://wiki.melvoridle.com/w/V0.21)

**Design inference:** Dao's End can use short production chains that feed an understandable combat/preparation objective. It does not need Melvor's catalog size or punitive offline death.

## What “300 hours active” actually requires

Use three separate measures:

| Measure | What it means | What it does not prove |
| --- | --- | --- |
| Engaged session time | Player plans, experiments, fights a challenge, compares results, or chooses a route | That every second contains a click |
| Foreground waiting | Client remains open while automated actions run | Active engagement |
| Offline elapsed time | Growth is computed while the player is absent | Playtime |

These are proposed evaluation definitions, not universally standardized metrics. Analytics can approximate engagement through interaction and focus, but cannot reliably measure attention; use observed playtests and interviews too.

Generating 500 equipment names, exponential costs, or repeated realm stages is relatively inexpensive. Making their interactions legible, balanced, varied, illustrated, save-safe, and worth revisiting is the substantial work. A simulation taking 300 hours to clear proves a duration under that strategy; it does not prove 300 hours of active enjoyment.

For this target, long-term depth should come from **different build problems**: route choice, enemy traits, resource tradeoffs, technique interactions, finite challenge sets, and reincarnation constraints. New content must change an approach rather than simply require a larger number. Automatically handle solved repetitive work as the player advances. Avoid adding mandatory micro-management to inflate measured activity.

## Reduced offline growth: proposed experiment

User preference authorizes rebalancing, but a blanket offline penalty risks rewarding an unattended open tab. Keep baseline idle simulation equivalent whether the client is open or closed. Separately reward meaningful engaged actions: first clears, solving a challenge, exploration branches, and build achievements.

One **unvalidated starting experiment** is 30% baseline cultivation and repeat-resource production in both unattended foreground and offline simulation, with an eight-hour offline cap. Active objectives award additional resources and discoveries; do not supply a bonus merely for focus or recent arbitrary clicks. Exact rates and any approach for recognizing unattended foreground need an explicit implementable spec before code changes. No existing save resource should be confiscated during migration.

Compare active, unattended-open, overnight-return, and irregular-return strategies. Offline support should leave useful preparation and a clear next objective without completing major first clears automatically. Reassess the rate from tests; 30% is not genre evidence or an established project rule.

## Practical scope recommendation

Design the 300-hour roadmap, then validate an initial **5–10-hour engaged-play slice** with several genuinely different challenge/build problems and a meaningful ending. Expand after observed play reveals its strengths. Maintain a content matrix recording each region's rule, builds supported, rewards, prerequisite, visual needs, and estimated engaged/wait/offline time separately. Treat every hour estimate as provisional until tested.

The researched games support connected progression, automation, preparation, and persistent growth as reference structures. They do not demonstrate that the current Dao's End architecture or content can already support this target, nor that menu-based implementation makes it easy.
