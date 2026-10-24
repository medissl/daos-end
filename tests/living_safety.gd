extends SceneTree
const State=preload("res://scripts/cultivation_state.gd")
const Store=preload("res://scripts/save_store.gd")
const Session=preload("res://scripts/cultivation_session.gd")
const Combat=preload("res://scripts/combat.gd")
const Data=preload("res://scripts/chapter_data.gd")
const Old=preload("res://scripts/legacy_v3/save_store.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		push_error(label)
func golden() -> RefCounted:
	return Store.state_from(JSON.parse_string(FileAccess.get_file_as_string("res://.verification/living-earned-golden-fixture.json")))
func encounter(s: RefCounted, traits: Array) -> Dictionary:
	return Combat.begin(Data.stats(s),{"traits":traits,"hp":10000,"attack":20,"barriers":6})
func _initialize() -> void:
	var s=golden()
	# Controlled mechanic fixture; reachability is verified separately through
	# actual earned rewards. Never shipped to the user's save directory.
	for id in Data.all().skills:
		if not id in s.learned: s.learned.append(id)
	s.cleared_trials.append("earth_heir")
	s.cleared_trials.append("fire_heir")
	s.cleared_trials.append("water_heir")
	s.law="fire"
	var b=encounter(s,[])
	b.burn={"next":20,"until":80,"damage":10}
	Combat.skill(b,"sword")
	check(b.law_procs==1,"Fire caps one indirect event per Sword cast")
	Combat.enemy_hit(b,100,true,true)
	check(b.law_procs==1,"DOT cannot recurse Fire")
	s.law="water"
	b=encounter(s,[])
	Combat.skill(b,"river")
	check(b.law_procs==0 and b.shield==0,"Clean healthy target cannot proc Water")
	b.poison={"next":20,"until":80,"damage":3}
	Combat.skill(b,"river")
	check(b.law_procs==1 and b.shield==.1*b.stats.hp,"Real cleanse grants one short shield")
	s.law="earth"
	b=encounter(s,["channeler"])
	b.shield=200
	b.focus=0
	Combat.player_hit(b,30,false,"burst")
	check(b.focus_refunded==2 and b.law_procs==1,"One charged hit refunds exactly two focus")
	Combat.player_hit(b,3,true,"poison")
	check(b.focus_refunded==2,"DOT shield absorption cannot refund Earth")
	s.law=""
	b=encounter(s,["warded"])
	b.focus=5
	var broken_before=b.barriers_broken
	Combat.skill(b,"returning")
	check(b.barriers_broken-broken_before==2 and b.focus_refunded==2,"Two broken layers refund only once per cast")
	Combat.skill(b,"mirror")
	Combat.player_hit(b,10,false,"physical")
	Combat.player_hit(b,10,false,"physical")
	check(b.counters==1 and not b.counter_ready,"Mirror retaliation consumes its one-use trigger before damage")
	b=encounter(s,["channeler"])
	b.ticks=b.next_burst-20
	b.focus=5
	check(Combat.eligible(b,"thunder"),"Thunder eligible inside charge window")
	var next_basic=b.next_enemy
	Combat.skill(b,"thunder")
	check(b.interrupts==1 and b.next_enemy==next_basic and b.next_burst>b.ticks+20,"Interrupt defers only charge, never basic pressure")
	check(not Combat.eligible(b,"thunder"),"Interrupt cannot loop without cooldown and next telegraph")
	# Preparation selection is non-spending. Only successful departure consumes.
	s=golden()
	var herbs=s.herbs
	var stones=s.stones
	check(s.select_preparation("storm") and s.herbs==herbs and s.stones==stones,"Selection reserves no spend")
	check(s.select_preparation("") and s.herbs==herbs and s.stones==stones,"Cancel refunds by spending zero")
	s.select_preparation("storm")
	check(s.start_journey("storm_ascent"),"Prepared authorized departure")
	check(s.herbs==herbs-4 and s.stones==stones-8 and s.preparation.is_empty(),"Exact cost once on Depart")
	check(not s.start_journey("storm_ascent") and s.herbs==herbs-4,"Double Depart cannot double spend")
	check(s.journey.battle.constraint.preparation=="storm","Committed preparation snapshots into encounter")
	var snap=Store.snapshot(s,1000)
	check(Store.valid(JSON.parse_string(JSON.stringify(snap,"",false,true))),"Prepared in-flight save validates")
	var restored=Store.state_from(snap)
	s.advance(300)
	for i in range(300): restored.advance(1)
	check(s.journey==restored.journey and is_equal_approx(s.qi,restored.qi),"Prepared journey partition/reload deterministic")
	check(s.herbs>=herbs-4,"Automatic stages never repeat consumable cost")
	# Preset omission paths and queued encounter commit.
	s=golden()
	check(s.save_preset(),"Whole-build preset saved")
	s.preset.slots=["mirror","ward","ward"]
	s.preset.equipment.weapon="lake_blade"
	s.preset.law="water"
	check(s.apply_preset() and s.combat_slots==["","ward",""] and s.equipment.weapon=="" and s.law=="" and "omitted" in s.preset_notice,"Preset never invents ownership, law or duplicate slots")
	s=golden()
	s.start_journey("storm_ascent")
	var committed=s.journey.battle.stats.slots.duplicate()
	s.set_combat_slot(0,"sword")
	check(s.journey.battle.stats.slots==committed,"Build changes never mutate an active encounter")
	s.journey.camp_requested=true
	s.advance(400)
	check(s.journey.status=="camp","Requested camp at safe boundary")
	s.continue_journey()
	check(s.journey.battle.stats.slots==s.combat_slots,"Queued build applies on Continue")
	# Closed/open, cap, backward clock, repeated resume and corrupted primary.
	s=golden()
	check(s.assign_supply("stone_steps",6),"Exclusive solved supply selected")
	var closed=Store.state_from(Store.snapshot(s,1000))
	var session=Session.new(closed,1000,0)
	s.advance(28800)
	session.restore(1000,999999,0)
	check(s.supply==closed.supply and s.journey==closed.journey and is_equal_approx(s.qi,closed.qi),"Eight-hour cap and finite supply match foreground")
	var before=closed.qi
	session.resume(999999,0)
	check(closed.qi==before,"Repeated resume awards nothing")
	session.suspend(1000,0)
	session.resume(500,0)
	check(closed.qi==before,"Backward absence clock awards nothing")
	var directory="res://.verification/living-recovery-%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(directory)
	var store=Store.new(directory+"/save.json")
	check(store.save_game(closed,1000) and store.save_game(closed,1000),"Atomic save and backup")
	FileAccess.open(store.path,FileAccess.WRITE).store_string("{corrupted")
	var recovered=store.load_game(1000)
	check(recovered.state.qi==closed.qi and "Recovered" in store.warning and DirAccess.get_files_at(directory).size()>=3,"Corrupted primary preserved and valid backup recovered")
	# Frozen v3 in-flight resolver and one-time first-clear funding.
	var old_data=JSON.parse_string(FileAccess.get_file_as_string("res://.verification/jade-developed-fixture.json"))
	var old=Old.state_from(old_data)
	old.journey.status="complete"
	old.start_journey("stone_steps")
	old.advance(2)
	old_data=Old.snapshot(old,1000)
	var old_store=Store.new(directory+"/old.json")
	FileAccess.open(old_store.path,FileAccess.WRITE).store_string(JSON.stringify(old_data,"",false,true))
	var migration=old_store.load_game(1010)
	check(migration.state.journey.get("legacy_battle",false) and migration.state.journey.battle.ticks>old.journey.battle.ticks,"Old authorized in-flight combat settles with frozen old resolver")
	check(Store.valid(Store.snapshot(migration.state,1010)),"Migrated in-flight battle validates against frozen definition")
	check(old_store.save_game(migration.state,1010),"Migrated checkpoint writes without losing historical battle")
	var wealth=migration.state.qi
	check(old_store.load_game(1010).state.qi==wealth,"Repeated migration checkpoint cannot grant funding twice")
	# Reject impossible new identifiers and ownership in corruption recovery.
	for key in ["law","preparation"]:
		var bad=Store.snapshot(golden(),1000)
		bad.chapter[key]="unknown"
		check(not Store.valid(bad),"Reject unknown "+key)
	for key in Store.CHAPTER_FIELDS:
		var bad=Store.snapshot(golden(),1000)
		bad.chapter[key]=null
		check(not Store.valid(bad),"Reject null chapter field "+key)
	var damage_bad=Store.snapshot(golden(),1000)
	var damage_state=Store.state_from(damage_bad)
	damage_state.start_journey("storm_ascent")
	damage_bad=Store.snapshot(damage_state,1000)
	damage_bad.chapter.journey.battle.damage.extra="invalid"
	check(not Store.valid(damage_bad),"Reject unexpected nonnumeric damage channel before canonicalization")
	print("Living safety: %d checks; %d failures" % [checks,failures])
	FileAccess.open("res://docs/living-dao/SAFETY_RESULTS.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	quit(1 if failures else 0)
