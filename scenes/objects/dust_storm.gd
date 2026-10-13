extends Area2D

# ═══════════════════════════════════════════════════════════════
# Dust Storm — Mars environmental turbulence hazard
# Buffets the player and applies turbulent drag.
# ═══════════════════════════════════════════════════════════════

@export var storm_intensity: float = 160.0
var player_in_storm: CharacterBody2D = null
var turbulence_timer: float = 0.0

@onready var particles: CPUParticles2D = $StormParticles

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if player_in_storm and is_instance_valid(player_in_storm):
		turbulence_timer += delta * 4.0
		var jitter = Vector2(sin(turbulence_timer) * 0.7, cos(turbulence_timer * 1.3)) * storm_intensity * delta
		if player_in_storm.has_method("apply_external_force"):
			player_in_storm.apply_external_force(jitter)
		else:
			player_in_storm.velocity += jitter

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_storm = body as CharacterBody2D

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_storm:
		player_in_storm = null
