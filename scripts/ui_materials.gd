extends RefCounted
## Shared generated materials. Slice margins preserve spindles and jade tips;
## text, prices and hit targets remain independent native Godot controls.
static var textures = {}
static func texture(id: String) -> Texture2D:
	if not textures.has(id):
		textures[id] = load("res://assets/ui/%s.png" % id)
	return textures[id]

static func skin(id: String, tint: Color = Color.WHITE) -> StyleBoxTexture:
	var s = StyleBoxTexture.new()
	s.texture = texture(id)
	s.modulate_color = tint
	var margins = {"main-panel":[24,24,24,24],"methods-scroll": [24, 28, 24, 28], "action-plaque": [24, 16, 24, 16], "action-clean":[24,16,24,16], "reward-tray": [112, 72, 112, 72], "progress-track": [28, 3, 28, 3], "progress-fill": [16,0,16,0]}.get(id, [8, 8, 8, 8])
	for side in range(4):
		s.set_texture_margin(side, margins[side])
	s.content_margin_left = 40 if id == "methods-scroll" else (28 if id == "reward-tray" else 8)
	s.content_margin_right = s.content_margin_left
	s.content_margin_top = 40 if id == "methods-scroll" else (30 if id == "reward-tray" else 0)
	s.content_margin_bottom = 40 if id == "methods-scroll" else (30 if id == "reward-tray" else 0)
	if id == "action-clean":
		s.content_margin_left = 16
		s.content_margin_right = 16
		s.content_margin_top = 6
		s.content_margin_bottom = 6
	if id == "main-panel":
		s.content_margin_left = 20
		s.content_margin_right = 20
		s.content_margin_top = 20
		s.content_margin_bottom = 16
	return s

static func action(button: Button) -> void:
	button.add_theme_stylebox_override("normal", skin("action-clean"))
	button.add_theme_stylebox_override("hover", skin("action-clean", Color(1.08,1.08,1.02)))
	button.add_theme_stylebox_override("pressed", skin("action-clean", Color(.82,.90,.84)))
	button.add_theme_stylebox_override("disabled", skin("action-clean", Color(1,1,1,.40)))
	button.add_theme_color_override("font_disabled_color", Color("40554a"))

static func paper(inset: int = 12, opacity: float = .96) -> StyleBoxFlat:
	var surface = StyleBoxFlat.new()
	surface.bg_color = Color(.953,.929,.875,opacity)
	surface.set_content_margin_all(inset)
	return surface

static func meter(bar: ProgressBar, color: Color) -> void:
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.custom_minimum_size.y = 10
	var track = skin("progress-track")
	track.region_rect = Rect2(48,0,track.texture.get_width()-96,track.texture.get_height())
	var fill = skin("progress-fill",color.lightened(.25))
	fill.region_rect = Rect2(24,0,fill.texture.get_width()-48,fill.texture.get_height())
	for side in range(4):
		track.set_texture_margin(side,0)
		fill.set_texture_margin(side,0)
	bar.add_theme_stylebox_override("background", track)
	bar.add_theme_stylebox_override("fill", fill)
	# Independent cap layers stay round while the center stretches with the HUD.
	for side in ["left", "right"]:
		var cap = TextureRect.new()
		cap.texture = texture("progress-end-"+side)
		cap.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cap.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_child(cap)
		cap.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT if side == "left" else Control.PRESET_CENTER_RIGHT)
		cap.offset_left = 0 if side == "left" else -10
		cap.offset_right = 10 if side == "left" else 0
		cap.offset_top = -5
		cap.offset_bottom = 5
