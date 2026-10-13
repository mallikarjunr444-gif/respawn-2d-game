extends Node2D

@export var speed: float = 120.0
var target_player: CharacterBody2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var disk_poly: Polygon2D = $DiskPoly

var alert_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("devourer")

func _process(delta: float) -> void:
	position.x += speed * delta
	disk_poly.rotation += 0.8 * delta
	
	if target_player and is_instance_valid(target_player):
		var dist_to_player = target_player.global_position.x - global_position.x
		
		# Gravitational drag
		if dist_to_player < 450.0 and dist_to_player > 0.0:
			var pull_factor = (1.0 - (dist_to_player / 450.0))
			target_player.velocity.x -= 340.0 * pull_factor * delta
			
			# Warning alert
			alert_cooldown -= delta
			if alert_cooldown <= 0.0 and dist_to_player < 280.0:
				SoundManager.play("alert", 0.05, -2.0)
				alert_cooldown = 1.2
				
		# Consumed
		if dist_to_player <= 0.0:
			target_player.take_damage(99, "CONSUMED BY THE DEVOURER")
