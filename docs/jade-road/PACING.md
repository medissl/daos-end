# Jade Road pacing and build evidence

Measured on 2026-10-23. Machine-readable inputs/results:
[earned path](CHAPTER_REACHABILITY.json), [build comparisons](BUILD_COMPARISONS.json),
[economy comparison](ECONOMY_COMPARISON.json). These are deterministic simulations,
not human playtest hours. Real-time browser observations are recorded separately
in [NORMAL_BROWSER_RESULTS.json](NORMAL_BROWSER_RESULTS.json).

## Earned chapter path

The entry fixture is Foundation with capped tutorial practices, 0 Qi, 12 herbs,
Azure selected and no chapter gear/history. It starts an authorized Bamboo trip.
All chapter arts, equipment, stones and clears are earned through public actions.
Every checkpoint is serialized and validated. The automated policy changes
builds at safe camps and uses separate purchases; it records 34 action decisions.

| Milestone | Cumulative simulated wall time | Interpretation |
|---|---:|---|
| First Stone Steps route | 138s | Sword initially; Flame equipped at discovery camp |
| Six routes | 721s | About 12 minutes of foreground combat waiting |
| Six optional trials too | 945s | About 15.75 minutes of combat waiting |
| Separate Core Trial won | 1009s | About 16.82 minutes of combat waiting |
| Golden Core purchased | 2709s | About 45.15 minutes total, including 1700s retreat waiting |

This falls well short of several hours of engaged play. It does **not** establish
300 hours, or even 45 minutes of engagement. Human build experimentation,
discovery and tutorial play are additional and unmeasured. Do not extend timers
to make that target appear satisfied. The chapter needs a gameplay/balance
review before further content.

## Useful choices and weak choices

Seeded fresh-encounter comparisons grant their documented equipment up front;
they are not progression reachability claims. Focus won 22/24 encounters, guard
24/24, mixed 24/24 and naive 17/24. Encounters reset HP between nodes by design.

With the same bare Sword/Flame build against the first finale:

| Method | Max HP | Focus/s | Outcome |
|---|---:|---:|---|
| None | 120 | 0.5 | Defeat at 70s |
| Azure | 135 | 1.0 | Win at 63s, 27 HP left |
| Iron | 150 | 0.75 | Win at 76s, 22.5 HP left |

Foundation resonance accounts for the half-strength inactive method. Azure's
additional focus supports more Flame actions; Iron's HP supports survival.
For Azure Ward/Flame with both methods M1, Ward/Flame M1, Pine/Stoneweave/Bone
and herb preparation, unrefined gear loses the Core Trial at 66s. R1 on all
three items wins at 64s with 15.78 HP: 7,500 Qi and 45 stones total. R2 wins in
60s with 22.11 HP, at cumulative 30,000 Qi/135 stones. R3 wins in 58s with
33.84 HP, at cumulative 97,500 Qi/315 stones. Secondary effects stay fixed.
This proves a useful R1 threshold, not equal value for every refinement level.

Guard Ward/Flame with Pine/Stoneweave/Bone is practically dominant on ordinary
routes. Poison survival requires an actual cleanse build; reflected-damage
limits favor Flame ticks; the mixed sequence remains solvable by the normal
guard build. The limited-focus trial is weak: even the naive seeded policy can
solve it in 42s. These are remaining design weaknesses, not concealed successes.

## Exact tuning during implementation

Stone Gate Guardian HP 360 and armor 8 were retained. Its attack changed from
10 to 5 and strike interval from 3s to 4s because both bare Azure and Iron
entrants died before they could earn the intended first gear/Ward reward.
This restored the deterministic starting path without inflating HP/timers.

Burst-defense trial requires surviving three bursts over 30s, shielding at
least one, and retaining 25% HP. The initial provisional 40-point absorbed-damage
target punished armor, which reduced the damage available to absorb. The
final objective measures shielding a burst and survival instead. Azure mastery
is the authorized 4/8 herbs; Iron remains 8/16. Tutorial Qi formulas are intact.

## Visible, closed and repeated play

Identical earned-build Foundation fixtures have resources zeroed and the same
authorized Bamboo trip. No new completion history is granted for these cases.

| Mode / wall time | Effective simulation | Qi | Herbs | Stones |
|---|---:|---:|---:|---:|
| Visible retreat, 1h | 1080s | 37,260 | 72 | 0 |
| Closed retreat, 1h | 1080s | 37,260 | 72 | 0 |
| Visible or closed retreat, 8h | 8640s | 298,080 | 576 | 0 |
| One authorized foreground journey then retreat, 1h | 1139.5s | 41,932.75 | 85 | 48 |
| One authorized closed journey then retreat, 1h | 1080s | 39,880 | 77 | 48 |
| 43 explicit foreground departures, 1h | 3600s | 234,560 | 451 | 2022 |
| Nine-hour return, capped at eight hours | 8640s | 298,080 | 576 | 0 |

Visible and closed retreat match. A finite authorized frontier segment resolves
once; it never chooses another route. Explicit repeated starts earn more, but
most of that time remains passive combat waiting. Replaying solved routes for
stones is repetitive. Future design should add decisions and useful counters,
not classify foreground idling as engagement or add mandatory reaction taps.
