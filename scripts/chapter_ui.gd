extends Node
## Task-based presentation; the existing state/session/save providers own rules.
const Data = preload("res://scripts/chapter_data.gd")
const Combat = preload("res://scripts/combat.gd")
const Materials = preload("res://scripts/ui_materials.gd")
var host: Control
var controls = {}
var sections = {}
var surfaces = {}
var nav = {}
var docks = {}
var headers = {}
var section = "retreat"
var destination = "cultivate"
var build_section = "arts"
var explore_section = "journey"
var positions = {}
var selected_route = "stone_steps"
var region = "Misty Mountain"
var equipment_filter = "all"
var discover = false
var selected_detail = ["art","sword"]
var built = false
var discover_arts = false
var preview_nodes: VBoxContainer
var preview_expanded = false
var preview_title: Label
var preview_reward: Label
var preview_hazard: Label
var preview_image: TextureRect
var routes = {}
var arts = {}
var gear = {}
var methods = {}
var slots = []
var equipped_slots = []
var equipped_names = []
var equipped_icons = []
var home_method: Label
var home_icon: TextureRect
var home_pending: Label
var home_goal: Label
var goal_action = Callable()
var enemy_hp: Label
var player_hp: Label
var focus_label: Label
var threat: Label
var enemy_meter: ProgressBar
var player_meter: ProgressBar
var focus_meter: ProgressBar
var readiness = []
var feedback: Label
var reward_title: Label
var reward_note: Label
var rewards: VBoxContainer
var reward_values = {}
var reward_key = ""
var core_rows = {}
var core_marks = {}
var preparation: Label
var core_hint: Label
var boundary: Label
var empty_gear: VBoxContainer
var detail_panel: PanelContainer
var detail_body: VBoxContainer
var detail_key = ""
var sheet: PopupPanel
var sheet_title: Label
var sheet_body: VBoxContainer
var sheet_actions: VBoxContainer
var sheet_content: VBoxContainer
var costs = {}
var toast: Label
var toast_until = 0
var seen_learned = []
var navigation_tween: Tween
var audio_popup: PopupPanel
var audio_sliders = {}
var audio_values = {}
var audio_mute: Button
var menu_content: VBoxContainer

func _init(game: Control) -> void:
	host = game

func column(parent: Node, gap: int = 8) -> VBoxContainer:
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_theme_constant_override("separation",gap)
	parent.add_child(box)
	return box

func row(parent: Node, gap: int = 8) -> HBoxContainer:
	var box = HBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_theme_constant_override("separation",gap)
	parent.add_child(box)
	return box

func text(parent: Node, value: String, pixels: int = 15, wrap: bool = true) -> Label:
	var label = host._label(value,pixels,host.INK,wrap)
	parent.add_child(label)
	return label

func heading(parent: Node, value: String, pixels: int = 23) -> Label:
	var label = host._heading(value,pixels)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func button(parent: Node, value: String, callback: Callable, id: String = "", primary: bool = false) -> Button:
	var b = host._button(value,not primary)
	if not primary:
		var surface = host._style(Color(.24,.40,.32,.045),Color(.24,.40,.32,.24),8)
		surface.set_border_width_all(0)
		surface.border_width_bottom = 1
		b.add_theme_stylebox_override("normal",surface)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(callback)
	parent.add_child(b)
	if not id.is_empty():
		b.name = id
		controls[id] = b
	return b

func identity(parent: Node, id: String, title: String, role: String) -> Dictionary:
	var line = row(parent,12)
	line.add_child(host._icon(id,44))
	var labels = column(line,2)
	return {"name":heading(labels,title,22),"role":text(labels,role,14)}

func object_choice(parent: Node, id: String, title: String, role: String, callback: Callable, key: String) -> Dictionary:
	var choice = button(parent,"",callback,key)
	choice.custom_minimum_size.y = 88
	var visual = row(choice,10)
	visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visual.offset_left = 8
	visual.offset_right = -8
	visual.offset_top = 8
	visual.offset_bottom = -8
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.add_child(host._icon(id,40))
	var labels = column(visual,2)
	labels.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heading(labels,title,22)
	var effect = text(labels,role,14)
	var state_line = row(labels,6)
	var state_label = text(state_line,"",14)
	state_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var marks = []
	for i in range(3 if Data.all().items.has(id) else 2):
		var mark = host._icon("mastery-socket",10)
		state_line.add_child(mark)
		marks.append(mark)
	labels.minimum_size_changed.connect(func(): choice.custom_minimum_size.y = maxf(88,labels.get_combined_minimum_size().y+16))
	choice.accessibility_name = title+"; manage equipment or technique"
	return {"unit":choice,"state":state_label,"role":effect,"marks":marks}

func mark_object(r: Dictionary, level: int, equipped: bool) -> void:
	var key = level*2+int(equipped)
	if r.get("status_key",-1)==key: return
	r.status_key = key
	for i in range(r.marks.size()): r.marks[i].texture = host._texture("selection-seal" if i<level else "mastery-socket")
	var style = host._style(Color(.24,.40,.32,.13 if equipped else .035),Color(.24,.40,.32,.32),8)
	style.set_border_width_all(0)
	style.border_width_left = 3 if equipped else 0
	style.border_width_bottom = 1
	r.unit.add_theme_stylebox_override("normal",style)

func divider(parent: Node) -> void:
	var line = HSeparator.new()
	line.add_theme_stylebox_override("separator",host._style(Color(.28,.43,.36,.18),Color.TRANSPARENT,0))
	parent.add_child(line)

func image(parent: Node, id: String, height: int = 100) -> TextureRect:
	var picture = host._icon(id,height)
	picture.custom_minimum_size = Vector2(0,height)
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	parent.add_child(picture)
	return picture

func clear_content(parent: Node) -> void:
	for key in controls.keys():
		if not is_instance_valid(controls[key]) or parent.is_ancestor_of(controls[key]): controls.erase(key)
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	for key in costs.keys():
		if not is_instance_valid(costs[key].button): costs.erase(key)

func action(kind: String, id: String = "", index: int = -1) -> void:
	host._chapter_action(kind,id,index)
	detail_key = ""

func make_section(id: String) -> VBoxContainer:
	var surface = PanelContainer.new()
	surface.add_theme_stylebox_override("panel",Materials.paper(12,.96))
	host.cultivate_view.get_parent().add_child(surface)
	var box = column(surface,10)
	sections[id] = box
	surfaces[id] = surface
	surface.hide()
	return box

func dock(id: String) -> VBoxContainer:
	var box = column(host.task_dock,4)
	docks[id] = box
	return box

func top_group(id: String) -> VBoxContainer:
	var box = column(host.task_header,6)
	headers[id] = box
	return box

func build() -> void:
	sections.practices = host.cultivate_view
	sections.gather = host.forest_view
	nav.cultivate = host.cultivate_tab
	nav.explore = host.forest_tab
	nav.build = button(host.tabs,"Build",navigate.bind("build"),"tab_build")
	nav.build.toggle_mode = true
	host.tabs.add_theme_constant_override("separation",2)
	host.hud.move_child(host.tabs,host.save_status.get_index()-1)
	var extra = row(host.hud,6)
	host.hud.move_child(extra,host.wallet_row.get_index()+1)
	host.herb_icon.reparent(extra)
	host.herb_label.reparent(extra)
	extra.add_child(host._icon("spirit_stone",20))
	controls.extra_resources = extra
	controls.stones = text(extra,"",14,false)
	host.hud_panel.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	detail_panel = PanelContainer.new()
	detail_panel.custom_minimum_size.x = 350
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.add_theme_stylebox_override("panel",Materials.paper(20,.98))
	host.body_split.add_child(detail_panel)
	var detail_scroll = ScrollContainer.new()
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_scroll.custom_minimum_size.y = 64
	detail_panel.add_child(detail_scroll)
	detail_body = column(detail_scroll,10)
	build_home()
	build_journeys()
	build_arts()
	build_equipment()
	build_core()
	build_sheet()
	build_audio()
	audio_popup.add_theme_stylebox_override("panel",Materials.paper(24,1))
	toast = text(host.hud,"",14)
	toast.add_theme_stylebox_override("normal",Materials.paper(8,1))
	host.hud.move_child(toast,host.task_dock.get_index())
	toast.hide()
	seen_learned = host.state.learned.duplicate()
	boundary = text(host.task_header,"",14)
	button(dock("build"),"Back to journey",resume_explore,"build_return")
	button(dock("gather"),"Back to cultivate",navigate.bind("cultivate"),"gather_back")
	button(dock("practices"),"Back to cultivate",navigate.bind("cultivate"),"practices_back")
	var locked = make_section("build_locked")
	heading(locked,"Prepare for the Jade Road")
	text(locked,"Combat techniques and equipment open at Foundation. Cultivation practices are available at home.")
	button(locked,"Go to cultivate",navigate.bind("cultivate"),"locked_home")
	var explore_locked = make_section("explore_locked")
	identity(explore_locked,"herbs","Bamboo Forest","Gathering opens at Qi Refining.")
	text(explore_locked,"Practise cultivation and enter Qi Refining to gather herbs. The Jade Road opens at Foundation.")
	button(explore_locked,"Go to cultivate",navigate.bind("cultivate"),"explore_locked_home")
	built = true
	show_section("journey" if host.state.journey.status in ["battle","camp"] else "retreat")

