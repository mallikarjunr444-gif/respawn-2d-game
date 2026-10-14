extends Node

# ═══════════════════════════════════════════════════════════════
# SPACE ODYSSEY — Global Game State & Progression Singleton
# Manages fuel, upgrades, level unlocks, scoring, and save data.
# ═══════════════════════════════════════════════════════════════

signal fuel_changed(current: float, max_fuel: float)
signal score_changed(score: int)
signal health_changed(current: int, max_hp: int)
signal player_died(reason: String)
signal level_completed()
signal toast_requested(title: String, subtitle: String, duration: float)
signal weapons_changed()
signal upgrade_purchased(upgrade_name: String)
signal pause_toggled(is_paused: bool)

# ── Character ──
var selected_character: String = "arin"  # "arin" or "mira"

# ── Game Mode ──
var game_mode: String = "story"  # "story" or "endless"
var current_world_idx: int = 0
var is_paused: bool = false

# ── Fuel System ──
var fuel: float = 100.0
var max_fuel: float = 100.0
const FUEL_CONSUMPTION_RATE: float = 3.2    # Per second while thrusting (allows 30+ seconds continuous flight)
const FUEL_IDLE_DRAIN: float = 0.0          # No idle drain
const FUEL_CELL_VALUE: float = 16.0         # Each fuel cell gives generous fuel
const ENERGY_ORB_VALUE: float = 35.0        # Energy orbs give massive refill
const LOW_FUEL_THRESHOLD: float = 25.0      # Warning below this %
var fuel_warning_active: bool = false

# ── Scoring ──
var score: int = 0
var level_score: int = 0
var total_score: int = 0
var fuel_cells_collected: int = 0
var orbs_collected: int = 0
var bonus_routes_found: int = 0

# ── Player HP (collision damage) ──
var player_hp: int = 3
const MAX_HP: int = 3

# ── Weapons & Defense ──
var has_sword: bool = false
var has_blaster: bool = false
var has_shield: bool = true  # Exactly 1 Shield in each level
var has_lance: bool = false
var shield_charges: int = 1  # 1 Shield charge per level
var endless_sector: int = 1  # Endless Frontier sector count

# ── Upgrades ──
var upgrade_tank_level: int = 0       # 0-3, each adds 25% capacity
var upgrade_thrust_level: int = 0     # 0-3, each adds 15% thrust
var upgrade_efficiency_level: int = 0 # 0-3, each reduces consumption 15%
const MAX_UPGRADE_LEVEL: int = 3
const UPGRADE_COSTS: Array[int] = [100, 250, 500]  # Score cost per level

# ── Progression ──
var unlocked_levels: Array[int] = [0]  # Level indices unlocked
var level_best_scores: Dictionary = {} # {level_idx: best_score}
var levels_completed: Array[int] = []  # Levels finished at least once

# ── Crystals (legacy, now secondary currency) ──
var crystals: int = 0
signal crystals_changed(amount: int)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input_actions()
	load_saved_data()

