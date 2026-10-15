extends CharacterBody2D

# ═══════════════════════════════════════════════════════════════
# Surface Astronaut — Platformer character for planet surfaces.
# Walks, jumps, collects resources, affected by planet-specific
# environmental effects (wind, ice friction, gravity, toxic).
# ═══════════════════════════════════════════════════════════════

signal resource_collected(collected: int, total: int)
signal astronaut_died(reason: String)
signal reached_rocket()

# ── Movement ──
@export var walk_speed: float = 220.0
@export var run_speed: float = 340.0
@export var jump_force: float = 520.0
@export var base_gravity: float = 980.0

var gravity_mult: float = 1.0
var friction: float = 0.9
var wind_force: Vector2 = Vector2.ZERO
var wind_variance: float = 0.0
var oxygen_drain: float = 0.0
var surface_width: float = 4000.0
var surface_floor_y: float = 0.0

var facing_dir: float = 1.0
var is_on_ice: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
const COYOTE_TIME: float = 0.12
const JUMP_BUFFER_TIME: float = 0.1

# ── Health / Suit ──
var hp: int = 5
var max_hp: int = 5
var suit_integrity: float = 100.0  # Oxygen / suit protection
var invulnerable_timer: float = 0.0
var shield_active_timer: float = 0.0

# ── Resources ──
var resources_collected: int = 0
var resources_required: int = 0
var has_all_resources: bool = false

# ── Environmental ──
var env_effects: Array = []
var wind_timer: float = 0.0  # For variable wind gusts

# ── Refs ──
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visor_light: PointLight2D = $VisorLight
@onready var dust_particles: CPUParticles2D = $DustParticles

func _ready() -> void:
	add_to_group("astronaut")
	add_to_group("player")
	_update_character_appearance()

func _update_character_appearance() -> void:
	if GameState.selected_character == "mira":
		sprite.texture = load("res://assets/characters/mira_female.svg")
	else:
		sprite.texture = load("res://assets/characters/arin_male.svg")

func configure(config: Dictionary) -> void:
	gravity_mult = config.get("gravity_mult", 1.0)
	friction = config.get("friction", 0.9)
	wind_force = config.get("wind_force", Vector2.ZERO)
	wind_variance = config.get("wind_variance", 0.0)
	oxygen_drain = config.get("oxygen_drain", 0.0)
	env_effects = config.get("env_effects", [])
	resources_required = config.get("mandatory_count", 5)
	resources_collected = 0
	has_all_resources = false