func build_home() -> void:
	var home = make_section("retreat")
	var method = row(home,12)
	home_icon = host._icon("azure",40)
	method.add_child(home_icon)
	home_method = text(method,"",16)
	home_pending = text(home,"",14)
	var choices = row(home,8)
	button(choices,"Methods",show_section.bind("methods"),"methods")
	button(choices,"Practices",open_practices,"practices")
	button(home,"Bamboo gathering",show_section.bind("gather"),"gather")
	button(home,"Realm goal",show_section.bind("core"),"retreat_core")
	var goal = dock("retreat")
	home_goal = text(goal,"",15)
	button(goal,"Explore Stone Steps",follow_goal,"goal",true)
	var choices_box = make_section("methods")
	heading(choices_box,"Cultivation methods")
	text(choices_box,"Choose a primary method. At Foundation, the other contributes half its effect.",14)
	for id in ["azure","iron"]:
		var unit = column(choices_box,4)
		var item = identity(unit,id,{"azure":"Azure Cloud","iron":"Iron Body"}[id],"")
		var state_label = text(unit,"",14)
		var actions = row(unit)
		var select = button(actions,"Choose",select_method.bind(id),"method_"+id)
		button(actions,"Improve",show_detail.bind("method",id),"improve_method_"+id)
		methods[id] = {"role":item.role,"state":state_label,"select":select}
		divider(choices_box)
	button(dock("methods"),"Back to cultivate",navigate.bind("cultivate"),"methods_back")

func open_practices() -> void:
	host.expanded_practice = true
	show_section("practices")

func select_method(id: String) -> void:
	host._action("select",id)

func follow_goal() -> void:
	if goal_action.is_valid(): goal_action.call()

func next_goal() -> Dictionary:
	var s = host.state
	if s.journey.status in ["battle","camp"]:
		return {"title":"Your journey is "+("paused at camp" if s.journey.status=="camp" else "under way"),"label":"Return to "+("camp" if s.journey.status=="camp" else "battle"),"action":resume_explore}
	if not "stone_steps" in s.cleared_routes:
		return {"title":"Next: clear Stone Steps · earn Pinewood Sword","label":"Explore Stone Steps","action":open_route.bind("stone_steps")}
	for place in ["Misty Mountain","Spirit River"]:
		if s.region_clears(place)<2:
			for id in Data.all().routes:
				if Data.all().routes[id].region==place and not id in s.cleared_routes:
					return {"title":"Next: clear "+Data.all().routes[id].name,"label":"Explore "+Data.all().routes[id].name,"action":open_route.bind(id)}
	if s.realm in ["Golden Core","Nascent Soul"]:
		for id in Data.all().realm_requirements.routes:
			if not id in s.cleared_routes and s.route_available(id): return {"title":"Next: "+Data.all().routes[id].name,"label":"Explore "+Data.all().routes[id].name,"action":open_route.bind(id)}
		for id in ["earth_heir","fire_heir","water_heir"]:
			if not id in s.cleared_trials: return {"title":"Next: earn a law through inheritance","label":Data.all().trials[id].name,"action":open_route.bind(id)}
		if s.realm=="Golden Core": return {"title":"Next: attain Nascent Soul","label":"Review advancement","action":show_section.bind("core")}
		for id in ["thunder_heir","tomb_heir","moon_heir"]:
			if not id in s.cleared_trials: return {"title":"Chapter complete · optional mastery","label":Data.all().trials[id].name,"action":open_route.bind(id)}
		return {"title":"Nascent Soul · the Living Dao chapter is complete","label":"Review your four-art build","action":navigate.bind("build")}
	if not s.core_trial_won:
		return {"title":"Next: overcome the Core Trial","label":"Review Core Trial","action":show_section.bind("core")}
	return {"title":"Next: form Golden Core · 24,000 Qi","label":"Review advancement","action":show_section.bind("core")}

func build_journeys() -> void:
	var choices = row(top_group("explore"),4)
	button(choices,"Misty Mountain ▾",region_sheet,"region_misty")
	button(choices,"Challenges",challenges_sheet,"region_river")
	make_section("journey")
	var route_choices = row(headers.explore,4)
	for id in Data.all().routes:
		var d: Dictionary = Data.all().routes[id]
		var select = button(route_choices,d.name.replace(" ","\n"),open_route.bind(id),"route_"+id)
		select.add_theme_font_size_override("font_size",14)
		routes[id] = {"unit":select}
	var trials = make_section("trials")
	heading(trials,"Trials")
	text(trials,"Optional challenges · guaranteed first-clear rewards",14)
	for id in Data.all().trials:
		var d: Dictionary = Data.all().trials[id]
		button(trials,d.name,open_route.bind(id),"route_"+id)
		text(trials,d.description,14)
	var preview = make_section("preview")
	preview_image = image(preview,"misty_mountain",80)
	preview_title = heading(preview,"")
	preview_reward = text(preview,"",16)
	preview_hazard = text(preview,"",15)
	button(preview,"Prepare build · no consumable",departure_sheet,"preview_build")
	button(preview,"Inspect encounters",toggle_encounters,"preview_inspect")
	preview_nodes = column(preview,4)
	preview_nodes.hide()
	var departure = dock("preview")
	button(departure,"Depart",start_selected,"depart",true)
	var battle = make_section("battle")
	battle.add_theme_constant_override("separation",4)
	enemy_hp = text(battle,"",16)
	enemy_meter = meter(battle,Color("a66a50"))
	player_hp = text(battle,"",16)
	player_meter = meter(battle,Color("587d69"))
	threat = text(battle,"",15)
	focus_label = text(battle,"",14)
	focus_meter = meter(battle,Color("719697"))
	var ready = GridContainer.new()
	ready.columns = 2
	ready.add_theme_constant_override("h_separation",12)
	battle.add_child(ready)
	for i in range(4):
		var cell = row(ready,4)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var symbol = host._icon("sword",24)
		cell.add_child(symbol)
		var words = column(cell,0)
		readiness.append({"cell":cell,"symbol":symbol,"title":text(words,"",14,false),"status":text(words,"",14,false)})
	feedback = text(battle,"",14)
	var combat_actions = row(dock("battle"),4)
	button(combat_actions,"Camp after fight",action.bind("camp"),"camp_request",true).add_theme_font_size_override("font_size",15)
	button(combat_actions,"Inspect enemy",inspect_enemy,"enemy_details").add_theme_font_size_override("font_size",15)
	var camp = make_section("result")
	reward_title = heading(camp,"",24)
	var band = row(camp,10)
	for id in ["qi","herbs","stones"]:
		var unit = row(band,3)
		unit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		unit.add_child(host._icon("spirit_stone" if id=="stones" else id,20))
		reward_values[id] = text(unit,"",14,false)
	reward_note = text(camp,"",14)
	rewards = column(camp,8)
	var camp_actions = dock("result")
	button(camp_actions,"Continue journey",action.bind("continue"),"continue",true)
	button(camp_actions,"Next route",open_next_route,"result_routes",true)
	var secondary = row(camp_actions,4)
	button(secondary,"Adjust build",navigate.bind("build"),"camp_build")
	button(secondary,"Cultivate",navigate.bind("cultivate"),"leave")
	button(camp,"End journey · keep rewards",return_home,"end_journey")

func meter(parent: Node, color: Color) -> ProgressBar:
	var bar = ProgressBar.new()
	Materials.meter(bar,color)
	parent.add_child(bar)
	return bar

func choose_region(value: String) -> void:
	region = value
	positions.journey = 0
	for id in Data.all().routes:
		if Data.all().routes[id].region==region:
			open_route(id)
			return

