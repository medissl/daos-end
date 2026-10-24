extends SceneTree
const State = preload("res://scripts/cultivation_state.gd")
const Store = preload("res://scripts/save_store.gd")
const Legacy = preload("res://scripts/legacy/save_store.gd")
const Session = preload("res://scripts/cultivation_session.gd")
const Data = preload("res://scripts/chapter_data.gd")
const Combat = preload("res://scripts/combat.gd")
var checks = 0
var failures = 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func cultivator(method: String = "azure") -> RefCounted:
	var s = State.new()
	s.realm = "Foundation Establishment"
	s.levels = {"breathing": 4, "meridian": 2, "mind": 1}
	s.primary = method
	return s

func _initialize() -> void:
	check(Data.all().enemies.size() == 48 and Data.all().routes.size() == 12 and Data.all().trials.size() == 13 and Data.all().items.size() == 15 and Data.all().skills.size()==7, "Complete Jade Road and Living Dao authored catalog")
	var s = cultivator()
	var stats = Data.stats(s)
	check(stats.hp == 135 and stats.attack == 12 and stats.armor == 2 and stats.focus_regen == 1.0, "Azure full focus and half Iron HP")
	s.primary = "iron"
	stats = Data.stats(s)
	check(stats.hp == 150 and stats.focus_regen == .75, "Iron full HP and half Azure focus")
	for id in Data.all().enemies:
		s = cultivator()
		s.learned = ["sword", "flame", "ward", "river"]
		s.combat_slots = ["sword", "flame"]
		var large = Combat.begin(Data.stats(s), Data.all().enemies[id])
		var small = large.duplicate(true)
		Combat.advance(large, 90)
		for i in range(9000):
			if small.outcome.is_empty():
				Combat.advance(small, .01)
		check(large == small, "Combat partition equivalence: " + id)
		check(large.focus >= 0 and large.focus <= large.stats.focus_cap and large.hp <= large.stats.hp, "Combat bounds: " + id)
		check(not large.outcome.is_empty(), "Bounded verdict: " + id)
	test_effects()
	test_equipment()
	test_routes_and_time()
	test_migration()
	test_serialized_battles()
	print("Jade Road: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)

func test_serialized_battles() -> void:
	# The completed earned path supplies history; each battle is a labeled
	# checkpoint fixture. Serialize before validation to catch int/float drift.
	var entry = JSON.parse_string(FileAccess.get_file_as_string("res://.verification/jade-golden-fixture.json"))
	check(Store.valid(entry),"Earned Golden Core checkpoint validates after JSON")
	for id in Data.all().routes.keys() + Data.all().trials.keys() + ["core"]:
		var s = Store.state_from(entry)
		if FileAccess.file_exists("res://.verification/living-before-"+id+".json"):
			s = Store.state_from(JSON.parse_string(FileAccess.get_file_as_string("res://.verification/living-before-"+id+".json")))
		check(s.start_journey(id),"Checkpoint starts "+id)
		s.advance(.37)
		var packed = JSON.parse_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))
		check(Store.valid(packed),"Serialized active battle validates "+id)
		var restored = Store.state_from(packed)
		s.advance(1.13)
		restored.advance(1.13)
		check(Store.snapshot(s,1000) == Store.snapshot(restored,1000),"Reload preserves exact subsequent combat "+id)
		var bad = packed.duplicate(true)
		bad.chapter.journey.battle.stats.attack += 100
		check(not Store.valid(bad),"Reject inflated saved attack "+id)
		bad = packed.duplicate(true)
		bad.chapter.journey.battle.enemy.armor += 100
		check(not Store.valid(bad),"Reject altered enemy data "+id)

