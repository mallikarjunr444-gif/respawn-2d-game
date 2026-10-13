extends Area2D

@export var max_hp: int = 2
var hp: int = 2
var patrol_center_x: float = 0.0
var patrol_range: float = 120.0
var patrol_speed: float = 1.6
var base_y: float = 0.0
var time_alive: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_particles: CPUParticles2D = $HitParticles

func _ready() -> void:
	add_to_group("enemies")
	hp = max_hp
	patrol_center_x = global_position.x
	base_y = global_position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time_alive += delta
	var target_x = patrol_center_x + sin(time_alive * patrol_speed) * patrol_range
	var target_y = base_y + sin(time_alive * 3.0) * 16.0
	
	# Face movement direction
	sprite.flip_h = target_x < global_position.x
	global_position = Vector2(target_x, target_y)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(1, "VOIDLING STRIKE")

func take_damage(amount: int) -> void:
	hp -= amount
	SoundManager.play("hit", 0.15)
	hit_particles.restart()
	
	# Damage flash
	sprite.modulate = Color(3.0, 1.0, 3.0, 1.0)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE
		
	if hp <= 0:
		_die()

func _die() -> void:
	GameState.add_crystals(2)
	GameState.add_kill()
	SoundManager.play("gem", 0.1)
	queue_free()
