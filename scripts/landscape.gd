extends Control
## Independent illustrated layers. No baked interface pixels or duplicated scene layers.
var portrait_texture: Texture2D = preload("res://assets/art/sanctuary-portrait.png")
var wide_texture: Texture2D = preload("res://assets/art/sanctuary-wide.png")
var breath = 0.0
var awakened = false
var realm_stage = 0
var flash = 0.0
var reduced_motion = false
var character_rect = Rect2()
var world_width = 0.0
var hud_top = 400.0
var wide = false
var region_texture: Texture2D
var guardian_texture: Texture2D
var encounter = false
var effect_texture: Texture2D
var effect_time = 0.0
var warded = false
var poisoned = false
var barriers = 0
var telegraph = false
var presentation = "home"
var visual: Node2D
var hit_time = 0.0
var handoff_time = 0.0
var enemy_action_time = 0.0
var celebration = 0.0
var region_name = "Misty Mountain"
const LAYERS = {
	"mist":preload("res://assets/art/living/mist-layer.png"),
	"water":preload("res://assets/art/living/water-layer.png"),
	"wind":preload("res://assets/art/living/wind-layer.png"),
	"reed":preload("res://assets/art/living/reed-layer.png"),
	"lamp":preload("res://assets/art/living/lamp-layer.png"),
	"pine":preload("res://assets/art/living/pine-layer.png")}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual = preload("res://scripts/cultivator_visual.gd").new()
	add_child(visual)

func _process(delta: float) -> void:
	var scenic = presentation in ["home","battle"]
	visual.visible = scenic
	visual.set_realm(realm_stage)
	visual.reduced_motion = reduced_motion
	visual.celebration = celebration
	visual.position = character_rect.position
	visual.scale = character_rect.size/640.0
	effect_time = maxf(0,effect_time-delta)
	hit_time = maxf(0,hit_time-delta)
	handoff_time = maxf(0,handoff_time-delta)
	enemy_action_time = maxf(0,enemy_action_time-delta)
	celebration = 0 if reduced_motion else maxf(0,celebration-delta)
	flash = maxf(0,flash-delta*.5)
	if not scenic: return
	if not reduced_motion: breath += delta*1.4
	queue_redraw()

func player_action(kind: String) -> void:
	visual.play_action(kind)
	if kind in ["strike","sword","flame","thunder","returning","counter"]: hit_time = .5

func enemy_action(_kind: String) -> void:
	enemy_action_time = .5

func handoff() -> void:
	handoff_time = 0 if reduced_motion else .4

func compose(is_wide: bool, controls_top: float, available_width: float) -> void:
	wide = is_wide
	hud_top = controls_top
	world_width = available_width
	var height = minf(size.y * .76, available_width * .76) if wide else minf(hud_top + 4, size.x * .94)
	height = maxf(160.0, height)
	if encounter:
		height *= .82
	var center = Vector2(available_width * (.30 if encounter else .50), size.y * .95) if wide else Vector2(size.x * (.30 if encounter else .5), hud_top + 8)
	character_rect = Rect2(center - Vector2(height * .5, height), Vector2.ONE * height)
	queue_redraw()

