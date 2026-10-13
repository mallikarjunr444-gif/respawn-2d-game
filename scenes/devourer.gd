extends Node2D

# ═══════════════════════════════════════════════════════════════
# Devourer — Black Hole Singularity (Level 1 Black Space)
# Positioned behind the player, pulling the astronaut & debris
# toward the singularity.
# ═══════════════════════════════════════════════════════════════

@export var pull_radius: float = 1900.0
@export var pull_strength: float = 480.0
@export var max_pull_force: float = 440.0
@export var kill_radius: float = 140.0
@export var rotation_speed: float = 1.0

var target_player: CharacterBody2D = null
var alert_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var disk_poly: Polygon2D = $DiskPoly

func _ready() -> void:
	add_to_group("devourer")
	z_index = -1

func _process(delta: float) -> void:
	disk_poly.rotation += rotation_speed * delta

	# 1. Pull Player toward singularity center
	if not target_player or not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0]

	if target_player and is_instance_valid(target_player):
		var offset_to_player = target_player.global_position - global_position
		var dist = offset_to_player.length()

		if dist < pull_radius and dist > 0.0:
			# Stable, smooth quadratic falloff with safe force cap
			var norm_dist = clampf(dist / pull_radius, 0.0, 1.0)
			var pull_factor = pow(1.0 - norm_dist, 1.3)
			var pull_dir = -offset_to_player.normalized()
			var pull_mag = minf(pull_strength * pull_factor, max_pull_force)
			var pull_force = pull_dir * (pull_mag * delta)

			if target_player.has_method("apply_external_force"):
				target_player.apply_external_force(pull_force)
			else:
				target_player.velocity += pull_force

			# Warning alert when getting critically close to singularity
			alert_cooldown -= delta
			if alert_cooldown <= 0.0 and dist < pull_radius * 0.45:
				SoundManager.play("alert", 0.05, -2.0)
				alert_cooldown = 1.2

		# Consumed if inside the event horizon kill radius
		if dist <= kill_radius:
			if target_player.has_method("take_damage"):
				target_player.take_damage(99, "CONSUMED BY THE EVENT HORIZON")

	# 2. Pull nearby debris / asteroids toward singularity
	var debris_list = get_tree().get_nodes_in_group("debris")
	for d in debris_list:
		if is_instance_valid(d) and d is Node2D:
			var offset_d = d.global_position - global_position
			var dist_d = offset_d.length()
			if dist_d < pull_radius and dist_d > 0.0:
				var pull_dir_d = -offset_d.normalized()
				var factor_d = 1.0 - (dist_d / pull_radius)
				var force_d = pull_dir_d * (pull_strength * 0.7 * factor_d * delta)
				if d.has_method("apply_external_force"):
					d.apply_external_force(force_d)
				else:
					d.global_position += force_d * 0.5

				# Debris swallowed by singularity
				if dist_d <= kill_radius:
					if d.has_method("_shatter"):
						d._shatter()
					else:
						d.queue_free()
