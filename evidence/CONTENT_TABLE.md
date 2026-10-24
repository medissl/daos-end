# Living Dao runtime content table

Generated from the shipped data and canonical enemy defaults. CONTENT_RUNTIME.json contains every trait timing, challenge sequence, cost, numeric item effect and rule. The table is the balance-review source; reachability reports use these values.

| Route / unlock | Encounters (HP / attack / armor / interval seconds; traits) | First-clear reward |
|---|---|---|
| storm_ascent — Thunder Peak | storm_ascent_1: 300.0 / 15.0 / 3.0 / 3.2; channeler<br>storm_ascent_2: 330.0 / 16.0 / 4.0 / 3.2; <br>storm_ascent_3: 370.0 / 17.0 / 3.0 / 3.2; channeler, warded<br>storm_ascent_4: 460.0 / 18.0 / 4.0 / 3.2; channeler | 7500.0 Qi + storm_thread; thunder |
| thunder_crown — Thunder Peak | thunder_crown_1: 330.0 / 16.0 / 3.0 / 2.8; <br>thunder_crown_2: 380.0 / 17.0 / 4.0 / 2.8; channeler<br>thunder_crown_3: 400.0 / 18.0 / 3.0 / 2.8; channeler, venomous<br>thunder_crown_4: 480.0 / 19.0 / 4.0 / 2.8; channeler | 7500.0 Qi + cloud_bell; no new art |
| silent_gate — Ancient Tomb | silent_gate_1: 340.0 / 15.0 / 3.0 / 3.2; warded<br>silent_gate_2: 370.0 / 16.0 / 4.0 / 3.2; warded, veiled<br>silent_gate_3: 400.0 / 17.0 / 3.0 / 3.2; warded<br>silent_gate_4: 480.0 / 18.0 / 4.0 / 3.2; warded, channeler | 7500.0 Qi + seal_needle; returning |
| buried_sun — Ancient Tomb | buried_sun_1: 320.0 / 16.0 / 3.0 / 2.8; thorned<br>buried_sun_2: 350.0 / 17.0 / 4.0 / 2.8; thorned, healer<br>buried_sun_3: 380.0 / 18.0 / 3.0 / 2.8; thorned, veiled<br>buried_sun_4: 440.0 / 19.0 / 4.0 / 2.8; thorned, warded | 7500.0 Qi + ember_lantern; no new art |
| mirror_shore — Moon Lake | mirror_shore_1: 350.0 / 15.0 / 3.0 / 3.2; alternating<br>mirror_shore_2: 370.0 / 16.0 / 4.0 / 3.2; alternating, venomous<br>mirror_shore_3: 400.0 / 17.0 / 3.0 / 3.2; alternating, channeler<br>mirror_shore_4: 480.0 / 18.0 / 4.0 / 3.2; alternating | 7500.0 Qi + moon_silk; mirror |
| moonless_crossing — Moon Lake | moonless_crossing_1: 300.0 / 16.0 / 3.0 / 2.8; venomous<br>moonless_crossing_2: 320.0 / 17.0 / 4.0 / 2.8; channeler<br>moonless_crossing_3: 350.0 / 18.0 / 3.0 / 2.8; alternating, venomous<br>moonless_crossing_4: 430.0 / 19.0 / 4.0 / 2.8; alternating, channeler | 7500.0 Qi + lake_blade; no new art |

Thunder Peak unlocks at Golden Core. One Thunder clear opens the Tomb; one Tomb clear opens Moon Lake. Each new route awards ordinary 1200/1300/1400/1500 Qi, 16/18/20/22 stones, 2 herbs per node. First rewards occur once. Supply receives ordinary node rewards only. Moonless Crossing carries HP and restores 15% maximum HP between its four encounters; Lotus Broth changes that to 25%.

