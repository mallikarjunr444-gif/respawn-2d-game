extends Node2D

# ═══════════════════════════════════════════════════════════════
# SPACE ODYSSEY — Core Game Controller & Level Generator
# Open-space 360° planetary flight, per-planet environmental hazards,
# fuel cell distribution, launch gate navigation, and camera tracking.
# ═══════════════════════════════════════════════════════════════

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var camera: Camera2D = $Camera2D
@onready var hud: CanvasLayer = $HUD
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var level_complete_ui: CanvasLayer = $LevelComplete
@onready var parallax_bg: ParallaxBackground = $ParallaxBackground
@onready var sky_rect: ColorRect = $ParallaxBackground/ParallaxLayerSky/SkyRect
@onready var planet_sprite: Sprite2D = $ParallaxBackground/ParallaxLayerPlanet/PlanetSprite

# Scenes
var player_scene = preload("res://scenes/player.tscn")
var devourer_scene = preload("res://scenes/devourer.tscn")
var fuel_cell_scene = preload("res://scenes/objects/fuel_cell.tscn")
var energy_orb_scene = preload("res://scenes/objects/energy_orb.tscn")
var launch_gate_scene = preload("res://scenes/objects/launch_gate.tscn")
var meteor_scene = preload("res://scenes/objects/meteor.tscn")

# Hazard Scenes
var wind_zone_scene = preload("res://scenes/objects/wind_zone.tscn")
var heat_zone_scene = preload("res://scenes/objects/heat_zone.tscn")
var dust_storm_scene = preload("res://scenes/objects/dust_storm.tscn")
var ring_debris_scene = preload("res://scenes/objects/ring_debris.tscn")

var player: CharacterBody2D = null
var devourer: Node2D = null
var launch_gate: Node2D = null

var world_info: Dictionary = {}
var meteor_timer: float = 0.0
var meteor_interval: float = 4.0
var level_bounds: Rect2 = Rect2(0, 0, 6000, 4000)

func _ready() -> void:
	world_info = LevelData.get_world_info(GameState.current_world_idx)
	level_bounds = Rect2(0.0, 0.0, world_info.get("level_width", 6000.0), world_info.get("level_height", 4000.0))
	meteor_interval = world_info.get("meteor_rate", 4.0)

	_setup_visuals()
	_generate_level()

	hud.set_sector_title(world_info.get("name", "SPACE ODYSSEY"))
	GameState.show_toast(world_info.get("name", ""), world_info.get("subtitle", "Survive and reach the gate"), 4.0)

func _setup_visuals() -> void:
	sky_rect.color = world_info.get("sky_color", Color(0.02, 0.03, 0.06, 1.0))
	# Scale sky rect to cover expansive camera view
	sky_rect.size = Vector2(level_bounds.size.x + 2000.0, level_bounds.size.y + 2000.0)
	sky_rect.position = Vector2(-1000.0, -1000.0)

	if planet_sprite:
		var planet_tex = world_info.get("planet_texture", "")
		if planet_tex != "" and ResourceLoader.exists(planet_tex):
			planet_sprite.texture = load(planet_tex)
			planet_sprite.modulate = world_info.get("accent_color", Color.WHITE)
			planet_sprite.visible = true
		else:
			planet_sprite.visible = false

	_create_starfield()

func _create_starfield() -> void:
	# Add atmospheric floating particles layer
	var particles = CPUParticles2D.new()
	particles.amount = 120
	particles.lifetime = 8.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = level_bounds.size * 0.5
	particles.position = level_bounds.size * 0.5
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 5.0
	particles.initial_velocity_max = 20.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 3.0
	var col = world_info.get("atmosphere_particles", Color(0.5, 0.7, 1.0, 0.2))
	particles.color = col
	add_child(particles)

