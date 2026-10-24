extends SceneTree
## Reachability through public actions only. Foundation entry is a labeled fixture.
const State = preload("res://scripts/cultivation_state.gd")
const Store = preload("res://scripts/save_store.gd")
const Data = preload("res://scripts/chapter_data.gd")
var s = State.new()
var seconds = 0.0
var combat_seconds = 0.0
var decisions = 0
var failures = 0
var events = []
func event(label: String) -> void:
	events.append({"event":label,"wall_seconds":seconds,"combat_seconds":combat_seconds,"qi":s.qi,"herbs":s.herbs,"stones":s.stones,"gear":s.equipment.duplicate(),"arts":s.combat_slots.duplicate(),"journey":s.journey.status})
	print(events.back())
func step(duration: float) -> void:
	seconds += duration
	if s.journey.status == "battle": combat_seconds += duration
	s.advance(duration)
func choose_build(kind: String = "guard") -> void:
	decisions += 1
	s.select_primary("iron" if kind in ["guard","heal"] else "azure")
	s.set_combat_slot(0,"ward" if "ward" in s.learned and kind == "guard" else ("river" if "river" in s.learned and kind == "heal" else "sword"))
	s.set_combat_slot(1,"flame" if "flame" in s.learned else "")
	for ids in [["pine_sword","cinnabar_blade"],["stoneweave_robe","traveller_robe"],["bone_ring","mystic_gourd","jade_pendant"]]:
		for id in ids:
			if s.inventory.has(id):
				s.equip(id)
				break
	if kind == "heal":
		for id in ["river_silk","mystic_gourd"]:
			if s.inventory.has(id): s.equip(id)
func attempt(id: String, kind: String = "guard") -> bool:
	choose_build(kind)
	if not s.start_journey(id):
		push_error("Cannot start "+id)
		failures += 1
		return false
	decisions += 1
	var limit = seconds + 600
	while seconds < limit and s.journey.status in ["battle","camp"]:
		if s.journey.status=="battle" and "flame" in s.learned and not "flame" in s.combat_slots:
			s.journey.camp_requested = true
		if s.journey.status == "camp":
			choose_build(kind)
			s.continue_journey()
			decisions += 1
		step(.05)
	event(id+" "+s.journey.status+" "+s.journey.reason)
	if not Store.valid(JSON.parse_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))):
		push_error("Invalid checkpoint "+id)
		failures += 1
	return s.journey.status == "complete"
func run() -> void:
	var fresh = "--fresh" in OS.get_cmdline_user_args()
	if fresh: s = Store.state_from(JSON.parse_string(FileAccess.get_file_as_string("res://.verification/living-fresh-foundation.json")))
	else:
		s.realm = "Foundation Establishment"
		s.levels = {"breathing":4,"meridian":2,"mind":1}
		s.herbs = 12
		s.primary = "azure"
		s.start_trip()
	event("Actual public-action fresh Foundation" if fresh else "Foundation fixture: capped tutorial practices, 0 Qi, 12 herbs, no chapter rewards or gear")
	for id in ["stone_steps","cloud_bridge","hermits_cleft","reed_shallows","lotus_pools","broken_ford"]:
		if id=="broken_ford": attempt("poison_trial","heal")
		if not attempt(id):
			# Try a meaningful learned alternative, without granting gear/resources.
			if not attempt(id,"heal"):
				failures += 1
	for id in ["ward_trial","poison_trial","burst_trial","focus_trial","reflection_trial","mixed_trial"]:
		if id in s.cleared_trials: continue
		if id == "poison_trial":
			attempt(id,"heal")
		elif id == "reflection_trial":
			attempt(id,"heal")
		else:
			attempt(id)
	for method in ["azure","iron"]:
		while s.mastery[method] < 1:
			if not s.improve(method): step(10)
	for art in ["ward","flame"]:
		while s.combat_mastery[art] < 1:
			if not s.improve_art(art): step(10)
	for id in ["pine_sword","stoneweave_robe","bone_ring"]:
		if s.inventory.has(id):
			while s.inventory[id] < 1 and seconds < 20000:
				if not s.refine(id): step(10)
		else: failures += 1
	while not s.core_prepared:
		if not s.prepare_core(): step(10)
	if not attempt("core") and not attempt("core","heal"): failures += 1
	while s.qi < s.breakthrough_cost() and seconds < 20000: step(10)
	if not s.breakthrough(): failures += 1
	event("Golden Core advancement")
	if not s.save_preset() or not s.apply_preset() or not Store.valid(JSON.parse_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))): failures += 1
	var report = {"fixture":"Foundation entry only; capped tutorial practices, 0 Qi, 12 herbs. All chapter gear, arts and clears earned through public actions.","automated_policy":true,"engaged_human_hours":"not measured; combat seconds are foreground waiting, not engagement", "events":events,"wall_seconds":seconds,"combat_seconds":combat_seconds,"retreat_wait_seconds":seconds-combat_seconds,"explicit_action_decisions":decisions,"routes":s.cleared_routes,"trials":s.cleared_trials,"realm":s.realm,"failures":failures}
	if fresh: report.fixture = "Actual public-action fresh opening; no granted wealth, gear, arts or clears."
	FileAccess.open("res://docs/living-dao/"+("FRESH_JADE_REACHABILITY.json" if fresh else "CHAPTER_REACHABILITY.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	FileAccess.open("res://.verification/"+("living-fresh-golden.json" if fresh else "living-earned-golden-fixture.json"),FileAccess.WRITE).store_string(JSON.stringify(Store.snapshot(s,Time.get_unix_time_from_system()),"",false,true))
	print("Reachability failures: ",failures)
	quit(1 if failures else 0)
func _initialize() -> void:
	call_deferred("run")
