extends SceneTree
const State = preload("res://scripts/cultivation_state.gd")
const Data = preload("res://scripts/chapter_data.gd")
const Combat = preload("res://scripts/combat.gd")

func actor(method: String, slots: Array, items: Array, level: int = 0) -> RefCounted:
	var s = State.new()
	s.realm = "Foundation Establishment"
	s.levels = {"breathing": 4, "meridian": 2, "mind": 1}
	s.primary = method
	s.learned = ["sword", "flame", "ward", "river"]
	s.combat_slots = slots.duplicate()
	for id in items:
		s.inventory[id] = level
		s.equip(id)
	return s

func _initialize() -> void:
	var policies = {
		"focus": actor("azure", ["sword", "flame"], ["pine_sword", "traveller_robe", "jade_pendant"]),
		"guard": actor("iron", ["ward", "flame"], ["cinnabar_blade", "stoneweave_robe", "bone_ring"]),
		"mixed": actor("iron", ["river", "flame"], ["river_needle", "river_silk", "mystic_gourd"]),
		"naive": actor("none", ["sword", ""], [])}
	var report = {"kind": "Explicit seeded build/encounter comparisons, not ordinary progression or engaged play", "policies": {}, "trials": {}, "core": [], "azure_core_refinement": [], "method_ablation": []}
	for name in policies:
		var rows = []
		for id in Data.all().enemies:
			var b = Combat.begin(Data.stats(policies[name]), Data.all().enemies[id])
			Combat.advance(b, 90)
			rows.append({"enemy": id, "outcome": b.outcome, "seconds": b.ticks * Combat.STEP, "hp": b.hp, "focus_spent": b.focus_spent, "skills": b.skill_counts, "reason": b.reason})
		report.policies[name] = rows
		print(name, ": ", rows.filter(func(r): return r.outcome == "win").size(), "/24 wins; first boss ", rows[3])
	for id in Data.all().trials:
		var t: Dictionary = Data.all().trials[id]
		var rows = []
		for name in policies:
			var policy: RefCounted = policies[name]
			var sequence: Array = t.sequence if t.has("sequence") else [t.enemy]
			var elapsed = 0.0
			var encounters = []
			var b: Dictionary
			for enemy in sequence:
				b = Combat.begin(Data.stats(policy, t), enemy, t)
				Combat.advance(b, 90)
				elapsed += b.ticks * Combat.STEP
				encounters.append({"outcome":b.outcome,"seconds":b.ticks * Combat.STEP,"hp":b.hp})
				if b.outcome != "win": break
			rows.append({"policy": name, "outcome": b.outcome, "seconds": elapsed, "encounters":encounters, "hp": b.hp, "reason": b.reason, "bursts": b.bursts, "blocked": b.blocked, "cleanses": b.cleanses})
		report.trials[id] = rows
		print(id, " ", rows)
	for method in ["azure", "iron"]:
		var newcomer = actor(method, ["sword", "flame"], [])
		var first = Combat.begin(Data.stats(newcomer), Data.all().enemies.stone_guardian)
		Combat.advance(first, 90)
		print("First route, no equipment ", method, " ", first.outcome, " ", first.ticks * Combat.STEP, "s HP ", first.hp)
		for level in range(4):
			var s = actor(method, ["river", "flame"] if method == "azure" else ["ward", "flame"], ["pine_sword", "traveller_robe", "mystic_gourd"] if method == "azure" else ["pine_sword", "stoneweave_robe", "bone_ring"], level)
			s.mastery = {"azure": 1, "iron": 1}
			s.combat_mastery = {"sword": 0, "flame": 1, "ward": 1, "river": 1}
			s.core_prepared = true
			var b = Combat.begin(Data.stats(s, {"core": true}), Data.all().core, {"core": true})
			Combat.advance(b, 90)
			var row = {"method": method, "refinement": level, "outcome": b.outcome, "seconds": b.ticks * Combat.STEP, "hp": b.hp, "reason": b.reason}
			report.core.append(row)
			print("Core ", row)
	for slots in [["ward", "flame"], ["river", "flame"], ["river", "sword"]]:
		var s = actor("azure", slots, ["pine_sword", "stoneweave_robe", "bone_ring"], 1)
		s.mastery = {"azure": 1, "iron": 1}
		s.combat_mastery = {"sword": 1, "flame": 1, "ward": 1, "river": 1}
		s.core_prepared = true
		var b = Combat.begin(Data.stats(s, {"core": true}), Data.all().core, {"core": true})
		Combat.advance(b, 90)
		print("Azure Core alternate ", slots, " ", b.outcome, " ", b.ticks * Combat.STEP, "s HP ", b.hp)
	for level in range(4):
		var s = actor("azure",["ward","flame"],["pine_sword","stoneweave_robe","bone_ring"],level)
		s.mastery = {"azure":1,"iron":1}
		s.combat_mastery = {"sword":0,"flame":1,"ward":1,"river":0}
		s.core_prepared = true
		var b = Combat.begin(Data.stats(s,{"core":true}),Data.all().core,{"core":true})
		Combat.advance(b,90)
		report.azure_core_refinement.append({"level_each_item":level,"total_qi_spent":3 * [0,2500,10000,32500][level],"total_stones_spent":3 * [0,15,45,105][level],"outcome":b.outcome,"seconds":b.ticks * Combat.STEP,"hp":b.hp})
	for method in ["none","azure","iron"]:
		var s = actor(method,["sword","flame"],[])
		var b = Combat.begin(Data.stats(s),Data.all().enemies.stone_guardian)
		Combat.advance(b,90)
		report.method_ablation.append({"method":method,"same_build":"Sword/Flame, no gear or mastery", "hp_max":b.stats.hp,"focus_regen":b.stats.focus_regen,"outcome":b.outcome,"seconds":b.ticks * Combat.STEP,"hp_left":b.hp,"skills":b.skill_counts})
	var file = FileAccess.open("res://docs/jade-road/BUILD_COMPARISONS.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t", true, true))
	file.close()
	quit()
