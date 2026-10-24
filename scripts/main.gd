extends Control
const Rules = preload("res://scripts/progression.gd")
const Store = preload("res://scripts/save_store.gd")
const Session = preload("res://scripts/cultivation_session.gd")
const Landscape = preload("res://scripts/landscape.gd")
const Route = preload("res://scripts/forest_route.gd")
const ChapterUI = preload("res://scripts/chapter_ui.gd")
const GameAudio = preload("res://scripts/game_audio.gd")
const Materials = preload("res://scripts/ui_materials.gd")
var chapter_ui: Node
var audio: Node
var observed_reward = 0
var observed_action = ""
var observed_enemy = ""
var departed_at_ms = -1000
const INK = Color("293e39")
const MUTED = Color("58685f")
const PAPER = Color("f4efe2")
var state: RefCounted
var session: RefCounted
var store: RefCounted
var initialized = false
var save_elapsed = 0.0
var paint_elapsed = 0.0
var landscape: Control
var hud: VBoxContainer
var hud_panel: PanelContainer
var qi_label: Label
var rate_label: Label
var realm_label: Label
var herb_label: Label
var progress_bar: ProgressBar
var breakthrough_button: Button
var prepare_button: Button
var save_status: Label
var notice = "Qi gathers as you breathe. Your first practice costs 25 Qi."
var upgrade_buttons = {}
var upgrade_labels = {}
var upgrade_rows = {}
var upgrade_level_labels = {}
var technique_select = {}
var technique_mastery = {}
var technique_effect = {}
var tabs: HBoxContainer
var cultivate_tab: Button
var forest_tab: Button
var practice_scroll: ScrollContainer
var cultivate_view: VBoxContainer
var forest_view: VBoxContainer
var practice: VBoxContainer
var practice_toggle: Button
var method_status: Label
var forest_status: Label
var trip_time: Label
var start_button: Button
var repeat_button: Button
var unlock_hint: Label
var method_detail: Button
var preparation_hint: Label
var preparation_group: HBoxContainer
var help_button: Button
var active_view = "cultivate"
var expanded_practice = false
var last_unlocked = false
var icons = {}
var realm_icon: TextureRect
var herb_icon: TextureRect
var technique_seals = {}
var technique_pips = {}
var route: Control
var advance_title: Label
var advance_qi: Label
var advance_herbs: Label
var advance_herb_icon: TextureRect
var prepared_seal: TextureRect
var techniques: VBoxContainer
var method_heading: HBoxContainer
var attainment: HBoxContainer
var attainment_text: Label
var preparation_state: Label
var journey_state: Label
var technique_panels = {}
var technique_parts = {}
var compact_methods = false
var reward_row: VBoxContainer
var reward_qi: Label
var reward_herbs: Label
var save_error_shown = false
var resource_flash = 0.0
var displayed_herbs = -1
var advance_badge: TextureRect
var wide = false
var serif: FontVariation
var details_dialog: PopupPanel
var details_body: Label
var dialog_close: Button
var dialog_heading: Label
var dialog_content: VBoxContainer
var dialog_scroll: ScrollContainer
var dialog_scrim: ColorRect
var motion_button: Button
var reduced_motion = false
var preferences_path = ""
var web_visibility_callback: JavaScriptObject
var web_hide_callback: JavaScriptObject
var web_show_callback: JavaScriptObject
var header_row: HBoxContainer
var wallet_row: HBoxContainer
var task_header: VBoxContainer
var task_dock: VBoxContainer
var body_split: HBoxContainer
var body_surface: PanelContainer

func _ready() -> void:
	if OS.has_feature("web") or OS.has_feature("mobile"):
		_configure_display_scale()
		get_window().size_changed.connect(_configure_display_scale)
	if store == null:
		store = Store.new()
	var now = Time.get_unix_time_from_system()
	var loaded = store.load_game(now)
	state = loaded.state
	session = Session.new(state, now, _tick())
	var reward = session.restore(loaded.saved_at, now, _tick(), loaded.get("legacy_rate", -1.0))
	if loaded.has("migration_reward"):
		reward = loaded.migration_reward
	_load_preferences()
	_build_screen()
	audio = GameAudio.new()
	audio.preferences_path = store.path.get_base_dir().path_join("audio.cfg")
	add_child(audio)
	chapter_ui = ChapterUI.new(self)
	add_child(chapter_ui)
	chapter_ui.build()
	if not state.chapter_unlocked():
		_set_view("cultivate")
	observed_reward = state.reward_serial
	details_dialog.add_theme_stylebox_override("panel", Materials.skin("methods-scroll"))
	initialized = true
	get_tree().auto_accept_quit = false
	resized.connect(_layout)
	_refresh()
	_layout()
	if reward.seconds >= 1.0:
		_offline_notice(reward)
	if not store.warning.is_empty():
		_show_notice(store.warning + (" " + notice if reward.seconds >= 1.0 else ""), 0.0)
		if "unreadable" in store.warning or "Recovered" in store.warning:
			_details("Save recovery", notice)
	_save()
	if OS.has_feature("web"):
		web_visibility_callback = JavaScriptBridge.create_callback(_web_visibility)
		web_hide_callback = JavaScriptBridge.create_callback(_web_hide)
		web_show_callback = JavaScriptBridge.create_callback(_web_show)
		JavaScriptBridge.get_interface("document").addEventListener("visibilitychange", web_visibility_callback)
		JavaScriptBridge.get_interface("window").addEventListener("pagehide", web_hide_callback)
		JavaScriptBridge.get_interface("window").addEventListener("pageshow", web_show_callback)
	# Containers compute their first minimum sizes after _ready. Clamp the HUD
	# again once that layout has settled, including on reload at a fixed viewport.
	await get_tree().process_frame
	_layout()

func _configure_display_scale() -> void:
	# The backing canvas uses physical pixels. Layout and touch targets use
	# logical pixels, including on high-density phones and after a resize.
	var window = get_window()
	var density = DisplayServer.screen_get_scale()
	if not is_finite(density) or density <= 0:
		return
	var logical = Vector2i((Vector2(window.size) / density).round())
	logical.x = maxi(1, logical.x)
	logical.y = maxi(1, logical.y)
	if window.content_scale_mode != Window.CONTENT_SCALE_MODE_CANVAS_ITEMS:
		window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	if window.content_scale_aspect != Window.CONTENT_SCALE_ASPECT_IGNORE:
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
	if window.content_scale_size != logical:
		window.content_scale_size = logical

