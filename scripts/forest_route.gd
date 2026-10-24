extends Control
## A view of the specified timer; no movement simulation or second clock.
var texture: Texture2D
var method_texture: Texture2D
var progress = 0.0
var active = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	if texture:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
	var points = PackedVector2Array()
	for i in range(33):
		var t = i / 32.0
		points.append(Vector2(size.x * (.12 + .76 * t), size.y * (.76 - sin(t * PI) * .20)))
	draw_polyline(points, Color(.95,.94,.87,.85), 5, true)
	draw_polyline(points, Color(.25,.38,.32,.65), 1.5, true)
	for t in [0.0, .5, 1.0]:
		var p = Vector2(size.x * (.12 + .76 * t), size.y * (.76 - sin(t * PI) * .20))
		draw_circle(p, 4, Color("587969"))
	if active:
		var p = Vector2(size.x * (.12 + .76 * progress), size.y * (.76 - sin(progress * PI) * .20))
		draw_circle(p, 9, Color("f5f0e2"))
		draw_circle(p, 6, Color("9c513a"))
		if method_texture:
			draw_texture_rect(method_texture, Rect2(p - Vector2(16, 42), Vector2(32, 32)), false)
