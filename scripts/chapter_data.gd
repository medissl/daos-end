extends RefCounted
## Stable configurable content, independent of the presentation and save names.
static var definitions: Dictionary = {}
static func all() -> Dictionary:
	if definitions.is_empty():
		definitions = JSON.parse_string(FileAccess.get_file_as_string("res://data/jade_road.json"))
		var chapter: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/living_dao.json"))
		for key in chapter:
			if definitions.has(key) and definitions[key] is Dictionary: definitions[key].merge(chapter[key],true)
			else: definitions[key] = chapter[key]
	return definitions

static func enemy(source: Dictionary) -> Dictionary:
	var d = {"name": "Guardian", "traits": [], "hp": 180.0, "armor": 2.0, "attack": 8.0, "interval": 3.0, "resistance": 0.0, "barriers": 4, "poison": 3.0, "poison_duration": 6, "reflect": 3.0, "heal": .08, "heal_interval": 6, "burst": 2.5, "burst_interval": 10, "phase_period": 6, "phase_length": 2, "stones": 8, "qi": 400, "herbs": 1, "art": "sentinel"}
	d.merge(source, true)
	# JSON decodes numbers as floats. Canonicalize defaults as well, so a
	# partial trial/Core definition compares identically after persistence.
	for key in d:
		if d[key] is int:
			d[key] = float(d[key])
	return d

static func stats(state: RefCounted, constraint: Dictionary = {}) -> Dictionary:
	var build = {"realm": state.realm, "mastery": state.mastery.duplicate(), "inventory": state.inventory.duplicate(), "equipment": state.equipment.duplicate(), "primary": state.pending_primary if not state.pending_primary.is_empty() else state.primary, "combat_slots": state.combat_slots.duplicate(), "combat_mastery": state.combat_mastery.duplicate(), "core_prepared": state.core_prepared, "law":state.law, "preparation":constraint.get("preparation", "")}
	return evaluate(build, constraint)

static func evaluate(build: Dictionary, constraint: Dictionary = {}) -> Dictionary:
	var multiplier: float = 12.0 if build.realm == "Nascent Soul" else (8.0 if build.realm == "Golden Core" else 4.0)
	var d = {"hp": 30.0 * multiplier, "attack": 3.0 * multiplier, "armor": floor(log(multiplier) / log(2)), "resistance": 0.0, "focus_cap": float(constraint.get("focus_cap", 10)), "focus_start": 5.0, "focus_regen": float(constraint.get("focus_base", .5)), "burst_reduction":0.0, "refund_bonus":0.0, "law":build.get("law",""), "sword_bonus": 0.0, "burn_duration": 0.0, "pierce": 0.0, "dot_reduction": 0.0, "healing_bonus": 0.0, "shield_bonus": 0.0, "incoming": .9 if build.core_prepared and constraint.get("core", false) else 1.0}
	for slot in build.equipment:
		var id: String = build.equipment[slot]
		if id.is_empty():
			continue
		var item: Dictionary = all().items[id]
		for key in ["hp", "attack", "armor"]:
			d[key] += item.get(key, 0.0) * (1.0 + .2 * build.inventory[id])
		for key in ["burst_reduction", "refund_bonus", "sword_bonus", "burn_duration", "pierce", "dot_reduction", "focus_regen", "healing_bonus", "shield_bonus"]:
			d[key] += item.get(key, 0.0)
	var prep: Dictionary = all().preparations.get(constraint.get("preparation",""),{})
	d.burst_reduction = minf(.45,d.burst_reduction+prep.get("burst_reduction",0))
	d.attack *= prep.get("attack_multiplier",1.0)
	d.healing_bonus += prep.get("healing_bonus",0.0)
	var method: String = build.primary
	for id in ["azure", "iron"]:
		var strength = 1.0 if method == id else (.5 if method != "none" else 0.0)
		if id == "azure":
			d.focus_regen += (.5 + .125 * build.mastery.azure) * strength
		else:
			d.hp *= 1.0 + (.25 + .05 * build.mastery.iron) * strength
	d.focus_start = minf(d.focus_start, d.focus_cap)
	d.slots = build.combat_slots.duplicate()
	d.mastery = build.combat_mastery.duplicate()
	d.method = method
	d.build = build.duplicate(true)
	return d
