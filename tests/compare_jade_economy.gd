extends SceneTree
const Store = preload("res://scripts/save_store.gd")
const Session = preload("res://scripts/cultivation_session.gd")
var fixture: Dictionary
func actor() -> RefCounted:
	var s = Store.state_from(fixture)
	s.realm = "Foundation Establishment"
	s.combat_slots = ["ward","flame"]
	s.preset = {}
	s.qi = 0
	s.herbs = 0
	s.stones = 0
	s.journey = preload("res://scripts/cultivation_state.gd").new().journey.duplicate(true)
	return s
func row(s: RefCounted, label: String, wall: float, reward: Dictionary, decisions: int) -> Dictionary:
	return {"mode":label,"wall_seconds":wall,"effective_seconds":reward.get("effective_seconds",0),"qi":s.qi,"herbs":s.herbs,"stones":s.stones,"journey_status":s.journey.status,"explicit_departures":decisions,"engaged_human_time":"not measured; foreground combat is waiting"}
func _initialize() -> void:
	fixture = JSON.parse_string(FileAccess.get_file_as_string("res://.verification/jade-golden-fixture.json"))
	var report = {"fixture":"Earned chapter build converted to Foundation; balances zeroed; existing Bamboo trip retained identically. No new completion history granted.","rows":[]}
	for hours in [1,8]:
		for offline in [false,true]:
			var s = actor()
			var reward: Dictionary = s.advance(hours*3600,offline)
			report.rows.append(row(s,"retreat closed" if offline else "retreat visible",hours*3600,reward,0))
	for offline in [false,true]:
		var s = actor()
		s.start_journey("stone_steps")
		var reward: Dictionary = s.advance(3600,offline)
		report.rows.append(row(s,"one authorized journey closed" if offline else "one authorized journey foreground",3600,reward,1))
	var repeated = actor()
	var count = 0
	var elapsed = 0.0
	while elapsed < 3600:
		if repeated.journey.status != "battle":
			repeated.start_journey("stone_steps")
			count += 1
		repeated.advance(.05)
		elapsed += .05
	report.rows.append(row(repeated,"explicit repeated foreground departures",3600,{"effective_seconds":3600},count))
	var overnight = actor()
	var session = Session.new(overnight,1000,0)
	session.suspend(1000,0)
	var returned: Dictionary = session.resume(1000+9*3600,1)
	report.rows.append(row(overnight,"nine-hour return capped to eight wall hours",9*3600,returned,0))
	var file = FileAccess.open("res://docs/jade-road/ECONOMY_COMPARISON.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t",true,true))
	print(JSON.stringify(report))
	quit()
