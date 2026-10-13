extends Area2D

@export var speed: float = 620.0
@export var damage: int = 3
var direction: float = 1.0
var lifetime: float = 1.6
var hit_entities: Array[Node] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	scale.x = direction

func _process(delta: float) -> void:
	position.x += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		
	# Gravitational pull: pull nearby enemies toward the lance core
	var space_state = get_world_2d().direct_space_state
	for body in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(body) and body is Node2D:
			var dist = global_position.distance_to(body.global_position)
			if dist < 220.0:
				var pull_dir = (global_position - body.global_position).normalized()
				body.global_position += pull_dir * 320.0 * delta

func _on_body_entered(body: Node2D) -> void:
	if not hit_entities.has(body):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			hit_entities.append(body)
			SoundManager.play("hit", 0.1)

func _on_area_entered(area: Area2D) -> void:
	if not hit_entities.has(area):
		if area.has_method("take_damage"):
			area.take_damage(damage)
			hit_entities.append(area)
			SoundManager.play("hit", 0.1)
