extends SceneTree
func _initialize() -> void:
	call_deferred("render")
func render() -> void:
	root.size = Vector2i(896, 480)
	var canvas = Control.new()
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(canvas)
	var paper = ColorRect.new()
	paper.color = Color("f3eddf")
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(paper)
	var ids = ["qi", "herbs", "breathing", "meridian", "mind", "azure", "iron", "forest", "preparation", "advancement", "mortal", "refining", "foundation"]
	for i in range(ids.size()):
		var x = 12 + (i % 4) * 224
		var y = 8 + (i / 4) * 118
		var label = Label.new()
		label.text = ids[i] + " · 32 / 48 / 64 px"
		label.add_theme_font_override("font", load("res://assets/fonts/Lato-Regular.ttf"))
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color("293e39"))
		label.position = Vector2(x, y)
		canvas.add_child(label)
		for pair in [[0, 32], [42, 48], [100, 64]]:
			var icon = TextureRect.new()
			icon.texture = load("res://assets/icons/%s.png" % ids[i])
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.position = Vector2(x + pair[0], y + 30)
			icon.size = Vector2.ONE * pair[1]
			canvas.add_child(icon)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/art-direction/milestone-2/screenshots/icon-set-runtime-sizes.png")
	quit()
