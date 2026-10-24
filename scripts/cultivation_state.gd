extends RefCounted
const Rules = preload("res://scripts/progression.gd")
const Data = preload("res://scripts/chapter_data.gd")
const Combat = preload("res://scripts/combat.gd")
const OldCombat = preload("res://scripts/legacy_v3/combat.gd")
var law = ""
var preparation = ""
var soul_trial_won = false
var supply = {"active":false,"route":"","remaining":0,"completed":0,"qi":0,"stones":0,"herbs":0}
var preset_notice = ""
var qi: float = 0.0
var realm: String = "Mortal"
var levels: Dictionary = {"breathing": 0, "meridian": 0, "mind": 0}
var herbs = 0
var mastery = {"azure": 0, "iron": 0}
var primary = "none"
var pending_primary = ""
var prepared = false
var repeat = true
var trip = idle_trip()
var stones = 0
var combat_mastery = {"sword": 0, "flame": 0, "ward": 0, "river": 0, "thunder":0, "returning":0, "mirror":0}
var learned = ["sword"]
var combat_slots = ["sword", ""]
var inventory = {}
var equipment = {"weapon": "", "robe": "", "artifact": ""}
var cleared_nodes = []
var cleared_routes = []
var cleared_trials = []
var core_prepared = false
var core_trial_won = false
var preset = {}
var journey = {"status": "idle", "id": "", "node": 0, "battle": {}, "camp_requested": false, "rewards": {"qi": 0, "herbs": 0, "stones": 0, "items": []}, "reason": ""}
var reward_serial = 0

func chapter_unlocked() -> bool:
	return realm in ["Foundation Establishment", "Golden Core", "Nascent Soul"]

static func idle_trip() -> Dictionary:
	return {"active": false, "elapsed": 0.0, "primary": "none", "azure": 0.0, "iron": 0}

func unlocked() -> bool:
	return realm != "Mortal"

func base_rate() -> float:
	return (1.0 + levels.breathing) * (1.0 + .25 * levels.meridian) * Rules.REALM_MULTIPLIERS[realm]

func next_bonuses() -> Dictionary:
	return Rules.bonuses(pending_primary if not pending_primary.is_empty() else primary, mastery, chapter_unlocked())

func effective_bonuses() -> Dictionary:
	return trip if trip.active else Rules.bonuses(primary, mastery, chapter_unlocked())

func rate() -> float:
	return base_rate() * (1.0 + effective_bonuses().azure)

func cost(id: String) -> int:
	if not Rules.UPGRADES.has(id):
		return -1
	var definition: Dictionary = Rules.UPGRADES[id]
	return ceili(definition.cost * pow(definition.growth, levels[id]))

func purchase(id: String) -> bool:
	if not Rules.UPGRADES.has(id) or levels[id] >= Rules.UPGRADES[id].cap or qi < cost(id):
		return false
	qi -= cost(id)
	levels[id] += 1
	return true

func mastery_cost(id: String) -> int:
	return (Rules.AZURE_MASTERY_COSTS if id == "azure" else Rules.MASTERY_COSTS)[mastery[id]] if Rules.TECHNIQUES.has(id) and mastery[id] < 2 else -1

func improve(id: String) -> bool:
	var price = mastery_cost(id)
	if not unlocked() or price < 0 or herbs < price:
		return false
	herbs -= price
	mastery[id] += 1
	return true

func select_primary(id: String) -> bool:
	if not unlocked() or not Rules.TECHNIQUES.has(id):
		return false
	if trip.active:
		pending_primary = id if id != primary else ""
	else:
		primary = id
	return true

func start_trip() -> bool:
	if not unlocked() or trip.active:
		return false
	var effects = Rules.bonuses(primary, mastery, chapter_unlocked())
	trip = {"active": true, "elapsed": 0.0, "primary": primary, "azure": effects.azure, "iron": effects.iron}
	return true

func set_repeat(enabled: bool) -> void:
	repeat = enabled

