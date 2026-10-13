extends Area2D

@export var speed: float = 340.0
@export var damage: int = 1
var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 4.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	add_to_group("enemy_projectiles")

func _process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, "ENEMY PLASMA FIRE")
		queue_free()
	elif body is StaticBody2D:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Blocked by shield or sword attack
	if area.is_in_group("shield") or area.is_in_group("sword"):
		SoundManager.play("hit", 0.2)
		queue_free()