func _tick() -> float:
	return Time.get_ticks_msec() / 1000.0

func _web_visibility(_arguments: Array) -> void:
	if JavaScriptBridge.get_interface("document").hidden:
		suspend_game()
	else:
		resume_game()

func _web_hide(_arguments: Array) -> void:
	suspend_game()

func _web_show(_arguments: Array) -> void:
	resume_game()

func _process(delta: float) -> void:
	if not initialized:
		return
	session.update(_tick())
	if not session.active:
		return
	if observed_reward != state.reward_serial:
		observed_reward = state.reward_serial
		audio.effect("discovery" if state.journey.status == "camp" else "collect")
		_save()
		landscape.handoff()
	if state.journey.status == "battle":
		var action_key = state.journey.id+"/"+str(state.journey.node)+"/"+str(state.journey.battle.last_action)+str(state.journey.battle.action_serial)
		if action_key != observed_action and state.journey.battle.action_serial>0:
			observed_action = action_key
			var sound_id: String = state.journey.battle.last_action
			audio.effect({"mirror":"ward","counter":"ward","thunder":"ward"}.get(sound_id,sound_id if sound_id in ["flame","ward","river"] else "strike"))
			landscape.effect_texture = _texture("mirror" if sound_id=="counter" else (sound_id if sound_id in ["flame","ward","river","sword","thunder","returning","mirror"] else "sword"))
			landscape.effect_time = .55
			landscape.player_action(sound_id)
		var enemy_key = state.journey.id+"/"+str(state.journey.battle.enemy_serial)+"/"+str(state.journey.node)
		if enemy_key != observed_enemy:
			observed_enemy = enemy_key
			if state.journey.battle.enemy_serial > 0:
				audio.effect("enemy-hit")
				landscape.enemy_action(state.journey.battle.last_enemy_action)
	var in_encounter: bool = state.journey.status == "battle" and chapter_ui.section == "battle"
	if landscape.encounter != in_encounter:
		landscape.encounter = in_encounter
		_layout()
	landscape.region_texture = _texture(chapter_ui.region_art()) if state.chapter_unlocked() and chapter_ui.section in ["battle", "journey", "preview", "result"] else null
	landscape.region_name = chapter_ui.region if landscape.region_texture else "Misty Mountain"
	if in_encounter:
		var b: Dictionary = state.journey.battle
		landscape.guardian_texture = _texture(b.enemy.art)
		landscape.warded = b.shield > 0
		landscape.poisoned = not b.poison.is_empty()
		landscape.barriers = b.barriers
		landscape.telegraph = "channeler" in b.enemy.traits and b.next_burst-b.ticks <= 40
	audio.set_scene(state.journey.status == "battle", chapter_ui.region == "Spirit River" and chapter_ui.section != "retreat")
	resource_flash = maxf(0.0, resource_flash - delta)
	save_elapsed += delta
	paint_elapsed += delta
	if save_elapsed >= 10.0:
		_save()

	if paint_elapsed >= .1:
		_refresh()
		paint_elapsed = 0.0

func _notification(what: int) -> void:
	if not initialized:
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		suspend_game()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		resume_game()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		suspend_game()
		get_tree().quit()

func suspend_game() -> void:
	audio.suspend_audio()
	if session.active:
		session.suspend(Time.get_unix_time_from_system(), _tick())
		_save()

func resume_game() -> void:
	audio.resume_audio()
	if not session.active:
		var reward = session.resume(Time.get_unix_time_from_system(), _tick())
		if reward.seconds >= 1.0:
			_offline_notice(reward)
		_save()
		_refresh()

func _save() -> void:
	var now = Time.get_unix_time_from_system() if session.active else session.absent_since
	if session.active:
		session.update(_tick())
	var success = store.save_game(state, now)
	save_status.text = "Saved" if success else "SAVE UNAVAILABLE · keep this session open"
	if not success:
		_show_notice("Saving is unavailable. Keep this session open to retain progress. " + store.warning, 0.0)
		if not save_error_shown:
			save_error_shown = true
			_details("Saving unavailable", notice)
	save_elapsed = 0.0

func _action(kind: String, id: String = "") -> void:
	if not session.active:
		return
	session.update(_tick())
	var success = false
	match kind:
		"upgrade":
			success = state.purchase(id)
			if success:
				_show_notice("Mind settled. Mortal advancement now needs 800 Qi." if id == "mind" else Rules.UPGRADES[id].title + " deepened.", 5)
		"select":
			success = state.select_primary(id)
			if success:
				_show_notice("Queued for the next departure." if state.trip.active else "Primary method: " + Rules.TECHNIQUES[id].short + ".", 5)
		"mastery":
			success = state.improve(id)
			if success:
				_show_notice("Mastery deepened. Effects apply next departure." if state.trip.active else "Mastery deepened. Effects apply now.", 5)
		"start":
			success = state.start_trip()
		"repeat":
			state.set_repeat(not state.repeat)
			success = true
		"prepare":
			success = state.prepare_foundation()
			if success:
				_show_notice("Foundation prepared. Advancement still needs 7,000 Qi and 12 herbs.", 8)
		"advance":
			success = state.breakthrough()
			if success:
				landscape.flash = 1.0
				landscape.celebration = 0 if reduced_motion else 2
				_show_notice("Qi Refining. Choose a primary method, then visit the forest." if state.realm == "Qi Refining" else "Foundation established. The other method now contributes half its effect.", 8)
	if success:
		audio.effect("breakthrough" if kind == "advance" else ("purchase" if kind in ["upgrade", "mastery", "prepare"] else "select"))
		_save()
	else:
		audio.effect("unavailable")
	_refresh()
	_layout()

func buy_upgrade(id: String) -> void:
	_action("upgrade", id)

func attempt_breakthrough() -> void:
	if state.chapter_unlocked():
		chapter_ui.show_section("core")
		return
	_action("advance")

