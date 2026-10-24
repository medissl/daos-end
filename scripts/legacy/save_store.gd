extends RefCounted
const State = preload("res://scripts/legacy/cultivation_state.gd")
const Rules = preload("res://scripts/legacy/progression.gd")
const VERSION = 2
const MAX_BYTES = 65536
var path: String
var warning = ""
var writable = true

func _init(save_path: String = "user://cultivation.json") -> void:
	path = save_path

static func finite_number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))

static func integer(value: Variant, minimum: int, maximum: int) -> bool:
	return finite_number(value) and value >= minimum and value <= maximum and float(value) == floor(float(value))

static func common_valid(data: Variant) -> bool:
	if not data is Dictionary or not finite_number(data.get("qi")) or data.qi < 0.0:
		return false
	if not finite_number(data.get("saved_at")) or data.saved_at < 0.0:
		return false
	if not data.get("realm") is String or not data.get("levels") is Dictionary:
		return false
	for id in Rules.UPGRADES:
		if not integer(data.levels.get(id), 0, Rules.UPGRADES[id].cap):
			return false
	return finite_number(data.get("rate")) and finite_number(data.get("version"))

static func valid_v1(data: Variant) -> bool:
	if not common_valid(data) or data.version != 1 or not data.realm in ["Mortal", "Qi Refining"]:
		return false
	# Frozen legacy formula: never validate old data using new technique effects.
	var multiplier = 1.0 if data.realm == "Mortal" else 2.0
	var legacy = (1.0 + data.levels.breathing) * (1.0 + .25 * data.levels.meridian) * multiplier
	return data.rate == legacy

static func valid(data: Variant, verify_rate: bool = true) -> bool:
	if valid_v1(data):
		return true
	if not common_valid(data) or data.version != VERSION or not Rules.REALM_MULTIPLIERS.has(data.realm):
		return false
	if not integer(data.get("herbs"), 0, 9007199254740991) or not data.get("mastery") is Dictionary:
		return false
	for id in Rules.TECHNIQUES:
		if not integer(data.mastery.get(id), 0, 2):
			return false
	if not data.get("primary") is String or not data.primary in ["none", "azure", "iron"]:
		return false
	if not data.get("pending_primary") is String or not data.pending_primary in ["", "azure", "iron"]:
		return false
	if not data.get("prepared") is bool or not data.get("repeat") is bool or not data.get("trip") is Dictionary:
		return false
	var trip: Dictionary = data.trip
	if not trip.get("active") is bool or not trip.get("primary") is String or not trip.primary in ["none", "azure", "iron"]:
		return false
	if not finite_number(trip.get("elapsed")) or trip.elapsed < 0.0 or trip.elapsed >= Rules.TRIP_SECONDS:
		return false
	if not finite_number(trip.get("azure")) or not integer(trip.get("iron"), 0, 6):
		return false
	if not trip.active:
		if trip.elapsed != 0.0 or trip.primary != "none" or trip.azure != 0.0 or trip.iron != 0 or data.pending_primary != "":
			return false
	else:
		if data.realm == "Mortal" or trip.primary != data.primary or data.pending_primary == data.primary:
			return false
		# A trip may predate a mastery purchase or Foundation. Its commitment must
		# be obtainable from an earlier mastery and resonance state, never a future one.
		var possible = false
		for azure in range(int(data.mastery.azure) + 1):
			for iron in range(int(data.mastery.iron) + 1):
				for resonance in [false, true] if data.realm == "Foundation Establishment" else [false]:
					var effects = Rules.bonuses(trip.primary, {"azure": azure, "iron": iron}, resonance)
					possible = possible or (trip.azure == effects.azure and trip.iron == effects.iron)
		if not possible:
			return false
	if data.realm == "Mortal" and (data.herbs != 0 or data.mastery.azure != 0 or data.mastery.iron != 0 or data.primary != "none" or data.prepared):
		return false
	if data.realm == "Foundation Establishment" and data.prepared:
		return false
	# Rate is derived metadata. A decimal JSON round-trip can move one ULP;
	# never reject an otherwise valid player save for that parser difference.
	return not verify_rate or absf(data.rate-state_from(data).rate())<=.000000001

static func state_from(data: Dictionary) -> RefCounted:
	var state = State.new()
	state.qi = float(data.qi)
	state.realm = data.realm
	for id in state.levels:
		state.levels[id] = int(data.levels[id])
	if data.version == VERSION:
		state.herbs = int(data.herbs)
		for id in state.mastery:
			state.mastery[id] = int(data.mastery[id])
		state.primary = data.primary
		state.pending_primary = data.pending_primary
		state.prepared = data.prepared
		state.repeat = data.repeat
		state.trip = {"active": data.trip.active, "elapsed": float(data.trip.elapsed),
			"primary": data.trip.primary, "azure": float(data.trip.azure), "iron": int(data.trip.iron)}
	return state

static func snapshot(state: RefCounted, now: float) -> Dictionary:
	return {"version": VERSION, "qi": state.qi, "realm": state.realm,
		"levels": state.levels.duplicate(), "rate": state.rate(), "saved_at": now,
		"herbs": state.herbs, "mastery": state.mastery.duplicate(), "primary": state.primary,
		"pending_primary": state.pending_primary, "prepared": state.prepared,
		"repeat": state.repeat, "trip": state.trip.duplicate()}

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
				if valid_v1(data):
					if not preserve(candidate):
						writable = false
						warning += "Could not preserve the legacy save; saving is paused. "
					else:
						warning += "Your cultivation has carried forward. Techniques await your choice. "
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
	return {"state": state_from(loaded), "saved_at": float(loaded.saved_at),
		"legacy_rate": float(loaded.rate) if valid_v1(loaded) else -1.0}

func save_game(state: RefCounted, now: float) -> bool:
	if not writable:
		return false
	var data = snapshot(state, now)
	if not valid(data):
		return false
	var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
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
