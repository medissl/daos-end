extends SceneTree
const Main=preload("res://scripts/main.gd")
const Store=preload("res://scripts/save_store.gd")
func settle() -> void:
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw
func run() -> void:
	var main=Main.new()
	main.store=Store.new("res://.verification/living-budget-isolated-%d.json" % Time.get_ticks_usec())
	root.size=Vector2i(390,844)
	root.add_child(main)
	main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await settle()
	main.session.active=false
	main.state=Store.state_from(JSON.parse_string(FileAccess.get_file_as_string("res://.verification/living-earned-soul-fixture.json")))
	main.session.state=main.state
	main.chapter_ui.show_section("arts")
	for id in ["thunder_peak","ancient_tomb","moon_lake","spirit_river","storm_guardian","tomb_guardian","lake_guardian"]: main._texture(id)
	await settle()
	var nodes=get_node_count()
	var objects=Performance.get_monitor(Performance.OBJECT_COUNT)
	var texture=RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED)
	var measurements=[]
	for i in range(60):
		main.state.start_journey("stone_steps")
		main.state.advance(200)
		main.chapter_ui.open_route("stone_steps")
		main.chapter_ui.departure_sheet()
		main.chapter_ui.sheet.hide()
		main.chapter_ui.show_section("arts")
		main.chapter_ui.show_detail("art","mirror")
		main.chapter_ui.sheet.hide()
		# Rapid interrupted transitions, one owned tween and reused scene rig.
		for destination in ["explore","build","cultivate","build"]: main.chapter_ui.navigate(destination)
		await settle()
		if i in [0,9,29,59]: measurements.append({"journeys":i+1,"nodes":get_node_count(),"objects":Performance.get_monitor(Performance.OBJECT_COUNT),"texture_bytes":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED),"orphans":Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)})
	var growth=get_node_count()-nodes
	FileAccess.open("res://docs/living-dao/RUNTIME_BUDGET.json",FileAccess.WRITE).store_string(JSON.stringify({"device":"Windows Intel Iris Xe, Godot 4.7.2 OpenGL compatibility native; not an Android measurement","viewport":[390,844],"initial_nodes":nodes,"initial_objects":objects,"initial_texture_bytes":texture,"samples":measurements,"node_growth":growth,"note":"Includes first creation of final preparation/detail contents; retained UI is bounded. Browser rAF and JS heap are reported separately."},"\t"))
	var plateau: int = int(measurements[-1].nodes)-int(measurements[1].nodes)
	if plateau>2:
		push_error("Repeated journeys grew nodes after warm-up: "+str(plateau))
		quit(1)
		return
	print("Runtime budget node growth: ",growth)
	quit()
func _initialize() -> void: call_deferred("run")
