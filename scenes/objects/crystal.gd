extends Area2D

var time_offset: float = 0.0

func _ready() -> void:
	time_offset = randf() * TAU
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.y += sin(Time.get_ticks_msec() * 0.004 + time_offset) * 0.5

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.add_crystals(1)
		queue_free()
