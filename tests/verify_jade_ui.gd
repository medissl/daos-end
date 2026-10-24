extends SceneTree
const Main = preload("res://scripts/main.gd")
const Store = preload("res://scripts/save_store.gd")
const State = preload("res://scripts/cultivation_state.gd")
const Data = preload("res://scripts/chapter_data.gd")
var failures = 0
var checks = 0
var geometry = {}
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func settle() -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
func adjusted_rect(c: Control) -> Rect2:
	var r = c.get_global_rect()
	if c.get_window() != root:
		r.position += Vector2(c.get_window().position)
	return r
func rect_array(c: Control) -> Array:
	var r = adjusted_rect(c)
	return [r.position.x,r.position.y,r.size.x,r.size.y]
func point(c: Control) -> Array:
	var p = adjusted_rect(c).get_center()
	return [p.x,p.y]
func text_bounds(node: Node, context: String) -> void:
	if node is Control and node.is_visible_in_tree():
		if node is ProgressBar:
			for cap in node.get_children():
				if cap is TextureRect:
					check(node.get_global_rect().encloses(cap.get_global_rect()),"Meter caps stay in track "+context)
		var value = ""
		var available: float = node.size.x
		if node is Label and node.autowrap_mode == TextServer.AUTOWRAP_OFF:
			value = node.text
		elif node is Button:
			value = node.text
			var skin = node.get_theme_stylebox("normal")
			available -= skin.get_margin(SIDE_LEFT)+skin.get_margin(SIDE_RIGHT)
			if node.icon:
				available -= node.get_theme_constant("icon_max_width")+node.get_theme_constant("h_separation")
		if not value.is_empty():
			var font: Font = node.get_theme_font("font")
			for line in value.split("\n"):
				var pixels = font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,node.get_theme_font_size("font_size")).x
				check(pixels <= available+1,"Text fits %s: %s (%s > %s)" % [context,line,pixels,available])
		if node is Label:
			var ancestor = node.get_parent()
			while ancestor is Control:
				if ancestor is Button:
					var label_rect = node.get_global_rect()
					var button_rect = ancestor.get_global_rect()
					check(label_rect.position.x >= button_rect.position.x-1 and label_rect.end.x <= button_rect.end.x+1 and label_rect.end.y <= button_rect.end.y+1,"Label stays in action %s: %s" % [context,node.text])
					break
				ancestor = ancestor.get_parent()
	for child in node.get_children():
		text_bounds(child,context)
