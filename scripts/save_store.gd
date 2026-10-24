extends RefCounted
const State = preload("res://scripts/cultivation_state.gd")
const Rules = preload("res://scripts/progression.gd")
const Legacy = preload("res://scripts/legacy/save_store.gd")
const Data = preload("res://scripts/chapter_data.gd")
const Validation = preload("res://scripts/chapter_validation.gd")
const Old = preload("res://scripts/legacy_v3/save_store.gd")
const VERSION = 4
const MAX_BYTES = 262144
const CHAPTER_FIELDS = ["stones", "combat_mastery", "learned", "combat_slots", "inventory", "equipment", "cleared_nodes", "cleared_routes", "cleared_trials", "core_prepared", "core_trial_won", "preset", "journey", "reward_serial", "law", "preparation", "supply", "soul_trial_won"]
var path: String
var warning = ""
var writable = true

func _init(save_path: String = "user://cultivation.json") -> void:
	path = save_path

static func finite_number(value: Variant) -> bool:
	return Legacy.finite_number(value)

static func integer(value: Variant, minimum: int, maximum: int) -> bool:
	return Legacy.integer(value, minimum, maximum)

static func valid_v1(data: Variant) -> bool:
	return Legacy.valid_v1(data)

static func valid(data: Variant) -> bool:
	if Old.valid(data):
		return true
	if not data is Dictionary or data.get("version") != VERSION or data.get("policy") != "living-dao-v1" or data.get("azure_refund") != true or not data.get("chapter") is Dictionary:
		return false
	if not data.get("realm") is String or not data.realm in Rules.REALM_MULTIPLIERS:
		return false
	var base = data.duplicate(true)
	base.version = 2
	if data.realm in ["Golden Core","Nascent Soul"]:
		if not finite_number(data.get("rate")):
			return false
		base.realm = "Foundation Establishment"
		base.rate *= 4.0 / Rules.REALM_MULTIPLIERS[data.realm]
	if not Legacy.valid(base,false):
		return false
	if not Validation.valid(data.chapter,data.realm,data.mastery): return false
	return absf(data.rate-state_from(data).rate())<=.000000001

static func state_from(data: Dictionary) -> RefCounted:
	var state = State.new()
	state.qi = float(data.qi)
	state.realm = data.realm
	state.levels = data.levels.duplicate()
	for id in state.levels:
		state.levels[id] = int(state.levels[id])
	if data.version >= 2:
		for field in ["herbs", "mastery", "primary", "pending_primary", "prepared", "repeat", "trip"]:
			var value: Variant = data[field]
			state.set(field, value.duplicate(true) if value is Dictionary or value is Array else value)
		state.herbs = int(state.herbs)
		for id in state.mastery:
			state.mastery[id] = int(state.mastery[id])
		state.trip.iron = int(state.trip.iron)
	if data.version >= 3:
		for field in CHAPTER_FIELDS:
			if not data.chapter.has(field): continue
			var value: Variant = data.chapter[field]
			state.set(field, value.duplicate(true) if value is Dictionary or value is Array else value)
		state.stones = int(state.stones)
		state.reward_serial = int(state.reward_serial)
		for key in ["remaining","completed","qi","herbs","stones"]: state.supply[key] = int(state.supply[key])
		for dictionary in [state.combat_mastery, state.inventory]:
			for id in dictionary:
				dictionary[id] = int(dictionary[id])
		state.journey.node = int(state.journey.node)
		for key in ["qi", "herbs", "stones"]:
			state.journey.rewards[key] = int(state.journey.rewards[key])
		if not state.journey.battle.is_empty():
			if data.version<4: state.journey.legacy_battle = true
			var b: Dictionary = state.journey.battle
			for field in ["ticks", "shield_until", "next_enemy", "next_burst", "next_heal", "action_serial", "enemy_serial", "focus_spent", "cleanses", "bursts", "bursts_blocked", "barriers_broken", "barriers", "interrupts", "focus_refunded", "counters", "law_procs"]:
				if b.has(field): b[field] = int(b[field])
			for dictionary in [b.skill_counts, b.cooldowns, b.stats.mastery, b.stats.build.mastery, b.stats.build.combat_mastery, b.stats.build.inventory]:
				for id in dictionary:
					dictionary[id] = int(dictionary[id])
			for key in ["burn", "poison"]:
				if not b[key].is_empty():
					b[key].next = int(b[key].next)
					b[key].until = int(b[key].until)
			if state.journey.get("legacy_battle",false): preload("res://scripts/legacy_v3/combat.gd").canonical(b)
			else: preload("res://scripts/combat.gd").canonical(b)
	for id in Data.all().skills:
		if not state.combat_mastery.has(id): state.combat_mastery[id] = 0
	return state

