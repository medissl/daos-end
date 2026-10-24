extends SceneTree
const State=preload("res://scripts/cultivation_state.gd")
const Store=preload("res://scripts/save_store.gd")
const Data=preload("res://scripts/chapter_data.gd")
const Combat=preload("res://scripts/combat.gd")
var s: RefCounted
var seconds=0.0
var failures=0
var events=[]
var alternatives={}
func check(ok: bool,message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)
func config(arts: Array,method: String="iron") -> void:
	s.select_primary(method)
	for i in range(s.combat_slots.size()): s.set_combat_slot(i,"")
	for i in range(mini(arts.size(),s.combat_slots.size())): s.set_combat_slot(i,arts[i])
	for group in [["lake_blade","seal_needle","pine_sword"],["moon_silk","storm_thread","river_silk","stoneweave_robe"],["cloud_bell","mystic_gourd","jade_pendant","bone_ring"]]:
		for id in group:
			if s.inventory.has(id):
				s.equip(id)
				break
func candidates() -> Array:
	var result=[]
	for arts in [["ward","river","flame"],["thunder","river","flame"],["mirror","river","flame"],["river","sword","flame"],["river","returning","flame"],["ward","sword","flame"],["thunder","sword","flame"],["returning","river","sword"],["mirror","river","sword"]]:
		var valid=true
		for id in arts:
			if not id in s.learned: valid=false
		if valid: result.append(arts)
	return result
func attempt(id: String) -> void:
	var base=Store.snapshot(s,1000)
	var wins=[]
	for arts in candidates():
		var probe=Store.state_from(base)
		var old=s
		s=probe
		config(arts)
		if s.start_journey(id):
			var duration=0.0
			while s.journey.status=="battle" and duration<600:
				s.advance(.05)
				duration+=.05
			if s.journey.status=="complete": wins.append({"arts":arts,"seconds":snappedf(duration,.05),"hp":s.journey.battle.hp})
		s=old
	alternatives[id]=wins
	if wins.is_empty():
		check(false,"No earned solution for "+id)
		return
	# Use the fastest demonstrated earned option, retaining the slower protective
	# alternatives in the report instead of treating every win as equivalent.
	wins.sort_custom(func(a,b): return a.seconds<b.seconds)
	config(wins[0].arts)
	FileAccess.open("res://.verification/living-before-"+id+".json",FileAccess.WRITE).store_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))
	check(s.start_journey(id),"Start "+id)
	var duration=0.0
	while s.journey.status=="battle" and duration<600:
		s.advance(.05)
		duration+=.05
	seconds+=duration
	events.append({"id":id,"seconds":snappedf(duration,.05),"arts":s.combat_slots.duplicate(),"qi":s.qi,"herbs":s.herbs,"stones":s.stones,"hp":s.journey.battle.hp,"solutions":wins.size()})
	print(events.back())
	check(Store.valid(JSON.parse_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))),"Valid earned snapshot "+id)
	check(wins.size()>=2,"Two approaches for "+id)
	FileAccess.open("res://.verification/living-after-"+id+".json",FileAccess.WRITE).store_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))
func run() -> void:
	var fresh = "--fresh" in OS.get_cmdline_user_args()
	s=Store.state_from(JSON.parse_string(FileAccess.get_file_as_string("res://.verification/"+("living-fresh-golden.json" if fresh else "living-earned-golden-fixture.json"))))
	# A completed pre-extension encounter is historical; begin each new battle
	# through public actions with the currently owned, earned selections.
	for id in ["storm_ascent","thunder_crown","earth_heir","thunder_heir","silent_gate","buried_sun","fire_heir","tomb_heir","mirror_shore","moonless_crossing","water_heir","moon_heir","soul"]:
		attempt(id)
		for law in Data.all().laws:
			if s.law_available(law): s.select_law(law)
	check(s.soul_trial_won,"Soul tribulation earned")
	FileAccess.open("res://.verification/living-soul-ready.json",FileAccess.WRITE).store_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))
	var wait=0.0
	while s.qi<s.breakthrough_cost() and wait<10000:
		s.advance(10)
		wait+=10
	check(s.breakthrough(),"Nascent Soul advancement")
	check(s.combat_slots.size()==4,"Fourth earned slot")
	check(Store.valid(JSON.parse_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))),"Nascent save valid")
	FileAccess.open("res://docs/living-dao/"+("FRESH_SOUL_REACHABILITY.json" if fresh else "SOUL_REACHABILITY.json"),FileAccess.WRITE).store_string(JSON.stringify({"fixture":"Actual earned Jade Road Golden Core save; no awarded new resources, gear or arts. No preparations used.","fresh_run":fresh,"automated_policy":true,"human_engagement":"unmeasured","events":events,"alternatives":alternatives,"combat_seconds":snappedf(seconds,.05),"funding_wait_seconds":wait,"realm":s.realm,"failures":failures},"\t"))
	FileAccess.open("res://.verification/"+("living-fresh-soul.json" if fresh else "living-earned-soul-fixture.json"),FileAccess.WRITE).store_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))
	print("Soul reachability failures: ",failures)
	quit(1 if failures else 0)
func _initialize() -> void: call_deferred("run")