func _chapter_action(kind: String, id: String = "", index: int = -1) -> void:
	if not session.active:
		return
	# A rapid second Depart tap lands where Camp appears in the next scene.
	# Ignore that one stale input; simulation commits immediately on tap one.
	if kind=="camp" and Time.get_ticks_msec()-departed_at_ms<220: return
	session.update(_tick())
	var success = false
	match kind:
		"journey": success = state.start_journey(id)
		"supply": success = state.assign_supply(id,3)
		"camp":
			state.journey.camp_requested = not state.journey.camp_requested
			success = true
		"continue": success = state.continue_journey()
		"leave": success = state.leave_camp()
		"art": success = state.set_combat_slot(index, id)
		"train_art": success = state.improve_art(id)
		"equip": success = state.equip(id)
		"unequip":
			if state.equipment.has(id):
				state.equipment[id] = ""
				success = true
		"refine": success = state.refine(id)
		"prepare_core": success = state.prepare_core()
		"law": success = state.select_law(id)
		"preparation": success = state.select_preparation(id)
		"preset_save": success = state.save_preset()
		"preset_apply": success = state.apply_preset()
		"advance": success = state.breakthrough()
	if success:
		if kind in ["journey","supply"]:
			departed_at_ms = Time.get_ticks_msec()
			observed_action = ""
			observed_enemy = ""
			landscape.handoff()
		audio.effect("breakthrough" if kind == "advance" else ("purchase" if kind in ["train_art", "refine", "prepare_core"] else "select"))
		_save()
		if kind in ["journey", "supply", "continue", "leave"]:
			chapter_ui.show_section("journey" if kind != "leave" else "retreat")
		if kind == "advance":
			landscape.flash = 1
			landscape.celebration = 0 if reduced_motion else 2
			chapter_ui.show_section("retreat")
	else:
		audio.effect("unavailable")
	_refresh()
	_layout()

func _offline_notice(reward: Dictionary) -> void:
	if chapter_ui:
		chapter_ui.toast_message("While away: +%s Qi · +%d herbs · +%d stones" % [_number(reward.get("qi",0)),reward.get("herbs",0),reward.get("stones",0)])

func _unhandled_input(event: InputEvent) -> void:
	if not initialized or landscape.celebration<=0: return
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed) or event.is_action_pressed("ui_accept"):
		landscape.celebration = 0


func _show_notice(message: String, _seconds: float) -> void:
	notice = message
	if chapter_ui and chapter_ui.built: chapter_ui.toast_message(message)

func _number(value: float) -> String:
	if value >= 1000000000000.0:
		return "%.2e" % value
	if value >= 1000000.0:
		return "%.2fM" % (value / 1000000.0)
	if is_equal_approx(value, round(value)):
		return str(int(value))
	var formatted = "%.4f" % value
	while formatted.ends_with("0"):
		formatted = formatted.left(-1)
	return formatted.trim_suffix(".")

func _method(id: String) -> String:
	return "None" if id == "none" else Rules.TECHNIQUES[id].short

func _effects(effects: Dictionary) -> String:
	return "+%s%% Qi · +%d herbs / trip" % [_number(effects.azure * 100), effects.iron]

