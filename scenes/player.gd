extends CharacterBody2D

signal health_updated(hp: int, max_hp: int)
signal died(reason: String)

@export var move_speed: float = 380.0
@export var jump_velocity: float = -680.0
@export var gravity: float = 1900.0

var facing_dir: float = 1.0
var coyote_timer: float = 0.0
var jump_buffer: float = 0.0
var dash_timer: float = 0.0
var dash_cooldown: float = 0.0
var dash_direction: float = 1.0
var is_dashing: bool = false
var has_air_dashed: bool = false

var invulnerable_timer: float = 0.0
var attack_cooldown: float = 0.0
var shoot_cooldown: float = 0.0
var shield_active_timer: float = 0.0
var shield_cooldown: float = 0.0
var lance_charge_time: float = 0.0

var is_slippery: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var sword_arc: Polygon2D = $SwordArea/SwordArc
@onready var shield_bubble: Area2D = $ShieldBubble
@onready var thruster_particles: CPUParticles2D = $ThrusterParticles
@onready var visor_light: PointLight2D = $VisorLight

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
	# Timers
	coyote_timer -= delta
	jump_buffer -= delta
	dash_cooldown -= delta
	attack_cooldown -= delta
	shoot_cooldown -= delta
	shield_cooldown -= delta
	
	if invulnerable_timer > 0.0:
		invulnerable_timer -= delta
		# Blink effect
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

	# Dash update
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * 760.0
		velocity.y = 0.0
		move_and_slide()
		if dash_timer <= 0.0:
			is_dashing = false
		return

	# Ground check & coyote time
	if is_on_floor():
		coyote_timer = 0.12
		has_air_dashed = false
	else:
		velocity.y += gravity * delta
		velocity.y = minf(velocity.y, 950.0)

	# Movement input
	var move_input = Input.get_axis("move_left", "move_right")
	if move_input != 0.0:
		facing_dir = signf(move_input)
		sprite.flip_h = facing_dir < 0.0
		sword_area.position.x = 24.0 * facing_dir
		sword_area.scale.x = facing_dir

	# Acceleration & deceleration
	var target_vx = move_input * move_speed
	var accel = 3200.0 if is_on_floor() else 2000.0
	if is_slippery and is_on_floor():
		accel = 650.0
	velocity.x = move_toward(velocity.x, target_vx, accel * delta)

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.12

	# Execute jump
	if jump_buffer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		coyote_timer = 0.0
		jump_buffer = 0.0
		SoundManager.play("jump", 0.08)
		thruster_particles.restart()

	# Variable jump height cut
	if Input.is_action_just_released("jump") and velocity.y < -200.0:
		velocity.y *= 0.5

	# Dash
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0 and (is_on_floor() or not has_air_dashed):
		is_dashing = true
		dash_timer = 0.18
		dash_cooldown = 0.65
		dash_direction = facing_dir
		if not is_on_floor():
			has_air_dashed = true
		invulnerable_timer = maxf(invulnerable_timer, 0.22)
		SoundManager.play("dash", 0.1)

	# Melee Attack (Energy Sword)
	if Input.is_action_just_pressed("attack") and GameState.has_sword and attack_cooldown <= 0.0:
		_perform_sword_slash()

	# Shoot / Charge Lance
	if (GameState.has_blaster or GameState.has_lance):
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

	move_and_slide()

func _perform_sword_slash() -> void:
	attack_cooldown = 0.35
	sword_area.monitoring = true
	sword_arc.visible = true
	SoundManager.play("swing", 0.1)
	
	# Check overlapping enemies and barriers
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

func take_damage(amount: int, reason: String = "VOID DAMAGE") -> void:
	if invulnerable_timer > 0.0 or is_dashing or shield_active_timer > 0.0:
		return
	invulnerable_timer = 1.2
	velocity.y = -350.0
	velocity.x = -facing_dir * 260.0
	
	if GameState.damage_player(amount, reason):
		died.emit(reason)

func _on_sword_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(2)
	elif area.is_in_group("enemy_projectiles"):
		area.queue_free()
