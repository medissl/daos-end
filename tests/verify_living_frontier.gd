extends SceneTree
const Main=preload("res://scripts/main.gd")
const Store=preload("res://scripts/save_store.gd")
var geometry={}
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		push_error(label)
func settle() -> void:
	await process_frame
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
func rect(c: Control) -> Rect2:
	var r=c.get_global_rect()
	if c.get_window()!=root: r.position+=Vector2(c.get_window().position)
	return r
func inspect(n: Node,key: String) -> void:
	if n is Control and n.is_visible_in_tree():
		if n.get_window()!=root:
			var popup_rect=Rect2(Vector2(n.get_window().position),Vector2(n.get_window().size))
			check(rect(n).position.x>=popup_rect.position.x-1 and rect(n).end.x<=popup_rect.end.x+1,key+" popup horizontal content "+n.name)
		if n is Button:
			check(n.size.y>=48,key+" touch target "+n.name)
			var available=n.size.x-n.get_theme_stylebox("normal").get_margin(SIDE_LEFT)-n.get_theme_stylebox("normal").get_margin(SIDE_RIGHT)
			if n.icon: available-=n.get_theme_constant("icon_max_width")+n.get_theme_constant("h_separation")
			for line in n.text.split("\n"): check(n.get_theme_font("font").get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,n.get_theme_font_size("font_size")).x<=available+1,key+" button "+n.text)
		if n is Label and n.autowrap_mode==TextServer.AUTOWRAP_OFF:
			check(n.get_theme_font("font").get_string_size(n.text,HORIZONTAL_ALIGNMENT_LEFT,-1,n.get_theme_font_size("font_size")).x<=n.size.x+1,key+" label "+n.text)
	for c in n.get_children(): inspect(c,key)
func capture(main: Control,key: String) -> Dictionary:
	var ui=main.chapter_ui
	var scroll=main.practice_scroll
	var sr=scroll.get_global_rect()
	var bar=scroll.get_v_scroll_bar()
	var targets={}
	for id in ui.controls:
		var c=ui.controls[id]
		if not is_instance_valid(c) or not c is Button or not c.is_visible_in_tree(): continue
		var r=rect(c)
		var offset=clampf(r.get_center().y-sr.get_center().y,0,maxf(0,bar.max_value-bar.page)) if scroll.is_ancestor_of(c) else 0.0
		targets[id]={"point":[r.get_center().x,r.get_center().y-offset],"scroll":offset}
		if main.task_dock.is_ancestor_of(c): check(Rect2(Vector2.ZERO,root.size).encloses(r),key+" pinned action "+id)
	var tabs={}
	for id in ui.nav:
		var point=rect(ui.nav[id]).get_center();tabs[id]=[point.x,point.y]
	inspect(main,key)
	check(Rect2(Vector2.ZERO,root.size).encloses(main.hud_panel.get_global_rect()),key+" HUD bounds")
	if ui.sheet.visible: check(Rect2(Vector2.ZERO,root.size).encloses(Rect2(Vector2(ui.sheet.position),ui.sheet.size)),key+" sheet bounds")
	if ui.section=="battle":
		for c in [ui.threat,ui.enemy_hp,ui.player_hp]: check(sr.encloses(c.get_global_rect()),key+" essential combat readout "+c.name)
	root.get_texture().get_image().save_png("res://docs/living-dao/screenshots/frontier-"+key+".png")
	var help_point=rect(main.help_button).get_center()
	return {"targets":targets,"tabs":tabs,"help":[help_point.x,help_point.y],"scroll":[sr.get_center().x,sr.get_center().y],"bar":[bar.global_position.x,bar.global_position.y,bar.size.x,bar.size.y],"maximum":bar.max_value-bar.page,"page":bar.page}