func _refresh() -> void:
	var unlocked: bool = state.unlocked()
	qi_label.text = "%s Qi" % _number(floor(state.qi))
	herb_label.text = "%d herbs" % state.herbs if unlocked else ""
	herb_icon.visible = unlocked
	realm_icon.texture = _texture({"Mortal": "mortal", "Qi Refining": "refining", "Foundation Establishment": "foundation", "Golden Core": "golden_core", "Nascent Soul":"nascent_soul"}[state.realm])
	if displayed_herbs >= 0 and displayed_herbs != state.herbs:
		resource_flash = 1.6
	displayed_herbs = state.herbs
	herb_label.add_theme_color_override("font_color", Color("914b37") if resource_flash > 0 else MUTED)
	herb_label.accessibility_name = "Spirit Herbs: %d" % state.herbs
	rate_label.text = "+%s Qi / second" % _number(state.rate())
	realm_label.text = "Foundation" if state.realm == "Foundation Establishment" else state.realm
	var requirement: float = state.breakthrough_cost()
	var completed = state.realm == "Foundation Establishment"
	progress_bar.max_value = maxf(1, requirement)
	progress_bar.value = requirement if completed else minf(state.qi, requirement)
	progress_bar.visible = not completed
	breakthrough_button.visible = not completed
	attainment.visible = completed
	preparation_group.visible = state.realm == "Qi Refining" and not state.prepared
	preparation_state.visible = state.prepared
	prepare_button.disabled = state.herbs < Rules.PREPARATION_HERBS
	prepare_button.accessibility_name = "Prepare Foundation; spend 12 extra herbs to lower advancement to 7000 Qi; advancement still costs 12 herbs"
	breakthrough_button.disabled = completed or state.qi < requirement or (unlocked and state.herbs < Rules.FOUNDATION_HERBS)
	advance_title.text = "Foundation established" if completed else ("Enter Foundation" if unlocked else "Enter Qi Refining")
	advance_title.add_theme_color_override("font_color", MUTED if breakthrough_button.disabled else PAPER)
	advance_qi.add_theme_color_override("font_color", MUTED if breakthrough_button.disabled else PAPER)
	advance_herbs.add_theme_color_override("font_color", MUTED if breakthrough_button.disabled else PAPER)
	advance_qi.text = _number(requirement) + " Qi"
	advance_herbs.text = "+ 12 herbs"
	advance_herbs.visible = unlocked and not completed
	advance_herb_icon.visible = unlocked and not completed
	advance_badge.texture = _texture("foundation" if unlocked else "refining")
	prepared_seal.visible = state.prepared
	breakthrough_button.accessibility_name = advance_title.text + ("; costs %s Qi" % _number(requirement) + (" and 12 herbs" if unlocked else "") if not completed else "")
	landscape.realm_stage = 2 if completed else (1 if unlocked else 0)
	landscape.awakened = unlocked
	tabs.visible = unlocked
	unlock_hint.visible = not unlocked
	method_heading.visible = unlocked
	method_detail.visible = unlocked
	practice_toggle.visible = unlocked
	practice.visible = not unlocked or expanded_practice
	for id in Rules.UPGRADES:
		var capped: bool = state.levels[id] >= Rules.UPGRADES[id].cap
		upgrade_level_labels[id].text = "%d/%d · %s" % [state.levels[id], Rules.UPGRADES[id].cap, {"breathing": "+1 base Qi/s", "meridian": "+25% base", "mind": "800 Qi goal"}[id]]
		upgrade_buttons[id].text = "Learned" if capped else "%s Qi" % _number(state.cost(id))
		upgrade_buttons[id].disabled = capped or state.qi < state.cost(id)
		upgrade_buttons[id].visible = not capped
		if capped: upgrade_level_labels[id].text += " · Learned"
	var learned = state.levels.breathing + state.levels.meridian + state.levels.mind
	practice_toggle.text = ("Close practices" if expanded_practice else ("Practices ›" if compact_methods else "Review practices ›")) + " · %d/7" % learned
	for id in Rules.TECHNIQUES:
		technique_panels[id].visible = unlocked
		technique_effect[id].text = ("+%s%% Qi" % _number(Rules.TECHNIQUES[id].azure[state.mastery[id]] * 100) if id == "azure" else "+%d herbs" % Rules.TECHNIQUES[id].iron[state.mastery[id]])
		var chosen: bool = state.primary == id
		var queued: bool = state.pending_primary == id
		technique_seals[id].text = "Queued" if queued else ("Primary" if chosen else "Equip ›")
		var frame = _style(Color.TRANSPARENT, Color("a6573f") if queued else Color("4c7161"), 4)
		frame.set_border_width_all(0)
		frame.border_width_left = 3 if chosen or queued else 0
		frame.border_width_top = 2 if queued else 0
		frame.content_margin_bottom = 2
		technique_panels[id].add_theme_stylebox_override("panel", frame)
		technique_select[id].toggle_mode = true
		technique_select[id].set_pressed_no_signal(chosen or queued)
		technique_select[id].add_theme_stylebox_override("pressed", _style(Color.TRANSPARENT))
		technique_select[id].accessibility_name = Rules.TECHNIQUES[id].title + "; " + technique_seals[id].text + "; mastery %d of 2" % state.mastery[id]
		for i in range(2):
			var pip = _style(Color("517565") if state.mastery[id] > i else Color.TRANSPARENT, Color("517565"), 0)
			pip.set_corner_radius_all(6)
			technique_pips[id][i].add_theme_stylebox_override("panel", pip)
		technique_mastery[id].text = "Mastered" if state.mastery[id] == 2 else ("Train\n%d herbs" if compact_methods else "Train · %d herbs") % state.mastery_cost(id)
		technique_mastery[id].accessibility_name = Rules.TECHNIQUES[id].title + (" mastered" if state.mastery[id] == 2 else "; increase mastery for %d herbs" % state.mastery_cost(id))
		technique_mastery[id].disabled = state.mastery[id] == 2 or state.herbs < state.mastery_cost(id)
	if unlocked:
		method_status.text = "Methods" if state.primary != "none" else "Choose a method"
		if state.trip.active:
			method_status.text = "Now %s\nNext %s" % [_effects(state.effective_bonuses()).replace(" / trip", ""), _effects(state.next_bonuses()).replace(" / trip", "")]
		method_detail.accessibility_name = "Current and next method effects"

		var reward: int = Rules.BASE_HERBS + (state.trip.iron if state.trip.active else state.next_bonuses().iron)
		forest_status.text = "%s · %s" % [_method(state.trip.primary if state.trip.active else state.primary), _effects(state.effective_bonuses())]
		trip_time.text = "%ds remaining · %d herbs" % [ceili(Rules.TRIP_SECONDS - state.trip.elapsed), reward] if state.trip.active else "120 seconds · %d herbs" % reward
		route.progress = state.trip.elapsed / Rules.TRIP_SECONDS if state.trip.active else 0.0
		route.active = state.trip.active
		route.method_texture = _texture(state.trip.primary) if state.trip.active and state.trip.primary != "none" else null
		route.queue_redraw()
		start_button.visible = not state.trip.active
		start_button.disabled = false
		start_button.text = "Depart"
		journey_state.text = "Travelling" if state.trip.active else "Ready"
		start_button.accessibility_name = "Bamboo Forest; " + start_button.text
		repeat_button.text = "Repeat on · Stop after trip" if state.trip.active and state.repeat else ("Repeat: off" if not state.repeat else "Repeat: on")
		repeat_button.set_pressed_no_signal(state.repeat)
		repeat_button.accessibility_name = "Repeat is " + ("on; finish this trip then stop" if state.repeat and state.trip.active else ("on; disable repeat" if state.repeat else "off; enable repeat"))
	if unlocked != last_unlocked:
		last_unlocked = unlocked
		_layout()
	if chapter_ui:
		chapter_ui.refresh()
		if state.chapter_unlocked():
			breakthrough_button.add_theme_stylebox_override("normal", _style(Color("dce5d8")))
			breakthrough_button.add_theme_stylebox_override("hover", _style(Color("c8d9c5")))
			breakthrough_button.add_theme_stylebox_override("pressed", _style(Color("c8d9c5")))
		_refresh_scene()

func _refresh_scene() -> void:
	var combat_active: bool = state.journey.status == "battle" and chapter_ui.section == "battle"
	landscape.encounter = combat_active
	if chapter_ui.has_method("scene_mode"):
		landscape.presentation = chapter_ui.scene_mode()
	var region = chapter_ui.region
	if combat_active and preload("res://scripts/chapter_data.gd").all().routes.has(state.journey.id):
		region = preload("res://scripts/chapter_data.gd").all().routes[state.journey.id].region
	landscape.region_texture = _texture(chapter_ui.region_art()) if state.chapter_unlocked() and chapter_ui.section in ["battle", "journey", "preview", "result"] else null
	landscape.region_name = region if landscape.region_texture else "Misty Mountain"
	if combat_active:
		var b: Dictionary = state.journey.battle
		landscape.guardian_texture = _texture(b.enemy.art)
		landscape.warded = b.shield > 0
		landscape.poisoned = not b.poison.is_empty()
		landscape.barriers = b.barriers
		landscape.telegraph = "channeler" in b.enemy.traits and b.next_burst-b.ticks <= 40
	landscape.compose(wide, hud_panel.position.y, hud_panel.position.x - 20 if wide else size.x)
	landscape.queue_redraw()

