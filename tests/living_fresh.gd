extends SceneTree
const State=preload("res://scripts/cultivation_state.gd")
const Store=preload("res://scripts/save_store.gd")
var s=State.new()
var seconds=0.0
var purchases=[]
func _initialize() -> void:
	while s.realm!="Foundation Establishment" and seconds<10000:
		for id in ["breathing","meridian","mind"]:
			if s.purchase(id): purchases.append({"at":seconds,"id":id,"level":s.levels[id]})
		if s.realm=="Mortal" and s.breakthrough():
			s.select_primary("azure")
			s.start_trip()
		elif s.realm=="Qi Refining":
			if s.herbs>=24 and not s.prepared: s.prepare_foundation()
			if s.prepared: s.breakthrough()
		if s.realm=="Foundation Establishment": break
		s.advance(.05)
		seconds+=.05
	assert(s.realm=="Foundation Establishment" and Store.valid(Store.snapshot(s,1000)))
	FileAccess.open("res://.verification/living-fresh-foundation.json",FileAccess.WRITE).store_string(JSON.stringify(Store.snapshot(s,1000),"",false,true))
	FileAccess.open("res://docs/living-dao/FRESH_OPENING.json",FileAccess.WRITE).store_string(JSON.stringify({"policy":"Public purchases/advancement, Azure gathering, optional Foundation preparation. No granted resources or clock multiplier.","foreground_seconds":snappedf(seconds,.05),"human_active_time":"unmeasured; includes waiting","purchases":purchases,"state":Store.snapshot(s,1000)},"\t"))
	print("Fresh Foundation attained: ",seconds,"s; Qi ",s.qi," herbs ",s.herbs)
	quit()