func breakthrough_cost() -> float:
	if realm == "Mortal":
		return Rules.PREPARED_BREAKTHROUGH_QI if levels.mind > 0 else Rules.BREAKTHROUGH_QI
	if realm == "Qi Refining":
		return Rules.PREPARED_FOUNDATION_QI if prepared else Rules.FOUNDATION_QI
	if realm == "Foundation Establishment":
		return Rules.CORE_QI
	if realm == "Golden Core": return Rules.SOUL_QI
	return 0.0

func prepare_foundation() -> bool:
	if realm != "Qi Refining" or prepared or herbs < Rules.PREPARATION_HERBS:
		return false
	herbs -= Rules.PREPARATION_HERBS
	prepared = true
	return true

func breakthrough() -> bool:
	if realm == "Nascent Soul" or qi < breakthrough_cost():
		return false
	if realm == "Golden Core":
		if not soul_requirements_met() or not soul_trial_won: return false
		qi -= Rules.SOUL_QI
		realm = "Nascent Soul"
		combat_slots.append("")
		if not preset.is_empty(): preset.slots.append("")
		return true
	if realm == "Foundation Establishment":
		if not core_requirements_met() or not core_trial_won:
			return false
		qi -= Rules.CORE_QI
		realm = "Golden Core"
		combat_slots.append("")
		core_prepared = false
		return true
	if realm == "Qi Refining" and herbs < Rules.FOUNDATION_HERBS:
		return false
	qi -= breakthrough_cost()
	if realm == "Mortal":
		realm = "Qi Refining"
	else:
		herbs -= Rules.FOUNDATION_HERBS
		realm = "Foundation Establishment"
		prepared = false
	return true

func advance_cultivation(seconds: float) -> Dictionary:
	var reward = {"seconds": 0.0, "qi": 0.0, "herbs": 0, "trips": 0}
	if not is_finite(seconds) or seconds <= 0.0 or not is_finite(qi + seconds * base_rate() * 1.4):
		return reward
	var before = qi
	var remaining = seconds
	# Cultivation and gathering share each segment. At most 240 boundaries per capped absence.
	while remaining > 0.0:
		var segment = minf(remaining, Rules.TRIP_SECONDS - trip.elapsed) if trip.active else remaining
		qi += segment * rate()
		remaining = maxf(0.0, remaining - segment)
		if trip.active:
			# The same nanounit grid as combat prevents JSON's decimal parser
			# from changing a later gathering boundary after a fractional reload.
			trip.elapsed = roundf((trip.elapsed+segment)*1000000000.0)/1000000000.0
			# Absorb sub-nanosecond roundoff from fractional frame sums at a boundary.
			if Rules.TRIP_SECONDS - trip.elapsed <= 0.000000001:
				var gathered: int = Rules.BASE_HERBS + trip.iron
				herbs += gathered
				reward.herbs += gathered
				reward.trips += 1
				trip = idle_trip()
				if not pending_primary.is_empty():
					primary = pending_primary
					pending_primary = ""
				if repeat:
					start_trip()
	reward.seconds = seconds
	reward.qi = qi - before
	return reward

func mode() -> String:
	if supply.active: return "Supply"
	return "Journey" if journey.status == "battle" else ("Retreat" if chapter_unlocked() else "Cultivating")

func displayed_rate() -> float:
	return rate() * (Rules.RETREAT_SPEED if chapter_unlocked() and (supply.active or journey.status != "battle") else 1.0)

