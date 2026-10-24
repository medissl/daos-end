extends Node2D
## Anchored painted layers. Visual clocks never mutate simulation or rewards.
const BODY = preload("res://assets/art/living/body.png")
const RELEASE = preload("res://assets/art/living/release.png")
const CAPE = preload("res://assets/art/living/cape.png")
const GOLDEN = preload("res://assets/art/living/golden.png")
const GOLDEN_RELEASE = preload("res://assets/art/living/golden-release.png")
const SOUL = preload("res://assets/art/living/soul.png")
const SOUL_RELEASE = preload("res://assets/art/living/soul-release.png")
var realm = 0
var reduced_motion = false
var elapsed = 0.0
var action_time = 0.0
var action_kind = ""
var celebration = 0.0
var cape_pivot: Node2D
var cape: Sprite2D
func _ready() -> void:
	cape_pivot = Node2D.new()
	cape_pivot.position = Vector2(275,220)
	add_child(cape_pivot)
	cape = Sprite2D.new()
	cape.texture = CAPE
	cape.centered = false
	cape.position = Vector2(-125,-33)
	cape.scale = Vector2(177.0/CAPE.get_width(),150.0/CAPE.get_height())
	cape_pivot.add_child(cape)
func set_realm(value: int) -> void:
	realm = value
func play_action(kind: String) -> void:
	if kind in ["strike","sword","flame","ward","river","thunder","returning","mirror","counter"]:
		action_kind = kind
		action_time = .72
func _process(delta: float) -> void:
	action_time = maxf(0,action_time-delta)
	if not is_visible_in_tree(): return
	elapsed += delta
	var gesture = action_time<.60 and action_time>.24 and action_kind!="strike" and not reduced_motion
	cape_pivot.visible = realm==2 and not gesture
	cape_pivot.rotation = 0 if reduced_motion else sin(elapsed*TAU/9-.4)*.021
	cape_pivot.scale.y = 1 if reduced_motion else 1+sin(elapsed*TAU/9)*.009
	queue_redraw()
func _draw() -> void:
	var gesture = action_time<.60 and action_time>.24 and action_kind!="strike" and not reduced_motion
	var body: Texture2D = SOUL if realm>=4 else (GOLDEN if realm==3 else BODY)
	var release: Texture2D = SOUL_RELEASE if realm>=4 else (GOLDEN_RELEASE if realm==3 else RELEASE)
	if realm>=4:
		# A restrained spirit echo retains the same anatomy and anchor. It is
		# subordinate to the attained garment, including in reduced motion.
		draw_texture_rect_region(SOUL,Rect2(Vector2(12,-13),Vector2(616,481.25)),Rect2(0,0,640,500),Color(.48,.69,.72,.13))
	# Head, hands-at-rest, legs and ground are fixed; only cloth deforms.
	draw_texture(release if gesture else body,Vector2.ZERO)
	if not gesture:
		cloth_patch(body,Rect2(288,216,104,117),Vector2(1.7,1),0)
		# Interior hair and sleeve folds lag the torso. The face, hand and
		# outer silhouette vertices stay fixed; the painted base fills overlap.
		cloth_patch(body,Rect2(263,82,21,52),Vector2(.8,.3),-.7)
		cloth_patch(body,Rect2(179,287,51,49),Vector2(1.1,.6),-1.0)
	if realm==3:
		draw_circle(Vector2(315,279),8,Color(.67,.34,.22,.18 if reduced_motion else .12+.08*sin(elapsed*TAU/7)))
	if realm>=1:
		var alpha = .22 if reduced_motion else .12+.1*sin(elapsed*TAU/9)
		draw_arc(Vector2(320,360),110,.25,2.6,28,Color(.28,.52,.47,alpha),1.3,true)
	if realm>=2:
		draw_arc(Vector2(320,567),205,.15,PI-.15,40,Color(.27,.46,.38,.5),2,true)
	if celebration>0:
		var progress = 1-celebration/2.0
		for i in range(3):
			draw_arc(Vector2(320,325),60+progress*100+i*16,-PI*.5,PI*progress,48,Color(.63,.32,.18,(1-progress)*.7),4-i,true)

func cloth_patch(texture: Texture2D, region: Rect2, displacement: Vector2, lag: float) -> void:
	var corners = PackedVector2Array([region.position,Vector2(region.end.x,region.position.y),region.end,Vector2(region.position.x,region.end.y)])
	var anchor = region.get_center()
	var center = anchor if reduced_motion else anchor+displacement*sin(elapsed*TAU/9+lag)
	for i in range(4):
		var a = corners[i]
		var b = corners[(i+1)%4]
		draw_colored_polygon(PackedVector2Array([a,b,center]),Color.WHITE,PackedVector2Array([a/640,b/640,anchor/640]),texture)