func _set_view(view: String) -> void:
	if chapter_ui:
		chapter_ui.navigate("cultivate" if view == "cultivate" else "explore")
		return
	active_view = view
	cultivate_view.visible = view == "cultivate"
	forest_view.visible = view == "forest"
	for pair in [[cultivate_tab, "cultivate"], [forest_tab, "forest"]]:
		var selected: bool = view == pair[1]
		pair[0].set_pressed_no_signal(selected)
		var mark = _style(Color.TRANSPARENT, Color("446c5a"))
		mark.set_border_width_all(0)
		mark.border_width_bottom = 3 if selected else 0
		pair[0].add_theme_stylebox_override("normal", mark)
		pair[0].add_theme_stylebox_override("pressed", mark)
		var hover = mark.duplicate()
		hover.bg_color = Color(.30,.43,.35,.06)
		pair[0].add_theme_stylebox_override("hover", hover)
	practice_scroll.scroll_vertical = 0

func _toggle_practice() -> void:
	expanded_practice = not expanded_practice
	_refresh()

func _load_preferences() -> void:
	preferences_path = store.path.get_base_dir().path_join("presentation.cfg")
	var config = ConfigFile.new()
	var system_reduced = bool(JavaScriptBridge.eval("window.matchMedia('(prefers-reduced-motion: reduce)').matches")) if OS.has_feature("web") else false
	reduced_motion = config.get_value("display", "reduced_motion", system_reduced) == true if config.load(preferences_path) == OK else system_reduced

func _toggle_motion(pressed: bool) -> void:
	reduced_motion = pressed
	landscape.reduced_motion = pressed
	landscape.breath = 0
	if pressed and chapter_ui:
		if chapter_ui.navigation_tween and chapter_ui.navigation_tween.is_valid(): chapter_ui.navigation_tween.kill()
		body_surface.modulate.a = 1
	motion_button.text = "Reduce animation"
	motion_button.icon = _texture("selection-seal") if pressed else null
	var config = ConfigFile.new()
	config.set_value("display", "reduced_motion", pressed)
	config.save(preferences_path)

func _details(title: String, text: String, include_settings: bool = false) -> void:
	dialog_heading.text = title
	reward_row.hide()
	details_body.text = text
	dialog_scroll.scroll_vertical = 0
	var width = mini(int(size.x) - 24, 440)
	details_body.custom_minimum_size.x = width - 96
	details_body.size.x = width - 96
	dialog_content.size.x = width - 84
	var body_height = theme.default_font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, width - 96, 16).y
	var reserved = 188
	dialog_scroll.custom_minimum_size.y = minf(body_height + 8, size.y - 32 - reserved)
	details_dialog.popup_centered(Vector2i(width, mini(ceili(body_height) + reserved + 8, int(size.y) - 32)))
	_fit_popup_content(details_dialog,dialog_content)
	dialog_close.grab_focus()

func _fit_popup_content(window: PopupPanel, content: Control) -> void:
	var skin = window.get_theme_stylebox("panel")
	var start = Vector2(skin.get_margin(SIDE_LEFT),skin.get_margin(SIDE_TOP))
	var end = Vector2(skin.get_margin(SIDE_RIGHT),skin.get_margin(SIDE_BOTTOM))
	content.position = start
	content.size = Vector2(window.size) - start - end

func _upgrade_details(id: String) -> void:
	var effects = {
		"breathing": "Adds 1 to base Qi per second per level, before Meridian, realm and technique multipliers. Maximum 4 levels.",
		"meridian": "Multiplies base production by 1.00, 1.25, then 1.50. Maximum 2 levels.",
		"mind": "Costs 200 Qi once. Lowers only the Mortal advancement requirement from 1,200 to 800 stored Qi. No production bonus.",
	}
	_details(Rules.UPGRADES[id].title, effects[id] + "\n\nCurrent production: %s Qi/second. Upgrades remain through advancement." % _number(state.rate()))

func _technique_details(id: String) -> void:
	var text = "Mastery 0/1/2 gives +20% / +30% / +40% Qi." if id == "azure" else "Mastery 0/1/2 gives +2 / +4 / +6 herbs per forest trip, in addition to 4 base herbs."
	text += "\n\nAzure mastery costs 4 then 8 herbs; Iron costs 8 then 16 herbs. Azure also recovers combat focus; Iron increases combat HP. Only the primary method contributes before Foundation."
	text += "\n\nAt Foundation the other method contributes half its normal bonus. During a trip all method bonuses are committed; changes apply at the next departure."
	_details(Rules.TECHNIQUES[id].title, text)

func _method_details() -> void:
	_details("Method effects", "%s: %s\n%s\nCurrent production: %s Qi/second.\n\nNext departure: %s\n%s\n\nMethod, mastery and resonance changes wait until the next departure while a trip is active. The realm’s base production changes immediately." %
		["Committed trip" if state.trip.active else "Primary", _method(state.primary), _effects(state.effective_bonuses()), _number(state.rate()), _method(state.pending_primary if state.pending_primary != "" else state.primary), _effects(state.next_bonuses())] + "\n\nAzure Cloud mastery: +20% / +30% / +40% Qi; training costs 4 then 8 herbs. Iron Body mastery: +2 / +4 / +6 herbs per trip above 4 base herbs; training costs 8 then 16 herbs. At Foundation the secondary method contributes half its bonus.")

func _help() -> void:
	chapter_ui.open_audio()

func _instructions() -> void:
	_details("A cultivator’s journey", "Choose a goal in Cultivate, a route in Explore, and ordered techniques and equipment in Build. Techniques act automatically. Changes apply at the next encounter. Request camp to stop at the next safe boundary. Ordinary discoveries and rewards credit without acknowledgement.\n\nFrontier journeys run at full speed while playing. Retreat and explicitly assigned cleared-route supply run at 30% open or closed. Absence credits at most eight hours; there is one reward timeline. Supply is finite, never spends preparations and never awards first-clear rewards.\n\nFoundation opens the Jade Road. Two routes in each original region and the Core Trial open Golden Core for 24,000 Qi. Golden Core opens Thunder Peak, Ancient Tomb and Moon Lake. Six new routes, one inheritance per new region and the free tribulation open Nascent Soul for 90,000 Qi, earning a fourth technique slot.\n\nOne law is freely reversible. Optional preparations display exact costs before Depart; selecting or cancelling spends nothing. There are no rare required drops. Defeat retains earned rewards. The chapter ends at Nascent Soul; remaining inheritances are optional mastery.")