func advance(seconds: float, offline: bool = false) -> Dictionary:
	var reward = {"seconds": 0.0, "qi": 0.0, "herbs": 0, "trips": 0, "stones": 0, "nodes": 0, "effective_seconds": 0.0}
	if not is_finite(seconds) or seconds <= 0 or not is_finite(qi + seconds * base_rate() * 1.4):
		return reward
	var remaining = seconds
	while remaining > .000000001:
		var speed = Rules.RETREAT_SPEED if chapter_unlocked() and (offline or supply.active or journey.status != "battle") else 1.0
		var effective = remaining * speed
		if journey.status == "battle":
			effective = OldCombat.advance(journey.battle,effective) if journey.get("legacy_battle",false) else Combat.advance(journey.battle, effective)
		var earned: Dictionary
		if supply.active:
			var gain = effective * rate()
			qi += gain
			earned = {"qi":gain,"herbs":0,"trips":0}
		else: earned = advance_cultivation(effective)
		for key in ["qi", "herbs", "trips"]:
			reward[key] += earned[key]
		reward.effective_seconds += effective
		remaining = maxf(0, remaining - effective / speed)
		if journey.status == "battle" and not journey.battle.outcome.is_empty():
			var node_reward = resolve_encounter()
			reward.stones += node_reward.stones
			reward.nodes += node_reward.nodes
			reward.qi += node_reward.qi
			reward.herbs += node_reward.herbs
		elif effective <= 0:
			break
	reward.seconds = seconds
	return reward

func set_combat_slot(index: int, id: String) -> bool:
	if not chapter_unlocked() or index < 0 or index >= combat_slots.size() or (not id.is_empty() and not id in learned):
		return false
	if id in combat_slots and combat_slots[index] != id and not id.is_empty():
		var previous = combat_slots.find(id)
		combat_slots[previous] = combat_slots[index]
	combat_slots[index] = id
	return true

func improve_art(id: String) -> bool:
	if not chapter_unlocked() or not id in learned or combat_mastery[id] >= 2:
		return false
	var level: int = combat_mastery[id]
	if qi < Data.all().combat_mastery_qi[level] or herbs < Data.all().combat_mastery_herbs[level]:
		return false
	qi -= Data.all().combat_mastery_qi[level]
	herbs -= int(Data.all().combat_mastery_herbs[level])
	combat_mastery[id] += 1
	return true

func equip(id: String) -> bool:
	if not chapter_unlocked() or not inventory.has(id):
		return false
	equipment[Data.all().items[id].slot] = id
	return true

func refine(id: String) -> bool:
	if not inventory.has(id) or inventory[id] >= 3:
		return false
	var level: int = inventory[id]
	if qi < Data.all().refine_qi[level] or stones < Data.all().refine_stones[level]:
		return false
	qi -= Data.all().refine_qi[level]
	stones -= int(Data.all().refine_stones[level])
	inventory[id] += 1
	return true

func route_available(id: String) -> bool:
	if not chapter_unlocked(): return false
	var d = Data.all()
	if d.routes.has(id):
		var place: String = d.routes[id].region
		if place == "Misty Mountain": return true
		if place == "Spirit River": return region_clears("Misty Mountain")>0
		if not realm in ["Golden Core","Nascent Soul"]: return false
		if place == "Thunder Peak": return true
		return region_clears("Thunder Peak" if place=="Ancient Tomb" else "Ancient Tomb")>0
	if d.trials.has(id):
		if id=="soul": return realm in ["Golden Core","Nascent Soul"] and soul_requirements_met()
		var place: String = d.trials[id].get("region","")
		if not place.is_empty(): return realm in ["Golden Core","Nascent Soul"] and region_clears(place)>0
		return region_clears("Misty Mountain")>0 if id in ["ward_trial","burst_trial"] else region_clears("Spirit River")>0
	return id=="core" and core_requirements_met()

func soul_requirements_met() -> bool:
	for id in Data.all().realm_requirements.routes:
		if not id in cleared_routes: return false
	for place in Data.all().realm_requirements.regional_coverage:
		var found = false
		for id in cleared_trials:
			if id.ends_with("_heir") and Data.all().trials[id].get("region")==place: found = true
		if not found: return false
	return true

func law_available(id: String) -> bool:
	return id.is_empty() or (Data.all().laws.has(id) and Data.all().laws[id].trial in cleared_trials)

func select_law(id: String) -> bool:
	if not law_available(id): return false
	law = id
	return true

