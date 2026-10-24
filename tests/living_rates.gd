extends SceneTree
const Store=preload("res://scripts/save_store.gd")
const State=preload("res://scripts/cultivation_state.gd")
const Old=preload("res://scripts/legacy_v3/save_store.gd")
var checks=0
var failures=[]
func _initialize() -> void:
	var fixture=JSON.parse_string(FileAccess.get_file_as_string("res://.verification/living-earned-soul-fixture.json"))
	var old=Old.state_from(JSON.parse_string(FileAccess.get_file_as_string("res://.verification/jade-golden-fixture.json")))
	old.levels.breathing=0;old.levels.meridian=2;old.mastery={"azure":0,"iron":0};old.primary="azure"
	old.trip=preload("res://scripts/legacy_v3/cultivation_state.gd").idle_trip()
	old.journey=preload("res://scripts/legacy_v3/cultivation_state.gd").new().journey
	old.preset={};old.pending_primary=""
	var legacy_json=JSON.parse_string(JSON.stringify(Old.snapshot(old,1000),"",false,true))
	checks+=1
	if not Store.valid(legacy_json): failures.append({"legacy":"old Golden Core fractional rate must survive JSON"})
	var damaged=legacy_json.duplicate(true);damaged.rate+=.01;checks+=1
	if Store.valid(damaged): failures.append({"legacy":"materially inflated cached rate accepted"})
	for realm in ["Golden Core","Nascent Soul"]:
		for breath in range(5):
			for meridian in range(3):
				for azure in range(3):
					for iron in range(3):
						for method in ["none","azure","iron"]:
							for gathering in [false,true]:
								var s=Store.state_from(fixture)
								s.realm=realm;s.combat_slots=["sword","river","flame"] if realm=="Golden Core" else ["sword","river","flame","mirror"]
								s.preset={};s.journey=State.new().journey;s.trip=State.idle_trip();s.pending_primary=""
								s.levels.breathing=breath;s.levels.meridian=meridian;s.mastery={"azure":azure,"iron":iron};s.primary=method
								if gathering: s.start_trip()
								checks+=1
								var data=Store.snapshot(s,1000)
								if not Store.valid(data) or not Store.valid(JSON.parse_string(JSON.stringify(data,"",false,true))): failures.append({"realm":realm,"levels":s.levels,"mastery":s.mastery,"method":method,"trip":gathering,"rate":s.rate()})
	FileAccess.open("res://docs/living-dao/RATE_SAVE_MATRIX.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	print("Rate/save combinations: ",checks,"; failures ",failures.size())
	if not failures.is_empty(): print(failures[0])
	quit(1 if not failures.is_empty() else 0)
