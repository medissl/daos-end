extends SceneTree
const State = preload("res://scripts/cultivation_state.gd")
const Rules = preload("res://scripts/progression.gd")
const Store = preload("res://scripts/save_store.gd")
const Session = preload("res://scripts/cultivation_session.gd")
var checks = 0
var failures = 0

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)

func novice() -> RefCounted:
	var s = State.new()
	s.qi = 1200.0
	assert(s.breakthrough())
	return s

func _initialize() -> void:
	var s = State.new()
	check(not s.select_primary("azure") and not s.start_trip() and not s.improve("iron"), "Mortal unlock restrictions")
	check(not s.prepare_foundation(), "Mortal cannot prepare Foundation")
	s = novice()
	check(s.primary == "none" and s.rate() == 2.0 and s.herbs == 0, "Unlocks free, no automatic primary")
	for id in Rules.TECHNIQUES:
		for level in range(3):
			s.mastery[id] = level
			s.select_primary(id)
			check(is_equal_approx(s.rate(), 2.0 * (1.0 + Rules.TECHNIQUES[id].azure[level])), "Primary Qi effect %s %d" % [id, level])
			check(s.effective_bonuses().iron == Rules.TECHNIQUES[id].iron[level], "Primary herb effect")
	s = novice()
	s.herbs = 11
	check(s.improve("azure") and s.herbs == 7 and s.mastery_cost("azure") == 8, "Authorized Azure mastery costs four then eight")
	check(not s.improve("azure") and s.herbs == 7, "Insufficient second mastery spends nothing")
	s.herbs = 8
	check(s.improve("azure") and s.herbs == 0 and not s.improve("azure") and s.mastery_cost("azure") == -1, "Authorized second Azure mastery costs eight and caps")
	check(not s.improve("unknown"), "Unknown mastery rejected")
	s = novice()
	s.herbs = 12
	check(s.improve("iron") and not s.prepare_foundation(), "Mastery competes with preparation")
	s.herbs = 12
	check(s.prepare_foundation() and s.herbs == 0 and s.breakthrough_cost() == 7000.0, "Preparation spends twelve, lowers only Qi")
	s.qi = 7000.0
	check(not s.breakthrough() and not s.prepare_foundation(), "Prepared advancement still needs twelve, preparation one-time")
	s.herbs = 12
	check(s.breakthrough() and s.herbs == 0 and not s.prepared and s.rate() == 4.0, "Prepared Foundation consumes both costs")
	check(not s.breakthrough(), "Foundation is milestone boundary")
	s = novice()
	s.qi = 10000.0
	s.herbs = 11
	check(not s.breakthrough(), "Unprepared Foundation herb requirement")
	s.herbs = 12
	check(s.breakthrough() and s.qi == 0 and s.herbs == 0, "Unprepared Foundation costs 10000 and twelve")
	s.mastery = {"azure": 1, "iron": 1}
	s.select_primary("azure")
	check(is_equal_approx(s.rate(), 5.2) and s.effective_bonuses().iron == 2, "Azure primary resonance example")
	s.select_primary("iron")
	check(is_equal_approx(s.rate(), 4.6) and s.effective_bonuses().iron == 4, "Iron primary resonance example")
	s.primary = "none"
	check(s.rate() == 4.0 and s.effective_bonuses().iron == 0, "None gives no resonance")
	test_trips()
	test_migration()
	test_validation()
	print("Milestone two: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)

func test_trips() -> void:
	var s = novice()
	check(s.repeat and not s.trip.active, "Repeat defaults on but never starts an unauthorized trip")
	s.advance(1000)
	check(s.herbs == 0 and not s.trip.active, "Idle time does not invent expeditions")
	s.qi = 0
	s.select_primary("azure")
	check(s.start_trip() and not s.start_trip(), "One departure only")
	s.advance(60)
	check(s.herbs == 0 and s.trip.elapsed == 60 and s.qi == 144, "Concurrent Qi and partial trip")
	s.select_primary("iron")
	check(s.primary == "azure" and s.pending_primary == "iron" and s.rate() == 2.4, "Queued choice cannot change active commitment")
	s.herbs = 8
	s.improve("iron")
	var reward = s.advance(60)
	check(reward.trips == 1 and reward.herbs == 4 and s.herbs == 4, "Boundary awards old commitment once")
	check(s.primary == "iron" and s.pending_primary == "" and s.trip.elapsed == 0 and s.trip.iron == 4 and s.rate() == 2.0, "New departure applies choice and mastery")
	s.set_repeat(false)
	var stopped = s.advance(180)
	check(stopped.trips == 1 and stopped.herbs == 8 and not s.trip.active and s.herbs == 12, "Stop finishes current only, leftover time cultivates")
	check(is_equal_approx(stopped.qi, 360.0), "Qi credited for same whole interval")
	s.set_repeat(true)
	s.advance(120)
	check(not s.trip.active and s.herbs == 12, "Repeat toggle alone never authorizes departure")
	s.start_trip()
	s.herbs += 8
	s.improve("azure")
	s.select_primary("azure")
	s.qi = 10000
	s.herbs += 12
	check(s.breakthrough() and s.rate() == 4.0 and s.trip.iron == 4, "Realm base updates immediately, resonance stays committed")
	s.advance(400)
	check(s.trip.iron == 2 and is_equal_approx(s.trip.azure, .3), "Next departure applies new resonance")
	var large = novice()
	large.select_primary("azure")
	large.start_trip()
	large.select_primary("iron")
	var small = Store.state_from(Store.snapshot(large, 0))
	large.advance(997.25)
	for i in range(3989):
		small.advance(.25)
	check(is_equal_approx(large.qi, small.qi) and large.herbs == small.herbs and large.trip == small.trip, "Large and small steps equivalent across queued boundary")
	var capped = novice()
	capped.select_primary("iron")
	capped.start_trip()
	var session = Session.new(capped, 0, 0)
	var away = session.restore(0, 999999, 0)
	check(away.seconds == 28800 and away.trips == 240 and away.herbs == 1440 and capped.trip.elapsed == 0, "Eight hours resolves exactly 240 trips")
	check(session.resume(999999, 0).trips == 0 and capped.herbs == 1440, "Duplicate resume awards no trips")
	session.suspend(1000000, 0)
	check(session.resume(1, 1).seconds == 0 and capped.herbs == 1440, "Backward time adds no trips")
	var fractional = novice()
	fractional.select_primary("iron")
	fractional.start_trip()
	for i in range(1200):
		fractional.advance(.1)
	check(fractional.herbs == 6 and is_zero_approx(fractional.trip.elapsed), "Fractional steps complete the exact 120-second boundary")
	fractional = novice()
	fractional.start_trip()
	fractional.advance(119.99999)
	check(fractional.herbs == 0, "A genuinely incomplete trip never awards early")
	fractional.advance(.00001)
	check(fractional.herbs == 4 and fractional.trip.elapsed == 0, "Remaining fractional time completes once")
	var online = novice()
	online.select_primary("azure")
	online.start_trip()
	online.select_primary("iron")
	online.herbs = 8
	online.improve("iron")
	var offline = Store.state_from(Store.snapshot(online, 0))
	online.advance(28800)
	session = Session.new(offline, 28800, 0)
	var summary = session.restore(0, 28800, 0)
	check(summary.herbs == 1916 and summary.trips == 240 and is_equal_approx(summary.qi, 57648), "Offline summary follows committed then queued production")
	check(Store.snapshot(online, 28800) == Store.snapshot(offline, 28800), "Online and absent event timelines agree")
	var file_store = Store.new("res://.verification/m2-stop-%d.json" % Time.get_ticks_usec())
	offline.prepared = true
	offline.set_repeat(false)
	offline.advance(73.25)
	offline.select_primary("azure")
	check(file_store.save_game(offline, 28800), "Full expedition state writes to disk")
	var restored = file_store.load_game(28800).state
	check(Store.snapshot(offline, 28800) == Store.snapshot(restored, 28800), "File round-trip preserves herbs, mastery, preparation, queue, commitment and stop")

func test_migration() -> void:
	var directory = "res://.verification/m2-migration-%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(directory)
	for realm in ["Mortal", "Qi Refining"]:
		var legacy = {"version": 1, "qi": 37.25, "realm": realm, "levels": {"breathing": 4, "meridian": 2, "mind": 1}, "rate": 7.5 if realm == "Mortal" else 15.0, "saved_at": 100.0}
		check(Store.valid_v1(legacy), "Legacy formula accepted " + realm)
		var store = Store.new(directory.path_join(realm + ".json"))
		var file = FileAccess.open(store.path, FileAccess.WRITE)
		file.store_string(JSON.stringify(legacy))
		file.close()
		var loaded = store.load_game(99999)
		var s = loaded.state
		check(s.qi == 37.25 + legacy.rate * 28800 and loaded.saved_at == 99999 and s.realm == realm and s.levels.breathing == 4, "Migration settles old timestamp once before the new policy")
		check(s.herbs == 0 and s.primary == "none" and not s.trip.active and not s.prepared and s.mastery.azure == 0, "Migration starts new systems empty")
		var session = Session.new(s, 99999, 0)
		var reward: Dictionary = loaded.migration_reward
		check(reward.qi == legacy.rate * 28800 and reward.herbs == 0 and reward.trips == 0, "Legacy absence at legacy rate, capped, no retroactive trips")
		check(store.save_game(s, 99999) and store.read(store.path).version == Store.VERSION, "Migration checkpoint writes current version")
		loaded = store.load_game(99999)
		session = Session.new(loaded.state, 99999, 0)
		check(session.restore(loaded.saved_at, 99999, 0).qi == 0, "Migrated reload cannot duplicate absence")
		check(DirAccess.get_files_at(directory).size() >= 3, "Original legacy file preserved")
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)