func open_route(id: String) -> void:
	selected_route = id
	var route: bool = Data.all().routes.has(id)
	var d: Dictionary = Data.all().routes[id] if route else Data.all().trials[id]
	if route or d.has("region"): region = d.region
	preview_title.text = d.name
	preview_image.texture = host._texture(region_art())
	preview_reward.text = "First clear: "+(Data.all().items[d.item].name if not d.item.is_empty() else "Qi, herbs and Spirit Stones")
	preview_hazard.text = route_hint(id) if route else d.description
	clear_content(preview_nodes)
	button(preview_nodes,"Optional challenges",challenges_sheet,"preview_challenges")
	if id in host.state.cleared_routes:
		text(preview_nodes,"Supply: 3 cleared circuits at 30% speed, open or closed. Gathering pauses. No first-clear rewards or preparations.",14)
		button(preview_nodes,"Assign 3 supply circuits",action.bind("supply",id),"supply_assign",true)
	var encounters: Array = d.nodes if route else (d.sequence if d.has("sequence") else [d.enemy])
	for i in range(encounters.size()):
		var e: Dictionary = Data.all().enemies[encounters[i]] if route else Data.enemy(encounters[i])
		button(preview_nodes,"%d. %s" % [i+1,e.name],encounter_details.bind(e),"inspect_"+str(i))
	preview_expanded = false
	preview_nodes.hide()
	controls.preview_inspect.text = "Inspect %d encounters" % encounters.size()
	positions.preview = 0
	show_section("preview")

func route_hint(id: String) -> String:
	return Data.all().routes[id].get("hint", {"stone_steps":"Armored guardians and heavy strikes.\nDiscover Flame at the first encounter; its burn bypasses armor.","cloud_bridge":"Barriers and mist protection.\nDirect hits break barriers; watch for exposed moments.","hermits_cleft":"Reflection and protection.\nFlame burn avoids direct-hit reflection.","reed_shallows":"Poison and healing.\nRiver cleanses poison; sustained damage pressures healers.","broken_ford":"Armor and heavy strikes.\nWard can absorb incoming bursts.","lotus_pools":"Poison, healing and mist.\nRiver cleanses; Flame keeps damage flowing."}.get(id,"Inspect the guardians and prepare your techniques."))

func toggle_encounters() -> void:
	preview_expanded = not preview_expanded
	preview_nodes.visible = preview_expanded

func start_selected() -> void:
	action("journey",selected_route)

func resume_explore() -> void:
	navigate("explore")

func return_home() -> void:
	if host.state.journey.status=="camp": action("leave")
	else: navigate("cultivate")

func open_next_route() -> void:
	var goal = next_goal()
	goal.action.call()

func inspect_enemy() -> void:
	if not host.state.journey.battle.is_empty(): encounter_details(host.state.journey.battle.enemy)

func encounter_details(e: Dictionary) -> void:
	host._details(e.name,", ".join(e.traits)+"\n\nHP %s · Armor %s · Magic resistance %d%%\nAttack %s every %ss\n\nPhysical damage subtracts armor (minimum 1); magic and burn use resistance. Direct hits break one barrier each. Burn bypasses reflection. River cleanses poison; Ward absorbs incoming damage." % [host._number(e.hp),host._number(e.armor),int(e.resistance*100),host._number(e.attack),host._number(e.interval)])

func build_arts() -> void:
	var header = top_group("build")
	var tabs = row(header,2)
	button(tabs,"Techniques",show_section.bind("arts"),"build_arts")
	button(tabs,"Equipment",show_section.bind("gear"),"build_gear")
	var loadout = GridContainer.new()
	loadout.columns = 2
	loadout.add_theme_constant_override("h_separation",4)
	header.add_child(loadout)
	controls.art_loadout = loadout
	for i in range(4):
		var b = button(loadout,"",manage_slot.bind(i),"slot_"+str(i))
		b.add_theme_font_size_override("font_size",14)
		slots.append(b)
	var equipped = row(header,4)
	controls.equipment_loadout = equipped
	for slot in ["weapon","robe","artifact"]:
		var b = button(equipped,"",filter_gear.bind(slot),"equipped_"+slot)
		b.custom_minimum_size.y = 84
		var visual = column(b,2)
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		visual.offset_left = 4
		visual.offset_right = -4
		visual.offset_top = 4
		visual.offset_bottom = -4
		var symbol = host._icon("spirit_stone",20)
		symbol.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		visual.add_child(symbol)
		equipped_icons.append(symbol)
		var title = text(visual,{"weapon":"Weapon","robe":"Robe","artifact":"Charm"}[slot],14,false)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var item_name = text(visual,"Empty",14)
		item_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		equipped_names.append(item_name)
		equipped_slots.append(b)
	var list = make_section("arts")
	for id in Data.all().skills:
		arts[id] = object_choice(list,id,Data.all().skills[id].name,skill_role(id),show_detail.bind("art",id),"art_"+id)
	button(list,"Law: none",law_sheet,"laws")
	button(list,"Collection: learned / all",toggle_art_discover,"art_discover")
	var presets = row(list)
	button(presets,"Build preset",preset_sheet,"preset_manage")
	controls.presets = presets

func preset_sheet() -> void:
	open_sheet("Build preset")
	text(sheet_body,"Save method, ordered techniques, equipment and law together. Restore is free; changes apply next encounter.",15)
	if not host.state.preset.is_empty():
		text(sheet_body,"Saved: "+host._method(host.state.preset.primary),16)
		for id in host.state.preset.slots:
			if not id.is_empty(): text(sheet_body,Data.all().skills[id].name,15)
	button(sheet_actions,"Save current build",action.bind("preset_save"),"preset_save")
	button(sheet_actions,"Restore saved build",restore_preset,"preset_apply").disabled = host.state.preset.is_empty()

func restore_preset() -> void:
	action("preset_apply")
	toast_message(host.state.preset_notice)
	sheet.hide()

func skill_role(id: String) -> String:
	return {"sword":"Direct damage · low focus","flame":"Burn damage · bypasses armor","ward":"Absorbs incoming damage","river":"Cleanse poison · restore HP","thunder":"Interrupt a charged strike","returning":"Barrier break · focus refund","mirror":"Protection · one retaliation"}[id]

func toggle_art_discover() -> void:
	discover_arts = not discover_arts
	refresh()

func equip_art(id: String) -> void:
	var s = host.state
	if id in s.combat_slots:
		manage_slot(s.combat_slots.find(id))
		return
	var empty: int = s.combat_slots.find("")
	if empty>=0:
		action("art",id,empty)
	else:
		open_sheet("Replace a technique")
		text(sheet_body,"Choose the technique to replace. Equipping is free.",15)
		for i in range(s.combat_slots.size()):
			button(sheet_actions,"Slot %d · replace\n%s" % [i+1,Data.all().skills[s.combat_slots[i]].name],replace_art.bind(id,i),"replace_"+str(i))

func replace_art(id: String, index: int) -> void:
	action("art",id,index)
	sheet.hide()

func manage_slot(index: int) -> void:
	var s = host.state
	if index>=s.combat_slots.size(): return
	var id: String = s.combat_slots[index]
	open_sheet("Technique slot "+str(index+1))
	if id.is_empty():
		text(sheet_body,"Choose a learned technique for this empty slot.",15)
	else:
		identity(sheet_body,id,Data.all().skills[id].name,skill_role(id))
		text(sheet_body,"Changes apply next encounter." if s.journey.status=="battle" else "Free to change at camp.",14)
		var order = row(sheet_body)
		if index>0: button(order,"Move earlier",move_art.bind(index,index-1),"move_earlier")
		if index+1<s.combat_slots.size(): button(order,"Move later",move_art.bind(index,index+1),"move_later")
		button(sheet_body,"Remove from slot",replace_art.bind("",index),"remove_slot")
	for known in s.learned:
		if known!=id: button(sheet_actions,"Equip "+Data.all().skills[known].name,replace_art.bind(known,index),"slot_equip_"+known)

func move_art(from: int, to: int) -> void:
	action("art",host.state.combat_slots[from],to)
	sheet.hide()

func art_details() -> void:
	var lines = ["Techniques act automatically in slot order when ready. Equip is free; Improve is a separate purchase."]
	for id in Data.all().skills:
		var d: Dictionary = Data.all().skills[id]
		lines.append(d.name+": "+d.description+"\n%d focus · %ds cooldown. " % [d.focus,d.cooldown]+d.source)
	host._details("Techniques","\n\n".join(lines))

