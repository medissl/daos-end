extends SceneTree
const State = preload("res://scripts/cultivation_state.gd")
const Store = preload("res://scripts/save_store.gd")
var checks = 0
var failures = 0
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(title)
func fixture(id: String) -> RefCounted:
	return Store.state_from(JSON.parse_string(FileAccess.get_file_as_string("res://.verification/jade-"+id+"-fixture.json")))
func _initialize() -> void:
	var s = fixture("foundation")
	check(s.start_journey("stone_steps"),"Depart starts authorized route")
	s.advance(40)
	check("flame" in s.learned and s.journey.status=="battle" and s.journey.node>=1,"Discovery credits without mandatory camp")
	check(s.combat_slots==["sword",""],"Discovery never replaces or auto-equips")
	check(Store.valid(Store.snapshot(s,1000)),"Continuous state serializes")
	s = fixture("foundation")
	s.start_journey("stone_steps")
	s.journey.camp_requested = true
	s.advance(90)
	check(s.journey.status=="camp" and s.journey.node==1,"Requested camp stops at next boundary")
	var reward = s.journey.rewards.duplicate(true)
	s.advance(100)
	check(s.journey.rewards==reward,"Camp does not reward again")
	var a = fixture("developed")
	var b = fixture("developed")
	check(a.assign_supply("stone_steps",3) and b.assign_supply("stone_steps",3),"Explicit solved supply assignment")
	var history = a.cleared_nodes.duplicate()
	var inventory = a.inventory.duplicate()
	a.advance(6000)
	for i in range(200): b.advance(30,true)
	check(a.supply==b.supply and a.journey==b.journey and is_equal_approx(a.qi,b.qi),"Open and closed supply use same event accounting")
	check(a.cleared_nodes==history and a.inventory==inventory,"Supply cannot earn first-clear history or items")
	check(a.supply.completed==3 and not a.supply.active,"Finite supply stops after authorized circuits")
	check(Store.valid(Store.snapshot(a,1000)),"Supply terminal state validates")
	a = fixture("developed")
	a.assign_supply("stone_steps",6)
	a.stop_supply()
	a.advance(1000)
	check(not a.supply.active and a.journey.status in ["camp","complete"],"Stop honors safe boundary")
	for profile in ["mortal","foundation","developed","golden","camp"]:
		var migrated = fixture(profile)
		var data = Store.snapshot(migrated,1000)
		check(Store.valid(data),"v3 to v4 snapshot "+profile)
		check(Store.snapshot(Store.state_from(data),1000)==data,"Repeated v4 load is stable "+profile)
	print("Living phase one: %d checks; %d failures" % [checks,failures])
	quit(1 if failures else 0)
