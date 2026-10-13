extends Node2D

@export var fall_speed: float = 780.0
@export var damage: int = 1
var target_y: float = 0.0
var has_exploded: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var trail: CPUParticles2D = $TrailParticles
@onready var explosion: CPUParticles2D = $ExplosionParticles
@onready var blast_area: Area2D = $BlastArea
@onready var warning_line: Line2D = $WarningLine

func _ready() -> void:
	warning_line.points = [Vector2(0, 0), Vector2(0, target_y - global_position.y)]

func _process(delta: float) -> void:
	if has_exploded:
		return
		
	global_position.y += fall_speed * delta
	warning_line.points = [Vector2(0, 0), Vector2(0, target_y - global_position.y)]
	
	if global_position.y >= target_y:
		_explode()

func _explode() -> void:
	has_exploded = true
	sprite.visible = false
	trail.emitting = false
	warning_line.visible = false
	explosion.restart()
	SoundManager.play("boom", 0.1)
	
	# Blast damage check
	for body in blast_area.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(damage, "METEOR IMPACT")
			
	await get_tree().create_timer(0.6).timeout
	queue_free()
