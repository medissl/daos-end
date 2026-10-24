extends SceneTree
const Data=preload("res://scripts/chapter_data.gd")
const Rules=preload("res://scripts/progression.gd")
func _initialize() -> void:
	var d=Data.all().duplicate(true)
	for id in d.enemies: d.enemies[id]=Data.enemy(d.enemies[id])
	for id in d.trials:
		if d.trials[id].has("sequence"):
			for i in range(d.trials[id].sequence.size()): d.trials[id].sequence[i]=Data.enemy(d.trials[id].sequence[i])
		else: d.trials[id].enemy=Data.enemy(d.trials[id].enemy)
	d.core=Data.enemy(d.core)
	d.accounting={"tick_seconds":.05,"basic_interval":2,"default_limit":90,"skill_check_interval":1,"one_cast_per_check":true,"priority":"Left to right ordered slots; first eligible art only","mastery_multiplier":"1 + .15 per mastery, maximum 2","base_stats":"HP=30×realm multiplier; attack=3×realm multiplier; armor=floor(log2(multiplier))","realm_multipliers":Rules.REALM_MULTIPLIERS,"refine_cap":3,"refine_primary_growth":.2,"secondary_refine_growth":0,"ordinary_speed":1,"retreat_and_supply_speed":.3,"absence_cap_seconds":28800,"core_qi":Rules.CORE_QI,"soul_qi":Rules.SOUL_QI,"endurance_crossing_recovery":.15,"prepared_endurance_recovery":.25,"burst_reduction_cap":.45,"supply_circuits":[1,3,6],"supply_ui_circuits":3}
	FileAccess.open("res://docs/living-dao/CONTENT_RUNTIME.json",FileAccess.WRITE).store_string(JSON.stringify(d,"\t"))
	var lines=["# Living Dao runtime content table","","Generated from the shipped data and canonical enemy defaults. CONTENT_RUNTIME.json contains every trait timing, challenge sequence, cost, numeric item effect and rule. The table is the balance-review source; reachability reports use these values.","","| Route / unlock | Encounters (HP / attack / armor / interval seconds; traits) | First-clear reward |","|---|---|---|"]
	for id in d.realm_requirements.routes:
		var route: Dictionary=d.routes[id]
		var enemies=[]
		for node in route.nodes:
			var e: Dictionary=d.enemies[node]
			enemies.append("%s: %s / %s / %s / %s; %s" % [node,e.hp,e.attack,e.armor,e.interval,", ".join(e.traits)])
		lines.append("| %s — %s | %s | %s Qi + %s; %s |" % [id,route.region,"<br>".join(enemies),route.first_qi,route.item,route.grant_art if not route.grant_art.is_empty() else "no new art"])
	lines.append("\nThunder Peak unlocks at Golden Core. One Thunder clear opens the Tomb; one Tomb clear opens Moon Lake. Each new route awards ordinary 1200/1300/1400/1500 Qi, 16/18/20/22 stones, 2 herbs per node. First rewards occur once. Supply receives ordinary node rewards only. Moonless Crossing carries HP and restores 15% maximum HP between its four encounters; Lotus Broth changes that to 25%.")
	lines.append("\n| Art | Focus / cooldown | Exact behavior |\n|---|---|---|")
	for id in d.skills: lines.append("| %s | %s / %ss | %s |" % [id,d.skills[id].focus,d.skills[id].cooldown,d.skills[id].description])
	lines.append("\n| Inheritance | Objective / availability |\n|---|---|")
	for id in d.trials:
		if d.trials[id].has("region"): lines.append("| %s | %s — %s |" % [id,d.trials[id].region,d.trials[id].description])
	lines.append("\nEach inheritance awards 4500 first-clear Qi, 35 stones (60 for the two-stage Moon sequence), 4 herbs. The three-stage Soul tribulation awards 10000 Qi, 60 stones, 4 herbs. Every attempt is free. One completed route in that region opens its inheritances; all six new routes and one inheritance per new region open Soul. Nascent Soul requires those accomplishments, Soul victory and 90000 Qi, then earns slot four. No rare drops or repeat preparations are required.")
	lines.append("\n| Law | Unlock | Per-event rule |\n|---|---|---|")
	for id in d.laws: lines.append("| %s | %s | %s |" % [id,d.laws[id].trial,d.laws[id].description])
	lines.append("\n| Preparation | Price on successful Depart | Effect |\n|---|---|---|")
	for id in d.preparations: lines.append("| %s | %s herbs + %s stones | %s |" % [id,d.preparations[id].herbs,d.preparations[id].stones,d.preparations[id].description])
	lines.append("\nSelection/cancellation spends zero. A committed preparation persists across this journey's nodes and reload, never recharges. Finite supply rejects preparations. All build/law changes commit at the next encounter; no animation callback spends or awards.")
	lines.append("\n| Gear | Guaranteed source | Base and fixed secondary effects |\n|---|---|---|")
	for id in ["storm_thread","cloud_bell","seal_needle","ember_lantern","moon_silk","lake_blade"]: lines.append("| %s | %s | %s |" % [id,d.items[id].source,d.items[id].description])
	lines.append("\nRefine tiers 0–3 multiply HP/attack/armor by 1 + .2×tier; secondary bonuses do not scale. Tier costs: "+str(d.refine_qi)+" Qi and "+str(d.refine_stones)+" stones. Art mastery tiers 0–2 cost "+str(d.combat_mastery_qi)+" Qi and "+str(d.combat_mastery_herbs)+" herbs. Focus costs/cooldowns are never reduced by mastery. See the JSON for all original content too.")
	FileAccess.open("res://docs/living-dao/CONTENT_TABLE.md",FileAccess.WRITE).store_string("\n".join(lines)+"\n")
	print("Content table: 6 new routes / 24 encounters, 6 inheritances, 1 Soul tribulation")
	quit()