func _generate_level() -> void:
	# 1. Spawn Player
	player = player_scene.instantiate()
	var start_pos = world_info.get("player_start", Vector2(400.0, 2000.0))
	player.position = start_pos

	# Configure planetary environmental forces
	var grav_val = world_info.get("gravity_strength", 400.0)
	player.level_gravity = Vector2(0.0, grav_val * 0.35) # Smooth flight gravity
	var wind_dir = world_info.get("wind_direction", Vector2.ZERO)
	var wind_str = world_info.get("wind_strength", 0.0)
	player.level_wind = wind_dir * wind_str
	player.level_drag = world_info.get("drag_coefficient", 0.02)
	add_child(player)

	# 2. Spawn Launch Gate
	launch_gate = launch_gate_scene.instantiate()
	var gate_pos = world_info.get("launch_gate_position", Vector2(level_bounds.size.x - 600.0, 1500.0))
	launch_gate.position = gate_pos
	launch_gate.set_min_fuel(world_info.get("min_fuel_to_launch", 25.0))
	add_child(launch_gate)

	# 3. Spawn Black Hole (Level 1 ONLY)
	if world_info.get("has_black_hole", false):
		devourer = devourer_scene.instantiate()
		devourer.position = world_info.get("black_hole_position", Vector2(800.0, 2000.0))
		devourer.pull_radius = world_info.get("black_hole_pull_radius", 1200.0)
		devourer.pull_strength = world_info.get("black_hole_pull_strength", 600.0)
		devourer.kill_radius = world_info.get("black_hole_kill_radius", 120.0)
		devourer.target_player = player
		add_child(devourer)

	# 4. Spawn Fuel Cells along the route
	_spawn_collectibles(start_pos, gate_pos)

	# 5. Spawn Specific Hazards
	_spawn_hazards(start_pos, gate_pos)

	# Camera initial setup
	camera.position = player.position

func _spawn_collectibles(start_pos: Vector2, gate_pos: Vector2) -> void:
	var cell_count = world_info.get("fuel_cell_count", 25)
	var orb_count = world_info.get("energy_orb_count", 6)

	var dir_to_gate = (gate_pos - start_pos)
	var dist = dir_to_gate.length()

	# Main flight path fuel cells
	for i in range(cell_count):
		var t = float(i + 1) / float(cell_count + 1)
		var base_pos = start_pos + dir_to_gate * t
		# Disperse perpendicular to path
		var perp = Vector2(-dir_to_gate.y, dir_to_gate.x).normalized()
		var offset = perp * randf_range(-600.0, 600.0)
		var cell_pos = base_pos + offset

		cell_pos.x = clampf(cell_pos.x, 200.0, level_bounds.size.x - 200.0)
		cell_pos.y = clampf(cell_pos.y, 200.0, level_bounds.size.y - 200.0)

		var cell = fuel_cell_scene.instantiate()
		cell.position = cell_pos
		add_child(cell)

	# Bonus route energy orbs (tucked in high or low altitudes with extra value)
	for j in range(orb_count):
		var t = float(j + 1) / float(orb_count + 1)
		var base_pos = start_pos + dir_to_gate * t
		var alt_offset = Vector2(0.0, randf_range(700.0, 1100.0) * (1.0 if j % 2 == 0 else -1.0))
		var orb_pos = base_pos + alt_offset

		orb_pos.x = clampf(orb_pos.x, 200.0, level_bounds.size.x - 200.0)
		orb_pos.y = clampf(orb_pos.y, 200.0, level_bounds.size.y - 200.0)

		var orb = energy_orb_scene.instantiate()
		orb.position = orb_pos
		add_child(orb)