func build_equipment() -> void:
	var list = make_section("gear")
	var filters = row(list,2)
	button(filters,"Owned",set_discover.bind(false),"gear_owned")
	button(filters,"Discover",set_discover.bind(true),"gear_discover")
	button(filters,"All slots",filter_gear.bind("all"),"gear_all")
	empty_gear = column(list)
	identity(empty_gear,"pine_sword","Your first equipment","Pinewood Sword is earned by clearing Stone Steps.")
	button(empty_gear,"View Stone Steps",open_route.bind("stone_steps"),"empty_gear_route",true)
	for id in Data.all().items:
		var d: Dictionary = Data.all().items[id]
		gear[id] = object_choice(list,id,d.name,"",show_detail.bind("item",id),"item_"+id)

func filter_gear(slot: String) -> void:
	equipment_filter = slot
	var current: String = host.state.equipment.get(slot,"")
	if not current.is_empty(): selected_detail = ["item",current]
	show_section("gear")
	positions.gear = 0
	host.practice_scroll.scroll_vertical = 0

func set_discover(value: bool) -> void:
	discover = value
	positions.gear = 0
	host.practice_scroll.scroll_vertical = 0
	refresh()

func item_source(id: String) -> void:
	if sheet.visible: sheet.hide()
	for route_id in Data.all().routes:
		if Data.all().routes[route_id].item==id:
			open_route(route_id)
			return
	for trial_id in Data.all().trials:
		if Data.all().trials[trial_id].item==id:
			open_route(trial_id)
			return

func item_effect(id: String, level: int = -1) -> String:
	if id.is_empty(): return "None equipped"
	var d: Dictionary = Data.all().items[id]
	if level<0: level = host.state.inventory.get(id,0)
	var values = []
	for key in ["attack","hp","armor"]:
		if d.has(key): values.append("+%s %s" % [host._number(d[key]*(1+.2*level)),{"attack":"attack","hp":"HP","armor":"armor"}[key]])
	for part in d.description.split(" · "):
		if not part.ends_with(" attack") and not part.ends_with(" HP") and not part.ends_with(" armor"): values.append(part)
	return " · ".join(values)

func build_core() -> void:
	var core = make_section("core")
	var identity_labels = identity(core,"golden_core","Golden Core","Three technique slots · one free preset")
	controls.core_name = identity_labels.name
	controls.core_role = identity_labels.role
	for id in ["qi","seals","misty","river","trial"]:
		var requirement = row(core,10)
		var mark = host._icon("selection-seal",22)
		requirement.add_child(mark)
		core_marks[id] = mark
		core_rows[id] = text(requirement,"",16)
	divider(core)
	preparation = text(core,"",15)
	button(core,"Prepare · 24 herbs",action.bind("prepare_core"),"prepare_core")
	core_hint = text(core,"",14)
	var next = dock("core")
	button(next,"Enter Core Trial",enter_tribulation,"core_trial",true)
	button(next,"Form Golden Core · 24,000 Qi",action.bind("advance"),"advance_core",true)
	button(next,"Back to cultivate",navigate.bind("cultivate"),"core_back")

func build_sheet() -> void:
	sheet = PopupPanel.new()
	sheet.wrap_controls = false
	sheet.add_theme_stylebox_override("panel",Materials.paper(20,1))
	host.add_child(sheet)
	var outer = column(sheet,8)
	sheet_content = outer
	sheet_title = heading(outer,"",25)
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.y = 80
	outer.add_child(scroll)
	sheet_body = column(scroll,10)
	sheet_actions = column(outer,4)
	button(outer,"Return",sheet.hide,"sheet_close")
	sheet.close_requested.connect(sheet.hide)
	sheet.size_changed.connect(layout_sheet)
	outer.minimum_size_changed.connect(layout_sheet.call_deferred)
	sheet.visibility_changed.connect(func(): host.dialog_scrim.visible = sheet.visible or audio_popup.visible or host.details_dialog.visible)

func open_sheet(title: String) -> void:
	clear_content(sheet_body)
	clear_content(sheet_actions)
	sheet_title.text = title
	sheet.popup_centered(Vector2i(mini(int(host.size.x)-24,480),mini(int(host.size.y)-32,550)))
	layout_sheet()

func layout_sheet() -> void:
	if sheet_content: host._fit_popup_content(sheet,sheet_content)

func show_detail(kind: String, id: String) -> void:
	selected_detail = [kind,id]
	detail_key = ""
	if host.wide and destination=="build":
		render_desktop_detail()
	else:
		open_sheet({"art":"Technique","method":"Cultivation method","item":"Equipment","refine":"Equipment"}[kind])
		render_detail(sheet_body,sheet_actions,kind,id,"sheet_")

func render_desktop_detail() -> void:
	clear_content(detail_body)
	heading(detail_body,"Build comparison",23)
	render_detail(detail_body,detail_body,selected_detail[0],selected_detail[1],"detail_")
	detail_key = str(selected_detail)+str(host.state.combat_mastery)+str(host.state.inventory)+str(host.state.equipment)

func render_detail(body: Node, actions: Node, kind: String, id: String, prefix: String) -> void:
	var s = host.state
	if kind=="method":
		var level: int = s.mastery[id]
		identity(body,id,{"azure":"Azure Cloud","iron":"Iron Body"}[id],"+%s%% Qi" % host._number(host.Rules.TECHNIQUES[id].azure[level]*100) if id=="azure" else "+%d herbs per gathering" % host.Rules.TECHNIQUES[id].iron[level])
		text(body,"Mastery %d of 2" % level,15)
		if level<2:
			text(body,"Next: "+("+%d%% Qi" % int(host.Rules.TECHNIQUES[id].azure[level+1]*100) if id=="azure" else "+%d herbs per gathering" % host.Rules.TECHNIQUES[id].iron[level+1]),16)
			text(body,"Your herbs: %d" % s.herbs,14)
			add_cost(actions,"Improve · %d herbs" % s.mastery_cost(id),"method",id,prefix+"buy")
		else: text(body,"Mastered",15)
		text(body,"While gathering, improvements apply at the next gathering departure.",14)
	elif kind=="art":
		var d: Dictionary = Data.all().skills[id]
		var level: int = s.combat_mastery[id]
		identity(body,id,d.name,skill_role(id))
		text(body,d.description,15)
		text(body,"%d focus · %ds cooldown" % [d.focus,d.cooldown],14)
		if not id in s.learned:
			text(body,d.source,15)
			return
		var equipped: int = s.combat_slots.find(id)
		if equipped>=0:
			text(body,"Equipped in slot %d" % [equipped+1],15)
			var order = row(body,4)
			if equipped>0: button(order,"Earlier",move_art.bind(equipped,equipped-1),prefix+"earlier")
			if equipped+1<s.combat_slots.size(): button(order,"Later",move_art.bind(equipped,equipped+1),prefix+"later")
			button(body,"Remove from slot",replace_art.bind("",equipped),prefix+"remove")
		else:
			var empty: int = s.combat_slots.find("")
			if empty>=0: button(actions,"Equip in slot %d · free" % [empty+1],replace_art.bind(id,empty),prefix+"equip")
			else:
				text(body,"Choose a replacement · free",15)
				for i in range(s.combat_slots.size()):
					button(body,"Replace slot %d · %s" % [i+1,Data.all().skills[s.combat_slots[i]].name],replace_art.bind(id,i),prefix+"replace_"+str(i)).add_theme_font_size_override("font_size",14)
		text(body,"Mastery %d of 2 · potency %d%%" % [level,100+15*level],15)
		if level<2:
			text(body,"Potency %d%% → %d%%" % [100+15*level,115+15*level],17)
			text(body,"Your balance: %s Qi · %d herbs" % [host._number(floor(s.qi)),s.herbs],14)
			add_cost(actions,"Improve · %d Qi + %d herbs" % [Data.all().combat_mastery_qi[level],Data.all().combat_mastery_herbs[level]],"art",id,prefix+"buy")
		else: text(body,"Mastered",15)
		text(body,"Changes apply next encounter.",14)
	else:
		var d: Dictionary = Data.all().items[id]
		var current: String = s.equipment[d.slot]
		var owned: bool = s.inventory.has(id)
		var level: int = s.inventory.get(id,0)
		identity(body,id,d.name,item_effect(id))
		if kind=="item":
			text(body,"Equipped: "+(Data.all().items[current].name if not current.is_empty() else "Nothing in this slot"),15)
			text(body,item_effect(current),15)
			if owned and current!=id: button(actions,"Equip · free",equip_item.bind(id),prefix+"equip")
			elif owned:
				text(body,"Equipped",15)
				button(actions,"Remove from slot",unequip_item.bind(d.slot),prefix+"remove")
			if owned and level<3:
				text(body,"Refine %d → %d: %s" % [level,level+1,item_effect(id,level+1)],15)
				text(body,"Balance: %s Qi · %d stones" % [host._number(floor(s.qi)),s.stones],14)
				add_cost(actions,"Refine · %d Qi + %d stones" % [Data.all().refine_qi[level],Data.all().refine_stones[level]],"refine",id,prefix+"buy")
			elif not owned:
				text(body,d.source,15)
				button(actions,"Travel to source",item_source.bind(id),prefix+"source")
		else:
			text(body,"Refinement %d of 3" % level,15)
			if owned and level<3:
				text(body,"Current: "+item_effect(id,level)+"\nNext: "+item_effect(id,level+1),16)
				text(body,"Your balance: %s Qi · %d Spirit Stones" % [host._number(floor(s.qi)),s.stones],14)
				add_cost(actions,"Refine · %d Qi + %d stones" % [Data.all().refine_qi[level],Data.all().refine_stones[level]],"refine",id,prefix+"buy")
			else: text(body,"Fully refined" if owned else d.source,15)
			text(body,"Secondary effects stay fixed. Changes apply next encounter.",14)

