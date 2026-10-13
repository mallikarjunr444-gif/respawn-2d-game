extends Area2D

# ═══════════════════════════════════════════════════════════════
# Launch Gate — Level exit portal. Requires minimum fuel to use.
# Pulsing ring with particle effects. Triggers level completion.
# ═══════════════════════════════════════════════════════════════

signal gate_entered()

var is_active: bool = true
var is_launching: bool = false
var launch_timer: float = 0.0
var ring_rotation: float = 0.0
var min_fuel_pct: float = 25.0
var player_nearby: bool = false

@onready var glow: PointLight2D = $GlowLight
@onready var gate_particles: CPUParticles2D = $GateParticles
@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.visible = false
	_draw_gate()

func _draw_gate() -> void:
	# Outer ring
	var outer = Line2D.new()
	outer.name = "OuterRing"
	var points: PackedVector2Array = []
	for i in range(32):
		var angle = TAU * float(i) / 32.0
		points.append(Vector2(cos(angle) * 60.0, sin(angle) * 60.0))
	points.append(points[0])
	outer.points = points
	outer.default_color = Color(0.3, 0.9, 1.0, 0.9)
	outer.width = 4.0
	add_child(outer)

	# Inner ring
	var inner = Line2D.new()
	inner.name = "InnerRing"
	var inner_pts: PackedVector2Array = []
	for i in range(24):
		var angle = TAU * float(i) / 24.0
		inner_pts.append(Vector2(cos(angle) * 40.0, sin(angle) * 40.0))
	inner_pts.append(inner_pts[0])
	inner.points = inner_pts
	inner.default_color = Color(0.5, 1.0, 0.8, 0.6)
	inner.width = 2.5
	add_child(inner)

	# Center diamond
	var center = Polygon2D.new()
	center.color = Color(0.4, 1.0, 0.9, 0.3)
	center.polygon = PackedVector2Array([
		Vector2(0, -25), Vector2(25, 0), Vector2(0, 25), Vector2(-25, 0)
	])
	add_child(center)

func set_min_fuel(pct: float) -> void:
	min_fuel_pct = pct

func _process(delta: float) -> void:
	if is_launching:
		launch_timer += delta
		if launch_timer >= 2.0:
			is_launching = false
			GameState.complete_level()
		return

	ring_rotation += delta * 0.8
	rotation = ring_rotation * 0.2

	# Pulse glow
	if glow:
		glow.energy = 1.2 + sin(Time.get_ticks_msec() * 0.003) * 0.5

	# Check if player can launch
	if player_nearby and is_active:
		var fuel_pct = GameState.get_fuel_percentage()
		if fuel_pct >= min_fuel_pct:
			prompt_label.text = "PRESS [E] TO LAUNCH\nFuel: " + str(int(fuel_pct)) + "%"
			prompt_label.modulate = Color(0.3, 1.0, 0.8)
		else:
			prompt_label.text = "NEED " + str(int(min_fuel_pct)) + "% FUEL\nCurrent: " + str(int(fuel_pct)) + "%"
			prompt_label.modulate = Color(1.0, 0.4, 0.3)

		if Input.is_action_just_pressed("interact") and fuel_pct >= min_fuel_pct:
			_trigger_launch()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_active:
		player_nearby = true
		prompt_label.visible = true
		SoundManager.play("gate_open", 0.05)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		prompt_label.visible = false

func _trigger_launch() -> void:
	is_launching = true
	is_active = false
	prompt_label.visible = false
	gate_particles.emitting = true
	SoundManager.play("portal", 0.05)
	SoundManager.play("level_complete", 0.05)
	GameState.show_toast("LAUNCH SEQUENCE INITIATED", "Warping to next destination...", 3.0)

	# Dramatic scale-up
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 1.5).set_ease(Tween.EASE_OUT)
