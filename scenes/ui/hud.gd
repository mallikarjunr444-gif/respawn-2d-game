extends CanvasLayer

# ═══════════════════════════════════════════════════════════════
# HUD — Space Odyssey Astronaut Flight HUD
# Fuel gauge, hull integrity, launch gate radar, score, alerts
# ═══════════════════════════════════════════════════════════════

@onready var fuel_bar: ProgressBar = $Margin/TopBar/FuelBox/FuelBar
@onready var fuel_label: Label = $Margin/TopBar/FuelBox/FuelLabel
@onready var health_container: HBoxContainer = $Margin/TopBar/HealthContainer
@onready var sector_label: Label = $Margin/TopBar/CenterInfo/SectorLabel
@onready var radar_label: Label = $Margin/TopBar/CenterInfo/RadarLabel
@onready var gate_indicator: Label = $Margin/TopBar/CenterInfo/GateIndicator
@onready var score_label: Label = $Margin/TopBar/ScoreBox/ScoreLabel
@onready var cells_label: Label = $Margin/TopBar/ScoreBox/CellsLabel
@onready var pause_btn: Button = $Margin/TopBar/PauseBtn

@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_title: Label = $ToastPanel/VBox/TitleLabel
@onready var toast_sub: Label = $ToastPanel/VBox/SubLabel

@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var game_over_reason: Label = $GameOverPanel/VBox/ReasonLabel

@onready var weapon_box: HBoxContainer = $BottomBar/VBox/WeaponBox
@onready var sword_icon: Label = $BottomBar/VBox/WeaponBox/SwordLabel
@onready var blaster_icon: Label = $BottomBar/VBox/WeaponBox/BlasterLabel
@onready var shield_icon: Label = $BottomBar/VBox/WeaponBox/ShieldLabel
@onready var lance_icon: Label = $BottomBar/VBox/WeaponBox/LanceLabel

var toast_timer: float = 0.0
var warning_flash: float = 0.0

