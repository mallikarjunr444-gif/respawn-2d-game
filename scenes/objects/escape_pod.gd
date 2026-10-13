extends Area2D

signal pod_launched()

var is_launching: bool = false
var launch_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var thruster: CPUParticles2D = $ThrusterParticles
@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_launching:
		launch_timer += delta
		position.y -= 380.0 * delta * (1.0 + launch_timer * 2.0)
		position.x += 120.0 * delta
		if launch_timer >= 2.0:
			pod_launched.emit()
			is_launching = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_launching:
		_trigger_launch()

func _trigger_launch() -> void:
	is_launching = true
	thruster.emitting = true
	SoundManager.play("victory", 0.05)
	GameState.show_toast("SECTOR ESCAPE SUCCESSFUL", "Preparing hyper-jump to next sector...", 3.0)
	await get_tree().create_timer(1.8).timeout
	GameState.level_completed.emit()