func test_effects() -> void:
	var s = cultivator()
	s.learned = ["sword", "flame", "ward", "river"]
	var stats = Data.stats(s)
	stats.slots = ["sword", "flame"]
	var b = Combat.begin(stats, {"traits": ["warded"], "barriers": 4})
	check(b.barriers == 1 and b.focus_spent == 3, "Basic plus two Sword hits break three separate layers")
	var before = b.focus
	b.cooldowns.sword = 999
	check(not Combat.eligible(b, "sword") and b.focus == before, "Ineligible cooldown spends no focus")
	b = Combat.begin(Data.stats(s), {"traits": ["thorned"], "reflect": 3, "hp": 500})
	var reflected = b.reflected
	Combat.enemy_hit(b, 10, true, true)
	check(b.reflected == reflected, "DOT does not reflect")
	Combat.enemy_hit(b, 10, true)
	check(b.reflected == reflected + 3, "Direct magic does reflect")
	stats.slots = ["ward", "river"]
	b = Combat.begin(stats, {"hp": 500})
	b.focus = 10
	Combat.skill(b,"ward")
	var shield: float = b.shield
	b.focus = 10
	Combat.skill(b, "ward")
	check(b.shield == shield and b.shield <= b.stats.hp * .6, "Shield replaces rather than stacks")
	b.hp = b.stats.hp - 10
	b.poison = {"next": 20, "until": 120, "damage": 3}
	Combat.skill(b, "river")
	check(b.poison.is_empty() and b.cleanses == 1 and b.hp == b.stats.hp, "Cleanse and capped healing")
	stats.slots = ["flame", ""]
	b = Combat.begin(stats, {"hp": 500, "attack": 0, "interval": 60})
	Combat.advance(b, 4)
	check(b.burn.is_empty(), "Flame expires after exactly four one-second ticks")
	check(b.skill_counts.flame == 1, "Flame cooldown has not accelerated")
	var initial = b.enemy_hp
	Combat.advance(b, .5)
	check(b.enemy_hp == initial, "No extra expired DOT tick")
	stats.slots = ["sword", ""]
	b = Combat.begin(stats, {"hp": 100000, "attack": 0, "interval": 60})
	Combat.advance(b, 1000)
	check(b.outcome == "defeat" and b.ticks == 1800, "Ninety-second timeout safely ends failed attempt")

func test_equipment() -> void:
	var s = cultivator()
	s.inventory = {"pine_sword": 0, "jade_pendant": 0, "river_silk": 0, "bone_ring": 0}
	check(s.equip("pine_sword") and s.equip("jade_pendant") and not s.equip("missing"), "Equipment slot selection and rejection")
	var before = Data.stats(s)
	s.qi = 2499
	s.stones = 15
	check(not s.refine("pine_sword") and s.stones == 15, "Refinement cannot spend insufficient Qi")
	s.qi = 2500
	check(s.refine("pine_sword") and s.qi == 0 and s.stones == 0, "Exact first refinement cost")
	var after = Data.stats(s)
	check(is_equal_approx(after.attack - before.attack, .6) and after.sword_bonus == .1, "Flat contributions scale; named effect does not compound")
	check(before.focus_regen == 1.25, "Pendant adds focus recovery")
	s.equip("river_silk")
	s.equip("bone_ring")
	var b = Combat.begin(Data.stats(s), {"hp": 500})
	var hp: float = b.hp
	Combat.player_hit(b, 10, true, "poison")
	check(b.hp == hp - 5, "River Silk halves incoming DOT")
	check(b.stats.shield_bonus == .25, "Bone ring has separate fixed shield bonus")

