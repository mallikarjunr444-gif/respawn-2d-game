extends Node2D

# ═══════════════════════════════════════════════════════════════
# Devourer — Black Hole Singularity (Level 1 Black Space)
# Radial gravitational pull that drags the player inward.
# ═══════════════════════════════════════════════════════════════

@export var pull_radius: float = 1200.0
@export var pull_strength: float = 600.0
@export var kill_radius: float = 120.0
@export var rotation_speed: float = 1.2

var target_player: CharacterBody2D = null
var alert_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var disk_poly: Polygon2D = $DiskPoly

func _ready() -> void:
	add_to_group("devourer")

func _process(delta: float) -> void:
	disk_poly.rotation += rotation_speed * delta

	if not target_player or not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0]
		return

	var offset_to_player = target_player.global_position - global_position
	var dist = offset_to_player.length()

	# Radial gravitational pull toward black hole center
	if dist < pull_radius and dist > 0.0:
		var pull_factor = 1.0 - (dist / pull_radius)
		var pull_dir = -offset_to_player.normalized()
		var pull_force = pull_dir * (pull_strength * pull_factor * delta)
		
		if target_player.has_method("apply_external_force"):
			target_player.apply_external_force(pull_force)
		else:
			target_player.velocity += pull_force

		# Warning alert when getting critically close
		alert_cooldown -= delta
		if alert_cooldown <= 0.0 and dist < pull_radius * 0.4:
			SoundManager.play("alert", 0.05, -2.0)
			alert_cooldown = 1.2

	# Consumed if within event horizon kill radius
	if dist <= kill_radius:
		if target_player.has_method("take_damage"):
			target_player.take_damage(99, "CONSUMED BY THE DEVOURER")
