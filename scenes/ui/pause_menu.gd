extends CanvasLayer

# ═══════════════════════════════════════════════════════════════
# Pause Menu — In-Game Pause, Settings, Level Navigation
# ═══════════════════════════════════════════════════════════════

@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var restart_btn: Button = $Panel/VBox/RestartBtn
@onready var level_select_btn: Button = $Panel/VBox/LevelSelectBtn
@onready var menu_btn: Button = $Panel/VBox/MenuBtn
@onready var music_slider: HSlider = $Panel/VBox/AudioBox/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBox/AudioBox/SfxSlider
@onready var music_check: CheckBox = $Panel/VBox/AudioBox/MusicCheck
@onready var sfx_check: CheckBox = $Panel/VBox/AudioBox/SfxCheck

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	GameState.pause_toggled.connect(_on_pause_toggled)

	resume_btn.pressed.connect(_on_resume_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	level_select_btn.pressed.connect(_on_level_select_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

	if music_slider:
		music_slider.value = SoundManager.music_volume
		music_slider.value_changed.connect(_on_music_slider_changed)
	if sfx_slider:
		sfx_slider.value = SoundManager.sfx_volume
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	if music_check:
		music_check.button_pressed = SoundManager.music_enabled
		music_check.toggled.connect(_on_music_toggled)
	if sfx_check:
		sfx_check.button_pressed = SoundManager.sfx_enabled
		sfx_check.toggled.connect(_on_sfx_toggled)

func _on_pause_toggled(is_paused: bool) -> void:
	visible = is_paused

func _on_resume_pressed() -> void:
	GameState.toggle_pause()

func _on_restart_pressed() -> void:
	GameState.force_unpause()
	GameState.restart_level()

func _on_level_select_pressed() -> void:
	GameState.force_unpause()
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func _on_menu_pressed() -> void:
	GameState.force_unpause()
	GameState.go_to_menu()

func _on_music_slider_changed(val: float) -> void:
	SoundManager.set_music_volume(val)

func _on_sfx_slider_changed(val: float) -> void:
	SoundManager.set_sfx_volume(val)

func _on_music_toggled(btn_pressed: bool) -> void:
	SoundManager.set_music_enabled(btn_pressed)

func _on_sfx_toggled(btn_pressed: bool) -> void:
	SoundManager.set_sfx_enabled(btn_pressed)
