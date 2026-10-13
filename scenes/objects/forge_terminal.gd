extends Area2D

signal puzzle_requested(reward_type: String)

@export var reward: String = "sword" # "sword", "blaster", "shield", "lance"
var is_active: bool = true
var player_inside: bool = false

@onready var prompt_label: Label = $PromptLabel
@onready var particles: CPUParticles2D = $GoldParticles

func _ready() -> void:
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if is_active and player_inside and Input.is_action_just_pressed("interact"):
		puzzle_requested.emit(reward)

func unlock_forge() -> void:
	is_active = false
	prompt_label.visible = false
	particles.restart()
	SoundManager.play("victory", 0.05)
	
	if reward == "sword":
		GameState.has_sword = true
		GameState.show_toast("ENERGY SWORD FORGED", "Press J to swing. Cuts voidlings and barriers!", 5.0)
	elif reward == "blaster":
		GameState.has_blaster = true
		GameState.show_toast("PLASMA BLASTER ONLINE", "Press K to fire plasma bolts!", 5.0)
	elif reward == "shield":
		GameState.has_shield = true
		GameState.show_toast("PHASE SHIELD READY", "Press Q for 1.8s invulnerable barrier!", 5.0)
	elif reward == "lance":
		GameState.has_lance = true
		GameState.show_toast("GRAVITY LANCE ACQUIRED", "Hold and release K to fire vortex spear!", 5.0)
		
	GameState.weapons_changed.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_active:
		player_inside = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		prompt_label.visible = false
