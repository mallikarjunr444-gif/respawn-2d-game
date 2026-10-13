extends StaticBody2D

@export var hp: int = 2

@onready var sprite: Sprite2D = $Sprite2D
@onready var break_particles: CPUParticles2D = $BreakParticles

func _ready() -> void:
	add_to_group("barriers")

func take_damage(amount: int) -> void:
	hp -= amount
	SoundManager.play("hit", 0.1)
	if hp <= 0:
		_break_barrier()

func _break_barrier() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	sprite.visible = false
	break_particles.restart()
	SoundManager.play("boom", 0.1)
	GameState.show_toast("BARRIER DESTROYED", "The path to the escape pod is clear!", 3.5)
	await get_tree().create_timer(0.5).timeout
	queue_free()