func add_cost(parent: Node, label: String, kind: String, id: String, key: String) -> void:
	var buy = button(parent,label,buy_context.bind(kind,id),key,true)
	costs[key] = {"button":buy,"kind":kind,"id":id}

func buy_context(kind: String, id: String) -> void:
	var context: String = selected_detail[0]
	if kind=="method": host._action("mastery",id)
	else: action("train_art" if kind=="art" else "refine",id)
	if sheet.visible: show_detail(context,id)
	else: detail_key = ""

func equip_item(id: String) -> void:
	action("equip",id)
	sheet.hide()

func unequip_item(slot: String) -> void:
	action("unequip",slot)
	sheet.hide()

func navigate(value: String) -> void:
	if value=="cultivate": show_section("retreat" if host.state.unlocked() else "practices")
	elif value=="explore": show_section(explore_section if host.state.chapter_unlocked() else ("gather" if host.state.unlocked() else "explore_locked"))
	else: show_section(build_section if host.state.chapter_unlocked() else "build_locked")

func show_section(value: String) -> void:
	if not built: return
	var next = value
	if value=="journey" and not host.state.journey.status in ["battle","camp","defeat"]:
		open_route(selected_route)
		return
	if value=="journey" or (value==explore_section and value in ["preview","result","battle"]):
		if host.state.journey.status in ["battle","camp","defeat"]:
			next = "battle" if host.state.journey.status=="battle" else "result"
	if next=="retreat" and not host.state.unlocked(): next="practices"
	if next in ["battle","result"]:
		var journey_id: String = host.state.journey.id
		var place: Dictionary = Data.all().routes.get(journey_id,Data.all().trials.get(journey_id,{}))
		region = place.get("region",region)
	if next=="gear" and section!="gear" and not selected_detail[0] in ["item","refine"]:
		selected_detail = ["item",host.state.inventory.keys()[0] if not host.state.inventory.is_empty() else "pine_sword"]
		detail_key = ""
	var changed: bool = section!=next
	if changed:
		positions[section] = host.practice_scroll.scroll_vertical
		section = next
		host.practice_scroll.set_deferred("scroll_vertical",int(positions.get(section,0)))
	if section in ["arts","gear","build_locked"]:
		destination = "build"
		if section!="build_locked": build_section=section
	elif section in ["journey","preview","battle","result","trials","explore_locked","gather"]:
		destination = "explore"
		if section!="gather": explore_section = section
	else: destination = "cultivate"
	for key in sections:
		sections[key].visible = key==section
		if surfaces.has(key): surfaces[key].visible = key==section
	host.active_view = section
	if host.audio: host.audio.effect("panel")
	refresh()
	layout()
	host._refresh_scene()
	if changed:
		if navigation_tween and navigation_tween.is_valid(): navigation_tween.kill()
		host.body_surface.modulate.a = 1 if host.reduced_motion else .68
		if not host.reduced_motion:
			navigation_tween = host.create_tween()
			navigation_tween.tween_property(host.body_surface,"modulate:a",1.0,.18)

func scene_mode() -> String:
	return "battle" if section=="battle" else ("home" if section in ["retreat","practices"] else "task")

func layout() -> void:
	if not built: return
	var screen: Vector2 = host.size
	host.wide = screen.x>=900 and screen.x>screen.y*1.15
	var home: bool = scene_mode()=="home"
	var top = maxf(208,screen.y-500) if home else (maxf(188,screen.y-440) if section=="battle" else 12.0)
	if host.wide:
		host.hud_panel.position = Vector2(screen.x-518,36) if home or section=="battle" else Vector2(40,24)
		host.hud_panel.size = Vector2(478,screen.y-72) if home or section=="battle" else Vector2(screen.x-80,screen.y-48)
		if section=="battle":
			host.hud_panel.position.y = screen.y-456
			host.hud_panel.size.y = 420
	else:
		host.hud_panel.position = Vector2(16,top)
		host.hud_panel.size = Vector2(screen.x-32,screen.y-top-12)
	host.header_row.custom_minimum_size.y = 48
	host.practice_scroll.custom_minimum_size.y = 64
	host.realm_icon.custom_minimum_size = Vector2.ONE*(28 if not home else 32)
	host.qi_label.add_theme_font_size_override("font_size",27)
	host.wallet_row.visible = home
	controls.extra_resources.visible = home and host.state.unlocked()
	host.herb_icon.custom_minimum_size = Vector2.ONE*20
	host.tabs.custom_minimum_size.y = 48
	host.body_surface.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	for id in headers:
		headers[id].visible = (id=="build" and destination=="build" and host.state.chapter_unlocked()) or (id=="explore" and section=="preview")
	for id in docks: docks[id].visible = id==section
	docks.practices.visible = section=="practices" and host.state.unlocked()
	docks.retreat.visible = section=="retreat" and host.state.chapter_unlocked()
	docks.build.visible = destination=="build" and host.state.chapter_unlocked()
	host.task_dock.visible = docks.has(section) or docks.build.visible
	host.task_header.visible = headers.build.visible or headers.explore.visible or boundary.visible
	var enabled: bool = host.state.chapter_unlocked()
	host.progress_bar.visible = not enabled and destination=="cultivate"
	host.breakthrough_button.visible = not enabled and destination=="cultivate"
	host.preparation_group.visible = not enabled and destination=="cultivate" and host.state.realm=="Qi Refining" and not host.state.prepared
	host.preparation_state.visible = not enabled and destination=="cultivate" and host.state.prepared
	host.attainment.hide()
	detail_panel.visible = host.wide and destination=="build" and enabled and (section=="arts" or not host.state.inventory.is_empty())
	if detail_panel.visible:
		var key = str(selected_detail)+str(host.state.combat_mastery)+str(host.state.inventory)+str(host.state.equipment)
		if key!=detail_key: render_desktop_detail()
	host.landscape.compose(host.wide,top,host.hud_panel.position.x-20 if host.wide and (home or section=="battle") else screen.x)
	host.landscape.queue_redraw()

