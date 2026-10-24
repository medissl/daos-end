# Milestone two pacing comparison

Measured October 23, 2026 using the production state/rules in
`tests/simulate_pacing.gd`. Exact purchase timestamps, remaining resources,
committed/current production and next-departure effects are in
`MILESTONE_2_PACING.json`. These are deterministic policy comparisons, not a
global optimum search or evidence of player enjoyment. No balance values were
changed beyond those specified in the implementation brief.

## Opening comparison

All fresh policies buy Breathing, Breathing, Meridian, Breathing, Mind,
Breathing, Meridian as soon as affordable, then save 800 Qi and advance.
Starter purchases total **1,375 Qi**, followed by **800 Qi** for advancement.
The first purchase is at **25 seconds**. Qi Refining is at **426.07 seconds
(7:06)**, retaining all seven purchases and producing **15 Qi/s**.

With the old 3,000-Qi prepared requirement, that same order takes 719.40 seconds
(11:59). The specified opening change saves 293.33 seconds, about 40.8%.
This comparison holds the purchase order constant. Buying nothing takes
1,200 seconds to reach the unprepared Mortal requirement.

## Three investment policies

Trips start immediately at Qi Refining, repeat remains on, decisions are made
at meaningful events, and no time is replayed per frame. A new mastery purchase
at a completion event still waits through the trip that has already departed.

| Policy | Decisions before Foundation | Fresh: Foundation | Migrated: Foundation | Herbs: mastery / preparation / advancement | Next departure after Foundation |
| --- | --- | --- | --- | --- | --- |
| Cultivation-first | Azure primary; deepen Azure twice; no preparation | 25:06 | 18:00 | 24 / 0 / 12 | 42 Qi/s; 5 herbs/trip |
| Gathering/preparation-first | Iron primary; deepen Iron once; prepare | 17:06 | 10:00 | 8 / 12 / 12 | 33 Qi/s; 8 herbs/trip |
| Mastery-first | Iron primary; deepen Iron twice, then Azure twice; prepare | 25:06 | 18:00 | 48 / 12 / 12 | 36 Qi/s; 10 herbs/trip |

“Migrated” starts already in Qi Refining with 1,000 stored Qi, capped starter
upgrades, zero herbs/mastery/absence and no selected method or active trip.
It goes through the version-one state conversion. Its Qi Refining timestamp
is zero because that realm was already earned. Fresh timestamps include the
7:06 opening.

The production column describes the next departure, when resonance applies.
The immediate rate may be lower if Foundation was reached during a committed
trip. The policies retain different methods and mastery, so they do not end
in identical states.

## Controls and practical dominance

| Simpler control | Fresh: Foundation | Migrated: Foundation | Herbs spent | Next Qi/s; herbs/trip |
| --- | --- | --- | --- | --- |
| Azure, no mastery or preparation | 16:22 | 8:20 | 12 advancement | 36; 5 |
| Iron, no mastery or preparation | 18:13 | 10:00 | 12 advancement | 33; 6 |
| Iron, preparation only | **15:06** | **8:00** | 12 preparation + 12 advancement | 33; 6 |

For the sole objective of reaching Foundation in these starting states,
**Iron plus preparation without mastery is the fastest tested policy**.
Azure mastery before advancement is a poor investment: it delays herbs that
already constrain advancement, while the extra Qi accumulates unused. The
cultivation-first policy finishes with approximately **10,880 surplus Qi**.
Merely having two methods therefore does not establish a balanced choice.

Mastery retains value for later herb production and completion of the other
techniques. These differing end states prevent a claim of strict dominance
over every future objective. However, after capped practices and Foundation,
Qi has no additional spending purpose within this milestone. The apparent
benefit of higher Qi production should not be presented as meaningful long-term
depth at this boundary.

Preparation helps Iron in this comparison because its extra herb trips cost
less time than saving the additional 3,000 Qi. For Azure, those extra herbs can
be the slower requirement. A blanket recommendation to prepare or deepen
everything as soon as possible is unjustified.

## Ordinary-speed browser evidence

One fresh isolated browser journey, without seeds or acceleration, completed:

- First purchase around 37 seconds including load, persistence observation and
  input latency; the saved resource had crossed 25 at the preceding poll.
- All seven starter purchases and the prepared Mortal requirement by 445.49s;
  Qi Refining followed through the real advancement control.
- Iron departure, Azure queued, repeat stopped; first full trip at 576.03s.
- A second full trip, Azure mastery 1 purchased, Iron queued, then preparation.
- Foundation action at 1,188.85s (19:49); current trip still had its old bonus.
- Resonance observed on the next departure at 1,307.46s.
- A real 12-second page absence plus load time retained the trip and credited
  about 18.095 seconds between saved observations at 34.5 Qi/s.

This mixed verification route intentionally exercises stop/restart and queued
changes; it is not one of the optimized policy simulations. Resource polling
observes ten-second autosave intervals and adds input/check latency. The full
ordinary run was recorded while the final icon presentation was still being
finished. Final illustrated controls are separately exercised with explicit
browser fixtures; those captures are not claimed as fresh unseeded progression.
See `normal-browser-results.json` and `browser-results.json` in the milestone
screenshots directory.

## Suggestions for a later balance review — not implemented

Compare a lower Azure mastery herb price or a higher Foundation Qi requirement
in a separate simulation, then playtest whether players can explain a useful
reason to choose each path. Raising the Qi requirement could add waiting, so
it should not be adopted solely to equalize a spreadsheet.

Review whether mastery should compete with advancement at the present prices
and whether higher post-Foundation Qi has a useful purpose before adding any
new systems. Keep this milestone stopped at Foundation for that review.