| Art | Focus / cooldown | Exact behavior |
|---|---|---|
| sword | 3.0 / 6.0s | Two physical hits, each 95% attack. |
| flame | 4.0 / 8.0s | 60% attack magic; then 40% each second for 4s. Refreshes, never stacks. |
| ward | 3.0 / 10.0s | Shield 30% HP for 6s. Times protection before charges; otherwise triggers below 65% HP. |
| river | 3.0 / 10.0s | Cleanse poison/burn and heal 20% maximum HP. |
| thunder | 4.0 / 12.0s | Interrupt one charge within 2s of release; 100% attack magic. Basic attacks continue. |
| returning | 3.0 / 7.0s | Two 70% physical hits. Breaking a barrier refunds 2 focus once per cast (maximum 3 with Seal Needle). |
| mirror | 3.0 / 9.0s | 18% HP shield for 4s. One absorbed strike retaliates for 120% attack magic; indirect damage never counters. |

| Inheritance | Objective / availability |
|---|---|
| earth_heir | Thunder Peak — Interrupt or shield at least one charged strike, then win. |
| fire_heir | Ancient Tomb — Use Flame and Sword or Returning in the same fight, then win. |
| water_heir | Moon Lake — Remove poison twice with River, then win. Choose offense or protection as companions. |
| thunder_heir | Thunder Peak — 24 focus total. Answer a charge through interruption or protection, then win. |
| tomb_heir | Ancient Tomb — Break nine layers and win within 24 focus. Returning refunds or Sword conserves casts. |
| moon_heir | Moon Lake — Two encounters; HP carries with 15% recovery. Finish with at least 25% HP. |
| soul | Moon Lake — Three continuous stages: charge, barrier, alternating venom. Build changes apply at each boundary. |

Each inheritance awards 4500 first-clear Qi, 35 stones (60 for the two-stage Moon sequence), 4 herbs. The three-stage Soul tribulation awards 10000 Qi, 60 stones, 4 herbs. Every attempt is free. One completed route in that region opens its inheritances; all six new routes and one inheritance per new region open Soul. Nascent Soul requires those accomplishments, Soul victory and 90000 Qi, then earns slot four. No rare drops or repeat preparations are required.

| Law | Unlock | Per-event rule |
|---|---|---|
| earth | earth_heir | A shield absorbing a charged hit refunds 2 focus once per charge. Poison and reflections do not trigger it. |
| fire | fire_heir | Sword against a burning target adds one indirect 35% attack hit per cast. Never refreshes burn or triggers itself. |
| water | water_heir | A real River cleanse grants a 10% HP shield for 3s. No poison removed means no shield. |

| Preparation | Price on successful Depart | Effect |
|---|---|---|
| storm | 4.0 herbs + 8.0 stones | Charged damage −15% for this route. Consumed once on Depart. |
| tomb | 3.0 herbs + 10.0 stones | Attack +10% for this route. Consumed once on Depart. |
| endurance | 6.0 herbs + 6.0 stones | Healing +15%; endurance crossings restore 25% HP instead of 15%. Consumed once on Depart. |

Selection/cancellation spends zero. A committed preparation persists across this journey's nodes and reload, never recharges. Finite supply rejects preparations. All build/law changes commit at the next encounter; no animation callback spends or awards.

| Gear | Guaranteed source | Base and fixed secondary effects |
|---|---|---|
| storm_thread | Storm Ascent first clear | +25 HP · +2 armor · charged damage −20% |
| cloud_bell | Thunder Crown first clear | +10 HP · +0.4 focus/s |
| seal_needle | Silent Gate first clear | +4 attack · ignore 2 armor · Returning refund +1 (cap 3) |
| ember_lantern | Buried Sun first clear | +2 attack · burn lasts +2s |
| moon_silk | Mirror Shore first clear | +35 HP · healing +20% · poison damage −25% |
| lake_blade | Moonless Crossing first clear | +5 attack · shields +15% |

Refine tiers 0–3 multiply HP/attack/armor by 1 + .2×tier; secondary bonuses do not scale. Tier costs: [2500.0, 7500.0, 22500.0] Qi and [15.0, 30.0, 60.0] stones. Art mastery tiers 0–2 cost [1000.0, 3000.0] Qi and [4.0, 8.0] herbs. Focus costs/cooldowns are never reduced by mastery. See the JSON for all original content too.