func _physics_process(delta: float) -> void:
	# ── Timers ──
	if shield_active_timer > 0.0:
		shield_active_timer = maxf(shield_active_timer - delta, 0.0)
	if Input.is_action_just_pressed("shield") and GameState.consume_shield_charge():
		shield_active_timer = 1.8
		SoundManager.play("shield", 0.05)

	if shield_active_timer > 0.0:
		sprite.modulate = Color(0.3, 0.9, 1.0, 0.85)
	elif invulnerable_timer > 0.0:
		invulnerable_timer -= delta
		sprite.modulate.a = 0.4 if fmod(invulnerable_timer * 10.0, 1.0) > 0.5 else 1.0
	else:
		sprite.modulate.a = 1.0

	# ── Gravity (planet-specific) ──
	if not is_on_floor():
		velocity.y += base_gravity * gravity_mult * delta
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME

	jump_buffer_timer -= delta

	# ── Horizontal Movement ──
	var input_dir := 0.0
	if Input.is_action_pressed("move_left"):
		input_dir -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir += 1.0

	var is_running = Input.is_action_pressed("boost")
	var target_speed = run_speed if is_running else walk_speed

	if input_dir != 0.0:
		facing_dir = input_dir
		sprite.flip_h = input_dir < 0.0

		# Ice friction: much slower acceleration
		if _has_effect(PlanetConfig.EnvEffect.ICE):
			velocity.x = lerpf(velocity.x, input_dir * target_speed, friction * 0.3 * delta * 10.0)
		else:
			velocity.x = lerpf(velocity.x, input_dir * target_speed, friction * delta * 10.0)

		# Footstep dust particles
		if is_on_floor() and dust_particles:
			dust_particles.emitting = true
	else:
		# Deceleration (ice = slide further)
		if _has_effect(PlanetConfig.EnvEffect.ICE):
			velocity.x = lerpf(velocity.x, 0.0, friction * 0.15 * delta * 10.0)
		else:
			velocity.x = lerpf(velocity.x, 0.0, friction * delta * 10.0)

		if dust_particles:
			dust_particles.emitting = false

	# ── Jump ──
	if Input.is_action_just_pressed("thrust") or Input.is_action_just_pressed("move_up"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		var effective_jump = jump_force
		# Low gravity = higher jumps
		if _has_effect(PlanetConfig.EnvEffect.LOW_GRAVITY):
			effective_jump *= 1.3
		# High gravity = weaker jumps
		elif _has_effect(PlanetConfig.EnvEffect.HIGH_GRAVITY):
			effective_jump *= 0.7

		velocity.y = -effective_jump
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		SoundManager.play("boost", 0.05)

	# Variable height jump (release early = lower jump)
	if (Input.is_action_just_released("thrust") or Input.is_action_just_released("move_up")) and velocity.y < 0.0:
		velocity.y *= 0.5

	# ── Mid-Air Space EVA Jetpack Propulsion ──
	if not is_on_floor() and (Input.is_action_pressed("thrust") or Input.is_action_pressed("move_up")):
		var thruster_accel = 640.0
		if _has_effect(PlanetConfig.EnvEffect.LOW_GRAVITY):
			thruster_accel = 820.0
		velocity.y -= thruster_accel * delta
		if dust_particles:
			dust_particles.emitting = true

	# ── Wind ──
	if wind_force.length() > 0.0:
		wind_timer += delta
		var gust = wind_force + Vector2(
			sin(wind_timer * 2.0) * wind_variance,
			cos(wind_timer * 1.5) * wind_variance * 0.3
		)
		velocity += gust * delta

	# ── Toxic / Oxygen Drain ──
	if oxygen_drain > 0.0 and _has_effect(PlanetConfig.EnvEffect.TOXIC):
		suit_integrity -= oxygen_drain * delta
		suit_integrity = maxf(suit_integrity, 0.0)
		if suit_integrity <= 0.0:
			take_damage(1, "SUIT BREACH — TOXIC EXPOSURE")
			suit_integrity = 15.0  # Brief respite

	# ── Speed limit ──
	velocity.x = clampf(velocity.x, -600.0, 600.0)
	velocity.y = clampf(velocity.y, -900.0, 1200.0)

	# ── Move ──
	move_and_slide()
	if position.x < -100.0 or position.x > surface_width + 100.0 or position.y > surface_floor_y + 500.0:
		take_damage(99, "LOST BEYOND THE SURFACE")
		return

	# ── Visor light pulse ──
	if visor_light:
		visor_light.energy = 1.2 + sin(Time.get_ticks_msec() * 0.003) * 0.3

func _has_effect(effect: PlanetConfig.EnvEffect) -> bool:
	return env_effects.has(effect)

func apply_external_force(force: Vector2) -> void:
	velocity += force

# ═══════════════════════════════════════════════════════════════
# RESOURCE COLLECTION
# ═══════════════════════════════════════════════════════════════

func collect_resource() -> void:
	resources_collected += 1
	has_all_resources = resources_collected >= resources_required
	resource_collected.emit(resources_collected, resources_required)
	GameState.add_fuel_cell_score()
	GameState.add_score(15)
	SoundManager.play("gem", 0.1)

	if has_all_resources:
		GameState.show_toast("ALL RESOURCES COLLECTED!", "Return to the rocket to depart.", 4.0)
		SoundManager.play("upgrade", 0.05)

# ═══════════════════════════════════════════════════════════════
# DAMAGE
# ═══════════════════════════════════════════════════════════════

func take_damage(amount: int, reason: String = "HAZARD") -> void:
	if invulnerable_timer > 0.0 or shield_active_timer > 0.0:
		return
	invulnerable_timer = 1.5
	hp -= amount
	hp = maxi(hp, 0)

	# Knockback
	velocity = Vector2(-facing_dir * 200.0, -250.0)

	GameState.damage_player(amount, reason)
	SoundManager.play("hit", 0.1)

	if hp <= 0:
		astronaut_died.emit(reason)

func heal(amount: int = 1) -> void:
	hp = mini(hp + amount, max_hp)
	GameState.heal_player(amount)

# ═══════════════════════════════════════════════════════════════
# EXTERNAL FORCE (used by surface wind zones, hazards)
# ═══════════════════════════════════════════════════════════════

func apply_external_force(force: Vector2) -> void:
	velocity += force
