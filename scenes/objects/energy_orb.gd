extends Area2D

# ═══════════════════════════════════════════════════════════════
# Energy Orb — High-value fuel collectible found on bonus routes.
# Larger, brighter, and worth significantly more fuel.
# ═══════════════════════════════════════════════════════════════

var time_offset: float = 0.0
var collected: bool = false
var orbit_angle: float = 0.0

@onready var glow: PointLight2D = $GlowLight
@onready var particles: CPUParticles2D = $OrbParticles

func _ready() -> void:
	time_offset = randf() * TAU
	orbit_angle = randf() * TAU
	body_entered.connect(_on_body_entered)
	_draw_orb()

func _draw_orb() -> void:
	# Outer ring
	var ring = Line2D.new()
	var ring_points: PackedVector2Array = []
	for i in range(24):
		var angle = TAU * float(i) / 24.0
		ring_points.append(Vector2(cos(angle) * 20.0, sin(angle) * 20.0))
	ring_points.append(ring_points[0])  # Close the loop
	ring.points = ring_points
	ring.default_color = Color(1.0, 0.85, 0.2, 0.8)
	ring.width = 2.5
	add_child(ring)

	# Inner orb
	var inner_ring = Line2D.new()
	var inner_points: PackedVector2Array = []
	for i in range(16):
		var angle = TAU * float(i) / 16.0
		inner_points.append(Vector2(cos(angle) * 10.0, sin(angle) * 10.0))
	inner_points.append(inner_points[0])
	inner_ring.points = inner_points
	inner_ring.default_color = Color(1.0, 0.95, 0.4, 1.0)
	inner_ring.width = 3.0
	add_child(inner_ring)

func _process(delta: float) -> void:
	if collected:
		return
	# Orbital rotation
	orbit_angle += delta * 1.5
	# Pulse glow
	if glow:
		glow.energy = 1.5 + sin(Time.get_ticks_msec() * 0.004 + time_offset) * 0.6
	rotation = orbit_angle * 0.3

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not collected:
		collected = true
		GameState.add_fuel(GameState.ENERGY_ORB_VALUE)
		GameState.add_orb_score()
		GameState.show_toast("ENERGY ORB", "+25 FUEL", 2.0)
		SoundManager.play("portal", 0.05)
		if particles:
			particles.emitting = true
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0.01, 0.01), 0.2)
		tween.tween_callback(queue_free)
