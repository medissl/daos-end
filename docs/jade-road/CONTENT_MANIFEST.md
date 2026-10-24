# Jade Road content manifest

Source of truth: `data/jade_road.json` (definition version 1). Live stats are evaluated by `chapter_data.gd`; combat rules are in `combat.gd`.

## Six finite routes

| Region / route | Stable ID | Four node IDs | First-clear item |
|---|---|---|---|
| Misty Mountain / Stone Steps | stone_steps | steps_scout, steps_plated, steps_channeler, stone_guardian | Pinewood Sword |
| Misty Mountain / Cloud Bridge | cloud_bridge | bridge_warded, bridge_plated, bridge_veiled, cloud_sentry | Stoneweave Robe |
| Misty Mountain / Hermitâ€™s Cleft | hermits_cleft | cleft_thorned, cleft_warded, cleft_channeler, cleft_keeper | Beast Bone Ring |
| Spirit River / Reed Shallows | reed_shallows | reed_scout, reed_venomous, reed_healer, reed_guardian | River Needle |
| Spirit River / Broken Ford | broken_ford | ford_plated, ford_venomous, ford_channeler, ford_watcher | Cinnabar Blade |
| Spirit River / Lotus Pools | lotus_pools | lotus_warded, lotus_veiled, lotus_healer, lotus_warden | River Silk |

Every distinct route finale grants one Core Seal. Ordinary node rewards can repeat; first-clear item/seal/art history cannot.

## 24 encounter definitions

| ID / name | Traits | HP / armor / attack / interval | Qi / herbs / stones | Art family |
|---|---|---|---|---|
| steps_scout / Cloudpath Scout | scout | 148 / 1 / 7 / 3s | 320 / 1 / 6 | crane |
| steps_plated / Mossback Sentinel | plated | 180 / 7 / 8 / 3s | 420 / 1 / 8 | sentinel |
| steps_channeler / Bellstone Adept | channeler | 170 / 2 / 7 / 3s | 480 / 1 / 9 | crane |
| stone_guardian / Stone Gate Guardian | plated, channeler | 360 / 8 / 5 / 4s | 1400 / 2 / 25 | sentinel |
| bridge_warded / Sealwing Crane | warded | 160 / 2 / 7 / 3s | 360 / 1 / 7 | crane |
| bridge_plated / Bridgeback Sentinel | plated | 182 / 7 / 8 / 3s | 440 / 1 / 8 | sentinel |
| bridge_veiled / Mistwing Crane | veiled | 174 / 2 / 8 / 3s | 500 / 1 / 9 | crane |
| cloud_sentry / Cloud Sentry | warded, veiled | 390 / 3 / 10 / 3s | 1500 / 2 / 27 | crane |
| cleft_thorned / Briarback Tortoise | thorned | 170 / 1 / 7 / 3s | 380 / 1 / 7 | tortoise |
| cleft_warded / Cleft Sealkeeper | warded | 178 / 2 / 8 / 3s | 460 / 1 / 8 | crane |
| cleft_channeler / Hollow Bell Keeper | channeler | 185 / 2 / 8 / 3s | 520 / 1 / 10 | crane |
| cleft_keeper / Cleft Keeper | thorned, warded | 340 / 2 / 9 / 3s | 1600 / 2 / 28 | tortoise |
| reed_scout / Reedwater Scout | scout | 180 / 2 / 9 / 3s | 440 / 1 / 8 | crane |
| reed_venomous / Jade Reed Serpent | venomous | 180 / 2 / 6 / 3s | 520 / 1 / 10 | serpent |
| reed_healer / Lotus Mender | healer | 205 / 2 / 8 / 3s | 580 / 1 / 11 | tortoise |
| reed_guardian / Reed Guardian | venomous, healer | 380 / 3 / 9 / 3s | 1700 / 2 / 30 | serpent |
| ford_plated / Fordstone Sentinel | plated | 205 / 8 / 9 / 3s | 480 / 1 / 9 | sentinel |
| ford_venomous / Waterline Serpent | venomous | 190 / 2 / 7 / 3s | 560 / 1 / 10 | serpent |
| ford_channeler / Flood Bell Keeper | channeler | 210 / 3 / 9 / 3s | 620 / 1 / 12 | crane |
| ford_watcher / Ford Watcher | channeler, venomous | 400 / 4 / 11 / 3s | 1800 / 2 / 32 | serpent |
| lotus_warded / Pool Sealkeeper | warded | 190 / 2 / 8 / 3s | 500 / 1 / 9 | crane |
| lotus_veiled / Moonmist Crane | veiled | 200 / 3 / 9 / 3s | 580 / 1 / 11 | crane |
| lotus_healer / White Lotus Mender | healer | 220 / 2 / 9 / 3s | 660 / 1 / 12 | tortoise |
| lotus_warden / Lotus Warden | warded, healer | 400 / 3 / 10 / 3s | 1900 / 2 / 34 | tortoise |

