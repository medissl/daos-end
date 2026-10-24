extends SceneTree
const Store = preload("res://scripts/save_store.gd")
func _initialize() -> void:
	var base = JSON.parse_string(FileAccess.get_file_as_string("res://.verification/jade-foundation-fixture.json"))
	var state = Store.state_from(base)
	state.start_journey("stone_steps")
	state.advance(90)
	var data = Store.snapshot(state,Time.get_unix_time_from_system())
	assert(Store.valid(data) and state.journey.status == "camp")
	FileAccess.open("res://.verification/jade-camp-fixture.json",FileAccess.WRITE).store_string(JSON.stringify(data,"",false,true))
	print("Camp fixture: derived from Foundation via public simulation; isolated test data only.")
	var early = Store.state_from(JSON.parse_string(FileAccess.get_file_as_string("res://.verification/jade-mortal-fixture.json")))
	early.qi = 1200
	assert(early.breakthrough())
	var refining = Store.snapshot(early,Time.get_unix_time_from_system())
	assert(Store.valid(refining))
	FileAccess.open("res://.verification/jade-refining-fixture.json",FileAccess.WRITE).store_string(JSON.stringify(refining,"",false,true))
	quit()
