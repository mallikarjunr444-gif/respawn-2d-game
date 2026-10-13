extends Area2D

@export var speed: float = 850.0
@export var damage: int = 1
var direction: float = 1.0
var lifetime: float = 1.4

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	scale.x = direction

func _process(delta: float) -> void:
	position.x += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		_explode()
	elif body is StaticBody2D or body is TileMap:
		_explode()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and area.has_method("take_damage"):
		area.take_damage(damage)
		_explode()
	elif area.is_in_group("bosses") and area.has_method("take_damage"):
		area.take_damage(damage)
		_explode()
	elif area.is_in_group("barriers") and area.has_method("take_damage"):
		area.take_damage(damage)
		_explode()

func _explode() -> void:
	SoundManager.play("hit", 0.2, -4.0)
	queue_free()