## Optional trials

| ID / name | Objective | Item |
|---|---|---|
| ward_trial / Ward Breaking | Break nine barrier layers and win within 60s. | Jade Pendant |
| poison_trial / Poison Survival | Survive 30s and cleanse poison at least twice. | Mystic Gourd |
| burst_trial / Burst Defense | Endure three bursts; shield at least one and retain 25% HP. | Travellerâ€™s Robe |
| focus_trial / Limited Focus | Win in 45s. Focus cap 6; recovery base 0.25/s; total skill budget 12. | No item; guaranteed resources |
| reflection_trial / Reflected Damage | Skills only: no basic strike. Win with at most 30 reflected damage. | No item; guaranteed resources |
| mixed_trial / Three Currents | Three finite encounters: barriers, poison, then burst. Camp between counters. | No item; guaranteed resources |

First successful trial completion grants 2,000 Qi, 4 herbs and 35 stones (60 for the three-encounter mixed sequence); trial rewards are not repeat farms. First Core Trial victory grants 2,500 Qi, 4 herbs and 50 stones.

## Equipment

| ID / item | Slot | Base effect | Deterministic source |
|---|---|---|---|
| pine_sword / Pinewood Sword | weapon | +3 attack Â· Sword potency +10% | Stone Steps first clear |
| cinnabar_blade / Cinnabar Blade | weapon | +2 attack Â· Flame lasts +1s | Broken Ford first clear |
| river_needle / River Needle | weapon | +2 attack Â· physical hits ignore 2 armor | Reed Shallows first clear |
| traveller_robe / Travellerâ€™s Robe | robe | +30 HP | Burst Defense trial |
| stoneweave_robe / Stoneweave Robe | robe | +15 HP Â· +2 armor | Cloud Bridge first clear |
| river_silk / River Silk | robe | +15 HP Â· incoming DOT damage âˆ’50% | Lotus Pools first clear |
| jade_pendant / Jade Pendant | artifact | +5 HP Â· +0.25 focus/s | Ward Breaking trial |
| mystic_gourd / Mystic Gourd | artifact | +10 HP Â· healing received +25% | Poison Survival trial |
| bone_ring / Beast Bone Ring | artifact | +1 attack Â· shields granted +25% | Hermitâ€™s Cleft first clear |

Refinement R1/R2/R3 costs 2,500/7,500/22,500 Qi and 15/30/60 stones. Flat stats scale by 1 + 0.2 × level; secondary effects stay fixed. Four combat arts and their exact costs, cooldowns and descriptions remain in the JSON skills table.

Core requirements: 75,000 Qi, three distinct finale seals, at least two routes in each region and a separate Core Trial win. Optional 24-herb preparation reduces incoming Core Trial damage by 10%. Golden Core has multiplier 8, three ordered art slots and one free preset. No later chapter is implemented.