func test_validation() -> void:
	var s = novice()
	s.select_primary("iron")
	s.start_trip()
	s.advance(33.5)
	s.select_primary("azure")
	s.set_repeat(false)
	var data = Store.snapshot(s, 100)
	check(Store.valid(data), "Active stop intent and queued choice valid")
	var restored = Store.state_from(JSON.parse_string(JSON.stringify(data)))
	check(Store.snapshot(restored, 100) == data, "V2 active trip round-trip")
	var result = restored.advance(500)
	check(result.trips == 1 and result.herbs == 6 and not restored.trip.active and restored.primary == "azure" and not restored.repeat, "Stop intent and pending choice survive reload")
	for field in ["herbs", "primary", "pending_primary", "prepared", "repeat", "mastery", "trip"]:
		var bad = data.duplicate(true)
		bad[field] = null
		check(not Store.valid(bad), "Missing/invalid new field " + field)
	for invalid in [-1, .5, INF, true, "2", 9007199254740992]:
		var bad = data.duplicate(true)
		bad.herbs = invalid
		check(not Store.valid(bad), "Invalid herb integer")
	for field in ["elapsed", "azure", "iron", "active", "primary"]:
		var bad = data.duplicate(true)
		bad.trip[field] = null
		check(not Store.valid(bad), "Invalid trip field " + field)
	for pair in [["elapsed", 120], ["elapsed", -1], ["azure", .4], ["iron", 6], ["primary", "azure"]]:
		var bad = data.duplicate(true)
		bad.trip[pair[0]] = pair[1]
		check(not Store.valid(bad), "Reject impossible commitment")
	var bad = data.duplicate(true)
	bad.mastery.iron = 3
	check(not Store.valid(bad), "Reject mastery above cap")
	bad = data.duplicate(true)
	bad.realm = "Mortal"
	check(not Store.valid(bad), "Reject locked realm trip")
	bad = Store.snapshot(State.new(), 1)
	bad.primary = "azure"
	check(not Store.valid(bad), "Reject locked technique")
	bad = data.duplicate(true)
	bad.trip.active = false
	check(not Store.valid(bad), "Idle trip cannot carry progress/queue")