func run() -> void:
	var main = Main.new()
	main.store = Store.new("res://.verification/jade-ui-isolated-%d.json" % Time.get_ticks_usec())
	root.add_child(main)
	main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await settle()
	for b in main.upgrade_buttons.values()+main.technique_mastery.values()+[main.prepare_button,main.dialog_close]:
		check(b.get_theme_stylebox("normal") is StyleBoxTexture,"Illustrated material for every legacy purchase/commitment")
	var s = State.new()
	FileAccess.open("res://.verification/jade-mortal-fixture.json",FileAccess.WRITE).store_string(JSON.stringify(Store.snapshot(s,Time.get_unix_time_from_system()),"",false,true))
	s.realm = "Foundation Establishment"
	s.primary = "azure"
	s.qi = 5000
	s.herbs = 24
	s.levels = {"breathing":4,"meridian":2,"mind":1}
	var fixture = Store.snapshot(s, Time.get_unix_time_from_system())
	check(Store.valid(fixture), "Fresh Foundation fixture valid")
	FileAccess.open("res://.verification/jade-foundation-fixture.json",FileAccess.WRITE).store_string(JSON.stringify(fixture,"",false,true))
	main.state = s
	main.session.state = s
	main.session.active = false
	var foundation = fixture.duplicate(true)
	for profile in ["foundation","camp","developed","golden"]:
		geometry[profile] = {}
		fixture = foundation.duplicate(true) if profile in ["foundation","camp"] else JSON.parse_string(FileAccess.get_file_as_string("res://.verification/jade-golden-fixture.json"))
		if profile == "camp":
			var camp = Store.state_from(fixture)
			camp.start_journey("stone_steps")
			camp.advance(90)
			fixture = Store.snapshot(camp,Time.get_unix_time_from_system())
		if profile == "developed":
			fixture.realm = "Foundation Establishment"
			fixture.rate *= .5
			fixture.qi = 100000
			fixture.chapter.combat_slots = ["ward","flame"]
			fixture.chapter.preset = {}
			FileAccess.open("res://.verification/jade-developed-fixture.json",FileAccess.WRITE).store_string(JSON.stringify(fixture,"",false,true))
			var core_ready = fixture.duplicate(true)
			core_ready.chapter.core_trial_won = false
			core_ready.chapter.journey = State.new().journey.duplicate(true)
			check(Store.valid(core_ready),"Core Trial entry fixture valid")
			FileAccess.open("res://.verification/jade-core_ready-fixture.json",FileAccess.WRITE).store_string(JSON.stringify(core_ready,"",false,true))
		check(Store.valid(fixture), "Profile valid: "+profile)
		for dimensions in [Vector2i(320,640),Vector2i(390,844),Vector2i(430,932),Vector2i(1280,800)]:
			s = Store.state_from(fixture.duplicate(true))
			main.state = s
			main.session.state = s
			root.size = dimensions
			await settle()
			main._refresh()
			main._layout()
			await settle()
			var key = "%dx%d" % [dimensions.x,dimensions.y]
			geometry[profile][key] = {"help":point(main.help_button),"tabs":{},"views":{}}
			for id in main.chapter_ui.nav:
				geometry[profile][key].tabs[id] = point(main.chapter_ui.nav[id])
			var views = ["retreat","journey","arts","gear","core","preview","battle","result","audio"]
			if profile == "developed": views.append_array(["river","trials","gear_robe","gear_artifact","core_prepared"])
			for view in views:
				s = Store.state_from(fixture.duplicate(true))
				main.state = s
				main.session.state = s
				main.chapter_ui.region = "Misty Mountain"
				main.chapter_ui.selected_equipment = "weapon"
				if view == "preview":
					main.chapter_ui.open_route("stone_steps")
				elif view == "battle":
					if s.journey.status == "camp":
						s.continue_journey()
					else:
						s.start_journey("stone_steps")
					s.advance(2)
					main.chapter_ui.show_section("journey")
				elif view == "result":
					s.start_journey("stone_steps")
					s.journey.camp_requested = true
					s.advance(90)
					main.chapter_ui.show_section("result")
				elif view == "audio":
					main.chapter_ui.open_audio()
				elif view == "river":
					main.chapter_ui.choose_region("Spirit River")
					main.chapter_ui.show_section("journey")
				elif view.begins_with("gear_"):
					main.chapter_ui.filter_gear(view.trim_prefix("gear_"))
					main.chapter_ui.show_section("gear")
				elif view == "core_prepared":
					s.prepare_core()
					main.chapter_ui.show_section("core")
				else:
					main.chapter_ui.show_section(view)
				main._refresh()
				await settle()
				var rect = main.hud_panel.get_global_rect()
				if profile == "foundation" and view == "retreat" and rect.end.x <= dimensions.x:
					var rendered = root.get_texture().get_image()
					for side in range(4):
						var contour = false
						for inset in range(2,13):
							var p = rect.get_center()
							if side == 0: p.x = rect.position.x+inset
							elif side == 1: p.y = rect.position.y+inset
							elif side == 2: p.x = rect.end.x-1-inset
							else: p.y = rect.end.y-1-inset
							var pixel = rendered.get_pixelv(Vector2i(p))
							contour = contour or maxf(pixel.r,maxf(pixel.g,pixel.b)) < .7
						check(contour,"Rendered main panel edge %d present inside %s" % [side,key])
					rendered.save_png("res://docs/jade-road/screenshots/frame-after-%s.png" % key)
				text_bounds(main,key+"/"+view)
				check(rect.end.x <= dimensions.x and rect.end.y <= dimensions.y, "HUD fits %s %s: %s" % [key,view,rect])
				check(main.practice_scroll.size.x <= dimensions.x-20,"Scroll width fits %s %s" % [key,view])
				var targets = {}
				var scroll_rect = main.practice_scroll.get_global_rect()
				if view == "battle":
					check(scroll_rect.encloses(main.chapter_ui.controls.camp_request.get_global_rect()),"Camp action is above the fold "+key)
				for id in main.chapter_ui.controls:
					var c: Control = main.chapter_ui.controls[id]
					if not c is Button or not c.is_visible_in_tree():
						continue
					check(c.size.y >= 48,"48px action %s %s %s" % [key,view,id])
					check(c.get_global_rect().end.x <= dimensions.x,"Action fits horizontally %s %s %s: %s" % [key,view,id,c.get_global_rect()])
					var p = adjusted_rect(c).get_center()
					var offset = clampf(p.y-scroll_rect.get_center().y,0,main.practice_scroll.get_v_scroll_bar().max_value-main.practice_scroll.get_v_scroll_bar().page) if view != "audio" else 0.0
					targets[id] = {"point":[p.x,p.y-offset],"scroll":offset}
				geometry[profile][key].views[view] = {"targets":targets,"scroll":point(main.practice_scroll),"scroll_rect":[scroll_rect.position.x,scroll_rect.position.y,scroll_rect.size.x,scroll_rect.size.y],"maximum": main.practice_scroll.get_v_scroll_bar().max_value - main.practice_scroll.get_v_scroll_bar().page, "page": main.practice_scroll.get_v_scroll_bar().page, "bar": rect_array(main.practice_scroll.get_v_scroll_bar())}
				if view == "audio":
					geometry[profile][key].audio = {}
					for bus in main.chapter_ui.audio_sliders:
						var sr = adjusted_rect(main.chapter_ui.audio_sliders[bus])
						geometry[profile][key].audio[bus] = [sr.position.x,sr.position.y,sr.size.x,sr.size.y]
				if view == "retreat" and key == "430x932" and profile == "foundation":
					var previous = main.hud_panel.get_theme_stylebox("panel")
					main.hud_panel.add_theme_stylebox_override("panel",preload("res://scripts/ui_materials.gd").skin("methods-scroll"))
					await settle()
					root.get_texture().get_image().save_png("res://docs/jade-road/screenshots/style-a-full-scroll.png")
					main.hud_panel.add_theme_stylebox_override("panel",previous)
					await settle()
					root.get_texture().get_image().save_png("res://docs/jade-road/screenshots/style-b-quiet-instrument.png")
				root.get_texture().get_image().save_png("res://docs/jade-road/screenshots/native-%s-%s-%s.png" % [profile,key,view])
				if view == "audio":
					check(main.chapter_ui.audio_popup.size.x <= dimensions.x-24 and main.chapter_ui.audio_popup.size.y <= dimensions.y-24,"Audio dialog fits "+key)
					var menu_bounds = Rect2(Vector2(main.chapter_ui.audio_popup.position),Vector2(main.chapter_ui.audio_popup.size))
					check(menu_bounds.encloses(adjusted_rect(main.chapter_ui.controls.audio_close)),"Menu Return fully inside window "+key)
					main.chapter_ui.audio_popup.hide()
				if view == "result":
					s.leave_camp()
			main._instructions()
			await settle()
			text_bounds(main,key+"/help")
			if profile == "foundation":
				root.get_texture().get_image().save_png("res://docs/jade-road/screenshots/native-foundation-%s-help.png" % key)
			geometry[profile][key].help_close = point(main.dialog_close)
			check(main.details_dialog.size.x <= dimensions.x-24 and main.details_dialog.size.y <= dimensions.y-24,"Help/settings bounds "+key)
			var settings_bounds = Rect2(Vector2(main.details_dialog.position),Vector2(main.details_dialog.size))
			check(settings_bounds.encloses(adjusted_rect(main.dialog_close)),"Return remains inside help popup "+key)
			main.details_dialog.hide()
	FileAccess.open("res://.verification/jade-ui-geometry.json",FileAccess.WRITE).store_string(JSON.stringify(geometry,"\t"))
	print("Jade UI: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
