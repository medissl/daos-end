extends SceneTree
const Main = preload("res://scripts/main.gd")
const Store = preload("res://scripts/save_store.gd")
var checks = 0
var failures = 0
var geometry = {}
var actions = {}
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func _initialize() -> void:
	call_deferred("run")
func settle() -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
func rect(control: Control) -> Rect2:
	var value = control.get_global_rect()
	if control.get_window()!=root: value.position += Vector2(control.get_window().position)
	return value
func array_rect(value: Rect2) -> Array:
	return [value.position.x,value.position.y,value.size.x,value.size.y]
func bounds(node: Node, context: String) -> void:
	if node is Control and node.is_visible_in_tree():
		if node is Button:
			actions[str(node.get_path())] = {"label":node.text,"name":node.name,"accessible":node.accessibility_name,"seen_in":context}
			check(node.size.y>=48,context+" 48px "+node.name)
			var style = node.get_theme_stylebox("normal")
			var available = node.size.x-style.get_margin(SIDE_LEFT)-style.get_margin(SIDE_RIGHT)
			if node.icon: available -= node.get_theme_constant("icon_max_width")+node.get_theme_constant("h_separation")
			for line in node.text.split("\n"):
				check(node.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,node.get_theme_font_size("font_size")).x<=available+1,context+" button text "+node.text)
		if node is Label and node.autowrap_mode==TextServer.AUTOWRAP_OFF:
			for line in node.text.split("\n"):
				check(node.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,node.get_theme_font_size("font_size")).x<=node.size.x+1,context+" label "+node.text)
	for child in node.get_children(): bounds(child,context)