func _ready() -> void:
	toast_panel.visible = false
	game_over_panel.visible = false

	GameState.fuel_changed.connect(_on_fuel_changed)
	GameState.health_changed.connect(_on_health_changed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.weapons_changed.connect(_update_weapons)
	GameState.toast_requested.connect(_on_toast_requested)
	GameState.player_died.connect(_on_player_died)

	pause_btn.pressed.connect(func(): GameState.toggle_pause())

	_on_fuel_changed(GameState.fuel, GameState.get_effective_max_fuel())
	_on_health_changed(GameState.player_hp, GameState.MAX_HP)
	_on_score_changed(GameState.score)
	_update_weapons()

func _process(delta: float) -> void:
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast_panel.visible = false

	# Fuel low warning flash
	var pct = GameState.get_fuel_percentage()
	if pct <= GameState.LOW_FUEL_THRESHOLD:
		warning_flash += delta * 6.0
		var flash_color = Color(1.0, 0.2, 0.2, 1.0) if sin(warning_flash) > 0.0 else Color(1.0, 0.8, 0.2, 1.0)
		fuel_label.modulate = flash_color
		fuel_bar.modulate = flash_color
	else:
		fuel_label.modulate = Color(0.3, 1.0, 0.8, 1.0) if pct > 50.0 else Color(1.0, 0.8, 0.3, 1.0)
		fuel_bar.modulate = Color(0.3, 1.0, 0.8, 1.0) if pct > 50.0 else Color(1.0, 0.8, 0.3, 1.0)

func update_radar(dist_to_gate: float, gate_angle: float, has_min_fuel: bool, dist_to_devourer: float = -1.0) -> void:
	# Launch gate navigation
	var arrow = _angle_to_arrow(gate_angle)
	var fuel_status = "READY" if has_min_fuel else "LOW FUEL"
	if dist_to_gate < 120.0:
		if has_min_fuel:
			gate_indicator.text = "LAUNCH GATE: " + str(int(dist_to_gate)) + "m ✔ [GATE REACHED - READY TO WARP]"
			gate_indicator.modulate = Color(0.2, 1.0, 0.5)
		else:
			gate_indicator.text = "LAUNCH GATE: " + str(int(dist_to_gate)) + "m ⚠ [GATE REACHED - NEED FUEL]"
			gate_indicator.modulate = Color(1.0, 0.4, 0.2)
	else:
		gate_indicator.text = "LAUNCH GATE: " + str(int(dist_to_gate)) + "m " + arrow + " [" + fuel_status + "]"
		gate_indicator.modulate = Color(0.3, 1.0, 0.6) if has_min_fuel else Color(1.0, 0.5, 0.3)

	# Devourer warning for level 1
	if dist_to_devourer >= 0.0:
		radar_label.visible = true
		if dist_to_devourer < 600.0:
			radar_label.text = "⚠️ SINGULARITY EVENT HORIZON: " + str(int(dist_to_devourer)) + "m BEHIND"
			radar_label.modulate = Color(1.0, 0.2, 0.2) if sin(warning_flash) > 0.0 else Color(1.0, 0.7, 0.2)
		else:
			radar_label.text = "SINGULARITY BEHIND: " + str(int(dist_to_devourer)) + "m (BOOST EAST TO ESCAPE)"
			radar_label.modulate = Color(0.75, 0.5, 1.0)
	else:
		radar_label.visible = false

func _angle_to_arrow(angle: float) -> String:
	# Map angle in radians to cardinal/intercardinal arrow
	var deg = rad_to_deg(angle)
	if deg < 0: deg += 360.0
	if deg >= 337.5 or deg < 22.5: return "➜"
	elif deg >= 22.5 and deg < 67.5: return "➘"
	elif deg >= 67.5 and deg < 112.5: return "⬇"
	elif deg >= 112.5 and deg < 157.5: return "↙"
	elif deg >= 157.5 and deg < 202.5: return "⬅"
	elif deg >= 202.5 and deg < 247.5: return "↖"
	elif deg >= 247.5 and deg < 292.5: return "⬆"
	else: return "➚"

func set_sector_title(title_text: String) -> void:
	sector_label.text = title_text

func _on_fuel_changed(current: float, max_f: float) -> void:
	fuel_bar.max_value = max_f
	fuel_bar.value = current
	var pct = (current / max_f) * 100.0 if max_f > 0.0 else 0.0
	fuel_label.text = "FUEL: " + str(int(pct)) + "%"

func _on_health_changed(current_hp: int, max_hp: int) -> void:
	for i in range(health_container.get_child_count()):
		var pip = health_container.get_child(i)
		pip.modulate = Color(0.3, 0.9, 1.0, 1.0) if i < current_hp else Color(0.3, 0.3, 0.3, 0.4)

func _on_score_changed(s: int) -> void:
	score_label.text = "SCORE: " + str(s)
	cells_label.text = "CELLS: " + str(GameState.fuel_cells_collected) + " | ORBS: " + str(GameState.orbs_collected)

func _update_weapons() -> void:
	sword_icon.modulate = Color(0.3, 0.9, 1.0, 1.0) if GameState.has_sword else Color(0.3, 0.3, 0.3, 0.3)
	blaster_icon.modulate = Color(0.3, 0.9, 1.0, 1.0) if GameState.has_blaster else Color(0.3, 0.3, 0.3, 0.3)
	shield_icon.modulate = Color(0.3, 0.9, 1.0, 1.0) if GameState.has_shield else Color(0.3, 0.3, 0.3, 0.3)
	lance_icon.modulate = Color(0.8, 0.4, 1.0, 1.0) if GameState.has_lance else Color(0.3, 0.3, 0.3, 0.3)

func _on_toast_requested(title: String, subtitle: String, duration: float) -> void:
	toast_title.text = title
	toast_sub.text = subtitle
	toast_panel.visible = true
	toast_timer = duration

func _on_player_died(reason: String) -> void:
	game_over_reason.text = reason
	game_over_panel.visible = true

func _on_restart_pressed() -> void:
	GameState.force_unpause()
	GameState.restart_level()

func _on_menu_pressed() -> void:
	GameState.force_unpause()
	GameState.go_to_menu()
