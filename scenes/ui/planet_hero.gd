extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var c := size * 0.5
	var radius := minf(size.x, size.y) * 0.22

	for i in 5:
		var rad := fmod(t * 28.0 + i * 34.0, radius * 4.4)
		var alpha := maxf(0.0, 0.18 * (1.0 - rad / (radius * 4.4)))
		draw_arc(c, rad, 0.0, TAU, 64, Color(0.24, 0.94, 1.0, alpha), 1.4 + i * 0.25, true)

	var glow := radius * 1.85
	for i in 10:
		var k := float(i) / 10.0
		draw_circle(c, lerp(radius, glow, k), Color(0.55, 0.28, 0.95, 0.045 * (1.0 - k)))

	var ring_cols := [
		Color(1.0, 1.0, 1.0, 0.9),
		Color(0.24, 0.94, 1.0, 0.85),
		Color(1.0, 0.37, 0.82, 0.8),
		Color(1.0, 0.85, 0.28, 0.78),
		Color(1.0, 0.48, 0.18, 0.7)
	]
	for i in ring_cols.size():
		var rx := radius * (1.55 + i * 0.22)
		var ry := radius * (0.38 + i * 0.05)
		_draw_ring(c, rx, ry, -0.42 + sin(t * 0.2) * 0.04, ring_cols[i], 3.0 - i * 0.25)

	draw_circle(c, radius + 6.0, Color(0.7, 0.45, 1.0, 0.22))
	draw_circle(c, radius, Color(0.18, 0.08, 0.32, 1.0))
	draw_circle(c + Vector2(-radius * 0.28, -radius * 0.32), radius * 0.72, Color(0.62, 0.32, 0.78, 0.55))
	draw_circle(c + Vector2(-radius * 0.18, -radius * 0.22), radius * 0.28, Color(0.95, 0.82, 1.0, 0.28))
	draw_circle(c + Vector2(radius * 0.18, radius * 0.08), radius * 0.16, Color(0.08, 0.04, 0.14, 0.55))
	draw_circle(c + Vector2(-radius * 0.08, radius * 0.22), radius * 0.1, Color(0.1, 0.05, 0.16, 0.4))
	draw_arc(c, radius, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.55), 2.2, true)

func _draw_ring(center: Vector2, rx: float, ry: float, rot: float, color: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var steps := 72
	for i in steps + 1:
		var a := TAU * float(i) / float(steps)
		var p := Vector2(cos(a) * rx, sin(a) * ry).rotated(rot)
		pts.append(center + p)
	draw_polyline(pts, color, width, true)