static func snapshot(state: RefCounted, now: float) -> Dictionary:
	var data = {"version": VERSION, "policy": "living-dao-v1", "azure_refund": true, "qi": state.qi, "realm": state.realm,
		"levels": state.levels.duplicate(), "rate": state.rate(), "saved_at": now,
		"herbs": state.herbs, "mastery": state.mastery.duplicate(), "primary": state.primary,
		"pending_primary": state.pending_primary, "prepared": state.prepared,
		"repeat": state.repeat, "trip": state.trip.duplicate(), "chapter": {}}
	for field in CHAPTER_FIELDS:
		var value: Variant = state.get(field)
		data.chapter[field] = value.duplicate(true) if value is Dictionary or value is Array else value
	return data

func read(candidate: String) -> Variant:
	var file = FileAccess.open(candidate, FileAccess.READ)
	if file == null or file.get_length() > MAX_BYTES:
		return null
	var json = JSON.new()
	return json.data if json.parse(file.get_as_text()) == OK else null

func preserve(candidate: String) -> bool:
	var recovery = "%s.recovery-%d-%d" % [candidate, int(Time.get_unix_time_from_system()), Time.get_ticks_usec()]
	return DirAccess.copy_absolute(candidate, recovery) == OK

func load_game(now: float) -> Dictionary:
	warning = ""
	writable = true
	var loaded: Variant = null
	for candidate in [path, path + ".bak", path + ".tmp"]:
		if not FileAccess.file_exists(candidate):
			continue
		var data: Variant = read(candidate)
		if valid(data):
			if loaded == null:
				loaded = data
				if data.version < VERSION:
					if not preserve(candidate):
						writable = false
						warning += "Could not preserve the legacy save; saving is paused. "
					else:
						warning += "Your cultivation has carried forward to the Living Dao. "
				if candidate != path:
					warning += "Recovered cultivation from a prior save. "
		else:
			if preserve(candidate):
				warning += "An unreadable or unsupported save was preserved as a .recovery file. "
			else:
				writable = false
				warning += "Could not preserve an unreadable save; saving is paused to protect it. "
	if loaded == null:
		if not warning.is_empty():
			warning += "Starting a fresh cultivation."
		return {"state": State.new(), "saved_at": now}
	if loaded.version < VERSION:
		var reader = Old.new(path)
		var previous = reader.load_game(now)
		writable = writable and reader.writable
		warning += reader.warning
		var reward: Dictionary = previous.get("migration_reward",{})
		if reward.is_empty():
			reward = previous.state.advance(clampf(now-previous.saved_at,0,Rules.MAX_OFFLINE_SECONDS),true)
		var converted = Old.snapshot(previous.state,now)
		var migrated = state_from(converted)
		var funding = 0
		for id in migrated.cleared_routes: funding += int(Data.all().routes[id].get("first_qi",2400))
		migrated.qi += funding
		reward.qi = reward.get("qi",0)+funding
		reward.funding = funding
		return {"state":migrated,"saved_at":now,"migration_reward":reward}

	return {"state": state_from(loaded), "saved_at": float(loaded.saved_at)}

func save_game(state: RefCounted, now: float) -> bool:
	if not writable:
		return false
	var data = snapshot(state, now)
	if not valid(data):
		return false
	var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "", false, true))
	file.flush()
	var error = file.get_error()
	file.close()
	if error != OK:
		return false
	if FileAccess.file_exists(path):
		if valid(read(path)):
			if FileAccess.file_exists(path + ".bak"):
				if not valid(read(path + ".bak")) and not preserve(path + ".bak"):
					return false
				if DirAccess.remove_absolute(path + ".bak") != OK:
					return false
			if DirAccess.rename_absolute(path, path + ".bak") != OK:
				return false
		else:
			# Preserve again if corruption occurred since loading.
			if not preserve(path) or DirAccess.remove_absolute(path) != OK:
				return false
	return DirAccess.rename_absolute(path + ".tmp", path) == OK
