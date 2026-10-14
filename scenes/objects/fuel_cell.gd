extends Area2D

# ═══════════════════════════════════════════════════════════════
# Fuel Cell — Collectible that refills the astronaut's fuel.
# Floats with a gentle bob and glows. Drawn procedurally.
# ═══════════════════════════════════════════════════════════════

var time_offset: float = 0.0
var collected: bool = false

@onready var glow: PointLight2D = $GlowLight
@onready var particles: CPUParticles2D = $SparkleParticles

func _ready() -> void:
	time_offset = randf() * TAU
	body_entered.connect(_on_body_entered)
	# Draw the fuel cell shape
	_draw_fuel_cell()

func _draw_fuel_cell() -> void:
	# Create diamond-shaped fuel cell
	var poly = Polygon2D.new()
	poly.color = Color(0.2, 0.9, 0.4, 0.9)
	poly.polygon = PackedVector2Array([
		Vector2(0, -14), Vector2(10, 0), Vector2(0, 14), Vector2(-10, 0)
	])
	add_child(poly)

	# Inner glow
	var inner = Polygon2D.new()
	inner.color = Color(0.4, 1.0, 0.6, 0.5)
	inner.polygon = PackedVector2Array([
		Vector2(0, -8), Vector2(6, 0), Vector2(0, 8), Vector2(-6, 0)
	])
	add_child(inner)

	# Outline
	var outline = Line2D.new()
	outline.points = PackedVector2Array([
		Vector2(0, -14), Vector2(10, 0), Vector2(0, 14), Vector2(-10, 0), Vector2(0, -14)
	])
	outline.default_color = Color(0.3, 1.0, 0.5, 1.0)
	outline.width = 2.0
	add_child(outline)

func _process(delta: float) -> void:
	if collected:
		return
	# Gentle floating bob
	var bob = sin(Time.get_ticks_msec() * 0.003 + time_offset) * 6.0
	position.y += bob * 0.02

	# Magnetic collector attraction to player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		if is_instance_valid(p):
			var d_vec = p.global_position - global_position
			var dist = d_vec.length()
			if dist < 160.0 and dist > 0.0:
				global_position += d_vec.normalized() * (280.0 * delta)

	# Pulse the glow
	if glow:
		glow.energy = 0.8 + sin(Time.get_ticks_msec() * 0.005 + time_offset) * 0.4

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not collected:
		collected = true
		GameState.add_fuel(GameState.FUEL_CELL_VALUE)
		GameState.add_fuel_cell_score()
		if particles:
			particles.emitting = true
		# Quick scale-down animation
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0.01, 0.01), 0.15)
		tween.tween_callback(queue_free)
