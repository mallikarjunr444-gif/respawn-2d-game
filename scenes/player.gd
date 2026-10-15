extends CharacterBody2D

# ═══════════════════════════════════════════════════════════════
# SPACE ODYSSEY — Astronaut with Rocket Booster
# Free-flight movement with directional thrust, fuel consumption,
# momentum-based physics, and visible rocket exhaust.
# ═══════════════════════════════════════════════════════════════

signal health_updated(hp: int, max_hp: int)
signal died(reason: String)

# ── Flight Physics ──
@export var thrust_force: float = 750.0
@export var boost_force: float = 1400.0
@export var max_speed: float = 680.0
@export var rotation_speed: float = 4.5
@export var brake_deceleration: float = 300.0

var facing_dir: float = 1.0
var facing_angle: float = 0.0  # Radians, 0 = right
var is_thrusting: bool = false
var is_boosting: bool = false
var boost_cooldown: float = 0.0
var boost_duration: float = 0.0
const BOOST_MAX_DURATION: float = 0.4
const BOOST_COOLDOWN_TIME: float = 1.5
const BOOST_FUEL_COST: float = 8.0

# ── Damage ──
var invulnerable_timer: float = 0.0
var attack_cooldown: float = 0.0
var shoot_cooldown: float = 0.0
var shield_active_timer: float = 0.0
var lance_charge_time: float = 0.0

# ── Level physics (set by game.gd per level) ──
var level_gravity: Vector2 = Vector2(0, 400.0)
var level_wind: Vector2 = Vector2.ZERO
var level_drag: float = 0.02
var level_bounds: Rect2 = Rect2(0, 0, 8000, 5000)

# ── References ──
@onready var sprite: Sprite2D = $Sprite2D
@onready var rocket_sprite: Sprite2D = $RocketSprite
@onready var ship_sprite: Sprite2D = $ShipSprite
@onready var exhaust_particles: CPUParticles2D = $ExhaustParticles
@onready var boost_particles: CPUParticles2D = $BoostParticles
@onready var visor_light: PointLight2D = $VisorLight
@onready var sword_area: Area2D = $SwordArea
@onready var sword_arc: Polygon2D = $SwordArea/SwordArc
@onready var shield_bubble: Area2D = $ShieldBubble

var is_space_mode: bool = false
var blaster_scene: PackedScene = preload("res://scenes/projectiles/blaster_bolt.tscn")
var lance_scene: PackedScene = preload("res://scenes/projectiles/gravity_lance.tscn")

func _ready() -> void:
	add_to_group("player")
	sword_area.monitoring = false
	sword_arc.visible = false
	shield_bubble.monitoring = false
	shield_bubble.visible = false
	_update_character_appearance()

func set_space_vehicle_mode(in_space: bool) -> void:
	is_space_mode = in_space
	if ship_sprite:
		ship_sprite.visible = in_space
	if sprite:
		sprite.visible = not in_space
	if rocket_sprite:
		rocket_sprite.visible = not in_space

func _update_character_appearance() -> void:
	if GameState.selected_character == "mira":
		sprite.texture = load("res://assets/characters/mira_female.svg")
	else:
		sprite.texture = load("res://assets/characters/arin_male.svg")