func select_preparation(id: String) -> bool:
	if journey.status in ["battle","camp"]: return false
	if not id.is_empty() and (not realm in ["Golden Core","Nascent Soul"] or not Data.all().preparations.has(id)): return false
	preparation = id
	return true

func region_clears(region: String) -> int:
	var count = 0
	for id in cleared_routes:
		if Data.all().routes[id].region == region:
			count += 1
	return count

func core_requirements_met() -> bool:
	return cleared_routes.size() >= 3 and region_clears("Misty Mountain") >= 2 and region_clears("Spirit River") >= 2

func prepare_core() -> bool:
	if realm != "Foundation Establishment" or core_prepared or herbs < Rules.CORE_PREPARATION_HERBS:
		return false
	herbs -= Rules.CORE_PREPARATION_HERBS
	core_prepared = true
	return true

func start_journey(id: String) -> bool:
	if supply.active or not route_available(id) or journey.status in ["battle", "camp"]:
		return false
	var prep: Dictionary = Data.all().preparations.get(preparation,{})
	if herbs<prep.get("herbs",0) or stones<prep.get("stones",0): return false
	herbs -= int(prep.get("herbs",0))
	stones -= int(prep.get("stones",0))
	journey = {"preparation":preparation,"status": "battle", "id": id, "node": 0, "battle": {}, "camp_requested": false, "rewards": {"qi": 0, "herbs": 0, "stones": 0, "items": []}, "reason": ""}
	preparation = ""
	begin_encounter()
	return true

func begin_encounter() -> void:
	var definition: Dictionary
	var constraint = {}
	if Data.all().routes.has(journey.id):
		var id: String = Data.all().routes[journey.id].nodes[journey.node]
		definition = Data.all().enemies[id]
	elif Data.all().trials.has(journey.id):
		constraint = Data.all().trials[journey.id].duplicate(true)
		definition = constraint.sequence[journey.node] if constraint.has("sequence") else constraint.enemy
	else:
		definition = Data.all().core
		constraint = {"core": true}
	var previous: Dictionary = journey.battle
	var endurance: bool = Data.all().routes.get(journey.id,Data.all().trials.get(journey.id,{})).get("endurance",false)
	constraint = constraint.duplicate(true)
	if not journey.get("preparation","").is_empty(): constraint.preparation = journey.preparation
	journey.status = "battle"
	journey.erase("legacy_battle")
	journey.battle = Combat.begin(Data.stats(self, constraint), definition, constraint)
	if endurance and journey.node>0 and not previous.is_empty():
		var recovery = .25 if journey.get("preparation")=="endurance" else .15
		journey.battle.hp = minf(journey.battle.stats.hp,previous.hp+journey.battle.stats.hp*recovery)

func continue_journey() -> bool:
	if journey.status != "camp":
		return false
	journey.camp_requested = false
	begin_encounter()
	return true

func leave_camp() -> bool:
	if journey.status != "camp":
		return false
	journey.status = "complete"
	journey.reason = "Returned from camp. Earned node rewards retained."
	return true

