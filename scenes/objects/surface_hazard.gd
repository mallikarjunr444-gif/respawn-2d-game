extends Area2D

# ═══════════════════════════════════════════════════════════════
# Surface Hazard Zone — Environmental danger on planet surfaces.
# Configurable for fire/lava, toxic clouds, ice patches, acid rain.
# Visually rendered per hazard type with matching particles.
# ═══════════════════════════════════════════════════════════════

enum HazardKind {
	FIRE,
	TOXIC,
	ICE_PATCH,
	ACID,
	WIND_GUST,
}

@export var hazard_kind: HazardKind = HazardKind.FIRE
@export var damage_per_tick: float = 1.0
@export var tick_interval: float = 1.5
@export var zone_width: float = 120.0
@export var zone_height: float = 40.0

var player_in_zone: Node2D = null
var damage_timer: float = 0.0
var active_timer: float = 0.0  # For timed hazards

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles: CPUParticles2D = $HazardParticles

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_configure_shape()
	_draw_hazard()

func _configure_shape() -> void:
	if collision_shape and collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size = Vector2(zone_width, zone_height)

func _draw_hazard() -> void:
	var color := Color.WHITE
	match hazard_kind:
		HazardKind.FIRE:
			color = Color(1.0, 0.3, 0.1, 0.5)
		HazardKind.TOXIC:
			color = Color(0.3, 0.9, 0.2, 0.35)
		HazardKind.ICE_PATCH:
			color = Color(0.5, 0.85, 1.0, 0.4)
		HazardKind.ACID:
			color = Color(0.85, 0.7, 0.1, 0.45)
		HazardKind.WIND_GUST:
			color = Color(0.6, 0.8, 1.0, 0.25)

	var poly = Polygon2D.new()
	poly.color = color
	var hw = zone_width * 0.5
	var hh = zone_height * 0.5
	poly.polygon = PackedVector2Array([
		Vector2(-hw, -hh), Vector2(hw, -hh), Vector2(hw, hh), Vector2(-hw, hh)
	])
	add_child(poly)

	# Configure particles per type
	if particles:
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		particles.emission_rect_extents = Vector2(zone_width * 0.5, zone_height * 0.5)
		match hazard_kind:
			HazardKind.FIRE:
				particles.color = Color(1.0, 0.5, 0.15, 0.7)
				particles.direction = Vector2(0, -1)
				particles.initial_velocity_min = 30.0
				particles.initial_velocity_max = 80.0
				particles.gravity = Vector2(0, -50)
			HazardKind.TOXIC:
				particles.color = Color(0.3, 0.85, 0.2, 0.5)
				particles.direction = Vector2(0, -1)
				particles.initial_velocity_min = 10.0
				particles.initial_velocity_max = 30.0
				particles.gravity = Vector2(0, -20)
			HazardKind.ICE_PATCH:
				particles.color = Color(0.6, 0.9, 1.0, 0.4)
				particles.direction = Vector2(0, -1)
				particles.initial_velocity_min = 5.0
				particles.initial_velocity_max = 15.0
				particles.gravity = Vector2.ZERO
			HazardKind.ACID:
				particles.color = Color(0.85, 0.75, 0.1, 0.6)
				particles.direction = Vector2(0, 1)
				particles.initial_velocity_min = 20.0
				particles.initial_velocity_max = 50.0
				particles.gravity = Vector2(0, 100)
			HazardKind.WIND_GUST:
				particles.color = Color(0.7, 0.85, 1.0, 0.3)
				particles.direction = Vector2(1, 0)
				particles.initial_velocity_min = 60.0
				particles.initial_velocity_max = 120.0
				particles.gravity = Vector2.ZERO

func _process(delta: float) -> void:
	active_timer += delta

	if player_in_zone and is_instance_valid(player_in_zone):
		match hazard_kind:
			HazardKind.FIRE, HazardKind.ACID:
				damage_timer += delta
				if damage_timer >= tick_interval:
					damage_timer = 0.0
					if player_in_zone.has_method("take_damage"):
						var reason = "FIRE DAMAGE" if hazard_kind == HazardKind.FIRE else "ACID BURN"
						player_in_zone.take_damage(int(damage_per_tick), reason)

			HazardKind.TOXIC:
				# Drain suit integrity
				if "suit_integrity" in player_in_zone:
					player_in_zone.suit_integrity -= damage_per_tick * 3.0 * delta
					player_in_zone.suit_integrity = maxf(player_in_zone.suit_integrity, 0.0)

			HazardKind.ICE_PATCH:
				# Override friction while on ice
				if "is_on_ice" in player_in_zone:
					player_in_zone.is_on_ice = true

			HazardKind.WIND_GUST:
				# Push the player
				var push = Vector2(200.0, -50.0) * delta
				if player_in_zone.has_method("apply_external_force"):
					player_in_zone.apply_external_force(push)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("astronaut"):
		player_in_zone = body
		damage_timer = 0.0
		if hazard_kind == HazardKind.FIRE or hazard_kind == HazardKind.ACID:
			SoundManager.play("alert", 0.05, -3.0)

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		# Reset ice friction on exit
		if hazard_kind == HazardKind.ICE_PATCH and "is_on_ice" in player_in_zone:
			player_in_zone.is_on_ice = false
		player_in_zone = null
		damage_timer = 0.0