func refresh() -> void:
	if not built: return
	var s = host.state
	if s.learned!=seen_learned:
		for id in s.learned:
			if not id in seen_learned: toast_message("Learned "+Data.all().skills[id].name+" · available in Build")
		seen_learned = s.learned.duplicate()
	toast.visible = Time.get_ticks_msec()<toast_until
	var enabled: bool = s.chapter_unlocked()
	# The legacy readout updater runs every tick; visibility belongs to this task.
	host.tabs.show()
	host.progress_bar.visible = not enabled and destination=="cultivate"
	host.breakthrough_button.visible = not enabled and destination=="cultivate"
	host.preparation_group.visible = not enabled and destination=="cultivate" and s.realm=="Qi Refining" and not s.prepared
	host.preparation_state.visible = not enabled and destination=="cultivate" and s.prepared
	host.attainment.hide()
	if section=="battle" and s.journey.status!="battle":
		show_section("result")
		return
	host.cultivate_tab.text = "Cultivate"
	host.forest_tab.text = "Explore"
	for id in nav:
		var selected: bool = id==destination
		nav[id].set_pressed_no_signal(selected)
		var fill = Color(.23,.38,.31,.20) if selected else Color.TRANSPARENT
		if host.wide and scene_mode() in ["home","battle"]:
			fill = Color(.91,.92,.86,.97) if selected else Color(.953,.929,.875,.96)
		var style = host._style(fill,Color("446c5a"),6)
		style.set_border_width_all(0)
		style.border_width_bottom = 3 if selected else 0
		nav[id].add_theme_stylebox_override("normal",style)
		nav[id].add_theme_stylebox_override("pressed",style)
	for id in ["build_arts","build_gear","gear_owned","gear_discover","gear_all"]:
		var selected: bool = {"build_arts":section=="arts","build_gear":section=="gear","gear_owned":not discover,"gear_discover":discover,"gear_all":equipment_filter=="all","region_misty":region=="Misty Mountain","region_river":region=="Spirit River"}[id]
		var style = host._style(Color(.31,.45,.36,.12) if selected else Color(.31,.45,.36,.035),Color("446c5a"),0)
		style.set_border_width_all(0)
		style.border_width_bottom = 3 if selected else 1
		style.content_margin_left = 6
		style.content_margin_right = 6
		controls[id].add_theme_stylebox_override("normal",style)
	controls.stones.text = "%d stones" % s.stones
	var titles = {"retreat":s.realm.replace(" Establishment",""),"methods":"Methods","practices":"Cultivate","gather":"Bamboo Forest","journey":"Explore","preview":"Explore","battle":s.journey.battle.enemy.name if not s.journey.battle.is_empty() else "Encounter","result":"Safe camp" if s.journey.status=="camp" else "Journey result","arts":"Build","gear":"Build","core":"Realm goal","trials":"Explore","build_locked":"Build","explore_locked":"Explore"}
	host.realm_label.text = titles.get(section,"Cultivate")
	host.rate_label.text = "+%s Qi/s · Retreat" % host._number(s.displayed_rate()) if section=="retreat" else (s.realm.replace(" Establishment","")+" · "+destination.capitalize())
	host.rate_label.visible = section in ["retreat","battle","arts","gear","result"]
	if section in ["battle","result"] and Data.all().routes.has(s.journey.id):
		host.rate_label.text = "%s · %d / 4%s" % [Data.all().routes[s.journey.id].name,mini(s.journey.node+(1 if section=="battle" else 0),4)," cleared" if section=="result" else ""]
	host.techniques.hide()
	host.method_heading.hide()
	host.practice_toggle.get_parent().hide()
	host.practice.visible = section=="practices" and (enabled or host.expanded_practice or not s.unlocked())
	host.unlock_hint.visible = not enabled
	home_icon.texture = host._texture(s.primary if s.primary!="none" else "azure")
	home_method.text = (host._method(s.primary)+"\n"+host._effects(s.effective_bonuses()).replace(" / trip"," / gathering")) if s.unlocked() else "Practise breathing to gather Qi."
	home_pending.visible = s.trip.active and (s.effective_bonuses()!=s.next_bonuses() or not s.pending_primary.is_empty())
	home_pending.text = (host._method(s.pending_primary)+" queued for next gathering departure") if not s.pending_primary.is_empty() else "Mastery applies next gathering departure"
	controls.methods.disabled = not s.unlocked()
	controls.gather.disabled = not s.unlocked()
	controls.retreat_core.visible = enabled
	host.landscape.realm_stage = {"Mortal":0,"Qi Refining":1,"Foundation Establishment":2,"Golden Core":3,"Nascent Soul":4}[s.realm]
	var goal = next_goal()
	home_goal.text = goal.title
	controls.goal.text = goal.label
	goal_action = goal.action
	for id in methods:
		var r: Dictionary = methods[id]
		r.role.text = "+%d%% Qi" % int(host.Rules.TECHNIQUES[id].azure[s.mastery[id]]*100) if id=="azure" else "+%d herbs / gathering" % host.Rules.TECHNIQUES[id].iron[s.mastery[id]]
		r.state.text = ("Queued for next gathering departure" if s.pending_primary==id else ("Primary method" if s.primary==id else "Secondary at half strength"))+(" · Mastered" if s.mastery[id]==2 else "")
		r.select.disabled = s.primary==id or s.pending_primary==id
	for id in routes:
		var d: Dictionary = Data.all().routes[id]
		routes[id].unit.visible = d.region==region
		
		controls["route_"+id].disabled = not s.route_available(id)
	
	controls.depart.disabled = not s.route_available(selected_route) or s.journey.status in ["battle","camp"]
	var selected_prep: Dictionary = Data.all().preparations.get(s.preparation,{})
	controls.depart.text = "Depart" if selected_prep.is_empty() else "Depart\n%d herbs + %d stones" % [selected_prep.herbs,selected_prep.stones]
	controls.depart.disabled = controls.depart.disabled or s.herbs<selected_prep.get("herbs",0) or s.stones<selected_prep.get("stones",0)
	controls.art_loadout.visible = section=="arts"
	controls.equipment_loadout.visible = section=="gear"
	for i in range(4):
		var visible: bool = enabled and i<s.combat_slots.size()
		slots[i].visible = visible
		if visible:
			var id: String = s.combat_slots[i]
			slots[i].text = "%d %s" % [i+1,{"sword":"Sword","flame":"Flame","ward":"Ward","river":"River","thunder":"Thunder","returning":"Blade","mirror":"Mirror","":"Empty"}[id]]
			if id.is_empty(): slots[i].icon=null
			else: host._button_icon(slots[i],id,20)
	for id in arts:
		var r: Dictionary = arts[id]
		var known: bool = id in s.learned
		var equipped: bool = id in s.combat_slots
		r.unit.visible = known or discover_arts
		r.state.text = ("Equipped in slot "+str(s.combat_slots.find(id)+1)) if equipped else ("Ready to equip" if known else Data.all().skills[id].source)
		r.unit.modulate.a = 1 if known else .65
		mark_object(r,s.combat_mastery[id],equipped)
		r.unit.accessibility_name = "%s; mastery %d of 2; %s" % [Data.all().skills[id].name,s.combat_mastery[id],r.state.text]

	controls.presets.visible = s.realm in ["Golden Core","Nascent Soul"]
	controls.laws.visible = s.realm in ["Golden Core","Nascent Soul"]
	controls.laws.text = "Law: "+(Data.all().laws[s.law].name if not s.law.is_empty() else "none")
	controls.region_misty.text = region+" ▾"
	var prep: Dictionary = Data.all().preparations.get(s.preparation,{})
	controls.preview_build.text = "Prepare · "+prep.get("name","no consumable")
	
	var slot_names = ["weapon","robe","artifact"]
	for i in range(3):
		var id: String = s.equipment[slot_names[i]]
		equipped_names[i].text = "Empty" if id.is_empty() else Data.all().items[id].name
		equipped_icons[i].visible = not id.is_empty()
		if not id.is_empty(): equipped_icons[i].texture = host._texture(id)
	for id in gear:
		var r: Dictionary = gear[id]
		var d: Dictionary = Data.all().items[id]
		var owned: bool = s.inventory.has(id)
		r.unit.visible = (equipment_filter=="all" or equipment_filter==d.slot) and (owned if not discover else not owned)
		r.role.text = item_effect(id) if owned else d.source
		r.state.text = ("Equipped" if s.equipment[d.slot]==id else "Owned") if owned else "Undiscovered"
		mark_object(r,s.inventory.get(id,0),s.equipment[d.slot]==id)
		r.unit.accessibility_name = "%s; refinement %d of 3; %s" % [d.name,s.inventory.get(id,0),r.state.text]

	empty_gear.visible = s.inventory.is_empty() and not discover
	if s.realm in ["Golden Core","Nascent Soul"]:
		controls.core_name.text = "Nascent Soul"
		controls.core_role.text = "Fourth ordered technique slot · lasting spirit form"
		core_rows.qi.text = "%s / 90,000 Qi" % host._number(floor(s.qi))
		var count = 0
		for id in Data.all().realm_requirements.routes:
			if id in s.cleared_routes: count += 1
		core_rows.seals.text = "%d / 6 new routes" % count
		var met = {"qi":s.qi>=90000,"seals":count==6}
		for pair in [["misty","Thunder Peak"],["river","Ancient Tomb"],["trial","Moon Lake"]]:
			var found = false
			for id in s.cleared_trials:
				if id.ends_with("_heir") and Data.all().trials[id].region==pair[1]: found=true
			met[pair[0]]=found
			core_rows[pair[0]].text = pair[1]+" inheritance "+("earned" if found else "needed")
		for id in core_rows:
			core_marks[id].texture = host._texture("selection-seal" if met[id] else "mastery-socket")
		preparation.text = "Tribulation cleared" if s.soul_trial_won else "One inheritance from each new region opens the free tribulation."
		controls.prepare_core.hide()
		controls.core_trial.visible = not s.soul_trial_won
		controls.core_trial.text = "Enter Nascent Soul tribulation"
		controls.core_trial.disabled = not s.route_available("soul") or s.journey.status in ["battle","camp"]
		controls.advance_core.visible = s.soul_trial_won and s.realm=="Golden Core"
		controls.advance_core.text = "Form Nascent Soul · 90,000 Qi"
		controls.advance_core.disabled = not s.soul_requirements_met() or s.qi<90000
		core_hint.text = "Nascent Soul attained · fourth technique slot earned. Explore optional inheritances or keep a mastered supply route." if s.realm=="Nascent Soul" else "Earn a fourth ordered technique slot and a lasting spirit form."
	else:
		controls.core_name.text = "Golden Core"
		controls.core_role.text = "Third technique slot · one free preset"
		controls.core_trial.text = "Enter Core Trial"
		controls.advance_core.text = "Form Golden Core · 24,000 Qi"
		core_rows.qi.text = "%s / 24,000 Qi" % host._number(floor(s.qi))
		core_rows.seals.text = "%d / 3 distinct finale seals" % s.cleared_routes.size()
		core_rows.misty.text = "%d / 2 Misty Mountain routes" % s.region_clears("Misty Mountain")
		core_rows.river.text = "%d / 2 Spirit River routes" % s.region_clears("Spirit River")
		core_rows.trial.text = "Core Trial cleared" if s.core_trial_won else "Core Trial not cleared"
		var met = {"qi":s.qi>=24000,"seals":s.cleared_routes.size()>=3,"misty":s.region_clears("Misty Mountain")>=2,"river":s.region_clears("Spirit River")>=2,"trial":s.core_trial_won}
		for id in core_rows:
			core_marks[id].texture = host._texture("selection-seal" if met[id] else "mastery-socket")
			core_marks[id].modulate.a = 1.0 if met[id] else .65
			core_rows[id].modulate = Color("345746") if met[id] else host.INK
		preparation.text = "Prepared · incoming Core Trial damage −10%" if s.core_prepared else "Optional: 24 extra herbs reduce Core Trial damage by 10%."
		controls.prepare_core.visible = not s.core_prepared and s.realm!="Golden Core"
		controls.prepare_core.disabled = s.herbs<24
		controls.core_trial.visible = not s.core_trial_won and s.realm!="Golden Core"
		controls.core_trial.disabled = not s.core_requirements_met() or s.journey.status in ["battle","camp"]
		controls.advance_core.visible = s.core_trial_won and s.realm=="Foundation Establishment"
		controls.advance_core.disabled = not s.core_requirements_met() or s.qi<24000
		core_hint.text = "Golden Core attained." if s.realm=="Golden Core" else ("Clear two routes in each region and earn three seals before the Core Trial." if not s.core_requirements_met() else "The Core Trial is free. Defeat keeps all earned progress.")
	boundary.visible = enabled and destination=="build" and s.journey.status=="battle" and (s.combat_slots!=s.journey.battle.stats.slots or s.equipment!=s.journey.battle.stats.build.equipment)
	boundary.text = "Your changes apply next encounter."
	controls.build_return.visible = s.journey.status in ["battle","camp"] or explore_section=="preview"
	controls.build_return.text = "Back to camp" if s.journey.status=="camp" else ("Back to battle" if s.journey.status=="battle" else "Back to route")
	if section in ["battle","result"]: refresh_battle()
	refresh_costs()