func test_routes_and_time() -> void:
	var s = cultivator()
	check(not s.start_journey("reed_shallows"), "River requires a Misty finale")
	check(s.start_journey("stone_steps") and not s.start_journey("cloud_bridge"), "Finite route authorization is exclusive")
	s.journey.camp_requested = true
	var before = s.qi
	var r = s.advance(90)
	check(s.journey.status == "camp" and "flame" in s.learned and s.cleared_nodes == ["steps_scout"], "First encounter discovers Flame and honors a requested safe camp")
	check(r.nodes == 1 and s.stones == 6 and s.herbs == 1 and s.qi > before, "Concrete encounter rewards")
	check(Store.valid(Store.snapshot(s, 100)), "Camp snapshot validates")
	var encoded = JSON.parse_string(JSON.stringify(Store.snapshot(s, 100), "", false, true))
	var restored = Store.state_from(encoded)
	check(Store.snapshot(restored, 100) == Store.snapshot(s, 100), "Combat/camp save round-trip is exact")
	var stones: int = restored.stones
	restored.resolve_encounter()
	restored.advance(100)
	check(restored.stones == stones and restored.journey.node == 1, "Reload/camp cannot farm terminal rewards")
	s.set_combat_slot(1, "flame")
	check(s.continue_journey(), "Camp resumes a chosen route")
	var commitment = s.journey.battle.stats.duplicate(true)
	s.select_primary("iron")
	s.combat_slots = ["flame", "sword"]
	check(s.journey.battle.stats == commitment, "Mid-encounter changes preserve snapshot")
	var visible = cultivator()
	var closed = cultivator()
	visible.start_trip()
	closed.start_trip()
	visible.advance(400)
	closed.advance(400, true)
	check(Store.snapshot(visible, 1) == Store.snapshot(closed, 1), "Visible and closed retreat are equal")
	check(visible.trip.elapsed == 0 and visible.herbs == 5 and is_equal_approx(visible.qi, 4320), "Four hundred retreat seconds equals 120 simulation seconds")
	var session = Session.new(closed, 1, 0)
	var away = session.restore(1, 999999, 0)
	check(away.seconds == 28800 and is_equal_approx(away.effective_seconds, 8640), "Eight wall hours becomes 2.4 simulation hours")
	check(session.resume(999999, 0).qi == 0, "Focus cycles cannot duplicate absence")
	var failure = cultivator()
	failure.start_journey("stone_steps")
	failure.journey.battle.hp = 1
	failure.journey.battle.poison = {"next": 1, "until": 21, "damage": 20}
	failure.advance(1)
	check(failure.journey.status == "defeat" and failure.qi >= 0 and failure.cleared_nodes.is_empty(), "Defeat ends attempt without long-term loss")

func test_migration() -> void:
	var directory = "res://.verification/jade-migration-%d-%d" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()]
	DirAccess.make_dir_recursive_absolute(directory)
	for level in range(3):
		var old = preload("res://scripts/legacy/cultivation_state.gd").new()
		old.realm = "Foundation Establishment"
		old.qi = 100
		old.primary = "azure"
		old.mastery.azure = level
		old.herbs = 7
		old.start_trip()
		var store = Store.new(directory.path_join("legacy-%d.json" % level))
		var file = FileAccess.open(store.path, FileAccess.WRITE)
		file.store_string(JSON.stringify(Legacy.snapshot(old, 100)))
		file.close()
		var expected = Legacy.state_from(Legacy.snapshot(old, 100))
		expected.advance(120)
		var loaded = store.load_game(220)
		var state = loaded.state
		check(state.qi == expected.qi and state.herbs == expected.herbs + [0, 4, 12][level], "Full old absence plus exact Azure refund " + str(level))
		check(state.cleared_nodes.is_empty() and state.inventory.is_empty() and state.cleared_routes.is_empty(), "Migration invents no gear or victories")
		check(store.save_game(state, 220) and store.read(store.path).version == Store.VERSION, "New policy checkpoint")
		check(store.load_game(220).state.herbs == state.herbs, "Refund once after repeated load")
		var data = Store.snapshot(state, 220)
		data.chapter.stones = -1
		check(not Store.valid(data), "Reject invalid chapter currency")
		data = Store.snapshot(state, 220)
		data.chapter.combat_slots = ["sword", "sword"]
		check(not Store.valid(data), "Reject duplicate ordered arts")
