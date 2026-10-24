extends SceneTree
const State = preload("res://scripts/cultivation_state.gd")
const Store = preload("res://scripts/save_store.gd")
const Rules = preload("res://scripts/progression.gd")
const OPENING = ["breathing", "breathing", "meridian", "breathing", "mind", "breathing", "meridian"]
var report = []
func _initialize() -> void:
	for migrated in [false, true]:
		for policy in ["cultivation-first", "gathering/preparation-first", "mastery-first", "azure-no-mastery", "iron-no-preparation", "iron-preparation-only"]:
			run_policy(policy, migrated)
	var file = FileAccess.open("res://docs/design/MILESTONE_2_PACING.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	quit()

func run_policy(policy: String, migrated: bool) -> void:
	var state = State.new()
	var time = 0.0
	var history = []
	var qi_refining_at = 0.0
	if migrated:
		# Representative old capped starter build, modest stored Qi, no absence.
		state = Store.state_from({"version": 1, "qi": 1000.0, "realm": "Qi Refining",
			"levels": {"breathing": 4, "meridian": 2, "mind": 1}, "rate": 15.0, "saved_at": 100.0})
	else:
		for id in OPENING:
			var price: float = state.cost(id)
			var wait = maxf(0, price - state.qi) / state.rate() + .000001
			state.advance(wait)
			time += wait
			assert(state.purchase(id))
			history.append({"at": time, "purchase": id, "qi_spent": price})
		var wait = (state.breakthrough_cost() - state.qi) / state.rate() + .000001
		state.advance(wait)
		time += wait
		assert(state.breakthrough())
		qi_refining_at = time
	state.select_primary("azure" if policy in ["cultivation-first", "azure-no-mastery"] else "iron")
	assert(state.start_trip())
	var foundation_at = -1.0
	var herbs_spent = {"mastery": 0, "preparation": 0, "advancement": 0}
	# Event-driven waits: next trip boundary or sufficient Qi for an eligible breakthrough.
	while foundation_at < 0 and time < 20000:
		var changed = true
		while changed:
			changed = false
			var id = ""
			if policy == "cultivation-first" and state.mastery.azure < 2:
				id = "azure"
			elif policy == "gathering/preparation-first" and state.mastery.iron < 1:
				id = "iron"
			elif policy == "mastery-first":
				if state.mastery.iron < 2:
					id = "iron"
				elif state.mastery.azure < 2:
					id = "azure"
			if id != "" and state.herbs >= state.mastery_cost(id):
				var price: int = state.mastery_cost(id)
				assert(state.improve(id))
				herbs_spent.mastery += price
				history.append({"at": time, "purchase": id + " mastery", "herbs_spent": price})
				changed = true
			var ready_to_prepare = policy == "gathering/preparation-first" and state.mastery.iron >= 1
			ready_to_prepare = ready_to_prepare or (policy == "mastery-first" and state.mastery.iron == 2 and state.mastery.azure == 2)
			ready_to_prepare = ready_to_prepare or policy == "iron-preparation-only"
			if ready_to_prepare and not state.prepared and state.herbs >= Rules.PREPARATION_HERBS:
				assert(state.prepare_foundation())
				herbs_spent.preparation += Rules.PREPARATION_HERBS
				history.append({"at": time, "purchase": "Prepare Foundation", "herbs_spent": Rules.PREPARATION_HERBS})
				changed = true
		var purchases_done: bool = state.mastery.azure == 2 if policy == "cultivation-first" else (state.prepared if policy == "gathering/preparation-first" else state.prepared and state.mastery.azure == 2 and state.mastery.iron == 2)
		if policy in ["azure-no-mastery", "iron-no-preparation"]:
			purchases_done = true
		elif policy == "iron-preparation-only":
			purchases_done = state.prepared
		if purchases_done and state.herbs >= 12 and state.qi >= state.breakthrough_cost():
			var price: float = state.breakthrough_cost()
			assert(state.breakthrough())
			herbs_spent.advancement = 12
			foundation_at = time
			history.append({"at": time, "purchase": "Foundation", "qi_spent": price, "herbs_spent": 12})
			break
		var wait: float = Rules.TRIP_SECONDS - state.trip.elapsed
		if purchases_done and state.herbs >= 12:
			wait = minf(wait, maxf(.000001, (state.breakthrough_cost() - state.qi) / state.rate() + .000001))
		state.advance(wait)
		time += wait
	var immediately: float = state.rate()
	# At a departure all pending mastery/resonance effects are reflected.
	var post_effects: Dictionary = state.next_bonuses()
	var post_rate: float = state.base_rate() * (1.0 + post_effects.azure)
	var result = {"start": "migrated Qi Refining, 1000 Qi, capped starter upgrades, zero absence" if migrated else "fresh",
		"policy": policy, "qi_refining_seconds": qi_refining_at, "foundation_seconds": foundation_at,
		"journey_after_qi_refining_seconds": foundation_at - qi_refining_at,
		"herbs_spent": herbs_spent, "mastery": state.mastery.duplicate(), "primary": state.primary,
		"remaining_qi": state.qi, "remaining_herbs": state.herbs, "immediate_foundation_qi_per_second": immediately,
		"next_departure_qi_per_second": post_rate, "next_departure_herbs_per_trip": Rules.BASE_HERBS + post_effects.iron,
		"purchases": history}
	report.append(result)
	print("%s | %s | Qi Refining %.2fs | Foundation %.2fs | spent %s | next %.2f Qi/s, %d herbs/trip" %
		["migrated" if migrated else "fresh", policy, qi_refining_at, foundation_at, str(herbs_spent), post_rate, Rules.BASE_HERBS + post_effects.iron])
