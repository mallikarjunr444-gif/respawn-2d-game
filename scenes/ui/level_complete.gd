extends CanvasLayer

# ═══════════════════════════════════════════════════════════════
# Level Complete Screen — Post-mission summary and progression
# ═══════════════════════════════════════════════════════════════

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var subtitle_label: Label = $Panel/VBox/SubtitleLabel
@onready var fuel_label: Label = $Panel/VBox/StatsBox/FuelStat
@onready var cells_label: Label = $Panel/VBox/StatsBox/CellsStat
@onready var orbs_label: Label = $Panel/VBox/StatsBox/OrbsStat
@onready var score_label: Label = $Panel/VBox/StatsBox/ScoreStat
@onready var total_score_label: Label = $Panel/VBox/StatsBox/TotalScoreStat
@onready var next_btn: Button = $Panel/VBox/ButtonBox/NextBtn
@onready var upgrade_btn: Button = $Panel/VBox/ButtonBox/UpgradeBtn
@onready var menu_btn: Button = $Panel/VBox/ButtonBox/MenuBtn
@onready var upgrade_panel: PanelContainer = $UpgradePanel
@onready var close_upgrades_btn: Button = $UpgradePanel/VBox/CloseUpgradeBtn

@onready var tank_btn: Button = $UpgradePanel/VBox/Grid/TankBtn
@onready var thrust_btn: Button = $UpgradePanel/VBox/Grid/ThrustBtn
@onready var eff_btn: Button = $UpgradePanel/VBox/Grid/EffBtn
@onready var credits_label: Label = $UpgradePanel/VBox/CreditsLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if upgrade_panel:
		upgrade_panel.visible = false

	GameState.level_completed.connect(_on_level_completed)

	next_btn.pressed.connect(_on_next_pressed)
	if upgrade_btn:
		upgrade_btn.pressed.connect(_on_upgrade_pressed)
	if close_upgrades_btn:
		close_upgrades_btn.pressed.connect(_on_close_upgrades_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

	if tank_btn:
		tank_btn.pressed.connect(func(): _buy_upgrade("tank"))
	if thrust_btn:
		thrust_btn.pressed.connect(func(): _buy_upgrade("thrust"))
	if eff_btn:
		eff_btn.pressed.connect(func(): _buy_upgrade("efficiency"))

func _on_level_completed() -> void:
	visible = true
	var cur_info = LevelData.get_world_info(GameState.current_world_idx)
	title_label.text = "MISSION ACCOMPLISHED"
	subtitle_label.text = "DESTINATION: " + cur_info.get("name", "") + " CLEARED"

	fuel_label.text = "Fuel Remaining: " + str(int(GameState.get_fuel_percentage())) + "%"
	cells_label.text = "Fuel Cells Collected: " + str(GameState.fuel_cells_collected)
	orbs_label.text = "Energy Orbs Collected: " + str(GameState.orbs_collected)
	score_label.text = "Sector Score: " + str(GameState.level_score)
	total_score_label.text = "Total Fleet Credits: " + str(GameState.total_score)

	var next_idx = GameState.current_world_idx + 1
	if next_idx >= LevelData.get_planet_count():
		next_btn.text = "FINAL ODYSSEY VICTORY!"
	else:
		var next_info = LevelData.get_world_info(next_idx)
		next_btn.text = "WARP TO " + next_info.get("name", "NEXT SECTOR")
	next_btn.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or (upgrade_panel and upgrade_panel.visible):
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("thrust") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_on_next_pressed()

func _on_next_pressed() -> void:
	visible = false
	GameState.go_to_next_level()

func _on_menu_pressed() -> void:
	visible = false
	GameState.go_to_menu()

func _on_upgrade_pressed() -> void:
	upgrade_panel.visible = true
	_refresh_upgrade_ui()

func _on_close_upgrades_pressed() -> void:
	upgrade_panel.visible = false
	total_score_label.text = "Total Fleet Credits: " + str(GameState.total_score)

func _refresh_upgrade_ui() -> void:
	credits_label.text = "Available Credits: " + str(GameState.total_score)
	_update_btn_text(tank_btn, "tank", "Fuel Tank (Capacity +25%)", GameState.upgrade_tank_level)
	_update_btn_text(thrust_btn, "thrust", "Rocket Thrust (Thrust +15%)", GameState.upgrade_thrust_level)
	_update_btn_text(eff_btn, "efficiency", "Thruster Efficiency (Burn -15%)", GameState.upgrade_efficiency_level)

func _update_btn_text(btn: Button, type: String, title: String, level: int) -> void:
	if not btn: return
	if level >= GameState.MAX_UPGRADE_LEVEL:
		btn.text = title + "\n[MAX LEVEL " + str(level) + "]"
		btn.disabled = true
	else:
		var cost = GameState.UPGRADE_COSTS[level]
		btn.text = title + " (Lv " + str(level) + " -> " + str(level + 1) + ")\nCost: " + str(cost) + " Credits"
		btn.disabled = GameState.total_score < cost

func _buy_upgrade(type: String) -> void:
	if GameState.purchase_upgrade(type):
		SoundManager.play("upgrade", 0.05)
		_refresh_upgrade_ui()
