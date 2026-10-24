extends RefCounted
const Rules = preload("res://scripts/legacy/progression.gd")
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

static func idle_trip() -> Dictionary:
	return {"active": false, "elapsed": 0.0, "primary": "none", "azure": 0.0, "iron": 0}

func unlocked() -> bool:
	return realm != "Mortal"

func base_rate() -> float:
	return (1.0 + levels.breathing) * (1.0 + .25 * levels.meridian) * Rules.REALM_MULTIPLIERS[realm]

func next_bonuses() -> Dictionary:
	return Rules.bonuses(pending_primary if not pending_primary.is_empty() else primary, mastery, realm == "Foundation Establishment")

func effective_bonuses() -> Dictionary:
	return trip if trip.active else Rules.bonuses(primary, mastery, realm == "Foundation Establishment")

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
	return Rules.MASTERY_COSTS[mastery[id]] if Rules.TECHNIQUES.has(id) and mastery[id] < 2 else -1

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
	var effects = Rules.bonuses(primary, mastery, realm == "Foundation Establishment")
	trip = {"active": true, "elapsed": 0.0, "primary": primary, "azure": effects.azure, "iron": effects.iron}
	return true

func set_repeat(enabled: bool) -> void:
	repeat = enabled

func breakthrough_cost() -> float:
	if realm == "Mortal":
		return Rules.PREPARED_BREAKTHROUGH_QI if levels.mind > 0 else Rules.BREAKTHROUGH_QI
	if realm == "Qi Refining":
		return Rules.PREPARED_FOUNDATION_QI if prepared else Rules.FOUNDATION_QI
	return 0.0

func prepare_foundation() -> bool:
	if realm != "Qi Refining" or prepared or herbs < Rules.PREPARATION_HERBS:
		return false
	herbs -= Rules.PREPARATION_HERBS
	prepared = true
	return true

func breakthrough() -> bool:
	if realm == "Foundation Establishment" or qi < breakthrough_cost():
		return false
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

func advance(seconds: float) -> Dictionary:
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
			trip.elapsed += segment
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
