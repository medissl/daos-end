extends RefCounted
## Validate serialized chapter state before constructing it. Saved combat
## stats are recomputed from a bounded historical build, never trusted as input.
const Data = preload("res://scripts/chapter_data.gd")
const Legacy = preload("res://scripts/legacy/save_store.gd")
const Old = preload("res://scripts/legacy_v3/chapter_validation.gd")
const FIELDS = ["stones", "combat_mastery", "learned", "combat_slots", "inventory", "equipment", "cleared_nodes", "cleared_routes", "cleared_trials", "core_prepared", "core_trial_won", "preset", "journey", "reward_serial", "law", "preparation", "supply", "soul_trial_won"]

static func amount(x: Variant, maximum: float = 9007199254740991.0) -> bool:
	return Legacy.finite_number(x) and x >= 0 and x <= maximum

static func ids(value: Variant, allowed: Array) -> bool:
	if not value is Array or value.size() > allowed.size():
		return false
	var seen = []
	for id in value:
		if not id is String or not id in allowed or id in seen:
			return false
		seen.append(id)
	return true

static func levels(value: Variant, allowed: Array, cap: int, complete: bool = true) -> bool:
	if not value is Dictionary or (complete and value.size() != allowed.size()):
		return false
	for id in value:
		if not id in allowed or not Legacy.integer(value[id], 0, cap):
			return false
	return true

static func slots(value: Variant, learned: Array, count: int) -> bool:
	if not value is Array or value.size() != count:
		return false
	var seen = []
	for id in value:
		if not id is String or (not id.is_empty() and (not id in learned or id in seen)):
			return false
		if not id.is_empty():
			seen.append(id)
	return true

static func equipment(value: Variant, inventory: Dictionary) -> bool:
	if not value is Dictionary or value.size() != 3:
		return false
	for slot in ["weapon", "robe", "artifact"]:
		if not value.get(slot) is String:
			return false
		var id: String = value[slot]
		if not id.is_empty() and (not inventory.has(id) or Data.all().items[id].slot != slot):
			return false
	return true

static func valid(c: Dictionary, realm: String, mastery: Dictionary) -> bool:
	for key in FIELDS:
		if not c.has(key):
			return false
	var d = Data.all()
	if not c.journey is Dictionary or not c.inventory is Dictionary or not c.learned is Array: return false
	if not ids(c.cleared_routes,d.routes.keys()) or not ids(c.cleared_trials,d.trials.keys()): return false
	if not c.law is String or not c.preparation is String or not c.soul_trial_won is bool: return false
	if not c.law.is_empty() and not c.law in d.get("laws",{}): return false
	if not c.law.is_empty() and not d.laws[c.law].trial in c.cleared_trials: return false
	if not c.preparation.is_empty() and not c.preparation in d.get("preparations",{}): return false
	if realm not in ["Golden Core","Nascent Soul"]:
		if not c.law.is_empty() or not c.preparation.is_empty() or c.soul_trial_won: return false
		for id in ["thunder","returning","mirror"]:
			if id in c.learned: return false
		for id in c.cleared_routes:
			if d.realm_requirements.routes.has(id): return false
		for id in c.cleared_trials:
			if d.trials[id].has("region"): return false
	if not c.supply is Dictionary or not c.supply.get("active") is bool or not c.supply.get("route") is String: return false
	for key in ["remaining","completed"]:
		if not Legacy.integer(c.supply.get(key),0,6): return false
	if c.supply.remaining+c.supply.completed>6: return false
	if not c.supply.route.is_empty() and not d.routes.has(c.supply.route): return false
	for key in ["qi","stones","herbs"]:
		if not Legacy.integer(c.supply.get(key),0,100000000): return false
	if c.supply.active and (not c.supply.route in c.cleared_routes or c.supply.remaining<1 or c.journey.get("id")!=c.supply.route or c.journey.get("status")!="battle"): return false
	if not Legacy.integer(c.stones, 0, 9007199254740991) or not Legacy.integer(c.reward_serial, 0, 9007199254740991):
		return false
	if not levels(c.combat_mastery, d.skills.keys(), 2) or not levels(c.inventory, d.items.keys(), 3, false):
		return false
	if not ids(c.learned, d.skills.keys()) or not "sword" in c.learned or not slots(c.combat_slots, c.learned, slot_count(realm)):
		return false
	if not equipment(c.equipment, c.inventory) or not ids(c.cleared_nodes, d.enemies.keys()) or not ids(c.cleared_routes, d.routes.keys()) or not ids(c.cleared_trials, d.trials.keys()):
		return false
	if not c.core_prepared is bool or not c.core_trial_won is bool or not c.preset is Dictionary:
		return false
	var misty = 0
	var river = 0
	for id in c.cleared_routes:
		var route: Dictionary = d.routes[id]
		for node in route.nodes:
			if not node in c.cleared_nodes:
				return false
		if not c.inventory.has(route.item):
			return false
		if route.region == "Misty Mountain":
			misty += 1
		elif route.region=="Spirit River":
			river += 1
	for id in c.cleared_trials:
		var item: String = d.trials[id].item
		if not item.is_empty() and not c.inventory.has(item):
			return false
	if (c.core_trial_won or realm in ["Golden Core","Nascent Soul"]) and (misty < 2 or river < 2):
		return false
	if realm in ["Golden Core","Nascent Soul"] and (not c.core_trial_won or c.core_prepared):
		return false
	if not c.preset.is_empty():
		if realm not in ["Golden Core","Nascent Soul"] or not c.preset.get("primary") in ["none", "azure", "iron"] or not slots(c.preset.get("slots"), c.learned, slot_count(realm)) or not equipment(c.preset.get("equipment"), c.inventory):
			return false
		var preset_law: Variant = c.preset.get("law","")
		if not preset_law is String or (not preset_law.is_empty() and (not d.laws.has(preset_law) or not d.laws[preset_law].trial in c.cleared_trials)): return false
	if c.soul_trial_won != ("soul" in c.cleared_trials): return false
	if realm=="Nascent Soul":
		if not c.soul_trial_won: return false
		for id in d.realm_requirements.routes:
			if not id in c.cleared_routes: return false
		for place in d.realm_requirements.regional_coverage:
			var found = false
			for id in c.cleared_trials:
				if id.ends_with("_heir") and d.trials[id].region==place: found = true
			if not found: return false
	if realm in ["Mortal", "Qi Refining"] and (c.stones != 0 or not c.cleared_nodes.is_empty() or not c.inventory.is_empty() or c.core_prepared or c.core_trial_won or c.learned != ["sword"]):
		return false
	for id in c.combat_mastery:
		if c.combat_mastery[id] > 0 and not id in c.learned:
			return false
	return journey(c, realm, mastery)

