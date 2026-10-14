extends Control

# ═══════════════════════════════════════════════════════════════
# SPACE ODYSSEY — Main Menu
# Title screen, mission launch, 10-planet navigation, rocket upgrades,
# character selection, and flight manual.
# ═══════════════════════════════════════════════════════════════

@onready var char_label: Label = $CenterContainer/VBox/CharSelector/CharLabel
@onready var controls_modal: PanelContainer = $ControlsModal
@onready var upgrade_modal: PanelContainer = $UpgradeModal
@onready var credits_label: Label = $UpgradeModal/VBox/CreditsLabel
@onready var tank_btn: Button = $UpgradeModal/VBox/Grid/TankBtn
@onready var thrust_btn: Button = $UpgradeModal/VBox/Grid/ThrustBtn
@onready var eff_btn: Button = $UpgradeModal/VBox/Grid/EffBtn

func _ready() -> void:
	if controls_modal: controls_modal.visible = false
	if upgrade_modal: upgrade_modal.visible = false
	_update_char_ui()

func _update_char_ui() -> void:
	if GameState.selected_character == "mira":
		char_label.text = "ASTRONAUT: MIRA (VIOLET SUIT)"
		char_label.modulate = Color(1.0, 0.4, 0.8)
	else:
		char_label.text = "ASTRONAUT: ARIN (CYAN SUIT)"
		char_label.modulate = Color(0.24, 0.94, 1.0)

func _on_char_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	if GameState.selected_character == "arin":
		GameState.selected_character = "mira"
	else:
		GameState.selected_character = "arin"
	_update_char_ui()

func _on_launch_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	# Start at level 0 (Black Space tutorial) or first available
	GameState.start_level(0)

func _on_planets_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func _on_upgrades_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	upgrade_modal.visible = true
	_refresh_upgrades()

func _on_close_upgrades_pressed() -> void:
	SoundManager.play("click", 0.05)
	upgrade_modal.visible = false

func _refresh_upgrades() -> void:
	credits_label.text = "Fleet Credits Available: " + str(GameState.total_score)
	_update_btn_text(tank_btn, "tank", "Fuel Tank (Capacity +25%)", GameState.upgrade_tank_level)
	_update_btn_text(thrust_btn, "thrust", "Rocket Thrust (Power +15%)", GameState.upgrade_thrust_level)
	_update_btn_text(eff_btn, "efficiency", "Engine Efficiency (Burn -15%)", GameState.upgrade_efficiency_level)

func _update_btn_text(btn: Button, type: String, title: String, level: int) -> void:
	if not btn: return
	if level >= GameState.MAX_UPGRADE_LEVEL:
		btn.text = title + "\n[MAX LEVEL " + str(level) + "]"
		btn.disabled = true
	else:
		var cost = GameState.UPGRADE_COSTS[level]
		btn.text = title + " (Lv " + str(level) + " -> " + str(level + 1) + ")\nCost: " + str(cost) + " Credits"
		btn.disabled = GameState.total_score < cost

func _on_upgrade_tank_pressed() -> void:
	if GameState.purchase_upgrade("tank"):
		SoundManager.play("upgrade", 0.05)
		_refresh_upgrades()

func _on_upgrade_thrust_pressed() -> void:
	if GameState.purchase_upgrade("thrust"):
		SoundManager.play("upgrade", 0.05)
		_refresh_upgrades()

func _on_upgrade_eff_pressed() -> void:
	if GameState.purchase_upgrade("efficiency"):
		SoundManager.play("upgrade", 0.05)
		_refresh_upgrades()

func _on_controls_btn_pressed() -> void:
	SoundManager.play("click", 0.05)
	controls_modal.visible = true

func _on_close_controls_pressed() -> void:
	SoundManager.play("click", 0.05)
	controls_modal.visible = false
