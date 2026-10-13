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
var min_fuel_pct: float = 15.0
var required_cells: int = 0
var player_nearby: bool = false
var target_player: Node2D = null

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

func set_required_cells(count: int) -> void:
	required_cells = maxi(count, 0)

func _process(delta: float) -> void:
	if is_launching:
		launch_timer += delta
		if target_player and is_instance_valid(target_player):
			target_player.global_position = target_player.global_position.lerp(global_position, 5.0 * delta)
			if "velocity" in target_player:
				target_player.velocity = target_player.velocity * 0.88
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
		var has_fuel = fuel_pct >= min_fuel_pct
		var has_resources = GameState.fuel_cells_collected >= required_cells
		if has_fuel and has_resources:
			prompt_label.text = "ROCKET READY\n[PRESS E OR ENTER TO BOARD]"
			prompt_label.modulate = Color(0.3, 1.0, 0.8)
		elif not has_resources:
			prompt_label.text = "MISSION RESOURCES REQUIRED\nCells: " + str(GameState.fuel_cells_collected) + "/" + str(required_cells)
			prompt_label.modulate = Color(1.0, 0.8, 0.25)
		else:
			prompt_label.text = "NEED " + str(int(min_fuel_pct)) + "% FUEL TO LAUNCH\nCurrent: " + str(int(fuel_pct)) + "%"
			prompt_label.modulate = Color(1.0, 0.4, 0.3)

		# Auto-trigger if close to center, or on key press
		var dist_to_center = 999.0
		if target_player and is_instance_valid(target_player):
			dist_to_center = (target_player.global_position - global_position).length()

		var key_pressed = Input.is_action_just_pressed("interact") or Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_ENTER)
		if has_fuel and has_resources and (key_pressed or dist_to_center < 55.0):
			_trigger_launch()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_active:
		player_nearby = true
		target_player = body
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
	var next_idx = GameState.current_world_idx + 1
	var destination = "ORVEX hangar"
	if next_idx < LevelData.get_planet_count():
		var next_info = LevelData.get_world_info(next_idx)
		destination = next_info.get("name", "deep space")
	GameState.show_toast("BOARDING COMPLETE", "Ignition burn toward " + destination, 3.0)

	# Dramatic scale-up
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 1.5).set_ease(Tween.EASE_OUT)