func _texture(id: String) -> Texture2D:
	if not icons.has(id):
		var path = "res://assets/art/living/%s.png" % id
		if not ResourceLoader.exists(path): path = "res://assets/chapter/%s.png" % id
		if not ResourceLoader.exists(path):
			path = "res://assets/icons/%s.png" % id
		icons[id] = load(path) if ResourceLoader.exists(path) else null
	return icons[id]

func _icon(id: String, pixels: int = 32) -> TextureRect:
	var image = TextureRect.new()
	image.texture = _texture(id)
	image.custom_minimum_size = Vector2.ONE * pixels
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return image

func _button_icon(button: Button, id: String, pixels: int = 24) -> void:
	button.icon = _texture(id)
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", pixels)

func _style(fill: Color, border: Color = Color.TRANSPARENT, padding: int = 8) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	return style

func _label(text: String, font_size: int = 16, color: Color = INK, wrap: bool = false) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text: String, flat: bool = false) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(48, 48)
	b.mouse_filter = Control.MOUSE_FILTER_PASS
	b.focus_entered.connect(_reveal_focused.bind(b))
	b.add_theme_font_size_override("font_size", 16)
	for key in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(key, INK if flat else PAPER)
	b.add_theme_color_override("font_disabled_color", Color("54645a"))
	if flat:
		b.add_theme_stylebox_override("normal", _style(Color.TRANSPARENT))
		b.add_theme_stylebox_override("hover", _style(Color("e3e4d6")))
		b.add_theme_stylebox_override("pressed", _style(Color("d3d9c9")))
		b.add_theme_stylebox_override("disabled", _style(Color.TRANSPARENT))
	else:
		Materials.action(b)
	var focus = _style(Color.TRANSPARENT, Color("a54e38"))
	focus.set_border_width_all(2)
	b.add_theme_stylebox_override("focus", focus)
	return b

func _reveal_focused(control: Control) -> void:
	# Reveal once on an explicit focus change. Continuous follow_focus can
	# fight a player's scroll when a live meter/label triggers container layout.
	var parent = control.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible(control)
			return
		parent = parent.get_parent()

func _heading(text: String, size_px: int = 26) -> Label:
	var h = _label(text, size_px)
	h.add_theme_font_override("font", serif)
	return h