func resolve_encounter() -> Dictionary:
	var reward = {"stones": 0, "qi": 0, "herbs": 0, "nodes": 0}
	if journey.status != "battle":
		return reward
	var b: Dictionary = journey.battle
	if b.outcome != "win":
		journey.status = "defeat"
		supply.active = false
		journey.reason = b.reason
		reward_serial += 1
		return reward
	var is_route: bool = Data.all().routes.has(journey.id)
	var is_trial: bool = Data.all().trials.has(journey.id)
	var total = 1
	var discoveries = false
	if not journey.rewards.has("arts"):
		journey.rewards.arts = []
	if is_route:
		var route: Dictionary = Data.all().routes[journey.id]
		total = route.nodes.size()
		var id: String = route.nodes[journey.node]
		if not id in cleared_nodes:
			cleared_nodes.append(id)
			var skill: String = route.get("grant_art", "flame" if route.region=="Misty Mountain" else "river")
			if not skill.is_empty() and not skill in learned:
				learned.append(skill)
				journey.rewards.arts.append(skill)
				discoveries = true
		reward.merge({"stones": int(b.enemy.stones), "qi": int(b.enemy.qi), "herbs": int(b.enemy.herbs), "nodes": 1}, true)
		if journey.node == total - 1 and not journey.id in cleared_routes:
			cleared_routes.append(journey.id)
			reward.qi += int(route.get("first_qi",2400))
			grant_item(route.item)
			if route.region == "Misty Mountain" and not "ward" in learned:
				learned.append("ward")
				journey.rewards.arts.append("ward")
	elif is_trial:
		var trial: Dictionary = Data.all().trials[journey.id]
		total = trial.sequence.size() if trial.has("sequence") else 1
		if journey.node == total - 1 and not journey.id in cleared_trials:
			cleared_trials.append(journey.id)
			reward.merge({"stones": 60 if total > 1 else 35, "qi": int(trial.get("first_qi",2000)), "herbs": 4, "nodes": 1}, true)
			grant_item(trial.item)
		if journey.id=="soul" and journey.node==total-1: soul_trial_won = true
	else:
		if not core_trial_won:
			reward.merge({"stones": 50, "qi": 2500, "herbs": 4, "nodes": 1}, true)
		core_trial_won = true
	stones += reward.stones
	qi += reward.qi
	herbs += reward.herbs
	for key in ["stones", "qi", "herbs"]:
		journey.rewards[key] += reward[key]
	journey.node += 1
	reward_serial += 1
	if supply.active:
		for key in ["qi","stones","herbs"]: supply[key] += reward[key]
	if journey.node >= total:
		journey.status = "complete"
		journey.reason = "Journey complete. Rewards added."
		if supply.active:
			supply.completed += 1
			supply.remaining -= 1
			if supply.remaining>0 and not journey.camp_requested:
				journey.node = 0
				begin_encounter()
			else: supply.active = false
	elif journey.camp_requested:
		journey.status = "camp"
		supply.active = false
		journey.reason = "Requested camp. Adjust your build freely."
	else:
		begin_encounter()
	return reward

func assign_supply(id: String, circuits: int = 3) -> bool:
	if supply.active or journey.status in ["battle","camp"] or not id in cleared_routes or not circuits in [1,3,6] or not preparation.is_empty(): return false
	if not start_journey(id): return false
	supply = {"active":true,"route":id,"remaining":circuits,"completed":0,"qi":0,"stones":0,"herbs":0}
	return true

func stop_supply() -> bool:
	if not supply.active: return false
	journey.camp_requested = true
	return true

func grant_item(id: String) -> void:
	if not id.is_empty() and not inventory.has(id):
		inventory[id] = 0
		journey.rewards.items.append(id)

func save_preset() -> bool:
	if not realm in ["Golden Core","Nascent Soul"]:
		return false
	preset = {"primary": pending_primary if not pending_primary.is_empty() else primary, "slots": combat_slots.duplicate(), "equipment": equipment.duplicate(),"law":law}
	return true

func apply_preset() -> bool:
	if not realm in ["Golden Core","Nascent Soul"] or preset.is_empty():
		return false
	if preset.primary != "none":
		select_primary(preset.primary)
	var omissions = []
	var restored = []
	for i in range(combat_slots.size()):
		var id: String = preset.slots[i] if i<preset.slots.size() else ""
		if not id.is_empty() and (not id in learned or id in restored):
			omissions.append(id)
			id = ""
		restored.append(id)
	combat_slots = restored
	for slot in equipment:
		var id: String = preset.equipment.get(slot,"")
		if not id.is_empty() and (not inventory.has(id) or Data.all().items[id].slot!=slot):
			omissions.append(id)
			id = ""
		equipment[slot] = id
	var saved_law: String = preset.get("law","")
	if law_available(saved_law): law = saved_law
	else:
		omissions.append(saved_law)
		law = ""
	preset_notice = "Build restored for the next encounter." if omissions.is_empty() else "Unavailable selections omitted: "+", ".join(omissions)
	return true
