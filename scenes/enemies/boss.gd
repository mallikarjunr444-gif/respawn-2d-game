extends Area2D

signal boss_defeated()

@export var boss_type: String = "sentinel" # "sentinel" or "vortex"
@export var max_hp: int = 12
var hp: int = 12
var shoot_timer: float = 2.0
var time_alive: float = 0.0
var target_player: CharacterBody2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var ring: Node2D = $ShieldRing
@onready var hit_particles: CPUParticles2D = $HitParticles

var bolt_scene: PackedScene = preload("res://scenes/projectiles/boss_bolt.tscn")

func _ready() -> void:
	add_to_group("bosses")
	hp = max_hp
	body_entered.connect(_on_body_entered)
	_setup_type()

func _setup_type() -> void:
	if boss_type == "vortex":
		sprite.texture = load("res://assets/enemies/guardian_vortex.svg")
		hp = 20
		max_hp = 20
	else:
		sprite.texture = load("res://assets/enemies/guardian_aether_sentinel.svg")
		hp = 10
		max_hp = 10

func _process(delta: float) -> void:
	time_alive += delta
	ring.rotation += 1.8 * delta
	
	# Hover oscillation
	position.y += sin(time_alive * 2.0) * 18.0 * delta
	
	shoot_timer -= delta
	if shoot_timer <= 0.0 and target_player and is_instance_valid(target_player):
		_attack_player()
		shoot_timer = 2.4 if hp > max_hp / 2 else 1.6

func _attack_player() -> void:
	var to_player = (target_player.global_position - global_position).normalized()
	var count = 3 if hp > max_hp / 2 else 5
	var spread_angle = 0.35
	
	for i in range(count):
		var angle_offset = (i - (count - 1) * 0.5) * spread_angle
		var dir = to_player.rotated(angle_offset)
		var bolt = bolt_scene.instantiate()
		bolt.global_position = global_position
		bolt.velocity = dir * 280.0
		get_parent().add_child(bolt)
		
	SoundManager.play("lance", 0.15, -4.0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(1, "GUARDIAN COLLISION")

func take_damage(amount: int) -> void:
	hp -= amount
	SoundManager.play("hit", 0.1)
	hit_particles.restart()
	
	sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE
		
	if hp <= 0:
		_die()

func _die() -> void:
	GameState.add_crystals(10)
	GameState.add_kill()
	SoundManager.play("boom", 0.05)
	GameState.show_toast("GUARDIAN DOWN", "Extraction gate is unlocked! Reach the pod.", 4.5)
	boss_defeated.emit()
	queue_free()