func toast_message(message: String) -> void:
	toast.text = message
	toast_until = Time.get_ticks_msec()+7000
	toast.show()

func refresh_costs() -> void:
	var s = host.state
	for key in costs:
		var r: Dictionary = costs[key]
		if not is_instance_valid(r.button): continue
		var available = false
		if r.kind=="method": available = s.mastery[r.id]<2 and s.herbs>=s.mastery_cost(r.id)
		elif r.kind=="art":
			var level: int = s.combat_mastery[r.id]
			available = level<2 and s.qi>=Data.all().combat_mastery_qi[mini(1,level)] and s.herbs>=Data.all().combat_mastery_herbs[mini(1,level)]
		else:
			var level: int = s.inventory.get(r.id,3)
			available = level<3 and s.qi>=Data.all().refine_qi[mini(2,level)] and s.stones>=Data.all().refine_stones[mini(2,level)]
		r.button.disabled = not available

func refresh_battle() -> void:
	var s = host.state
	var j: Dictionary = s.journey
	if j.battle.is_empty(): return
	var b: Dictionary = j.battle
	enemy_hp.text = "Enemy %s / %s HP" % [host._number(snappedf(b.enemy_hp,.1)),host._number(b.enemy.hp)]
	player_hp.text = "You %s / %s HP" % [host._number(snappedf(b.hp,.1)),host._number(b.stats.hp)]
	if b.shield>0: player_hp.text += " · %s shield" % host._number(snappedf(b.shield,.1))
	focus_label.text = "Focus %s / %s" % [host._number(snappedf(b.focus,.1)),host._number(b.stats.focus_cap)]
	focus_label.visible = b.constraint.has("focus_budget") or b.focus<3
	focus_meter.hide()
	feedback.hide()
	for pair in [[enemy_meter,b.enemy_hp,b.enemy.hp],[player_meter,b.hp,b.stats.hp],[focus_meter,b.focus,b.stats.focus_cap]]:
		pair[0].max_value = pair[2]
		pair[0].value = pair[1]
	threat.text = salient_threat(b)
	for i in range(4):
		var cell: Dictionary = readiness[i]
		var id: String = b.stats.slots[i] if i<b.stats.slots.size() else ""
		cell.cell.visible = not id.is_empty()
		if id.is_empty(): continue
		cell.symbol.texture = host._texture(id)
		cell.title.text = "%d %s" % [i+1,{"sword":"Sword","flame":"Flame","ward":"Ward","river":"River","thunder":"Thunder","returning":"Blade","mirror":"Mirror"}[id]]
		var ready: bool = Combat.eligible(b,id)
		cell.symbol.modulate.a = 1 if ready else .55
		cell.status.text = "Ready"
		if not ready:
			if b.cooldowns[id]>b.ticks: cell.status.text = "%ds" % ceili((b.cooldowns[id]-b.ticks)/20.0)
			elif b.focus<Data.all().skills[id].focus: cell.status.text="%d focus" % Data.all().skills[id].focus
			elif b.focus_spent+Data.all().skills[id].focus>b.constraint.get("focus_budget",1000000): cell.status.text="Budget used"
			else: cell.status.text="Guard up" if id=="ward" else "Healthy"
	feedback.text = Data.all().skills[b.last_action].name if Data.all().skills.has(b.last_action) else ""
	controls.camp_request.text = "Camp queued" if j.camp_requested else "Camp after fight"
	controls.camp_request.disabled = j.camp_requested
	reward_title.text = "Attempt ended" if j.status=="defeat" else ("Discovery" if not j.rewards.get("arts",[]).is_empty() else "Rewards retained")
	for id in reward_values: reward_values[id].text = "+"+host._number(j.rewards[id])+{"qi":" Qi","herbs":" herb" if j.rewards.herbs==1 else " herbs","stones":" stones"}[id]
	reward_note.text = ("Encounter %d complete · journey paused" % j.node) if j.status=="camp" else (j.reason if j.status=="defeat" else "Journey complete. Rewards already added.")
	var key = str(j.rewards)+str(s.combat_slots)
	if key!=reward_key:
		reward_key = key
		clear_content(rewards)
		for id in j.rewards.get("arts",[]):
			identity(rewards,id,Data.all().skills[id].name,skill_role(id))
			if id in s.combat_slots: text(rewards,"Equipped in slot "+str(s.combat_slots.find(id)+1),15)
			else:
				var empty: int = s.combat_slots.find("")
				button(rewards,("Equip in slot %d · free" % [empty+1]) if empty>=0 else "Choose slot to replace",equip_art.bind(id),"discovery_"+id)
		for id in j.rewards.items: identity(rewards,id,Data.all().items[id].name,item_effect(id))
	controls.continue.visible = j.status=="camp"
	controls.result_routes.visible = j.status!="camp"
	controls.result_routes.text = next_goal().label
	controls.end_journey.visible = j.status=="camp"

