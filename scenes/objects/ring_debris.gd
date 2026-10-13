extends Area2D

# ═══════════════════════════════════════════════════════════════
# Ring Debris — Saturn ring field obstacle
# Drifts in bands, damages player on contact. Can be destroyed.
# ═══════════════════════════════════════════════════════════════

@export var drift_velocity: Vector2 = Vector2(-40.0, 15.0)
@export var rot_speed: float = 0.5
@export var hp: int = 2

@onready var poly: Polygon2D = $Polygon2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	rot_speed = randf_range(-1.2, 1.2)
	_generate_rock_shape()

func _generate_rock_shape() -> void:
	var pts: PackedVector2Array = []
	var count = 7
	var radius = randf_range(24.0, 36.0)
	for i in range(count):
		var angle = TAU * float(i) / float(count)
		var r = radius * randf_range(0.75, 1.25)
		pts.append(Vector2(cos(angle) * r, sin(angle) * r))
	if poly:
		poly.polygon = pts
		poly.color = Color(0.85, 0.75, 0.5, 0.85)

func _process(delta: float) -> void:
	global_position += drift_velocity * delta
	rotation += rot_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1, "RING DEBRIS COLLISION")
		_shatter()

func take_damage(dmg: int) -> void:
	hp -= dmg
	if hp <= 0:
		_shatter()

func _shatter() -> void:
	SoundManager.play("boom", 0.05, 3.0)
	queue_free()
