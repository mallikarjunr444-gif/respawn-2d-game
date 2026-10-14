extends Control

signal world_selected(idx: int)
signal back_to_menu()

@onready var w1_btn: Button = $Center/Panel/VBox/RouteGrid/W1Btn
@onready var w2_btn: Button = $Center/Panel/VBox/RouteGrid/W2Btn
@onready var w3_btn: Button = $Center/Panel/VBox/RouteGrid/W3Btn
@onready var w4_btn: Button = $Center/Panel/VBox/RouteGrid/W4Btn
@onready var w5_btn: Button = $Center/Panel/VBox/RouteGrid/W5Btn
@onready var w6_btn: Button = $Center/Panel/VBox/RouteGrid/W6Btn
@onready var back_btn: Button = $Center/Panel/VBox/BackBtn
@onready var status_label: Label = $Center/Panel/VBox/Status
@onready var warp_overlay: ColorRect = $WarpOverlay
@onready var scan_line: ColorRect = $ScanLine

var transitioning: bool = false
var route_buttons: Array[Button] = []
var route_signatures: Array[Color] = [
    Color(0.32, 0.88, 1.0), Color(0.48, 1.0, 0.72), Color(1.0, 0.62, 0.36),
    Color(0.72, 0.58, 1.0), Color(1.0, 0.82, 0.38), Color(0.54, 0.82, 1.0)
]

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    route_buttons = [w1_btn, w2_btn, w3_btn, w4_btn, w5_btn, w6_btn]
    for button_idx in range(route_buttons.size()):
        route_buttons[button_idx].modulate = route_signatures[button_idx]
        var scene_path := GameState.get_route_scene_path(button_idx)
        route_buttons[button_idx].disabled = scene_path.is_empty() or not ResourceLoader.exists(scene_path)
    w1_btn.pressed.connect(_on_world_pressed.bind(0))
    w2_btn.pressed.connect(_on_world_pressed.bind(1))
    w3_btn.pressed.connect(_on_world_pressed.bind(2))
    w4_btn.pressed.connect(_on_world_pressed.bind(3))
    w5_btn.pressed.connect(_on_world_pressed.bind(4))
    w6_btn.pressed.connect(_on_world_pressed.bind(5))

func _process(delta: float) -> void:
    scan_line.position.y = fmod(scan_line.position.y + delta * 80.0, get_viewport_rect().size.y)

func _on_world_pressed(idx: int) -> void:
    if transitioning:
        return
    var scene_path := GameState.get_route_scene_path(idx)
    if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
        status_label.text = "SIGNAL %02d UNAVAILABLE. No alternate route was loaded." % (idx + 1)
        status_label.modulate = Color(1.0, 0.35, 0.3)
        return
    transitioning = true
    SoundManager.play("click", 0.05)
    back_btn.disabled = true
    status_label.text = "ROUTE LOCKED\nDecrypting destination..."
    for button_idx in range(route_buttons.size()):
        var route_button = route_buttons[button_idx]
        route_button.disabled = true
        route_button.modulate = Color(0.35, 0.48, 0.58, 1.0) if button_idx != idx else Color(0.55, 1.0, 1.0, 1.0)

    var warp_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    warp_tween.tween_property(warp_overlay, "modulate:a", 1.0, 0.35)
    await warp_tween.finished
    await get_tree().create_timer(0.25, true).timeout
    emit_signal("world_selected", idx)

func set_status(message: String) -> void:
    status_label.text = message
    status_label.modulate = Color(0.3, 0.94, 1.0)

func _on_back_pressed() -> void:
    emit_signal("back_to_menu")
