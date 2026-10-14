extends Control

var stars: Array[Dictionary] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in 90:
		stars.append({
			"x": rng.randf(),
			"y": rng.randf(),
			"r": rng.randf_range(0.6, 2.2),
			"s": rng.randf_range(0.6, 2.8),
			"p": rng.randf_range(0.0, TAU),
			"c": Color(0.85, 0.92, 1.0, rng.randf_range(0.25, 0.85))
		})

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var t := Time.get_ticks_msec() * 0.001
	var sz := size
	for star in stars:
		var a := 0.35 + 0.65 * (0.5 + 0.5 * sin(t * star.s + star.p))
		draw_circle(Vector2(star.x * sz.x, star.y * sz.y), star.r, Color(star.c.r, star.c.g, star.c.b, star.c.a * a))
