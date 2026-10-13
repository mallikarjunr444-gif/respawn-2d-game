extends Control

@onready var char_label: Label = $CenterContainer/VBox/CharSelector/CharLabel
@onready var controls_modal: PanelContainer = $ControlsModal
@onready var world_select_modal: PanelContainer = $WorldSelectModal

func _ready() -> void:
	controls_modal.visible = false
	world_select_modal.visible = false
	_update_char_ui()

func _update_char_ui() -> void:
	if GameState.selected_character == "mira":
		char_label.text = "CHARACTER: MIRA (VIOLET SUIT)"
		char_label.modulate = Color(1.0, 0.4, 0.8)
	else:
		char_label.text = "CHARACTER: ARIN (CYAN SUIT)"
		char_label.modulate = Color(0.24, 0.94, 1.0)

func _on_char_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	if GameState.selected_character == "arin":
		GameState.selected_character = "mira"
	else:
		GameState.selected_character = "arin"
	_update_char_ui()

func _on_story_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	world_select_modal.visible = true

func _on_endless_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	GameState.start_endless()

func _on_controls_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	controls_modal.visible = true

func _on_close_controls_pressed() -> void:
	SoundManager.play("click", 0.05)
	controls_modal.visible = false

func _on_world_btn_pressed(world_idx: int) -> void:
	SoundManager.play("click", 0.05)
	world_select_modal.visible = false
	GameState.start_story(world_idx)

func _on_close_world_select_pressed() -> void:
	SoundManager.play("click", 0.05)
	world_select_modal.visible = false

func _on_quit_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	get_tree().quit()