func _build_screen() -> void:
	get_viewport().gui_embed_subwindows = true
	theme = Theme.new()
	theme.default_font = preload("res://assets/fonts/Lato-Regular.ttf")
	theme.default_font_size = 16
	serif = FontVariation.new()
	serif.base_font = preload("res://assets/fonts/CormorantGaramond.ttf")
	serif.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 650.0}
	landscape = Landscape.new()
	landscape.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	landscape.reduced_motion = reduced_motion
	add_child(landscape)
	# One complete illustrated reading surface; its four edges stay in bounds.
	hud_panel = PanelContainer.new()
	var surface = Materials.skin("main-panel")
	hud_panel.add_theme_stylebox_override("panel", surface)
	add_child(hud_panel)
	hud_panel.minimum_size_changed.connect(_layout.call_deferred)
	hud = VBoxContainer.new()
	hud.add_theme_constant_override("separation", 4)
	hud_panel.add_child(hud)
	var top = HBoxContainer.new()
	header_row = top
	top.add_theme_constant_override("separation", 8)
	hud.add_child(top)
	realm_icon = _icon("mortal", 32)
	top.add_child(realm_icon)
	var names = VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	names.add_theme_constant_override("separation", 0)
	top.add_child(names)
	realm_label = _heading("", 23)
	names.add_child(realm_label)
	rate_label = _label("", 14, MUTED)
	names.add_child(rate_label)
	help_button = _button("Menu", true)
	help_button.accessibility_name = "Menu: sound, display, help and credits"
	help_button.pressed.connect(_help)
	top.add_child(help_button)
	var resources = HBoxContainer.new()
	wallet_row = resources
	resources.add_theme_constant_override("separation", 4)
	hud.add_child(resources)
	resources.add_child(_icon("qi", 24))
	qi_label = _heading("0 Qi", 29)
	qi_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resources.add_child(qi_label)
	herb_icon = _icon("herbs", 26)
	resources.add_child(herb_icon)
	herb_label = _label("", 15, INK)
	herb_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	resources.add_child(herb_label)
	tabs = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 16)
	hud.add_child(tabs)
	cultivate_tab = _button("Cultivate", true)
	forest_tab = _button("Forest", true)
	for b in [cultivate_tab, forest_tab]:
		b.toggle_mode = true
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tabs.add_child(b)
	cultivate_tab.pressed.connect(_set_view.bind("cultivate"))
	forest_tab.pressed.connect(_set_view.bind("forest"))
	task_header = VBoxContainer.new()
	task_header.add_theme_constant_override("separation", 6)
	hud.add_child(task_header)
	body_surface = PanelContainer.new()
	body_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hud.add_child(body_surface)
	body_split = HBoxContainer.new()
	body_split.add_theme_constant_override("separation", 24)
	body_surface.add_child(body_split)
	practice_scroll = ScrollContainer.new()
	practice_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	practice_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	practice_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	practice_scroll.follow_focus = false
	practice_scroll.custom_minimum_size.y = 80
	body_split.add_child(practice_scroll)
	var views = VBoxContainer.new()
	views.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	practice_scroll.add_child(views)
	cultivate_view = VBoxContainer.new()
	cultivate_view.add_theme_constant_override("separation", 4)
	views.add_child(cultivate_view)
	unlock_hint = _label("Practise to open the way", 15, MUTED)
	cultivate_view.add_child(unlock_hint)
	method_heading = HBoxContainer.new()
	cultivate_view.add_child(method_heading)
	method_status = _label("", 14, MUTED, true)
	method_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	method_heading.add_child(method_status)
	method_detail = _button("Effects ›", true)
	method_detail.pressed.connect(_method_details)
	techniques = VBoxContainer.new()
	techniques.add_theme_constant_override("separation", 6)
	cultivate_view.add_child(techniques)
	for id in Rules.TECHNIQUES:
		var panel = PanelContainer.new()
		panel.mouse_filter = Control.MOUSE_FILTER_PASS
		techniques.add_child(panel)
		technique_panels[id] = panel
		var unit = BoxContainer.new()
		unit.mouse_filter = Control.MOUSE_FILTER_PASS
		unit.vertical = true
		unit.add_theme_constant_override("separation", 0)
		panel.add_child(unit)
		var choose = _button("", true)
		choose.custom_minimum_size.y = 64
		choose.pressed.connect(_action.bind("select", id))
		unit.add_child(choose)
		technique_select[id] = choose
		var identity = HBoxContainer.new()
		identity.mouse_filter = Control.MOUSE_FILTER_IGNORE
		identity.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		identity.offset_left = 4
		identity.offset_right = -4
		identity.add_theme_constant_override("separation", 6)
		choose.add_child(identity)
		var emblem = _icon(id, 56)
		identity.add_child(emblem)
		var description = VBoxContainer.new()
		description.mouse_filter = Control.MOUSE_FILTER_IGNORE
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		description.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		description.add_theme_constant_override("separation", 0)
		identity.add_child(description)
		var method_name = _heading(Rules.TECHNIQUES[id].short, 22)
		description.add_child(method_name)
		technique_effect[id] = _label("", 15)
		description.add_child(technique_effect[id])
		var seal = BoxContainer.new()
		seal.vertical = true
		seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		seal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		identity.add_child(seal)
		technique_seals[id] = _label("", 14)
		seal.add_child(technique_seals[id])
		var pips = HBoxContainer.new()
		pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pips.alignment = BoxContainer.ALIGNMENT_CENTER
		pips.custom_minimum_size.y = 16
		pips.add_theme_constant_override("separation", 6)
		seal.add_child(pips)
		technique_pips[id] = []
		for i in range(2):
			var pip = PanelContainer.new()
			pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pip.custom_minimum_size = Vector2(9, 9)
			pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			pips.add_child(pip)
			technique_pips[id].append(pip)
		var actions = HBoxContainer.new()
		actions.mouse_filter = Control.MOUSE_FILTER_PASS
		actions.add_theme_constant_override("separation", 8)
		unit.add_child(actions)
		technique_mastery[id] = _button("")
		technique_mastery[id].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		technique_mastery[id].pressed.connect(_action.bind("mastery", id))
		actions.add_child(technique_mastery[id])
		var detail = _button("Details ›", true)
		detail.accessibility_name = Rules.TECHNIQUES[id].title + "; details"
		detail.pressed.connect(_technique_details.bind(id))
		actions.add_child(detail)
		technique_parts[id] = {"unit": unit, "identity": identity, "description": description, "name": method_name, "seal": seal, "emblem": emblem, "detail": detail}
	var review = HBoxContainer.new()
	review.add_theme_constant_override("separation", 4)
	cultivate_view.add_child(review)
	practice_toggle = _button("Review practices ›", true)
	practice_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	practice_toggle.pressed.connect(_toggle_practice)
	review.add_child(practice_toggle)
	review.add_child(method_detail)
	practice = VBoxContainer.new()
	practice.add_theme_constant_override("separation", 8)
	cultivate_view.add_child(practice)
	for id in Rules.UPGRADES:
		var row = HBoxContainer.new()
		row.custom_minimum_size.y = 56
		practice.add_child(row)
		upgrade_rows[id] = row
		var detail = _button("", true)
		detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail.pressed.connect(_upgrade_details.bind(id))
		row.add_child(detail)
		var column = VBoxContainer.new()
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		detail.add_child(_icon(id, 40))
		detail.accessibility_name = Rules.UPGRADES[id].title + "; view effect"
		column.offset_left = 46
		column.offset_top = 2
		detail.add_child(column)
		upgrade_labels[id] = _heading({"breathing": "Breathing", "meridian": "Meridians", "mind": "Still Mind"}[id], 21)
		upgrade_level_labels[id] = _label("", 14, MUTED)
		column.add_child(upgrade_labels[id])
		column.add_child(upgrade_level_labels[id])
		var price = _button("")
		price.custom_minimum_size.x = 84
		price.pressed.connect(buy_upgrade.bind(id))
		row.add_child(price)
		upgrade_buttons[id] = price
	forest_view = VBoxContainer.new()
	forest_view.add_theme_constant_override("separation", 6)
	views.add_child(forest_view)
	var forest_heading = HBoxContainer.new()
	forest_view.add_child(forest_heading)
	var location = _heading("Bamboo Forest", 24)
	location.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	forest_heading.add_child(location)
	journey_state = _label("", 14, MUTED)
	journey_state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	forest_heading.add_child(journey_state)
	trip_time = _heading("", 23)
	forest_view.add_child(trip_time)
	route = Route.new()
	route.texture = load("res://assets/art/bamboo-route.png")
	route.custom_minimum_size.y = 124
	forest_view.add_child(route)
	forest_status = _label("", 14, MUTED, true)
	forest_view.add_child(forest_status)
	var journey_actions = HBoxContainer.new()
	journey_actions.add_theme_constant_override("separation", 8)
	forest_view.add_child(journey_actions)
	start_button = _button("Depart")
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.pressed.connect(_action.bind("start"))
	journey_actions.add_child(start_button)
	repeat_button = _button("Repeat: on", true)
	repeat_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	repeat_button.toggle_mode = true
	repeat_button.pressed.connect(_action.bind("repeat"))
	journey_actions.add_child(repeat_button)
	# Preparation lives next to the advancement it changes, in either view.
	preparation_group = HBoxContainer.new()
	preparation_group.add_theme_constant_override("separation", 4)
	hud.add_child(preparation_group)
	preparation_hint = _label("12 extra herbs → 7,000 Qi", 14, MUTED, true)
	preparation_hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preparation_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preparation_group.add_child(preparation_hint)
	prepare_button = _button("Prepare")
	prepare_button.pressed.connect(_action.bind("prepare"))
	preparation_group.add_child(prepare_button)
	preparation_state = _label("Prepared · 7,000 Qi + 12 herbs", 14, INK)
	hud.add_child(preparation_state)
	progress_bar = ProgressBar.new()
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Materials.meter(progress_bar, Color("638478"))
	hud.add_child(progress_bar)
	breakthrough_button = _button("")
	breakthrough_button.pressed.connect(attempt_breakthrough)
	breakthrough_button.custom_minimum_size.y = 60
	hud.add_child(breakthrough_button)
	var advance = HBoxContainer.new()
	advance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	advance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	advance.offset_left = 10
	advance.offset_top = 4
	advance.offset_right = -10
	breakthrough_button.add_child(advance)
	advance_badge = _icon("refining", 36)
	advance.add_child(advance_badge)
	var costs = VBoxContainer.new()
	costs.add_theme_constant_override("separation", 0)
	advance.add_child(costs)
	advance_title = _label("", 17, PAPER)
	costs.add_child(advance_title)
	var resources_needed = HBoxContainer.new()
	resources_needed.add_theme_constant_override("separation", 6)
	costs.add_child(resources_needed)
	advance_qi = _label("", 15, PAPER)
	resources_needed.add_child(advance_qi)
	advance_herb_icon = _icon("herbs", 22)
	resources_needed.add_child(advance_herb_icon)
	advance_herbs = _label("12 herbs", 15, PAPER)
	resources_needed.add_child(advance_herbs)
	prepared_seal = _icon("preparation", 30)
	advance.add_child(prepared_seal)
	attainment = HBoxContainer.new()
	attainment.add_theme_constant_override("separation", 8)
	hud.add_child(attainment)
	attainment.add_child(_icon("foundation", 36))
	attainment_text = _label("Foundation attained\nResonance · secondary at ½ strength", 14, INK)
	attainment.add_child(attainment_text)
	task_dock = VBoxContainer.new()
	task_dock.add_theme_constant_override("separation", 4)
	hud.add_child(task_dock)
	save_status = _label("", 11, MUTED)
	save_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud.add_child(save_status)
	_build_dialog()
	_set_view("cultivate")