static func slot_count(realm: String) -> int:
	return 4 if realm=="Nascent Soul" else (3 if realm=="Golden Core" else 2)

static func journey(c: Dictionary, realm: String, mastery: Dictionary) -> bool:
	var j: Variant = c.journey
	if not j is Dictionary or not j.get("status") in ["idle", "battle", "camp", "complete", "defeat"] or not j.get("id") is String or not j.get("battle") is Dictionary or not j.get("reason") is String or not j.get("camp_requested") is bool or not j.get("rewards") is Dictionary:
		return false
	if j.reason.length() > 500:
		return false
	if j.get("legacy_battle",false):
		if realm not in ["Foundation Establishment","Golden Core"]: return false
		var frozen = c.duplicate(true)
		for id in frozen.combat_mastery.keys():
			if not id in ["sword","flame","ward","river"]: frozen.combat_mastery.erase(id)
		return Old.journey(frozen,realm,mastery)
	for key in ["qi", "stones", "herbs"]:
		if not amount(j.rewards.get(key), 1000000000):
			return false
	if not ids(j.rewards.get("items"), c.inventory.keys()):
		return false
	if not ids(j.rewards.get("arts", []), c.learned):
		return false
	if j.status == "idle":
		return j.id.is_empty() and j.battle.is_empty() and j.get("node") == 0
	if realm in ["Mortal", "Qi Refining"]:
		return false
	var d = Data.all()
	var definition: Dictionary
	var constraint = {}
	var total = 1
	var position = int(j.get("node", -100)) - (1 if j.status in ["camp", "complete"] else 0)
	if d.routes.has(j.id):
		var route: Dictionary = d.routes[j.id]
		total = route.nodes.size()
		if position < 0 or position >= total:
			return false
		definition = d.enemies[route.nodes[position]]
	elif d.trials.has(j.id):
		constraint = d.trials[j.id]
		total = constraint.sequence.size() if constraint.has("sequence") else 1
		if position < 0 or position >= total:
			return false
		definition = constraint.sequence[position] if constraint.has("sequence") else constraint.enemy
	elif j.id == "core":
		definition = d.core
		constraint = {"core": true}
	else:
		return false
	var prep: Variant = j.get("preparation","")
	if not prep is String or (not prep.is_empty() and not d.preparations.has(prep)): return false
	constraint = constraint.duplicate(true)
	if not prep.is_empty(): constraint.preparation = prep
	if not Legacy.integer(j.get("node"), 0, total) or (j.status == "camp" and j.node >= total):
		return false
	return battle(j.battle, Data.enemy(definition), constraint, c, realm, mastery, j.status)