func _setup_input_actions() -> void:
	_register_action("move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_register_action("move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_register_action("move_up", [KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], JOY_AXIS_LEFT_Y, -1.0)
	_register_action("move_down", [KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], JOY_AXIS_LEFT_Y, 1.0)
	_register_action("thrust", [KEY_SPACE], [JOY_BUTTON_A])
	_register_action("boost", [KEY_SHIFT], [JOY_BUTTON_B])
	_register_action("attack", [KEY_J], [JOY_BUTTON_X], -1, 0.0, MOUSE_BUTTON_LEFT)
	_register_action("shoot", [KEY_K], [JOY_BUTTON_Y], -1, 0.0, MOUSE_BUTTON_RIGHT)
	_register_action("shield", [KEY_Q], [JOY_BUTTON_LEFT_SHOULDER])
	_register_action("interact", [KEY_E], [JOY_BUTTON_RIGHT_SHOULDER])
	_register_action("restart", [KEY_R], [JOY_BUTTON_BACK])
	_register_action("pause", [KEY_ESCAPE, KEY_P], [JOY_BUTTON_START])

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

# ═══════════════════════════════════════════════════════════════
# FUEL SYSTEM
# ═══════════════════════════════════════════════════════════════

func get_effective_max_fuel() -> float:
	return max_fuel * (1.0 + upgrade_tank_level * 0.25)

func get_fuel_efficiency() -> float:
	return 1.0 - (upgrade_efficiency_level * 0.15)

func get_thrust_multiplier() -> float:
	return 1.0 + (upgrade_thrust_level * 0.15)

func get_fuel_percentage() -> float:
	var eff_max = get_effective_max_fuel()
	if eff_max <= 0.0:
		return 0.0
	return (fuel / eff_max) * 100.0

func consume_fuel(amount: float) -> bool:
	## Returns true if fuel was consumed, false if empty
	var actual = amount * get_fuel_efficiency()
	if fuel <= 0.0:
		fuel = 0.0
		fuel_changed.emit(fuel, get_effective_max_fuel())
		return false
	fuel = maxf(fuel - actual, 0.0)

	# Low fuel warning
	var pct = get_fuel_percentage()
	if pct <= LOW_FUEL_THRESHOLD and not fuel_warning_active:
		fuel_warning_active = true
		SoundManager.play("low_fuel", 0.05)
		show_toast("LOW FUEL WARNING", "Emergency solar glide engaged! Collect fuel cells.", 3.5)
	elif pct > LOW_FUEL_THRESHOLD:
		fuel_warning_active = false

	fuel_changed.emit(fuel, get_effective_max_fuel())
	return true

func add_fuel(amount: float) -> void:
	var eff_max = get_effective_max_fuel()
	fuel = minf(fuel + amount, eff_max)
	fuel_warning_active = get_fuel_percentage() <= LOW_FUEL_THRESHOLD
	fuel_changed.emit(fuel, eff_max)
	SoundManager.play("fuel_pickup", 0.1)

func refill_fuel() -> void:
	fuel = get_effective_max_fuel()
	fuel_warning_active = false
	fuel_changed.emit(fuel, get_effective_max_fuel())

func is_fuel_empty() -> bool:
	return fuel <= 0.0

# ═══════════════════════════════════════════════════════════════
# SCORING
# ═══════════════════════════════════════════════════════════════

func add_score(points: int) -> void:
	score += points
	level_score += points
	score_changed.emit(score)

func add_fuel_cell_score() -> void:
	fuel_cells_collected += 1
	add_score(10)

func add_orb_score() -> void:
	orbs_collected += 1
	add_score(50)

func add_bonus_route_score() -> void:
	bonus_routes_found += 1
	add_score(100)

# ═══════════════════════════════════════════════════════════════
# PLAYER DAMAGE
# ═══════════════════════════════════════════════════════════════

func damage_player(amount: int, reason: String = "COLLISION") -> bool:
	player_hp = clampi(player_hp - amount, 0, MAX_HP)
	health_changed.emit(player_hp, MAX_HP)
	if player_hp <= 0:
		# Instead of instant death, drain remaining fuel as recovery penalty
		if fuel > 20.0:
			fuel -= 20.0
			player_hp = 1
			health_changed.emit(player_hp, MAX_HP)
			fuel_changed.emit(fuel, get_effective_max_fuel())
			show_toast("EMERGENCY RECOVERY", "Fuel spent to stabilize. Be careful!", 3.0)
			SoundManager.play("alert", 0.05)
			return false
		else:
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

# ═══════════════════════════════════════════════════════════════
# UPGRADES
# ═══════════════════════════════════════════════════════════════

func can_upgrade(upgrade_type: String) -> bool:
	var level = _get_upgrade_level(upgrade_type)
	if level >= MAX_UPGRADE_LEVEL:
		return false
	return total_score >= UPGRADE_COSTS[level]

func purchase_upgrade(upgrade_type: String) -> bool:
	var level = _get_upgrade_level(upgrade_type)
	if level >= MAX_UPGRADE_LEVEL:
		return false
	var cost = UPGRADE_COSTS[level]
	if total_score < cost:
		return false

	total_score -= cost
	match upgrade_type:
		"tank": upgrade_tank_level += 1
		"thrust": upgrade_thrust_level += 1
		"efficiency": upgrade_efficiency_level += 1

	upgrade_purchased.emit(upgrade_type)
	save_data()
	return true

func _get_upgrade_level(upgrade_type: String) -> int:
	match upgrade_type:
		"tank": return upgrade_tank_level
		"thrust": return upgrade_thrust_level
		"efficiency": return upgrade_efficiency_level
	return 0

# ═══════════════════════════════════════════════════════════════
# PAUSE SYSTEM
# ═══════════════════════════════════════════════════════════════

func toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_toggled.emit(is_paused)

func force_unpause() -> void:
	is_paused = false
	get_tree().paused = false

# ═══════════════════════════════════════════════════════════════
# LEVEL MANAGEMENT
# ═══════════════════════════════════════════════════════════════

func start_level(world_index: int) -> void:
	if game_mode != "endless":
		game_mode = "story"
	current_world_idx = world_index
	# Preserve collected fuel progression, ensuring player starts with at least 55% tank
	fuel = maxf(fuel, get_effective_max_fuel() * 0.55)
	fuel_warning_active = false
	player_hp = MAX_HP
	level_score = 0
	fuel_cells_collected = 0
	orbs_collected = 0
	bonus_routes_found = 0
	score = 0
	shield_charges = 1 # EXACTLY 1 SHIELD IN EACH LEVEL

	# Unlock weapons based on progression
	has_shield = true # Shield is available with 1 charge per level
	has_sword = world_index >= 2 or game_mode == "endless"
	has_blaster = world_index >= 4 or game_mode == "endless"
	has_lance = world_index >= 8 or game_mode == "endless"

	weapons_changed.emit()
	force_unpause()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func complete_level() -> void:
	# Record score
	var best = level_best_scores.get(current_world_idx, 0)
	if level_score > best:
		level_best_scores[current_world_idx] = level_score

	total_score += level_score

	# Mark completed + unlock next
	if not levels_completed.has(current_world_idx):
		levels_completed.append(current_world_idx)

	var next_idx = current_world_idx + 1
	if next_idx < LevelData.get_planet_count() and not unlocked_levels.has(next_idx):
		unlocked_levels.append(next_idx)

	if game_mode == "endless":
		endless_sector += 1

	save_data()
	level_completed.emit()

func restart_level() -> void:
	force_unpause()
	# If failed, restart from the start of the game (World 0)
	start_level(0)

func go_to_next_level() -> void:
	if game_mode == "endless":
		var next_idx = (current_world_idx + 1) % LevelData.get_planet_count()
		start_level(next_idx)
		return

	var next_idx = current_world_idx + 1
	if next_idx < LevelData.get_planet_count():
		start_level(next_idx)
	else:
		# Game complete — return to menu
		force_unpause()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func go_to_menu() -> void:
	force_unpause()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func is_level_unlocked(idx: int) -> bool:
	return unlocked_levels.has(idx)

func is_level_completed_flag(idx: int) -> bool:
	return levels_completed.has(idx)

# Legacy compatibility
func start_story(world_index: int = 0, _selected_from_route: bool = false) -> void:
	start_level(world_index)

func start_endless() -> void:
	game_mode = "endless"
	start_level(0)

func add_crystals(count: int) -> void:
	crystals += count
	crystals_changed.emit(crystals)
	add_score(count * 5)
	SoundManager.play("gem", 0.15)

func add_kill() -> void:
	add_score(25)

func show_toast(title: String, subtitle: String, duration: float = 4.0) -> void:
	toast_requested.emit(title, subtitle, duration)

# Legacy route system for backward compatibility
var route_destinations: Array[int] = []
var route_round_consumed: bool = false

func begin_route_round() -> void:
	route_round_consumed = false
	route_destinations.clear()
	for idx in range(LevelData.get_planet_count()):
		route_destinations.append(idx)
	route_destinations.shuffle()

func get_route_destination(route_idx: int) -> int:
	if route_destinations.size() == 0:
		begin_route_round()
	return route_destinations[clampi(route_idx, 0, route_destinations.size() - 1)]

# ═══════════════════════════════════════════════════════════════
# SAVE / LOAD
# ═══════════════════════════════════════════════════════════════

func save_data() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("progress", "unlocked_levels", unlocked_levels)
	cfg.set_value("progress", "levels_completed", levels_completed)
	cfg.set_value("progress", "total_score", total_score)
	cfg.set_value("progress", "level_scores", level_best_scores)
	cfg.set_value("upgrades", "tank", upgrade_tank_level)
	cfg.set_value("upgrades", "thrust", upgrade_thrust_level)
	cfg.set_value("upgrades", "efficiency", upgrade_efficiency_level)
	cfg.set_value("settings", "character", selected_character)
	cfg.save("user://space_odyssey_save.cfg")

func load_saved_data() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load("user://space_odyssey_save.cfg")
	if err == OK:
		# Untyped arrays from save need conversion
		var raw_unlocked = cfg.get_value("progress", "unlocked_levels", [0])
		unlocked_levels.clear()
		for v in raw_unlocked:
			unlocked_levels.append(int(v))
		var raw_completed = cfg.get_value("progress", "levels_completed", [])
		levels_completed.clear()
		for v in raw_completed:
			levels_completed.append(int(v))
		total_score = cfg.get_value("progress", "total_score", 0)
		level_best_scores = cfg.get_value("progress", "level_scores", {})
		upgrade_tank_level = cfg.get_value("upgrades", "tank", 0)
		upgrade_thrust_level = cfg.get_value("upgrades", "thrust", 0)
		upgrade_efficiency_level = cfg.get_value("upgrades", "efficiency", 0)
		selected_character = cfg.get_value("settings", "character", "arin")
