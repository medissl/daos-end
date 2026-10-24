extends SceneTree

const State = preload("res://scripts/cultivation_state.gd")
const Session = preload("res://scripts/cultivation_session.gd")
const Store = preload("res://scripts/save_store.gd")
var checks = 0
var failures = 0

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)

func _initialize() -> void:
	var state = State.new()
	check(state.qi == 0.0 and state.realm == "Mortal" and state.rate() == 1.0, "New game defaults")
	check(state.cost("breathing") == 25, "First breathing cost")
	check(not state.purchase("breathing"), "Cannot spend unavailable Qi")
	state.advance(25.0)
	check(state.purchase("breathing") and state.qi == 0.0 and state.rate() == 2.0, "First purchase spends Qi and updates production")
	check(state.cost("breathing") == 60, "Second breathing cost")
	state.qi = 144.0
	check(state.purchase("breathing") and state.cost("breathing") == 144, "Third breathing cost")
	state.qi = 144.0
	check(state.purchase("breathing") and state.cost("breathing") == 346, "Fourth breathing cost")
	state.qi = 100000.0
	check(state.purchase("breathing"), "Fourth breathing level can be purchased")
	check(state.cost("breathing") == 830, "Exponential breathing cost rounds up")
	check(not state.purchase("breathing") and state.levels.breathing == 4, "Breathing cap rejects repeated input")
	check(state.purchase("meridian") and state.cost("meridian") == 480 and state.rate() == 6.25, "Meridian multiplier and second cost")
	check(state.purchase("meridian") and not state.purchase("meridian") and state.rate() == 7.5, "Meridian cap")
	check(state.breakthrough_cost() == 1200.0, "Unprepared breakthrough cost")
	check(state.purchase("mind") and not state.purchase("mind") and state.breakthrough_cost() == 800.0, "Mind is one-time preparation")
	state.qi = 799.9
	check(not state.breakthrough(), "Breakthrough rejects insufficient funds")
	state.qi = 800.25
	check(state.breakthrough() and is_equal_approx(state.qi, 0.25), "Breakthrough consumes stored Qi")
	check(state.rate() == 15.0 and state.levels.breathing == 4 and state.levels.mind == 1, "Breakthrough doubles rate and retains upgrades")
	check(not state.breakthrough(), "Breakthrough cannot repeat")
	var unspecialized = State.new()
	unspecialized.qi = 1200.0
	check(unspecialized.breakthrough() and unspecialized.qi == 0.0 and unspecialized.rate() == 2.0, "Unprepared advancement")
	var many_steps = State.new()
	for i in range(10000):
		many_steps.advance(0.01)
	var one_step = State.new()
	one_step.advance(100.0)
	check(abs(many_steps.qi - one_step.qi) < 0.000001, "Equivalent elapsed time preserves resource totals")
	one_step.advance(NAN)
	one_step.advance(INF)
	one_step.advance(-1.0)
	check(one_step.qi == 100.0 and not one_step.purchase("unknown"), "Invalid input cannot alter resources")
	test_session()
	test_saves()
	print("%d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)

func test_session() -> void:
	var state = State.new()
	state.levels.breathing = 1
	var session = Session.new(state, 1000.0, 10.0)
	var reward = session.restore(0.0, 40000.0, 10.0)
	check(reward.seconds == 28800.0 and reward.qi == 57600.0, "Offline cap credits saved production at 100 percent")
	check(session.resume(40000.0, 10.0).qi == 0.0, "Repeated resume cannot duplicate load credit")
	session.update(12.0)
	check(state.qi == 57604.0, "Runtime starts after credited absence")
	session.suspend(40002.0, 12.0)
	session.suspend(40005.0, 15.0)
	session.update(100.0)
	check(state.qi == 57604.0, "Suspended frames do not cultivate twice")
	check(session.resume(40012.0, 22.0).qi == 20.0, "Duplicate suspension keeps original absence anchor")
	session.update(22.0)
	check(state.qi == 57624.0, "Resume frame does not duplicate offline time")
	session.suspend(50000.0, 22.0)
	check(session.resume(49000.0, 23.0).qi == 0.0, "Backward clock movement awards nothing")
	session.update(24.0)
	check(state.qi == 57626.0, "Monotonic runtime survives wall clock reversal")
	check(state.realm == "Mortal" and state.levels.breathing == 1, "Offline rewards never automatically purchase or advance")

func test_saves() -> void:
	var directory = "res://.verification/test-save-%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(directory)
	var store = Store.new(directory + "/cultivation.json")
	check(store.load_game(100.0).state.qi == 0.0, "Missing save starts safely")
	var state = State.new()
	state.qi = 1234.56789
	state.levels.meridian = 2
	check(store.save_game(state, 100.0), "Save writes successfully")
	var loaded = store.load_game(100.0)
	check(loaded.state.qi == state.qi and loaded.state.rate() == 1.5 and loaded.saved_at == 100.0, "Save round-trip retains precision and levels")
	var data = Store.snapshot(state, 100.0)
	for field in ["qi", "saved_at", "rate"]:
		for bad in [NAN, INF, -INF, -1.0, "12", null, true]:
			var invalid = data.duplicate(true)
			invalid[field] = bad
			check(not Store.valid(invalid), "Reject invalid %s: %s" % [field, str(bad)])
	for bad in [-1, 5, 0.5, INF, "1", null, true]:
		var invalid = data.duplicate(true)
		invalid.levels.breathing = bad
		check(not Store.valid(invalid), "Reject invalid upgrade level")
	var unknown = data.duplicate(true)
	unknown.realm = "Immortal"
	check(not Store.valid(unknown) and not Store.valid([]), "Reject unknown realm and malformed root")
	unknown = data.duplicate(true)
	unknown.version = 99
	check(not Store.valid(unknown), "Preserve unsupported save versions")
	unknown = data.duplicate(true)
	unknown.rate = 999.0
	check(not Store.valid(unknown), "Saved production must agree with upgrades and realm")
	for pair in [["meridian", 3], ["mind", 2]]:
		unknown = data.duplicate(true)
		unknown.levels[pair[0]] = pair[1]
		check(not Store.valid(unknown), "Reject values above each upgrade cap")
	state.qi = 2000.0
	check(store.save_game(state, 200.0), "Second save keeps prior version")
	var file = FileAccess.open(store.path, FileAccess.WRITE)
	file.store_string("{broken json")
	file.close()
	loaded = store.load_game(300.0)
	check(loaded.state.qi == 1234.56789 and not store.warning.is_empty(), "Corruption recovers prior save with explanation")
	var preserved = false
	for name in DirAccess.get_files_at(directory):
		preserved = preserved or ".recovery-" in name
	check(preserved and store.save_game(loaded.state, 300.0), "Corrupted original remains recoverable after saving")
	var session = Session.new(loaded.state, 310.0, 0.0)
	session.restore(loaded.saved_at, 310.0, 0.0)
	var credited: float = loaded.state.qi
	check(store.save_game(loaded.state, 310.0), "Offline reward checkpoint saves immediately")
	loaded = store.load_game(310.0)
	session = Session.new(loaded.state, 310.0, 0.0)
	check(session.restore(loaded.saved_at, 310.0, 0.0).qi == 0.0 and loaded.state.qi == credited, "Reloading checkpoint cannot duplicate reward")
	var broken_store = Store.new(directory + "/broken.json")
	file = FileAccess.open(broken_store.path, FileAccess.WRITE)
	file.store_string("[]")
	file.close()
	loaded = broken_store.load_game(100.0)
	check(loaded.state.qi == 0.0 and "fresh cultivation" in broken_store.warning, "Invalid save with no backup starts fresh and explains recovery")
	var temporary_store = Store.new(directory + "/interrupted.json")
	file = FileAccess.open(temporary_store.path + ".tmp", FileAccess.WRITE)
	file.store_string(JSON.stringify(Store.snapshot(state, 200.0)))
	file.close()
	check(temporary_store.load_game(300.0).state.qi == 2000.0, "Interrupted first save recovers temporary snapshot")
	# Clean only files produced by this isolated test directory.
	for name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(name))
	DirAccess.remove_absolute(directory)