func _physics_process(delta: float) -> void:
	# ── Timers ──
	boost_cooldown -= delta
	attack_cooldown -= delta
	shoot_cooldown -= delta

	if invulnerable_timer > 0.0:
		invulnerable_timer -= delta
		sprite.modulate.a = 0.4 if fmod(invulnerable_timer * 12.0, 1.0) > 0.5 else 1.0
	else:
		sprite.modulate.a = 1.0

	# Shield timer
	if shield_active_timer > 0.0:
		shield_active_timer -= delta
		shield_bubble.visible = true
		shield_bubble.monitoring = true
		if shield_active_timer <= 0.0:
			shield_bubble.visible = false
			shield_bubble.monitoring = false

	# ── Directional Steering & Rotation (Left/Right or A/D) ──
	var steer_input = 0.0
	if Input.is_action_pressed("move_left"):
		steer_input -= 1.0
	if Input.is_action_pressed("move_right"):
		steer_input += 1.0

	# Steer or rotate the rocket smoothly
	if steer_input != 0.0:
		facing_angle += steer_input * rotation_speed * delta
		facing_dir = signf(cos(facing_angle))
		if facing_dir == 0.0:
			facing_dir = 1.0

	# Rotate astronaut and rocket to point in facing flight direction
	# In Sprite2D space, head is at -Y and feet/rocket are at +Y, so +PI/2 aligns facing_angle 0 with +X
	rotation = lerp_angle(rotation, facing_angle + PI * 0.5, 12.0 * delta)

	# ── Forward Thrust (Up Arrow / W / Space) ──
	var is_forward_pressed = Input.is_action_pressed("move_up")
	var is_space_pressed = Input.is_action_pressed("thrust")
	var is_brake_pressed = Input.is_action_pressed("move_down")

	var want_thrust = is_forward_pressed or is_space_pressed
	var has_fuel = not GameState.is_fuel_empty()

	if want_thrust:
		var thrust_dir = Vector2.from_angle(facing_angle)
		var thrust_power = thrust_force * GameState.get_thrust_multiplier()

		if has_fuel:
			velocity += thrust_dir * (thrust_power * delta)
			GameState.consume_fuel(GameState.FUEL_CONSUMPTION_RATE * delta)
			exhaust_particles.emitting = true
			if is_space_mode:
				ship_sprite.modulate = Color(1.3, 1.2, 1.0, 1.0)
			else:
				rocket_sprite.modulate = Color(1.5, 1.2, 0.8, 1.0)
			visor_light.energy = 2.0
		else:
			# Emergency solar glide: low-power reserve thrust so astronaut is NEVER permanently stranded
			velocity += thrust_dir * (thrust_power * 0.45 * delta)
			exhaust_particles.emitting = true
			if is_space_mode:
				ship_sprite.modulate = Color(0.7, 1.1, 1.3, 0.9)
			else:
				rocket_sprite.modulate = Color(0.6, 1.0, 1.2, 0.8)
			visor_light.energy = 1.2

		is_thrusting = true
	else:
		is_thrusting = false
		exhaust_particles.emitting = false
		if is_space_mode:
			ship_sprite.modulate = Color.WHITE
		else:
			rocket_sprite.modulate = Color(0.8, 0.8, 0.9, 1.0)
		visor_light.energy = 1.0

	# ── Braking / Reverse (Down Arrow / S) ──
	if is_brake_pressed:
		velocity = velocity.move_toward(Vector2.ZERO, brake_deceleration * 2.5 * delta)
		var reverse_dir = -Vector2.from_angle(facing_angle)
		velocity += reverse_dir * (thrust_force * 0.35 * delta)

	# ── Rocket Boost (Shift) ──
	if Input.is_action_just_pressed("boost") and boost_cooldown <= 0.0:
		if has_fuel:
			is_boosting = true
			boost_duration = BOOST_MAX_DURATION
			boost_cooldown = BOOST_COOLDOWN_TIME
			GameState.consume_fuel(BOOST_FUEL_COST)
			SoundManager.play("boost", 0.1)
			invulnerable_timer = maxf(invulnerable_timer, 0.45)

	if boost_duration > 0.0:
		boost_duration -= delta
		var boost_dir = Vector2.from_angle(facing_angle)
		velocity += boost_dir * (boost_force * delta)
		boost_particles.emitting = true
	else:
		boost_particles.emitting = false

	# ── Environmental Forces ──
	# Gravity
	velocity += level_gravity * delta

	# Wind
	velocity += level_wind * delta

	# Space momentum drag / friction
	velocity *= (1.0 - level_drag * delta * 60.0)

	# Speed limits
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Natural glide friction when no thrust is applied
	if not want_thrust and not is_brake_pressed and boost_duration <= 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, (brake_deceleration * 0.15) * delta)

	# ── Weapons ──
	# Melee Attack (Energy Sword)
	if Input.is_action_just_pressed("attack") and GameState.has_sword and attack_cooldown <= 0.0:
		_perform_sword_slash()

	# Shoot / Charge Lance
	if GameState.has_blaster or GameState.has_lance:
		if Input.is_action_pressed("shoot"):
			lance_charge_time += delta
		elif Input.is_action_just_released("shoot"):
			if lance_charge_time >= 0.6 and GameState.has_lance:
				_fire_gravity_lance()
			elif GameState.has_blaster and shoot_cooldown <= 0.0:
				_fire_plasma_blaster()
			lance_charge_time = 0.0

	# Phase Shield
	if Input.is_action_just_pressed("shield") and GameState.consume_shield_charge():
		shield_active_timer = 1.8
		SoundManager.play("shield", 0.05)

	# ── Move ──
	move_and_slide()

	# Constrain astronaut safely within level bounds to avoid getting lost outside camera
	var min_x = level_bounds.position.x + 40.0
	var max_x = level_bounds.position.x + level_bounds.size.x - 40.0
	var min_y = level_bounds.position.y + 40.0
	var max_y = level_bounds.position.y + level_bounds.size.y - 40.0

	if position.x < min_x:
		position.x = min_x
		if velocity.x < 0.0: velocity.x = 0.0
	elif position.x > max_x:
		position.x = max_x
		if velocity.x > 0.0: velocity.x = 0.0

	if position.y < min_y:
		position.y = min_y
		if velocity.y < 0.0: velocity.y = 0.0
	elif position.y > max_y:
		position.y = max_y
		if velocity.y > 0.0: velocity.y = -30.0


