extends SceneTree
const Main = preload("res://scripts/main.gd")
const Store = preload("res://scripts/save_store.gd")
var checks = 0
var failures = 0
var geometry = {}
func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(text)
func _initialize() -> void:
	call_deferred("run")
func point(control: Control) -> Array:
	var p = control.get_global_rect().get_center()
	return [p.x, p.y]
func target(main: Control, control: Control) -> Dictionary:
	var rect = control.get_global_rect()
	var viewport = main.practice_scroll.get_global_rect()
	var maximum = maxf(0, main.practice_scroll.get_v_scroll_bar().max_value - main.practice_scroll.get_v_scroll_bar().page)
	# Godot wheel input uses steps, not browser CSS scroll pixels. Verify targets
	# at real top/bottom endpoints so browser input need not assume a pixel mapping.
	var scroll = 0.0 if rect.get_center().y >= viewport.position.y + 24 and rect.get_center().y <= viewport.end.y - 24 else maximum
	check(rect.get_center().y - scroll >= viewport.position.y + 24 and rect.get_center().y - scroll <= viewport.end.y - 24, "Action reachable at a scroll endpoint")
	return {"point": [rect.get_center().x, rect.get_center().y - scroll], "scroll": scroll}
func settle() -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
func run() -> void:
	root.size = Vector2i(1280, 800)
	var main = Main.new()
	main.store = Store.new("res://.verification/m2-ui-%d-%d.json" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()])
	root.add_child(main)
	main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await settle()
	check(main.hud_panel.get_global_rect().end.y <= 800, "Initial layout fits without a resize or action")
	for dimensions in [Vector2i(320, 640), Vector2i(430, 932), Vector2i(1280, 800)]:
		root.size = dimensions
		await settle()
		main._layout()
		await settle()
		var key = "%dx%d" % [dimensions.x, dimensions.y]
		geometry[key] = {}
		for phase in ["mortal", "unlocked", "foundation_unlocked"]:
			var unlocked = phase != "mortal"
			main.state.realm = "Foundation Establishment" if phase == "foundation_unlocked" else ("Qi Refining" if unlocked else "Mortal")
			main.state.primary = "azure" if phase == "foundation_unlocked" else "none"
			main.state.mastery = {"azure": 1 if phase == "foundation_unlocked" else 0, "iron": 0}
			main.state.qi = 350
			main.state.herbs = 8 if unlocked else 0
			main._refresh()
			main._layout()
			main.displayed_herbs = main.state.herbs
			main.resource_flash = 0
			main.expanded_practice = false
			main._set_view("cultivate")
			await settle()
			check(main.hud_panel.get_global_rect().end.y <= dimensions.y, "HUD fits " + key)
			check(main.hud_panel.get_global_rect().end.x <= dimensions.x, "HUD width fits " + key)
			check(main.help_button.get_global_rect().end.x <= dimensions.x - 12, "Help fits " + key)
			check(not main.breakthrough_button.visible or main.breakthrough_button.get_global_rect().end.y <= dimensions.y - 10, "Advancement reachable " + key)
			check(main.breakthrough_button.visible != (phase == "foundation_unlocked") and main.attainment.visible == (phase == "foundation_unlocked"), "Foundation is an attained state, not a disabled action")
			if unlocked:
				check(main.cultivate_tab.button_pressed and not main.forest_tab.button_pressed, "Tabs expose selected state")
				check(main.cultivate_tab.get_theme_stylebox("normal").border_width_bottom == 3, "Active tab underline")
				check(main.technique_effect.azure.text.contains("Qi") and main.technique_effect.iron.text.contains("herbs"), "Tradeoffs retain short labels")
			check(main.landscape.character_rect.size.y >= dimensions.y * .25, "Character prominence " + key)
			check(main.landscape.character_rect.position.y >= 0, "Character head fits " + key)
			var data = {"advance": point(main.breakthrough_button), "help": point(main.help_button), "scroll": point(main.practice_scroll),
				"scroll_rect": [main.practice_scroll.get_global_rect().position.x, main.practice_scroll.get_global_rect().position.y, main.practice_scroll.size.x, main.practice_scroll.size.y]}
			if unlocked:
				data.cultivate = point(main.cultivate_tab)
				data.forest = point(main.forest_tab)
				for id in ["azure", "iron"]:
					data[id] = target(main, main.technique_select[id])
					data[id + "_mastery"] = target(main, main.technique_mastery[id])
					check(main.technique_select[id].size.y >= 48 and main.technique_mastery[id].size.y >= 48, "Technique targets")
				data.practice = target(main, main.practice_toggle)
				data.effects = target(main, main.method_detail)
			else:
				for id in ["breathing", "meridian", "mind"]:
					data[id] = target(main, main.upgrade_buttons[id])
					check(main.upgrade_buttons[id].size.y >= 48, "Practice target")
			root.get_texture().get_image().save_png("res://docs/art-direction/milestone-2/screenshots/native-%s-%s.png" % [key, phase])
			geometry[key][phase] = data
			if unlocked:
				main._set_view("forest")
				await settle()
				data = {"scroll": point(main.practice_scroll)}
				for pair in [["start", main.start_button], ["repeat", main.repeat_button], ["prepare", main.prepare_button]]:
					if not pair[1].is_visible_in_tree():
						continue
					data[pair[0]] = point(pair[1]) if pair[0] == "prepare" else target(main, pair[1])
					check(pair[1].size.y >= 48, "Forest action targets")
				geometry[key]["foundation_forest" if phase == "foundation_unlocked" else "forest"] = data
				root.get_texture().get_image().save_png("res://docs/art-direction/milestone-2/screenshots/native-%s-forest.png" % key)
		main._help()
		await settle()
		check(main.details_dialog.size.y <= dimensions.y - 24 and main.details_dialog.size.x <= dimensions.x - 24, "Help bounded " + key)
		geometry[key].dialog_close = [main.details_dialog.position.x + main.dialog_close.get_global_rect().get_center().x, main.details_dialog.position.y + main.dialog_close.get_global_rect().get_center().y]
		geometry[key].motion = [main.details_dialog.position.x + main.motion_button.get_global_rect().get_center().x, main.details_dialog.position.y + main.motion_button.get_global_rect().get_center().y]
		root.get_texture().get_image().save_png("res://docs/art-direction/milestone-2/screenshots/native-%s-help.png" % key)
		main.details_dialog.hide()
		await settle()
		main._offline_notice({"seconds": 28800, "qi": 604800, "herbs": 2400, "trips": 240})
		await settle()
		check(main.details_dialog.visible, "Return reward panel is visible")
		print("Reward panel ", key, " ", main.details_dialog.position, " ", main.details_dialog.size)
		check(main.reward_qi.text == "Qi   +604800" and main.reward_herbs.text == "Herbs   +2400", "Reward labels and numbers")
		check(main.reward_row.size.x <= main.details_dialog.size.x - 24 and main.details_dialog.size.x <= dimensions.x - 24, "Reward summary fits")
		root.get_texture().get_image().save_png("res://docs/art-direction/milestone-2/screenshots/native-%s-rewards.png" % key)
		main.details_dialog.hide()
		# Decision-critical queue and preparation states at every viewport.
		main.state.realm = "Qi Refining"
		main.state.primary = "iron"
		main.state.pending_primary = "azure"
		main.state.mastery = {"azure": 1, "iron": 0}
		main.state.trip = {"active": true, "primary": "iron", "elapsed": 42.0, "azure": 0.0, "iron": 2}
		main._set_view("cultivate")
		main._refresh()
		await settle()
		check("Now +0% Qi" in main.method_status.text and "Next +30% Qi" in main.method_status.text, "Committed and pending bonuses remain visible")
		check(main.technique_seals.azure.text == "Queued" and main.technique_seals.iron.text == "Primary", "Queue and primary labels at " + key)
		if dimensions.x == 320:
			for id in ["azure", "iron"]:
				check(main.technique_parts[id].description.get_global_rect().end.y <= main.practice_scroll.get_global_rect().end.y, "Both narrow-screen identities, states and tradeoffs visible before details")
		check(main.advance_qi.text == "10000 Qi" and main.advance_herbs.text == "+ 12 herbs", "Full unprepared costs labelled")
		main.state.prepared = true
		main._refresh()
		await settle()
		check(main.preparation_state.visible and not main.preparation_group.visible and main.advance_qi.text == "7000 Qi" and main.advance_herbs.visible, "Prepared state retains separate advancement herb requirement")
		check(main.breakthrough_button.get_global_rect().end.y <= dimensions.y - 10, "Prepared advancement fits")
		main.state.repeat = true
		main._set_view("forest")
		main._refresh()
		await settle()
		check(not main.start_button.visible and main.journey_state.text == "Travelling", "Travelling is passive, not a disabled departure")
		check(main.trip_time.get_global_rect().end.y <= main.practice_scroll.get_global_rect().end.y and main.forest_status.get_global_rect().end.y <= main.practice_scroll.get_global_rect().end.y, "Time, reward and method visible before forest action scrolling")
		check("Repeat on" in main.repeat_button.text and "Stop after trip" in main.repeat_button.text and main.repeat_button.size.x <= main.practice_scroll.size.x, "Repeat label, state and stop action fit")
		main.state.prepared = false
		main.state.pending_primary = ""
		main.state.trip = {"active": false, "primary": "none", "elapsed": 0.0, "azure": 0.0, "iron": 0}
	main.state.realm = "Qi Refining"
	main.state.primary = "iron"
	main.state.start_trip()
	main.state.select_primary("azure")
	main.state.herbs = 8
	main._refresh()
	check(main.technique_seals.iron.text == "Primary" and main.technique_seals.azure.text == "Queued", "Current and queued seals distinct")
	check(main.technique_panels.azure.get_theme_stylebox("panel").border_width_top == 2, "Queued unit has persistent frame outside hover")
	check(not main.technique_select.iron.accessibility_name.is_empty(), "Emblem control accessible name")
	main._action("mastery", "iron")
	check(main.state.mastery.iron == 1 and main.state.trip.iron == 2, "Mastery control leaves active commitment")
	main._toggle_motion(true)
	check(main.reduced_motion and main.landscape.reduced_motion, "Reduced motion propagated")
	var preferences = ConfigFile.new()
	check(preferences.load(main.preferences_path) == OK and preferences.get_value("display", "reduced_motion"), "Motion preference saved")
	main.store.writable = false
	main._save()
	check("UNAVAILABLE" in main.save_status.text and main.details_dialog.visible, "Save failure visible and explained")
	main.details_dialog.hide()
	var recovery_path = "res://.verification/m2-ui-recovery-%d.json" % Time.get_ticks_usec()
	var file_recovery = FileAccess.open(recovery_path, FileAccess.WRITE)
	file_recovery.store_string("{truncated")
	file_recovery.close()
	var recovery_main = Main.new()
	recovery_main.store = Store.new(recovery_path)
	root.add_child(recovery_main)
	recovery_main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await settle()
	check(recovery_main.details_dialog.visible and recovery_main.dialog_heading.text == "Save recovery", "Unreadable-save recovery is immediately visible")
	var file = FileAccess.open("res://.verification/m2-ui-geometry.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(geometry, "\t"))
	file.close()
	print("Milestone two UI: %d checks; %d failures" % [checks, failures])
	quit(1 if failures else 0)