func run() -> void:
	var main=Main.new()
	main.store=Store.new("res://.verification/living-frontier-isolated-%d.json" % Time.get_ticks_usec())
	root.add_child(main)
	main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await settle()
	main.session.active=false
	for dimensions in [Vector2i(320,640),Vector2i(390,844),Vector2i(430,932),Vector2i(1280,800)]:
		root.size=dimensions
		await settle()
		var size_key="%dx%d" % [dimensions.x,dimensions.y]
		geometry[size_key]={}
		for view in ["home","storm_preview","preparations","regions","storm_battle","camp","arts","thunder_sheet","thunder_replaced","continue","route_complete","gear","storm_item","tomb_preview","tomb_battle","moon_preview","moon_battle","laws","soul_preview","soul_gate","soul_goal","soul_form","soul_build","soul_battle","reduced"]:
			var file="before-storm_ascent"
			if view in ["camp","arts","thunder_sheet","thunder_replaced","continue","route_complete","gear","storm_item"]: file="after-storm_ascent"
			elif view.begins_with("tomb"): file="before-silent_gate"
			elif view.begins_with("moon"): file="before-mirror_shore"
			elif view in ["laws","soul_goal"]: file="soul-ready"
			elif view in ["soul_preview","soul_gate"]: file="before-soul"
			elif view in ["soul_form","soul_build","soul_battle","reduced"]: file="earned-soul-fixture"
			var s=Store.state_from(JSON.parse_string(FileAccess.get_file_as_string("res://.verification/living-"+file+".json")))
			main.state=s;main.session.state=s
			var ui=main.chapter_ui
			ui.sheet.hide();ui.audio_popup.hide();ui.toast_until=0;ui.seen_learned=s.learned.duplicate();ui.positions={}
			await settle()
			main.reduced_motion=view=="reduced";main.landscape.reduced_motion=main.reduced_motion
			ui.selected_detail=["art","sword"]
			if view in ["home","soul_form","reduced"]: ui.show_section("retreat")
			elif view in ["storm_preview","preparations","regions"]:
				ui.open_route("storm_ascent")
				if view=="preparations": ui.departure_sheet()
				elif view=="regions": ui.region_sheet()
			elif view in ["storm_battle","soul_battle"]:
				s.start_journey("thunder_crown" if view=="soul_battle" else "storm_ascent")
				if view=="soul_battle":
					s.set_combat_slot(3,"mirror")
					# Restart through an actual safe boundary to commit fourth slot.
					s.journey.camp_requested=true;s.advance(100);s.continue_journey()
				s.advance(7);ui.show_section("battle")
			elif view in ["camp","arts","thunder_sheet","thunder_replaced","continue"]:
				s.start_journey("storm_ascent");s.journey.camp_requested=true;s.advance(100)
				if view=="camp": ui.show_section("result")
				elif view=="continue":
					s.continue_journey();ui.show_section("battle")
				else:
					ui.show_section("arts")
					if view=="thunder_sheet": ui.show_detail("art","thunder")
					elif view=="thunder_replaced": s.set_combat_slot(0,"thunder")
			elif view in ["tomb_preview","tomb_battle","moon_preview","moon_battle"]:
				var id="silent_gate" if view.begins_with("tomb") else "mirror_shore"
				if view.ends_with("preview"): ui.open_route(id)
				else: s.start_journey(id);s.advance(8);ui.show_section("battle")
			elif view=="laws": ui.show_section("arts");ui.law_sheet()
			elif view=="route_complete": ui.show_section("result")
			elif view in ["gear","storm_item"]:
				ui.show_section("gear")
				if view=="storm_item": ui.show_detail("item","storm_thread")
			elif view=="soul_preview": ui.open_route("soul")
			elif view in ["soul_goal","soul_gate"]: ui.show_section("core")
			elif view=="soul_build": ui.show_section("arts")
			main._refresh();main._layout();await settle()
			main._refresh_scene();await settle()
			geometry[size_key][view]=capture(main,size_key+"-"+view)
	FileAccess.open("res://.verification/living-frontier-geometry.json",FileAccess.WRITE).store_string(JSON.stringify(geometry,"\t"))
	FileAccess.open("res://docs/living-dao/FRONTIER_LAYOUT_RESULTS.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	print("Frontier UI: %d checks; %d failures" % [checks,failures])
	quit(1 if failures else 0)
func _initialize() -> void: call_deferred("run")
