extends Control

@onready var char_label: Label = $CenterContainer/VBox/CharSelector/CharLabel
@onready var controls_modal: PanelContainer = $ControlsModal
@onready var world_select_modal: PanelContainer = $WorldSelectModal
@onready var menu_contents: Control = $CenterContainer
@onready var route_status: Label = $WorldSelectModal/VBox/RouteStatus
@onready var warp_overlay: ColorRect = $WarpOverlay
@onready var route_back_btn: Button = $WorldSelectModal/VBox/BackBtn
@onready var route_backdrop: ColorRect = $RouteBackdrop
@onready var scan_line: ColorRect = $RouteScanLine

var route_buttons: Array[Button] = []
var route_signatures: Array[Color] = [
	Color(0.32, 0.88, 1.0), Color(0.48, 1.0, 0.72), Color(1.0, 0.62, 0.36),
	Color(0.72, 0.58, 1.0), Color(1.0, 0.82, 0.38), Color(0.54, 0.82, 1.0)
]
var route_transitioning: bool = false

func _ready() -> void:
	controls_modal.visible = false
	world_select_modal.visible = false
	route_backdrop.visible = false
	scan_line.visible = false
	route_buttons = [
		$WorldSelectModal/VBox/W1Btn,
		$WorldSelectModal/VBox/W2Btn,
		$WorldSelectModal/VBox/W3Btn,
		$WorldSelectModal/VBox/W4Btn,
		$WorldSelectModal/VBox/W5Btn,
		$WorldSelectModal/VBox/W6Btn
	]
	_update_char_ui()

func _update_char_ui() -> void:
	if GameState.selected_character == "mira":
		char_label.text = "CHARACTER: MIRA (VIOLET SUIT)"
		char_label.modulate = Color(1.0, 0.4, 0.8)
	else:
		char_label.text = "CHARACTER: ARIN (CYAN SUIT)"
		char_label.modulate = Color(0.24, 0.94, 1.0)

func _process(delta: float) -> void:
	if scan_line.visible:
		scan_line.position.y = fmod(scan_line.position.y + delta * 80.0, get_viewport_rect().size.y)

func _on_char_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	if GameState.selected_character == "arin":
		GameState.selected_character = "mira"
	else:
		GameState.selected_character = "arin"
	_update_char_ui()

func _on_story_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	if GameState.route_destinations.size() != 6:
		GameState.begin_route_round()
	elif GameState.route_round_consumed:
		GameState.begin_route_round()
	route_transitioning = false
	route_status.text = "Destination unknown. Choose your trajectory."
	warp_overlay.visible = false
	route_backdrop.visible = true
	scan_line.visible = true
	menu_contents.visible = false
	for button_idx in range(route_buttons.size()):
		route_buttons[button_idx].disabled = false
		route_buttons[button_idx].modulate = route_signatures[button_idx]
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
	if route_transitioning:
		return
	route_transitioning = true
	SoundManager.play("click", 0.05)
	route_status.text = "ROUTE LOCKED\nDecrypting destination..."
	for button_idx in range(route_buttons.size()):
		route_buttons[button_idx].disabled = true
		route_buttons[button_idx].modulate = Color(0.35, 0.48, 0.58, 1.0) if button_idx != world_idx else Color(0.55, 1.0, 1.0, 1.0)
	route_back_btn.disabled = true
	warp_overlay.visible = true
	var warp_tween = create_tween()
	warp_tween.tween_property(warp_overlay, "modulate:a", 1.0, 0.35)
	await warp_tween.finished
	await get_tree().create_timer(0.25).timeout
	GameState.start_story(GameState.get_route_destination(world_idx), true)

func _on_close_world_select_pressed() -> void:
	if route_transitioning:
		return
	SoundManager.play("click", 0.05)
	world_select_modal.visible = false
	route_backdrop.visible = false
	scan_line.visible = false
	menu_contents.visible = true

func _on_quit_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	get_tree().quit()