func _build_dialog() -> void:
	dialog_scrim = ColorRect.new()
	dialog_scrim.color = Color(0.10,.15,.13,.35)
	dialog_scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog_scrim.hide()
	add_child(dialog_scrim)
	details_dialog = PopupPanel.new()
	details_dialog.wrap_controls = false
	details_dialog.add_theme_stylebox_override("panel", _style(PAPER, Color("7e9382"), 16))
	add_child(details_dialog)
	dialog_content = VBoxContainer.new()
	dialog_content.add_theme_constant_override("separation", 12)
	details_dialog.add_child(dialog_content)
	dialog_heading = _heading("", 27)
	dialog_heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_content.add_child(dialog_heading)
	reward_row = VBoxContainer.new()
	reward_row.add_theme_constant_override("separation", 12)
	dialog_content.add_child(reward_row)
	var qi_reward = HBoxContainer.new()
	reward_row.add_child(qi_reward)
	qi_reward.add_child(_icon("qi", 42))
	reward_qi = _heading("", 27)
	qi_reward.add_child(reward_qi)
	var herb_reward = HBoxContainer.new()
	reward_row.add_child(herb_reward)
	herb_reward.add_child(_icon("herbs", 42))
	reward_herbs = _heading("", 27)
	herb_reward.add_child(reward_herbs)
	reward_row.hide()
	dialog_scroll = ScrollContainer.new()
	dialog_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	dialog_scroll.follow_focus = true
	dialog_content.add_child(dialog_scroll)
	details_body = _label("", 16, INK, true)
	dialog_scroll.add_child(details_body)
	var buttons = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	dialog_content.add_child(buttons)
	dialog_close = _button("Return")
	dialog_close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialog_close.pressed.connect(details_dialog.hide)
	buttons.add_child(dialog_close)
	motion_button = _button("Reduce animation", true)
	_button_icon(motion_button,"selection-seal",20)
	motion_button.icon = _texture("selection-seal") if reduced_motion else null
	motion_button.toggle_mode = true
	motion_button.button_pressed = reduced_motion
	motion_button.toggled.connect(_toggle_motion)
	buttons.add_child(motion_button)
	details_dialog.close_requested.connect(details_dialog.hide)
	details_dialog.visibility_changed.connect(func(): dialog_scrim.visible = details_dialog.visible)

func _layout() -> void:
	if not hud_panel:
		return
	if chapter_ui and chapter_ui.has_method("layout"):
		chapter_ui.layout()
		return
	wide = size.x >= 900 and size.x > size.y * 1.15
	route.custom_minimum_size.y = 80 if size.x < 360 else 124
	practice_scroll.custom_minimum_size.y = 64 if size.y < 780 and not wide else 80
	realm_label.text = "Foundation" if state.realm == "Foundation Establishment" else state.realm
	var margin = 10.0 if size.x < 400 else 18.0
	var height = minf(size.y - 36, 620 if state.unlocked() else 520) if wide else minf(size.y - 180, 552 if state.unlocked() else 428)
	if not wide and size.y < 780:
		height = size.y - (162 if state.unlocked() else 176)
	hud_panel.position = Vector2(size.x - 466, (size.y - height) * .5) if wide else Vector2(margin, size.y - height - margin)
	hud_panel.size = Vector2(438, height) if wide else Vector2(size.x - margin * 2, height)
	# On the narrow phone, equip and training sit side by side. Both method
	# tradeoffs stay above secondary explanations; no control is scaled down.
	var compact = not wide
	if compact != compact_methods:
		compact_methods = compact
		# Keep phone navigation in the thumb area; desktop retains its top tabs.
		hud.move_child(tabs,save_status.get_index()-1 if compact else (3 if chapter_ui else 2))
		for id in technique_select:
			var parts = technique_parts[id]
			parts.unit.vertical = not compact
			parts.unit.add_theme_constant_override("separation",8 if compact else 0)
			parts.seal.vertical = not compact
			parts.seal.reparent(parts.description if compact else parts.identity)
			parts.detail.visible = not compact
			parts.emblem.custom_minimum_size = Vector2.ONE * (32 if compact else 56)
			parts.identity.add_theme_constant_override("separation", 4 if compact else 6)
			parts.name.add_theme_font_size_override("font_size", 21 if compact else 22)
			technique_select[id].custom_minimum_size.y = 70 if compact else 68
			technique_select[id].size_flags_horizontal = Control.SIZE_EXPAND_FILL
			technique_mastery[id].custom_minimum_size = Vector2(80, 70) if compact else Vector2(48, 48)
			technique_mastery[id].add_theme_font_size_override("font_size", 15 if compact else 16)
		_refresh()
	landscape.compose(wide, hud_panel.position.y, hud_panel.position.x - 20 if wide else size.x)