func salient_threat(b: Dictionary) -> String:
	if b.constraint.get("objective", "win")!="win": return b.constraint.get("description","Meet the inheritance objective.")
	if not b.poison.is_empty(): return "Poisoned · River cleanses poison"
	if "channeler" in b.enemy.traits: return "Heavy strike in %ss" % host._number(snappedf(maxf(0,(b.next_burst-b.ticks)/20.0),.1))
	if b.barriers>0: return "%d barriers · direct hits break them" % b.barriers
	if "thorned" in b.enemy.traits: return "Reflects direct hits · Flame burn avoids reflection"
	if "venomous" in b.enemy.traits: return "Venom on hit · River can cleanse it"
	if "veiled" in b.enemy.traits and Combat.protected(b): return "Mist protection · damage reduced"
	if "healer" in b.enemy.traits: return "This guardian recovers health"
	if "alternating" in b.enemy.traits: return "Physical guard" if int(b.ticks/120)%2==0 else "Magic guard"
	return "Techniques act automatically"

func build_audio() -> void:
	audio_popup = PopupPanel.new()
	audio_popup.wrap_controls = false
	audio_popup.add_theme_stylebox_override("panel", Materials.skin("methods-scroll"))
	host.add_child(audio_popup)
	var outer = column(audio_popup, 8)
	menu_content = outer
	menu_content.minimum_size_changed.connect(layout_menu.call_deferred)
	heading(outer, "Menu", 28)
	var settings_scroll = ScrollContainer.new()
	settings_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	settings_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	settings_scroll.follow_focus = false
	settings_scroll.custom_minimum_size.y = 320
	outer.add_child(settings_scroll)
	var box = column(settings_scroll, 6)
	for bus in ["Master", "Music", "Ambience", "SFX"]:
		var line = row(box)
		var name_label = text(line, bus, 16, false)
		name_label.custom_minimum_size.x = 70
		var slider = HSlider.new()
		slider.custom_minimum_size = Vector2(80, 48)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.min_value = 0
		slider.max_value = 100
		slider.step = 1
		slider.value = host.audio.settings[bus] * 100
		slider.accessibility_name = bus + " volume"
		slider.focus_entered.connect(host._reveal_focused.bind(slider))
		slider.value_changed.connect(audio_volume.bind(bus))
		line.add_child(slider)
		audio_sliders[bus] = slider
		audio_values[bus] = text(line, "%d%%" % slider.value, 14, false)
		audio_values[bus].custom_minimum_size.x = 36
	audio_mute = button(box, "Mute", toggle_mute, "audio_mute")
	host._button_icon(audio_mute,"selection-seal",20)
	audio_mute.toggle_mode = true
	audio_mute.set_pressed_no_signal(host.audio.muted)
	host.motion_button.reparent(box)
	host.motion_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.menu_motion = host.motion_button
	var information = row(box,8)
	button(information, "Help", menu_instructions, "menu_help")
	button(information, "Credits", audio_credits, "audio_credits")
	button(outer, "Return to game", audio_popup.hide, "audio_close", true)
	audio_popup.close_requested.connect(audio_popup.hide)
	audio_popup.size_changed.connect(layout_menu)
	audio_popup.visibility_changed.connect(func(): host.dialog_scrim.visible = audio_popup.visible or host.details_dialog.visible)

func open_audio() -> void:
	host.details_dialog.hide()
	audio_mute.text = "Sound muted" if host.audio.muted else "Mute sound"
	audio_mute.icon = host._texture("selection-seal") if host.audio.muted else null
	audio_mute.set_pressed_no_signal(host.audio.muted)
	# Include the skin's spindle/content insets in the requested window height.
	# Window minimum size otherwise grows after centering and clips Return.
	audio_popup.popup_centered(Vector2i(mini(int(host.size.x) - 24, 430), mini(int(host.size.y)-32,564)))
	layout_menu()
	controls.audio_close.grab_focus()

func layout_menu() -> void:
	if menu_content:
		host._fit_popup_content(audio_popup,menu_content)

func audio_volume(value: float, bus: String) -> void:
	host.audio.set_volume(bus, value / 100.0)
	audio_values[bus].text = "%d%%" % value

func menu_instructions() -> void:
	audio_popup.hide()
	host._instructions()

func toggle_mute() -> void:
	host.audio.set_mute(not host.audio.muted)
	audio_mute.text = "Sound muted" if host.audio.muted else "Mute sound"
	audio_mute.icon = host._texture("selection-seal") if host.audio.muted else null

func audio_credits() -> void:
	audio_popup.hide()
	host._details("Credits & licenses", "Optional music: Lotus Pond and Dragon Dance by BiteMe Games.\nhttps://bitemegames.itch.io/chinese-game-music\nCreator lists CC0; commercial game use is permitted. Do not resell as an asset pack.\n\nRecorded wood, paper, air, impact, gong and flowing water: rubberduck, 100 CC0 SFX and 100 CC0 SFX #2.\nhttps://opengameart.org/users/rubberduck\n\nFlare ignition: qubodup.\nWater Waves: transitking, submitted by qubodup.\nEffects are CC0 1.0. Trimmed, filtered, level matched and loop-crossfaded. No bird loop or retro UI tones. Full file-level sources and edits: assets/audio/manifest.json.\n\nOriginal illustrations and layered realm/region art generated with OpenAI imagegen. Source images and prompts: docs/jade-road/ART_MANIFEST.json and docs/living-dao/ART_MANIFEST.json. Fonts: Lato and Cormorant Garamond, SIL Open Font License.")

func region_art() -> String:
	return {"Misty Mountain":"misty_mountain","Spirit River":"spirit_river","Thunder Peak":"thunder_peak","Ancient Tomb":"ancient_tomb","Moon Lake":"moon_lake"}.get(region,"misty_mountain")

func enter_tribulation() -> void:
	action("journey","soul" if host.state.realm in ["Golden Core","Nascent Soul"] else "core")

func region_sheet() -> void:
	open_sheet("Choose a region")
	for place in ["Misty Mountain","Spirit River","Thunder Peak","Ancient Tomb","Moon Lake"]:
		var unlocked = false
		for id in Data.all().routes:
			if Data.all().routes[id].region==place and host.state.route_available(id): unlocked=true
		var b = button(sheet_actions,place+("" if unlocked else " · locked"),select_region.bind(place),"choose_"+place.replace(" ","_"))
		b.disabled = not unlocked
	text(sheet_body,"Golden Core opens Thunder Peak; its first clear opens the Tomb, then Moon Lake.",15)

func select_region(place: String) -> void:
	sheet.hide()
	choose_region(place)

func challenges_sheet() -> void:
	open_sheet(region+" · challenges")
	for id in Data.all().trials:
		var d: Dictionary = Data.all().trials[id]
		if d.get("region", "Misty Mountain" if id in ["ward_trial","burst_trial"] else "Spirit River")!=region: continue
		var b = button(sheet_actions,d.name+(" · cleared" if id in host.state.cleared_trials else ""),select_challenge.bind(id),"challenge_"+id)
		b.disabled = not host.state.route_available(id)
	text(sheet_body,"Free attempts. Rewards settle once; defeat keeps earned progress.",15)

func select_challenge(id: String) -> void:
	sheet.hide()
	open_route(id)

func departure_sheet() -> void:
	open_sheet("Departure preparation")
	text(sheet_body,"One optional preparation. Selecting or cancelling spends nothing. Depart consumes it once for the whole journey. Supply cannot use preparations.",15)
	button(sheet_actions,"No consumable · free",choose_preparation.bind(""),"prep_none")
	if host.state.realm in ["Golden Core","Nascent Soul"]:
		for id in Data.all().preparations:
			var d: Dictionary = Data.all().preparations[id]
			identity(sheet_body,id,d.name,d.description)
			button(sheet_body,"Select · %d herbs + %d stones" % [d.herbs,d.stones],choose_preparation.bind(id),"prep_"+id)
	button(sheet_actions,"Adjust techniques & equipment",prepare_build,"departure_build")

func prepare_build() -> void:
	sheet.hide()
	navigate("build")

func choose_preparation(id: String) -> void:
	action("preparation",id)
	sheet.hide()

func law_sheet() -> void:
	open_sheet("Law accord")
	text(sheet_body,"One law at a time. Free changes apply next encounter; the current fight keeps its committed build.",15)
	button(sheet_actions,"No law · free",choose_law.bind(""),"law_none")
	for id in Data.all().laws:
		var d: Dictionary = Data.all().laws[id]
		identity(sheet_body,"law_"+id,d.name,d.description)
		var unlocked: bool = host.state.law_available(id)
		button(sheet_body,"Equip · free" if unlocked else "Earn "+Data.all().trials[d.trial].name,choose_law.bind(id) if unlocked else select_challenge.bind(d.trial),"law_"+id)

func choose_law(id: String) -> void:
	action("law",id)
	sheet.hide()
