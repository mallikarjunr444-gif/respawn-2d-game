extends Node

# Global Game State & Configuration Singleton

signal crystals_changed(amount: int)
signal health_changed(current: int, max_hp: int)
signal weapons_changed()
signal player_died(reason: String)
signal level_completed()
signal toast_requested(title: String, subtitle: String, duration: float)

var selected_character: String = "arin" # "arin" or "mira"
var game_mode: String = "story" # "story" or "endless"
var current_world_idx: int = 0
var sector_idx: int = 0

var crystals: int = 0
var kills: int = 0
var distance_traveled: float = 0.0
var best_distance: float = 0.0

# Weapons unlocked
var has_sword: bool = false
var has_blaster: bool = false
var has_shield: bool = false
var has_lance: bool = false

# Player stats
var player_hp: int = 5
const MAX_HP: int = 5

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input_actions()
	load_saved_data()

func _setup_input_actions() -> void:
	_register_action("move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_register_action("move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_register_action("jump", [KEY_SPACE, KEY_W, KEY_UP], [JOY_BUTTON_A])
	_register_action("dash", [KEY_SHIFT], [JOY_BUTTON_B])
	_register_action("attack", [KEY_J], [JOY_BUTTON_X], -1, 0.0, MOUSE_BUTTON_LEFT)
	_register_action("shoot", [KEY_K], [JOY_BUTTON_Y], -1, 0.0, MOUSE_BUTTON_RIGHT)
	_register_action("shield", [KEY_Q], [JOY_BUTTON_LEFT_SHOULDER])
	_register_action("interact", [KEY_E], [JOY_BUTTON_RIGHT_SHOULDER])
	_register_action("restart", [KEY_R], [JOY_BUTTON_BACK])
	_register_action("pause", [KEY_ESCAPE], [JOY_BUTTON_START])

func _register_action(action_name: String, keys: Array[Key], joy_buttons: Array[JoyButton] = [], joy_axis: JoyAxis = -1, axis_dir: float = 0.0, mouse_btn: MouseButton = MOUSE_BUTTON_NONE) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	
	for k in keys:
		var ev = InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action_name, ev)
		
	for b in joy_buttons:
		var ev = InputEventJoypadButton.new()
		ev.button_index = b
		InputMap.action_add_event(action_name, ev)
		
	if joy_axis != -1:
		var ev = InputEventJoypadMotion.new()
		ev.axis = joy_axis
		ev.axis_value = axis_dir
		InputMap.action_add_event(action_name, ev)
		
	if mouse_btn != MOUSE_BUTTON_NONE:
		var ev = InputEventMouseButton.new()
		ev.button_index = mouse_btn
		InputMap.action_add_event(action_name, ev)

func start_story(world_index: int = 0) -> void:
	game_mode = "story"
	current_world_idx = world_index
	sector_idx = 0
	crystals = 0
	kills = 0
	distance_traveled = 0.0
	player_hp = MAX_HP
	
	# Unlock weapons according to world progression
	has_sword = world_index >= 1
	has_blaster = world_index >= 3
	has_shield = world_index >= 4
	has_lance = world_index >= 5
	
	weapons_changed.emit()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func start_endless() -> void:
	game_mode = "endless"
	current_world_idx = 0
	sector_idx = 0
	crystals = 0
	kills = 0
	distance_traveled = 0.0
	player_hp = MAX_HP
	
	# All weapons enabled in infinite frontier mode
	has_sword = true
	has_blaster = true
	has_shield = true
	has_lance = true
	
	weapons_changed.emit()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func add_crystals(count: int) -> void:
	crystals += count
	crystals_changed.emit(crystals)
	SoundManager.play("gem", 0.15)

func add_kill() -> void:
	kills += 1

func damage_player(amount: int, reason: String = "DAMAGED") -> bool:
	player_hp = clampi(player_hp - amount, 0, MAX_HP)
	health_changed.emit(player_hp, MAX_HP)
	if player_hp <= 0:
		SoundManager.play("boom", 0.1)
		player_died.emit(reason)
		return true
	else:
		SoundManager.play("hit", 0.1)
		return false

func heal_player(amount: int = 1) -> void:
	if player_hp < MAX_HP:
		player_hp = clampi(player_hp + amount, 0, MAX_HP)
		health_changed.emit(player_hp, MAX_HP)
		SoundManager.play("heal")

func show_toast(title: String, subtitle: String, duration: float = 4.0) -> void:
	toast_requested.emit(title, subtitle, duration)

func save_data() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("record", "best_dist", maxf(best_distance, distance_traveled))
	cfg.set_value("record", "crystals", crystals)
	cfg.set_value("record", "world", current_world_idx)
	cfg.set_value("settings", "character", selected_character)
	cfg.save("user://event_horizon_save.cfg")

func load_saved_data() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load("user://event_horizon_save.cfg")
	if err == OK:
		best_distance = cfg.get_value("record", "best_dist", 0.0)
		selected_character = cfg.get_value("settings", "character", "arin")
