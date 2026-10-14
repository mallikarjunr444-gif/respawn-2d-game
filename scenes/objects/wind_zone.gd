extends Area2D

# ═══════════════════════════════════════════════════════════════
# Wind Zone — Environmental hazard that pushes the player
# Used in Jupiter, Neptune, Uranus, and Venus.
# ═══════════════════════════════════════════════════════════════

@export var wind_force: Vector2 = Vector2(-280.0, 0.0)
@export var zone_size: Vector2 = Vector2(800.0, 500.0)

var player_in_zone: CharacterBody2D = null

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles: CPUParticles2D = $WindParticles

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_setup_zone()

func _setup_zone() -> void:
	if collision_shape and collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size = zone_size

	if particles:
		particles.emission_rect_extents = zone_size * 0.5
		particles.direction = wind_force.normalized()
		particles.initial_velocity_min = wind_force.length() * 0.8
		particles.initial_velocity_max = wind_force.length() * 1.2

func _physics_process(delta: float) -> void:
	if player_in_zone and is_instance_valid(player_in_zone):
		var push = wind_force * delta
		if player_in_zone.has_method("apply_external_force"):
			player_in_zone.apply_external_force(push)
		else:
			player_in_zone.velocity += push

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = body as CharacterBody2D

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		player_in_zone = null