# ═══════════════════════════════════════════════════════════════
# COMBAT
# ═══════════════════════════════════════════════════════════════

func _perform_sword_slash() -> void:
	attack_cooldown = 0.35
	sword_area.monitoring = true
	sword_arc.visible = true
	SoundManager.play("swing", 0.1)

	var overlapping = sword_area.get_overlapping_areas() + sword_area.get_overlapping_bodies()
	for obj in overlapping:
		if obj.has_method("take_damage"):
			obj.take_damage(2)
		elif obj.is_in_group("enemy_projectiles"):
			obj.queue_free()

	await get_tree().create_timer(0.18).timeout
	sword_area.monitoring = false
	sword_arc.visible = false

func _fire_plasma_blaster() -> void:
	shoot_cooldown = 0.22
	var bolt = blaster_scene.instantiate()
	bolt.direction = facing_dir
	bolt.global_position = global_position + Vector2(facing_dir * 28.0, -12.0)
	get_parent().add_child(bolt)
	SoundManager.play("shoot", 0.1)

func _fire_gravity_lance() -> void:
	var lance = lance_scene.instantiate()
	lance.direction = facing_dir
	lance.global_position = global_position + Vector2(facing_dir * 36.0, -12.0)
	get_parent().add_child(lance)
	SoundManager.play("lance", 0.1)

# ═══════════════════════════════════════════════════════════════
# DAMAGE
# ═══════════════════════════════════════════════════════════════

func take_damage(amount: int, reason: String = "COLLISION") -> void:
	if invulnerable_timer > 0.0 or boost_duration > 0.0 or shield_active_timer > 0.0:
		return
	invulnerable_timer = 1.2

	# Knockback in opposite direction of velocity
	if velocity.length() > 10.0:
		velocity = -velocity.normalized() * 280.0
	else:
		velocity = Vector2(0, -200.0)

	if GameState.damage_player(amount, reason):
		died.emit(reason)

func _on_sword_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(2)
	elif area.is_in_group("enemy_projectiles"):
		area.queue_free()

# ═══════════════════════════════════════════════════════════════
# EXTERNAL FORCE (used by black hole, wind zones, etc.)
# ═══════════════════════════════════════════════════════════════

func apply_external_force(force: Vector2) -> void:
	velocity += force
