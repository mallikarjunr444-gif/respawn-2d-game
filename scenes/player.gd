extends CharacterBody2D

# ═══════════════════════════════════════════════════════════════
# SPACE ODYSSEY — Astronaut with Rocket Booster
# Free-flight movement with directional thrust, fuel consumption,
# momentum-based physics, and visible rocket exhaust.
# ═══════════════════════════════════════════════════════════════

signal health_updated(hp: int, max_hp: int)
signal died(reason: String)

# ── Flight Physics ──
@export var thrust_force: float = 650.0
@export var boost_force: float = 1200.0
@export var max_speed: float = 520.0
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
var shield_cooldown: float = 0.0
var lance_charge_time: float = 0.0

# ── Level physics (set by game.gd per level) ──
var level_gravity: Vector2 = Vector2(0, 400.0)
var level_wind: Vector2 = Vector2.ZERO
var level_drag: float = 0.02

# ── References ──
@onready var sprite: Sprite2D = $Sprite2D
@onready var rocket_sprite: Sprite2D = $RocketSprite
@onready var exhaust_particles: CPUParticles2D = $ExhaustParticles
@onready var boost_particles: CPUParticles2D = $BoostParticles
@onready var visor_light: PointLight2D = $VisorLight
@onready var sword_area: Area2D = $SwordArea
@onready var sword_arc: Polygon2D = $SwordArea/SwordArc
@onready var shield_bubble: Area2D = $ShieldBubble

var blaster_scene: PackedScene = preload("res://scenes/projectiles/blaster_bolt.tscn")
var lance_scene: PackedScene = preload("res://scenes/projectiles/gravity_lance.tscn")

func _ready() -> void:
	add_to_group("player")
	sword_area.monitoring = false
	sword_arc.visible = false
	shield_bubble.monitoring = false
	shield_bubble.visible = false
	_update_character_appearance()

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
	shield_cooldown -= delta

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

	# ── Directional Input ──
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	# Update facing direction for sprite flipping
	if input_dir.x != 0.0:
		facing_dir = signf(input_dir.x)
		sprite.flip_h = facing_dir < 0.0
		rocket_sprite.flip_h = facing_dir < 0.0

	# Calculate facing angle from input
	if input_dir.length_squared() > 0.01:
		var target_angle = input_dir.angle()
		facing_angle = lerp_angle(facing_angle, target_angle, rotation_speed * delta)

	# ── Thrust ──
	is_thrusting = Input.is_action_pressed("thrust") and not GameState.is_fuel_empty()
	is_boosting = false

	if is_thrusting:
		var thrust_dir: Vector2
		if input_dir.length_squared() > 0.01:
			thrust_dir = input_dir.normalized()
		else:
			thrust_dir = Vector2(facing_dir, 0.0)

		var effective_thrust = thrust_force * GameState.get_thrust_multiplier()
		velocity += thrust_dir * effective_thrust * delta

		# Fuel consumption
		GameState.consume_fuel(GameState.FUEL_CONSUMPTION_RATE * delta)

		# Exhaust visuals
		exhaust_particles.emitting = true
		# Point exhaust opposite to thrust direction
		exhaust_particles.direction = -thrust_dir
		exhaust_particles.rotation = thrust_dir.angle()

		# Rocket glow
		rocket_sprite.modulate = Color(1.5, 1.2, 0.8, 1.0)
		visor_light.energy = 2.0
	else:
		exhaust_particles.emitting = false
		rocket_sprite.modulate = Color(0.8, 0.8, 0.9, 1.0)
		visor_light.energy = 1.0

	# ── Boost ──
	if Input.is_action_just_pressed("boost") and boost_cooldown <= 0.0 and not GameState.is_fuel_empty():
		is_boosting = true
		boost_duration = BOOST_MAX_DURATION
		boost_cooldown = BOOST_COOLDOWN_TIME
		GameState.consume_fuel(BOOST_FUEL_COST)
		SoundManager.play("boost", 0.1)
		invulnerable_timer = maxf(invulnerable_timer, 0.3)

	if boost_duration > 0.0:
		boost_duration -= delta
		var boost_dir: Vector2
		if input_dir.length_squared() > 0.01:
			boost_dir = input_dir.normalized()
		else:
			boost_dir = Vector2(facing_dir, 0.0)
		velocity += boost_dir * boost_force * delta
		boost_particles.emitting = true
	else:
		boost_particles.emitting = false

	# ── Environmental Forces ──
	# Gravity
	velocity += level_gravity * delta

	# Wind
	velocity += level_wind * delta

	# Drag (air resistance / space friction for gameplay)
	velocity *= (1.0 - level_drag)

	# Speed cap
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# ── Braking (no input + no thrust = gentle deceleration) ──
	if input_dir.length_squared() < 0.01 and not is_thrusting:
		velocity = velocity.move_toward(Vector2.ZERO, brake_deceleration * delta)

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
	if Input.is_action_just_pressed("shield") and GameState.has_shield and shield_cooldown <= 0.0:
		shield_active_timer = 1.8
		shield_cooldown = 5.5
		SoundManager.play("shield", 0.05)

	# ── Move ──
	move_and_slide()

	# ── Rotate rocket sprite to face velocity direction ──
	if velocity.length() > 30.0:
		var vel_angle = velocity.angle()
		rocket_sprite.rotation = lerp_angle(rocket_sprite.rotation, vel_angle, 6.0 * delta)

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