static func battle(b: Dictionary, enemy: Dictionary, constraint: Dictionary, c: Dictionary, realm: String, mastery: Dictionary, status: String) -> bool:
	if not b.get("stats") is Dictionary or not b.stats.get("build") is Dictionary or b.get("enemy") != enemy or b.get("constraint") != constraint:
		return false
	var build: Dictionary = b.stats.build
	if not build.get("realm") in ["Foundation Establishment", "Golden Core", "Nascent Soul"] or slot_count(build.realm)>slot_count(realm):
		return false
	if not levels(build.get("mastery"), ["azure", "iron"], 2) or not levels(build.get("combat_mastery"), Data.all().skills.keys(), 2) or not levels(build.get("inventory"), c.inventory.keys(), 3, false) or not equipment(build.get("equipment"), build.inventory):
		return false
	for id in build.inventory:
		if build.inventory[id] > c.inventory[id]:
			return false
	for id in build.mastery:
		if build.mastery[id] > mastery[id]:
			return false
	for id in build.combat_mastery:
		if build.combat_mastery[id] > c.combat_mastery[id]:
			return false
	if not build.get("primary") in ["none", "azure", "iron"] or not build.get("core_prepared") is bool or not slots(build.get("combat_slots"), c.learned, slot_count(build.realm)):
		return false
	if not build.get("law","") is String or (not build.get("law","").is_empty() and (not Data.all().laws.has(build.law) or not Data.all().laws[build.law].trial in c.cleared_trials)): return false
	if build.get("preparation","")!=constraint.get("preparation",""): return false
	if Data.evaluate(build, constraint) != b.stats:
		return false
	if not Legacy.integer(b.get("ticks"), 0, 1800) or not amount(b.get("carry"), .049999999999) or not b.get("outcome") in ["", "win", "defeat"] or (status == "battle" and b.outcome != ""):
		return false
	if (status in ["camp","complete"] and b.outcome!="win") or (status=="defeat" and b.outcome!="defeat"): return false
	if not b.get("reason") is String or b.reason.length() > 500 or not b.get("last_action") in ["Prepare", "strike", "counter"]+Data.all().skills.keys() or not b.get("last_enemy_action") in ["Watching", "strike", "burst", "heal"]:
		return false
	for key in ["hp", "enemy_hp", "focus", "shield", "blocked", "reflected"]:
		if not amount(b.get(key), 1000000):
			return false
	if b.hp > b.stats.hp or b.enemy_hp > enemy.hp or b.focus > b.stats.focus_cap or b.shield > b.stats.hp * .6:
		return false
	for key in ["shield_until", "next_enemy", "next_burst", "next_heal", "action_serial", "enemy_serial", "focus_spent", "cleanses", "bursts", "bursts_blocked", "barriers_broken", "barriers"]:
		if not Legacy.integer(b.get(key), 0, 10000):
			return false
	for key in ["interrupts","focus_refunded","counters","law_procs"]:
		if not Legacy.integer(b.get(key),0,10000): return false
	if not b.get("counter_ready") is bool: return false
	if not levels(b.get("skill_counts"), Data.all().skills.keys(), 200) or not levels(b.get("cooldowns"), Data.all().skills.keys(), 2200) or not b.get("damage") is Dictionary:
		return false
	if b.damage.size()!=4: return false
	for key in ["physical", "poison", "burst", "reflection"]:
		if not amount(b.damage.get(key), 1000000):
			return false
	for key in ["burn", "poison"]:
		if not b.get(key) is Dictionary:
			return false
		var effect: Dictionary = b[key]
		if effect.is_empty():
			continue
		if not Legacy.integer(effect.get("next"), int(b.ticks), int(b.ticks) + 20) or not Legacy.integer(effect.get("until"), int(b.ticks), int(b.ticks) + 140) or not amount(effect.get("damage"), 1000):
			return false
	return true
