extends Area2D

# ═══════════════════════════════════════════════════════════════
# Exit Rocket — The rocket parked at the far end of each planet.
# Astronaut must collect all mandatory resources before boarding.
# Triggers the takeoff sequence and returns to space travel.
# ═══════════════════════════════════════════════════════════════

signal boarding_started()
signal takeoff_complete()

var is_active: bool = true
var is_boarding: bool = false
var is_taking_off: bool = false
var board_timer: float = 0.0
var takeoff_timer: float = 0.0
var player_nearby: bool = false
var target_astronaut: Node2D = null
var resources_required: int = 0
var resources_collected_ref: Callable  # Function to check current count

@onready var glow: PointLight2D = $GlowLight
@onready var prompt_label: Label = $PromptLabel
@onready var exhaust: CPUParticles2D = $ExhaustParticles
@onready var rocket_sprite: Sprite2D = $RocketSprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.visible = false
	_draw_rocket()

func set_resources_needed(count: int) -> void:
	resources_required = count

func _draw_rocket() -> void:
	# Rocket body
	var body_poly = Polygon2D.new()
	body_poly.color = Color(0.7, 0.75, 0.85, 0.95)
	body_poly.polygon = PackedVector2Array([
		Vector2(-16, 0), Vector2(-14, -40), Vector2(0, -65), Vector2(14, -40),
		Vector2(16, 0), Vector2(12, 20), Vector2(-12, 20)
	])
	add_child(body_poly)

	# Window
	var window = Polygon2D.new()
	window.color = Color(0.3, 0.8, 1.0, 0.7)
	window.polygon = PackedVector2Array([
		Vector2(-6, -30), Vector2(0, -38), Vector2(6, -30), Vector2(0, -22)
	])
	add_child(window)

	# Fins
	var left_fin = Polygon2D.new()
	left_fin.color = Color(0.9, 0.35, 0.2, 0.9)
	left_fin.polygon = PackedVector2Array([
		Vector2(-16, 0), Vector2(-28, 20), Vector2(-12, 20)
	])
	add_child(left_fin)

	var right_fin = Polygon2D.new()
	right_fin.color = Color(0.9, 0.35, 0.2, 0.9)
	right_fin.polygon = PackedVector2Array([
		Vector2(16, 0), Vector2(28, 20), Vector2(12, 20)
	])
	add_child(right_fin)

	# Base
	var base = Line2D.new()
	base.points = PackedVector2Array([Vector2(-14, 20), Vector2(14, 20)])
	base.default_color = Color(0.5, 0.5, 0.6)
	base.width = 3.0
	add_child(base)

func _process(delta: float) -> void:
	# Boarding animation
	if is_boarding:
		board_timer += delta
		if target_astronaut and is_instance_valid(target_astronaut):
			# Pull astronaut into rocket
			target_astronaut.global_position = target_astronaut.global_position.lerp(
				global_position + Vector2(0, -20), 4.0 * delta
			)
			if "velocity" in target_astronaut:
				target_astronaut.velocity = Vector2.ZERO
			# Shrink astronaut as they enter
			target_astronaut.scale = target_astronaut.scale.lerp(Vector2(0.3, 0.3), 3.0 * delta)

		if board_timer >= 1.5:
			is_boarding = false
			is_taking_off = true
			takeoff_timer = 0.0
			if target_astronaut and is_instance_valid(target_astronaut):
				target_astronaut.visible = false
			_start_takeoff()
		return

	# Takeoff animation
	if is_taking_off:
		takeoff_timer += delta
		exhaust.emitting = true

		# Shake during ignition
		if takeoff_timer < 1.0:
			position.x += sin(takeoff_timer * 40.0) * 2.0
		# Lift off
		elif takeoff_timer < 3.5:
			position.y -= (takeoff_timer - 1.0) * 250.0 * delta
			# Camera shake intensity increases
		else:
			is_taking_off = false
			takeoff_complete.emit()
		return

	# Idle glow pulse
	if glow:
		var pulse = 0.8 + sin(Time.get_ticks_msec() * 0.003) * 0.3
		glow.energy = pulse

	# Prompt display
	if player_nearby and is_active:
		var astronaut_has_all = false
		if target_astronaut and is_instance_valid(target_astronaut) and target_astronaut.has_method("collect_resource"):
			astronaut_has_all = target_astronaut.has_all_resources

		if astronaut_has_all:
			prompt_label.text = "ROCKET READY!\n[PRESS E TO BOARD]"
			prompt_label.modulate = Color(0.3, 1.0, 0.6)
		else:
			var collected = 0
			if target_astronaut and is_instance_valid(target_astronaut):
				collected = target_astronaut.resources_collected
			prompt_label.text = "COLLECT ALL RESOURCES FIRST\n" + str(collected) + " / " + str(resources_required)
			prompt_label.modulate = Color(1.0, 0.5, 0.3)

		# Board on interaction (only if all resources collected)
		if astronaut_has_all:
			if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("move_up"):
				_start_boarding()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("astronaut") and is_active:
		player_nearby = true
		target_astronaut = body
		prompt_label.visible = true
		SoundManager.play("gate_open", 0.05)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("astronaut"):
		player_nearby = false
		prompt_label.visible = false

func _start_boarding() -> void:
	is_boarding = true
	is_active = false
	board_timer = 0.0
	prompt_label.visible = false
	boarding_started.emit()
	SoundManager.play("portal", 0.05)
	GameState.show_toast("BOARDING ROCKET", "Preparing for launch...", 2.5)

func _start_takeoff() -> void:
	SoundManager.play("boost", 0.1)
	GameState.show_toast("LIFTOFF!", "Returning to orbit...", 3.0)