func run() -> void:
	var main = Main.new()
	main.store = Store.new("res://.verification/ux-ui-isolated-%d.json" % Time.get_ticks_usec())
	root.add_child(main)
	main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await settle()
	main.session.active = false
	var slice = "--slice" in OS.get_cmdline_user_args()
	var details_only = "--details" in OS.get_cmdline_user_args()
	var early_only = "--early" in OS.get_cmdline_user_args()
	var selected_profiles = []
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--profile="): selected_profiles.append(arg.trim_prefix("--profile="))
	if details_only or early_only: geometry = JSON.parse_string(FileAccess.get_file_as_string("res://.verification/living-ui-geometry.json"))
	var sizes = [Vector2i(320,640),Vector2i(430,932)] if slice else [Vector2i(320,640),Vector2i(390,844),Vector2i(430,932),Vector2i(1280,800)]
	for profile in (selected_profiles if not selected_profiles.is_empty() else (["mortal","refining"] if early_only else (["developed"] if details_only else (["foundation","camp"] if slice else ["foundation","camp","developed","golden","mortal","refining"])) )):
		if not details_only: geometry[profile] = {}
		var fixture = JSON.parse_string(FileAccess.get_file_as_string("res://.verification/jade-%s-fixture.json" % profile))
		for dimensions in sizes:
			root.size = dimensions
			await settle()
			var key = "%dx%d" % [dimensions.x,dimensions.y]
			if not details_only: geometry[profile][key] = {"tabs":{},"views":{}}
			var views = ["retreat","preview","battle","result","arts"] if slice else ["retreat","journey","preview","battle","result","arts","gear","core","methods","practices","gather","audio"]
			if not slice and profile=="developed": views += ["compare","refine","improve","replace","slot","discover","complete"]
			if details_only: views = ["compare","refine","improve","replace","slot","discover","complete"]
			if profile=="mortal": views = ["practices","explore_locked","build_locked","audio"]
			if profile=="refining": views = ["retreat","methods","practices","gather","build_locked","audio"]
			if profile=="camp": views += ["manage_flame"]
			for view in views:
				var s = Store.state_from(fixture.duplicate(true))
				main.state = s
				main.session.state = s
				var ui = main.chapter_ui
				ui.positions = {}
				ui.equipment_filter = "all"
				ui.discover = false
				ui.discover_arts = false
				ui.toast_until = 0
				ui.seen_learned = s.learned.duplicate()
				ui.sheet.hide()
				await settle()
				ui.selected_detail = ["art","sword"]
				ui.explore_section = "journey"
				ui.region = "Misty Mountain"
				if view=="explore_locked": ui.navigate("explore")
				elif view=="build_locked": ui.navigate("build")
				elif view=="preview": ui.open_route("stone_steps")
				elif view=="battle":
					if s.journey.status=="camp": s.continue_journey()
					else: s.start_journey("stone_steps")
					s.advance(2)
					ui.show_section("battle")
				elif view=="result":
					if s.journey.status!="camp":
						s.start_journey("stone_steps")
						s.journey.camp_requested = true
						s.advance(90)
					ui.show_section("result")
				elif view in ["compare","refine","discover"]:
					ui.show_section("gear")
					if view=="discover": ui.set_discover(true)
					else: ui.show_detail("item" if view=="compare" else "refine","cinnabar_blade")
				elif view in ["improve","replace","slot"]:
					ui.show_section("arts")
					if view=="improve": ui.show_detail("art","sword")
					elif view=="replace": ui.equip_art("sword")
					else: ui.manage_slot(0)
				elif view=="complete": ui.show_section("result")
				elif view=="manage_flame":
					ui.show_section("arts")
					ui.show_detail("art","flame")
				elif view=="audio": ui.open_audio()
				else: ui.show_section(view)
				main._refresh()
				main._layout()
				await settle()
				# Verify the next regular readout tick cannot restore legacy chrome.
				main._refresh()
				await settle()
				check(main.tabs.visible,"Primary destinations remain available")
				check(main.progress_bar.visible==(not s.chapter_unlocked() and ui.destination=="cultivate"),"Progress belongs only to early cultivation")
				check(main.breakthrough_button.visible==(not s.chapter_unlocked() and ui.destination=="cultivate"),"Advancement belongs only to early cultivation")
				if view=="gather": check(ui.destination=="explore" and not main.preparation_group.visible,"Gathering is an exploration task, without advancement controls")
				check(main.hud_panel.get_global_rect().end.x<=dimensions.x+1 and main.hud_panel.get_global_rect().end.y<=dimensions.y+1,profile+" "+key+" HUD fits "+view+" "+str(main.hud_panel.get_global_rect()))
				check(ui.nav.size()==3,"Three destinations")
				for id in ui.nav:
					var p = rect(ui.nav[id]).get_center()
					geometry[profile][key].tabs[id] = [p.x,p.y]
				var hp = rect(main.help_button).get_center()
				geometry[profile][key].help = [hp.x,hp.y]
				var scroll = main.practice_scroll
				var sr = scroll.get_global_rect()
				var bar = scroll.get_v_scroll_bar()
				var targets = {}
				for id in ui.controls:
					var c = ui.controls[id]
					if not is_instance_valid(c) or not c is Button or not c.is_visible_in_tree(): continue
					var r = rect(c)
					var offset = clampf(r.get_center().y-sr.get_center().y,0,maxf(0,bar.max_value-bar.page)) if scroll.is_ancestor_of(c) else 0.0
					targets[id] = {"point":[r.get_center().x,r.get_center().y-offset],"scroll":offset}
					if main.task_dock.is_ancestor_of(c): check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(r),"Persistent action visible "+key+" "+id)
				var center = sr.get_center()
				geometry[profile][key].views[view] = {"targets":targets,"tabs":geometry[profile][key].tabs.duplicate(true),"scroll":[center.x,center.y],"scroll_rect":array_rect(sr),"bar":array_rect(bar.get_global_rect()),"maximum":bar.max_value-bar.page,"page":bar.page}
				if view=="audio":
					geometry[profile][key].audio = {}
					for bus in ui.audio_sliders: geometry[profile][key].audio[bus] = array_rect(rect(ui.audio_sliders[bus]))
				if ui.sheet.visible:
					check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(Rect2(Vector2(ui.sheet.position),Vector2(ui.sheet.size))),"Sheet fits "+key+" "+view)
					for c in ui.sheet_actions.get_children():
						if c is Button: check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(rect(c)),"Sheet decision visible "+key+" "+view)
				if view in ["compare","refine","improve","replace","slot"] and not main.wide:
					check(ui.sheet.visible,"Phone detail sheet actually visible "+view)
				if view=="refine":
					var key_id = "detail_buy" if main.wide else "sheet_buy"
					check(ui.controls[key_id].text=="Refine · 2500 Qi + 15 stones","Exact level-zero refinement price")
				if view=="preview": check(targets.depart.scroll==0,"Depart needs no scroll")
				if view=="result" and s.journey.status=="camp":
					check(targets.continue.scroll==0 and targets.camp_build.scroll==0,"Camp actions need no scroll")
				bounds(main,key+"/"+view)
				root.get_texture().get_image().save_png("res://docs/living-dao/screenshots/native-%s-%s-%s.png" % [profile,key,view])
				if view=="audio": ui.audio_popup.hide()
				ui.sheet.hide()
	FileAccess.open("res://.verification/living-ui-geometry.json",FileAccess.WRITE).store_string(JSON.stringify(geometry,"\t"))
	FileAccess.open("res://docs/living-dao/VISIBLE_ACTIONS.json",FileAccess.WRITE).store_string(JSON.stringify(actions,"\t"))
	print("Living UI: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
