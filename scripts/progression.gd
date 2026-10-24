extends RefCounted
const MAX_OFFLINE_SECONDS = 28800.0
const BREAKTHROUGH_QI = 1200.0
const PREPARED_BREAKTHROUGH_QI = 800.0
const FOUNDATION_QI = 10000.0
const PREPARED_FOUNDATION_QI = 7000.0
const FOUNDATION_HERBS = 12
const PREPARATION_HERBS = 12
const TRIP_SECONDS = 120.0
const BASE_HERBS = 4
const MASTERY_COSTS = [8, 16]
const AZURE_MASTERY_COSTS = [4, 8]
const RETREAT_SPEED = .3
const SOUL_QI = 90000.0
const CORE_QI = 24000.0
const CORE_PREPARATION_HERBS = 24
const REALM_MULTIPLIERS = {"Mortal": 1.0, "Qi Refining": 2.0, "Foundation Establishment": 4.0, "Golden Core": 8.0, "Nascent Soul": 12.0}
const TECHNIQUES = {
	"azure": {"title": "Azure Cloud Meditation", "short": "Azure Cloud", "azure": [0.20, 0.30, 0.40], "iron": [0, 0, 0]},
	"iron": {"title": "Iron Body Sutra", "short": "Iron Body", "azure": [0.0, 0.0, 0.0], "iron": [2, 4, 6]},
}
const UPGRADES = {
	"breathing": {"title": "Deep Breathing", "cap": 4, "cost": 25.0, "growth": 2.4},
	"meridian": {"title": "Meridian Circulation", "cap": 2, "cost": 120.0, "growth": 4.0},
	"mind": {"title": "Settle the Mind", "cap": 1, "cost": 200.0, "growth": 1.0},
}

static func bonuses(primary: String, mastery: Dictionary, resonance: bool) -> Dictionary:
	var result = {"azure": 0.0, "iron": 0}
	if primary == "none":
		return result
	for id in TECHNIQUES:
		var strength = 1.0 if id == primary else (0.5 if resonance else 0.0)
		result.azure += TECHNIQUES[id].azure[mastery[id]] * strength
		result.iron += int(TECHNIQUES[id].iron[mastery[id]] * strength)
	return result