func _spawn_hazards(start_pos: Vector2, gate_pos: Vector2) -> void:
	var hazard_type = world_info.get("hazard_type", LevelData.HazardType.NONE)

	match hazard_type:
		LevelData.HazardType.STORM_WINDS, LevelData.HazardType.SIDEWAYS_WIND:
			var zone_count = 5
			for i in range(zone_count):
				var zone = wind_zone_scene.instantiate()
				var wx = lerpf(start_pos.x + 800.0, gate_pos.x - 600.0, float(i) / float(zone_count))
				var wy = randf_range(600.0, level_bounds.size.y - 600.0)
				zone.position = Vector2(wx, wy)
				var w_dir = world_info.get("wind_direction", Vector2(-1.0, 0.0))
				var w_str = world_info.get("wind_gust_strength", 300.0)
				zone.wind_force = w_dir * w_str
				add_child(zone)

		LevelData.HazardType.HEAT_ZONES, LevelData.HazardType.ACID_CLOUDS:
			var heat_count = world_info.get("heat_zone_count", 6)
			for i in range(heat_count):
				var hz = heat_zone_scene.instantiate()
				var hx = lerpf(start_pos.x + 600.0, gate_pos.x - 500.0, float(i) / float(heat_count))
				var hy = randf_range(800.0, level_bounds.size.y - 800.0)
				hz.position = Vector2(hx, hy)
				hz.drain_rate = world_info.get("heat_damage_rate", 3.0)
				hz.hazard_name = "ACID CORROSION" if hazard_type == LevelData.HazardType.ACID_CLOUDS else "SOLAR RADIATION"
				add_child(hz)

		LevelData.HazardType.DUST_STORM:
			var storm_count = world_info.get("dust_storm_count", 4)
			for i in range(storm_count):
				var ds = dust_storm_scene.instantiate()
				var sx = lerpf(start_pos.x + 700.0, gate_pos.x - 700.0, float(i) / float(storm_count))
				var sy = randf_range(600.0, level_bounds.size.y - 600.0)
				ds.position = Vector2(sx, sy)
				add_child(ds)

		LevelData.HazardType.RING_DEBRIS, LevelData.HazardType.ICY_DEBRIS, LevelData.HazardType.SATELLITES:
			var debris_count = 24
			for i in range(debris_count):
				var debris = ring_debris_scene.instantiate()
				var dx = randf_range(start_pos.x + 400.0, gate_pos.x - 200.0)
				var dy = randf_range(400.0, level_bounds.size.y - 400.0)
				debris.position = Vector2(dx, dy)
				debris.drift_velocity = Vector2(randf_range(-60.0, -10.0), randf_range(-20.0, 20.0))
				add_child(debris)

		_:
			# Default floating asteroids
			var ast_count = world_info.get("asteroid_count", 15)
			for i in range(ast_count):
				var deb = ring_debris_scene.instantiate()
				var ax = randf_range(start_pos.x + 500.0, gate_pos.x - 300.0)
				var ay = randf_range(400.0, level_bounds.size.y - 400.0)
				deb.position = Vector2(ax, ay)
				add_child(deb)

func _process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		return

	# Smooth camera follow with velocity lookahead
	var target_cam = player.position + player.velocity * 0.35
	target_cam.x = clampf(target_cam.x, 640.0, level_bounds.size.x - 640.0)
	target_cam.y = clampf(target_cam.y, 360.0, level_bounds.size.y - 360.0)
	camera.position = camera.position.lerp(target_cam, 4.0 * delta)

	# Meteor hazard spawning
	if meteor_interval > 0.0:
		meteor_timer += delta
		if meteor_timer >= meteor_interval:
			meteor_timer = 0.0
			_spawn_meteor()

	# Update radar and HUD navigation
	_update_hud_radar()

func _spawn_meteor() -> void:
	if not player or not is_instance_valid(player):
		return
	var meteor = meteor_scene.instantiate()
	var spawn_x = player.position.x + randf_range(-400.0, 500.0)
	var spawn_y = maxf(player.position.y - 800.0, 100.0)
	meteor.position = Vector2(spawn_x, spawn_y)
	meteor.target_y = player.position.y + randf_range(20.0, 180.0)
	add_child(meteor)

func _update_hud_radar() -> void:
	if not launch_gate or not is_instance_valid(launch_gate):
		return

	var offset_to_gate = launch_gate.position - player.position
	var dist_gate = offset_to_gate.length()
	var angle_gate = offset_to_gate.angle()
	var min_fuel = world_info.get("min_fuel_to_launch", 25.0)
	var has_min = GameState.get_fuel_percentage() >= min_fuel

	var dist_devourer = -1.0
	if devourer and is_instance_valid(devourer):
		dist_devourer = (devourer.position - player.position).length()

	hud.update_radar(dist_gate, angle_gate, has_min, dist_devourer)