func _draw() -> void:
	var background: Texture2D = wide_texture if wide else portrait_texture
	if region_texture:
		background = region_texture
	var scenic = presentation in ["home", "battle"]
	var scene_size = size if wide or not scenic else Vector2(size.x, hud_top + 24)
	var scale_factor = maxf(scene_size.x / background.get_width(), scene_size.y / background.get_height())
	var extent = background.get_size() * scale_factor
	# Bottom-align the terrace with the character's seat, rather than floating over mist.
	var origin = (size - extent) * .5 if wide else Vector2((size.x - extent.x) * .5, scene_size.y - extent.y)
	draw_rect(Rect2(Vector2.ZERO, size), Color("f3eddf"))
	draw_texture_rect(background, Rect2(origin, extent), false)
	if not wide and scenic:
		# The portrait painting ends behind the controls. Fade that boundary
		# into the paper ground instead of exposing a hard horizontal cut.
		var start = hud_top - 32
		var end = hud_top + 24
		draw_polygon(PackedVector2Array([Vector2(0,start),Vector2(size.x,start),Vector2(size.x,end),Vector2(0,end)]),PackedColorArray([Color(.953,.929,.875,0),Color(.953,.929,.875,0),Color("f3eddf"),Color("f3eddf")]))
	if not scenic:
		# Task screens retain the landscape without a decorative portrait block.
		draw_rect(Rect2(Vector2.ZERO,size),Color(.953,.929,.875,.70))
		return
	draw_place_layers(scene_size)
	var figure = character_rect
	if realm_stage == 3:
		var chest = figure.position + figure.size * Vector2(.50,.58)
		for i in range(5,0,-1):
			draw_circle(chest, figure.size.x * (.018 + i * .008), Color(1.0,.80,.31,.035 * (6-i)))
	if encounter and guardian_texture:
		var enemy_height = figure.size.y * .72
		var enemy_center = Vector2(world_width * .76, figure.end.y - enemy_height * .46)
		var enemy_rect = Rect2(enemy_center - Vector2.ONE * enemy_height * .5,Vector2.ONE * enemy_height)
		var pivot = Vector2(enemy_center.x,enemy_rect.end.y)
		var windup = -.035 if telegraph and not reduced_motion else 0.0
		var reaction = sin(hit_time*PI*8)*.022 if hit_time>0 and not reduced_motion else 0.0
		var arrival = (handoff_time/.4)*18 if not reduced_motion else 0.0
		draw_set_transform(pivot+Vector2(arrival,0),windup+reaction)
		draw_texture_rect(guardian_texture,Rect2(enemy_rect.position-pivot,enemy_rect.size),false,Color(1,1,1,1-handoff_time/.4))
		draw_set_transform(Vector2.ZERO)
		if barriers > 0:
			for i in range(mini(barriers,9)):
				draw_arc(enemy_center,enemy_height * .48+i*2,-1.5,.8,24,Color(.43,.64,.59,.42),1,true)
		if telegraph:
			draw_arc(enemy_center,enemy_height * .54,0,TAU,48,Color(.72,.29,.17,.8 if reduced_motion else .4+.35*sin(breath*4)),2,true)
		if warded:
			draw_arc(figure.get_center(),figure.size.y * .36,-2.4,.6,40,Color(.35,.67,.56,.6),3,true)
		if poisoned:
			draw_circle(figure.get_center()+Vector2(figure.size.x*.22,0),4,Color("75804a"))
		if effect_time > 0 and effect_texture:
			var t = 1.0 - effect_time / .55
			var target = figure.get_center().lerp(enemy_center,.5 if reduced_motion else t)
			var radius = figure.size.x * .19
			draw_texture_rect(effect_texture,Rect2(target-Vector2.ONE*radius*.5,Vector2.ONE*radius),false,Color(1,1,1,minf(1,effect_time*4)))
			var palm = figure.position+figure.size*Vector2(.44,.42)
			var impact = enemy_center+Vector2(0,-enemy_height*.15)
			if visual.action_kind in ["strike","sword"]:
				for i in range(2):
					var offset = Vector2(0,i*5)
					draw_line(palm+offset,impact+Vector2(10,-12)+offset,Color(.22,.35,.31,effect_time),2.5-i,true)
			elif visual.action_kind=="flame":
				for i in range(3):
					var extent_fx = Vector2(36,52)*(1+float(i)*.15)
					draw_texture_rect(effect_texture,Rect2(impact-extent_fx*.5+Vector2(i*8,0),extent_fx),false,Color(1,.85,.65,effect_time*.8))
			elif visual.action_kind=="river":
				for i in range(3): draw_arc(figure.get_center(),figure.size.y*(.22+i*.04),.1,PI*1.8,32,Color(.29,.55,.59,effect_time),2,true)
			elif visual.action_kind=="thunder":
				draw_polyline(PackedVector2Array([palm,palm.lerp(impact,.5)+Vector2(0,-16),palm.lerp(impact,.55)+Vector2(-12,8),impact]),Color(.25,.43,.49,effect_time),3,true)
			elif visual.action_kind=="returning":
				draw_arc(impact,enemy_height*.28,-PI,PI*.7,32,Color(.24,.4,.37,effect_time),3,true)
			elif visual.action_kind in ["mirror","counter"]:
				draw_arc(figure.get_center(),figure.size.y*.3,-PI*.9,PI*.3,32,Color(.35,.55,.61,effect_time),3,true)
		if enemy_action_time>0:
			draw_line(enemy_center,figure.position+figure.size*Vector2(.52,.48),Color(.62,.28,.18,enemy_action_time*.65),2,true)
	if awakened or flash > 0.0:
		var accent = Color("9c6445")
		accent.a = .24 if reduced_motion else .18 + flash * .28
		var center = Vector2(figure.get_center().x, figure.end.y - figure.size.y * .10)
		draw_arc(center, figure.size.x * .44, .10, PI - .10, 64, accent, 1.2, true)
		if realm_stage == 2:
			draw_arc(center, figure.size.x * .48, .05, PI - .05, 64, Color(.28,.48,.39,.34), 1.6, true)

func draw_place_layers(extent: Vector2) -> void:
	var t = 0.0 if reduced_motion else breath
	var w = extent.x
	var h = extent.y
	if region_name in ["Spirit River","Moon Lake"]:
		draw_texture_rect(LAYERS.water,Rect2(Vector2(w*.38+sin(t*.12)*5,h*.36),Vector2(w*.64,h*.32)),false,Color(1,1,1,.28))
		draw_set_transform(Vector2(w*.94,h*.93),sin(t*.21)*.018)
		draw_texture_rect(LAYERS.reed,Rect2(-w*.24,-h*.3,w*.24,h*.3),false,Color(1,1,1,.75))
		draw_set_transform(Vector2.ZERO)
	elif region_name=="Ancient Tomb":
		draw_texture_rect(LAYERS.lamp,Rect2(w*.85,h*.41,w*.12,h*.18),false,Color(1,1,1,.65+.05*sin(t*1.7)))
		for i in range(4):
			var phase = fmod(t*.08+i*.23,1.0)
			draw_circle(Vector2(w*(.87+i*.008),h*(.40-phase*.12)),.8,Color(.69,.57,.36,.18*sin(phase*PI)))
	elif region_name=="Thunder Peak":
		for i in range(2):
			var x = fmod(t*4+i*w*.6,w*1.5)-w*.4
			draw_texture_rect(LAYERS.wind,Rect2(x,h*(.1+i*.16),w*.5,h*.12),false,Color(1,1,1,.23))
		draw_set_transform(Vector2(0,h*.68),sin(t*.32)*.015)
		draw_texture_rect(LAYERS.pine,Rect2(0,-h*.2,w*.26,h*.2),false,Color(1,1,1,.55))
		draw_set_transform(Vector2.ZERO)
	else:
		draw_texture_rect(LAYERS.mist,Rect2(-w*.1+sin(t*.08)*9,h*.22,w*.9,h*.24),false,Color(1,1,1,.17))
		draw_set_transform(Vector2(0,h*.7),sin(t*.14)*.008)
		draw_texture_rect(LAYERS.pine,Rect2(0,-h*.18,w*.22,h*.18),false,Color(1,1,1,.4))
		draw_set_transform(Vector2.ZERO)
