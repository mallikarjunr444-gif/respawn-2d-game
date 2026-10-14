extends Control

const PUZZLE_SCENE = preload("res://scenes/ui/puzzle_modal.tscn")
const ROUTE_SELECTION_SCENE = preload("res://scenes/planet_selection.tscn")
const TEX_ARIN = preload("res://assets/characters/arin_male.svg")
const TEX_MIRA = preload("res://assets/characters/mira_female.svg")

@onready var char_label: Label = $MenuContents/Body/Left/PilotRow/PilotCol/CharLabel
@onready var char_btn: Button = $MenuContents/Body/Left/PilotRow/PilotCol/CharBtn
@onready var pilot_art: TextureRect = $MenuContents/Body/Left/PilotRow/PilotArt
@onready var sound_btn: Button = $MenuContents/Header/HeaderRow/SoundBtn
@onready var controls_modal: PanelContainer = $ControlsModal
@onready var hangar_modal: PanelContainer = $HangarModal
@onready var hangar_text: Label = $HangarModal/HangarBox/HangarText
@onready var menu_contents: Control = $MenuContents
@onready var story_btn: Button = $MenuContents/Body/Left/MenuButtons/StoryBtn
@onready var endless_btn: Button = $MenuContents/Body/Left/MenuButtons/EndlessBtn
@onready var hangar_btn: Button = $MenuContents/Body/Left/MenuButtons/HangarBtn
@onready var controls_btn: Button = $MenuContents/Body/Left/MenuButtons/ControlsBtn
@onready var quit_btn: Button = $MenuContents/Body/Left/MenuButtons/QuitBtn
@onready var close_hangar_btn: Button = $HangarModal/HangarBox/CloseHangarBtn
@onready var close_controls_btn: Button = $ControlsModal/VBox/CloseControlsBtn

var puzzle_modal: CanvasLayer
var route_selection: Control

func _ready() -> void:
	controls_modal.visible = false
	hangar_modal.visible = false
	_style_dashboard()
	_update_char_ui()
	_update_sound_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M:
		_on_sound_btn_pressed()
		get_viewport().set_input_as_handled()

func _style_dashboard() -> void:
	_panel_style($MenuContents/Header, Color(0.05, 0.08, 0.18, 0.72), Color(0.24, 0.94, 1.0, 0.28), 10)
	_panel_style(controls_modal, Color(0.05, 0.07, 0.16, 0.96), Color(0.24, 0.94, 1.0, 0.55), 14)
	_panel_style(hangar_modal, Color(0.05, 0.07, 0.16, 0.96), Color(0.24, 0.94, 1.0, 0.55), 14)
	_button_style(story_btn, true)
	for b in [endless_btn, hangar_btn, controls_btn, quit_btn, char_btn, sound_btn, close_hangar_btn, close_controls_btn]:
		_button_style(b, false)

func _panel_style(panel: PanelContainer, fill: Color, border: Color, radius: int) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.set_border_width_all(1)
	box.border_color = border
	box.set_corner_radius_all(radius)
	box.content_margin_left = 16
	box.content_margin_right = 16
	box.content_margin_top = 14
	box.content_margin_bottom = 14
	box.shadow_color = Color(0.1, 0.7, 1.0, 0.12)
	box.shadow_size = 12
	panel.add_theme_stylebox_override("panel", box)

