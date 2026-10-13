extends CanvasLayer

@onready var health_container: HBoxContainer = $Margin/TopBar/HealthContainer
@onready var crystal_label: Label = $Margin/TopBar/CrystalContainer/CrystalLabel
@onready var sector_label: Label = $Margin/TopBar/CenterInfo/SectorLabel
@onready var radar_label: Label = $Margin/TopBar/CenterInfo/RadarLabel
@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_title: Label = $ToastPanel/VBox/TitleLabel
@onready var toast_sub: Label = $ToastPanel/VBox/SubLabel

@onready var sword_icon: Label = $BottomBar/WeaponBox/SwordLabel
@onready var blaster_icon: Label = $BottomBar/WeaponBox/BlasterLabel
@onready var shield_icon: Label = $BottomBar/WeaponBox/ShieldLabel
@onready var lance_icon: Label = $BottomBar/WeaponBox/LanceLabel

@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var game_over_reason: Label = $GameOverPanel/VBox/ReasonLabel
@onready var victory_panel: PanelContainer = $VictoryPanel

var toast_timer: float = 0.0

func _ready() -> void:
	toast_panel.visible = false
	game_over_panel.visible = false
	victory_panel.visible = false
	
	GameState.health_changed.connect(_on_health_changed)
	GameState.crystals_changed.connect(_on_crystals_changed)
	GameState.weapons_changed.connect(_update_weapons)
	GameState.toast_requested.connect(_on_toast_requested)
	GameState.player_died.connect(_on_player_died)
	
	_on_health_changed(GameState.player_hp, GameState.MAX_HP)
	_on_crystals_changed(GameState.crystals)
	_update_weapons()

func _process(delta: float) -> void:
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast_panel.visible = false

func update_radar(dist_to_devourer: float) -> void:
	if dist_to_devourer < 300.0:
		radar_label.text = "⚠️ DEVOURER WARNING: " + str(int(dist_to_devourer)) + "m"
		radar_label.modulate = Color(1.0, 0.2, 0.2, 1.0) if fmod(Time.get_ticks_msec() * 0.005, 1.0) > 0.5 else Color.WHITE
	else:
		radar_label.text = "DEVOURER DISTANCE: " + str(int(dist_to_devourer)) + "m"
		radar_label.modulate = Color(0.4, 0.9, 1.0, 0.9)

func set_sector_title(title_text: String) -> void:
	sector_label.text = title_text

func _on_health_changed(current_hp: int, max_hp: int) -> void:
	for i in range(health_container.get_child_count()):
		var pip = health_container.get_child(i)
		pip.modulate = Color(0.24, 0.94, 1.0, 1.0) if i < current_hp else Color(0.3, 0.3, 0.3, 0.5)

func _on_crystals_changed(count: int) -> void:
	crystal_label.text = "💎 " + str(count)

func _update_weapons() -> void:
	sword_icon.modulate = Color(0.24, 0.94, 1.0, 1.0) if GameState.has_sword else Color(0.4, 0.4, 0.4, 0.4)
	blaster_icon.modulate = Color(0.24, 0.94, 1.0, 1.0) if GameState.has_blaster else Color(0.4, 0.4, 0.4, 0.4)
	shield_icon.modulate = Color(0.24, 0.94, 1.0, 1.0) if GameState.has_shield else Color(0.4, 0.4, 0.4, 0.4)
	lance_icon.modulate = Color(0.8, 0.4, 1.0, 1.0) if GameState.has_lance else Color(0.4, 0.4, 0.4, 0.4)

func _on_toast_requested(title: String, subtitle: String, duration: float) -> void:
	toast_title.text = title
	toast_sub.text = subtitle
	toast_panel.visible = true
	toast_timer = duration

func _on_player_died(reason: String) -> void:
	game_over_reason.text = reason
	game_over_panel.visible = true

func show_victory() -> void:
	victory_panel.visible = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameState.start_story(GameState.current_world_idx)

func _on_next_level_pressed() -> void:
	get_tree().paused = false
	if GameState.game_mode == "story":
		var next_idx = GameState.current_world_idx + 1
		if next_idx >= 6:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		else:
			GameState.start_story(next_idx)
	else:
		GameState.start_endless()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