func _button_style(button: Button, primary: bool) -> void:
	var normal := StyleBoxFlat.new()
	var hover := StyleBoxFlat.new()
	var pressed := StyleBoxFlat.new()
	for box in [normal, hover, pressed]:
		box.set_corner_radius_all(10)
		box.set_border_width_all(1)
		box.content_margin_left = 16
		box.content_margin_right = 16
	if primary:
		normal.bg_color = Color(0.07, 0.28, 0.42, 0.92)
		normal.border_color = Color(0.24, 0.94, 1.0, 0.85)
		hover.bg_color = Color(0.12, 0.42, 0.58, 0.95)
		hover.border_color = Color(0.55, 1.0, 1.0, 1.0)
		pressed.bg_color = Color(0.16, 0.55, 0.7, 1.0)
		pressed.border_color = Color(1, 1, 1, 0.9)
		button.add_theme_color_override("font_color", Color(0.85, 1, 1, 1))
		button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	else:
		normal.bg_color = Color(0.06, 0.1, 0.2, 0.88)
		normal.border_color = Color(0.4, 0.55, 0.8, 0.4)
		hover.bg_color = Color(0.1, 0.18, 0.32, 0.95)
		hover.border_color = Color(0.24, 0.94, 1.0, 0.7)
		pressed.bg_color = Color(0.12, 0.24, 0.4, 1.0)
		pressed.border_color = Color(0.24, 0.94, 1.0, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_font_size_override("font_size", 15)

func _update_char_ui() -> void:
	if GameState.selected_character == "mira":
		char_label.text = "PILOT: MIRA (VIOLET SUIT)"
		char_label.modulate = Color(1.0, 0.45, 0.85)
		pilot_art.texture = TEX_MIRA
	else:
		char_label.text = "PILOT: ARIN (CYAN SUIT)"
		char_label.modulate = Color(0.24, 0.94, 1.0)
		pilot_art.texture = TEX_ARIN

func _update_sound_ui() -> void:
	sound_btn.text = "SOUND  OFF" if SoundManager.muted else "SOUND  ON"

func _weapon_line(label: String, unlocked: bool) -> String:
	return ("%s  —  ONLINE" % label) if unlocked else ("%s  —  LOCKED  (forge in expedition)" % label)

func _refresh_hangar() -> void:
	hangar_text.text = "\n".join([
		"Active pilot: %s" % ("Mira" if GameState.selected_character == "mira" else "Arin"),
		"Record distance: %d km" % int(GameState.best_distance),
		"Crystals on last run: %d" % GameState.crystals,
		"",
		"WEAPON BAY",
		_weapon_line("Energy Sword", GameState.has_sword),
		_weapon_line("Plasma Blaster", GameState.has_blaster),
		_weapon_line("Phase Shield", GameState.has_shield),
		_weapon_line("Gravity Lance", GameState.has_lance),
		"",
		"Story expeditions unlock weapons at forge terminals.",
		"Infinite Frontier launches with the full loadout armed."
	])

func _on_char_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	if GameState.selected_character == "arin":
		GameState.selected_character = "mira"
	else:
		GameState.selected_character = "arin"
	GameState.save_data()
	_update_char_ui()

func _on_sound_btn_pressed() -> void:
	SoundManager.toggle_mute()
	if not SoundManager.muted:
		SoundManager.play("click", 0.05)
	_update_sound_ui()

func _on_story_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	_close_modals()
	if GameState.intro_puzzle_completed:
		_show_route_selection("Destination unknown. Choose your trajectory.")
		return
	menu_contents.visible = false
	puzzle_modal = PUZZLE_SCENE.instantiate()
	add_child(puzzle_modal)
	puzzle_modal.puzzle_solved.connect(_on_opening_puzzle_solved)
	puzzle_modal.open_laser_puzzle("sword", true)

func _on_endless_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	GameState.start_endless()

func _on_hangar_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	controls_modal.visible = false
	_refresh_hangar()
	hangar_modal.visible = true

func _on_controls_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	hangar_modal.visible = false
	controls_modal.visible = true

func _on_close_hangar_pressed() -> void:
	SoundManager.play("click", 0.05)
	hangar_modal.visible = false

func _on_close_controls_pressed() -> void:
	SoundManager.play("click", 0.05)
	controls_modal.visible = false

func _close_modals() -> void:
	hangar_modal.visible = false
	controls_modal.visible = false

func _on_opening_puzzle_solved(reward_id: String) -> void:
	if GameState.intro_puzzle_completed:
		return
	GameState.intro_puzzle_completed = true
	GameState.grant_weapon(reward_id)
	_show_route_selection("WEAPON UNLOCKED: ENERGY SWORD\nDestination unknown. Choose your trajectory.")

func _show_route_selection(status_text: String) -> void:
	menu_contents.visible = false
	route_selection = ROUTE_SELECTION_SCENE.instantiate()
	add_child(route_selection)
	route_selection.world_selected.connect(_on_route_selected)
	route_selection.back_to_menu.connect(_on_route_back)
	route_selection.set_status(status_text)

func _on_route_selected(route_idx: int) -> void:
	GameState.start_story(route_idx, true)

func _on_route_back() -> void:
	if is_instance_valid(route_selection):
		route_selection.queue_free()
	menu_contents.visible = true

func _on_quit_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	get_tree().quit()
