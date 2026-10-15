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
var surface_astronaut_scene = preload("res://scenes/surface_astronaut.tscn")
var surface_resource_scene = preload("res://scenes/objects/surface_resource.tscn")
var surface_hazard_scene = preload("res://scenes/objects/surface_hazard.tscn")
var surface_hazard_script = preload("res://scenes/objects/surface_hazard.gd")
var exit_rocket_scene = preload("res://scenes/objects/exit_rocket.tscn")
var voidling_scene = preload("res://scenes/enemies/voidling.tscn")

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
var surface_mode: bool = false
var landing_started: bool = false
var landing_complete: bool = false
var landing_pad: StaticBody2D = null
var surface_root: Node2D = null
var surface_astronaut: CharacterBody2D = null
var landing_speed: float = 0.0
var landing_surface_y: float = 0.0
var surface_origin_y: float = 0.0

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
	sky_rect.size = Vector2(level_bounds.size.x + 3000.0, level_bounds.size.y + 3000.0)
	sky_rect.position = Vector2(-1500.0, -1500.0)

	if planet_sprite:
		var planet_tex = world_info.get("planet_texture", "")
		if planet_tex != "" and ResourceLoader.exists(planet_tex):
			planet_sprite.texture = load(planet_tex)
			planet_sprite.modulate = world_info.get("accent_color", Color.WHITE)
			var p_start = world_info.get("player_start", Vector2(1200.0, 2000.0))
			planet_sprite.position = Vector2(p_start.x + 1300.0, p_start.y - 420.0)
			planet_sprite.scale = Vector2(2.6, 2.6)
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
	# 1. Spawn Player (Facing right, escaping away from black hole)
	player = player_scene.instantiate()
	var start_pos = world_info.get("player_start", Vector2(1200.0, 2000.0))
	player.position = start_pos
	player.facing_angle = 0.0
	player.velocity = Vector2(80.0, 0.0)
	player.level_bounds = level_bounds

	# Space mode: ONLY rocket in space; on planet: character
	var is_in_space = world_info.get("is_space", false) or world_info.get("id") == "black_space"
	player.set_space_vehicle_mode(is_in_space)

	# Configure planetary environmental forces
	var grav_val = world_info.get("gravity_strength", 200.0)
	player.level_gravity = Vector2(0.0, grav_val * 0.15) # Smooth flight gravity
	var wind_dir = world_info.get("wind_direction", Vector2.ZERO)
	var wind_str = world_info.get("wind_strength", 0.0)
	player.level_wind = wind_dir * wind_str
	player.level_drag = world_info.get("drag_coefficient", 0.015)
	add_child(player)

	# 2. Spawn Launch Gate
	launch_gate = launch_gate_scene.instantiate()
	var gate_pos = world_info.get("launch_gate_position", Vector2(level_bounds.size.x - 500.0, 2000.0))
	launch_gate.position = gate_pos
	launch_gate.set_min_fuel(world_info.get("min_fuel_to_launch", 15.0))
	launch_gate.set_required_cells(world_info.get("fuel_cell_count", 0))
	add_child(launch_gate)

	# 3. The singularity follows each flight leg and is suspended for touchdown.
	if world_info.get("has_black_hole", false) or GameState.current_world_idx > 0:
		devourer = devourer_scene.instantiate()
		var default_black_hole_position = Vector2(
			maxf(start_pos.x - 850.0, 80.0),
			clampf(start_pos.y - 850.0, 100.0, level_bounds.end.y - 100.0)
		)
		devourer.position = world_info.get("black_hole_position", default_black_hole_position)
		devourer.pull_radius = world_info.get("black_hole_pull_radius", 1700.0)
		devourer.pull_strength = world_info.get("black_hole_pull_strength", 360.0)
		devourer.kill_radius = world_info.get("black_hole_kill_radius", 140.0)
		devourer.pursuit_speed = world_info.get("black_hole_pursuit_speed", 70.0)
		devourer.target_player = player
		add_child(devourer)

	# 4. Spawn Fuel Cells along the route
	_spawn_collectibles(start_pos, gate_pos)

	# 5. Spawn Specific Hazards
	_spawn_hazards(start_pos, gate_pos)

	# Camera initial setup
	camera.position = player.position

func _spawn_collectibles(start_pos: Vector2, gate_pos: Vector2) -> void:
	# Risky pickups near the black hole for daring pilots
	if world_info.get("has_black_hole", false):
		var risky_positions = [
			Vector2(750.0, 1950.0),
			Vector2(950.0, 2120.0),
			Vector2(1100.0, 1880.0)
		]
		for r_pos in risky_positions:
			var r_cell = fuel_cell_scene.instantiate()
			r_cell.position = r_pos
			add_child(r_cell)

	var cell_count = world_info.get("fuel_cell_count", 28)
	var orb_count = world_info.get("energy_orb_count", 7)

	var dir_to_gate = (gate_pos - start_pos)
	var dist = dir_to_gate.length()

	# Main flight path fuel cells - clustered along flight corridor
	for i in range(cell_count):
		var t = float(i + 1) / float(cell_count + 1)
		var base_pos = start_pos + dir_to_gate * t
		var perp = Vector2(-dir_to_gate.y, dir_to_gate.x).normalized()
		var offset = perp * randf_range(-160.0, 160.0)
		var cell_pos = base_pos + offset

		cell_pos.x = clampf(cell_pos.x, 200.0, level_bounds.size.x - 200.0)
		cell_pos.y = clampf(cell_pos.y, 200.0, level_bounds.size.y - 200.0)

		var cell = fuel_cell_scene.instantiate()
		cell.position = cell_pos
		add_child(cell)

	# Guaranteed safety fuel cells right ahead of the gate
	var norm_dir = dir_to_gate.normalized()
	var safety_offsets = [320.0, 180.0, 70.0]
	for s_dist in safety_offsets:
		var safe_cell = fuel_cell_scene.instantiate()
		safe_cell.position = gate_pos - norm_dir * s_dist
		add_child(safe_cell)

	# Bonus route energy orbs
	for j in range(orb_count):
		var t = float(j + 1) / float(orb_count + 1)
		var base_pos = start_pos + dir_to_gate * t
		var alt_offset = Vector2(0.0, randf_range(450.0, 750.0) * (1.0 if j % 2 == 0 else -1.0))
		var orb_pos = base_pos + alt_offset

		orb_pos.x = clampf(orb_pos.x, 200.0, level_bounds.size.x - 200.0)
		orb_pos.y = clampf(orb_pos.y, 200.0, level_bounds.size.y - 200.0)

		var orb = energy_orb_scene.instantiate()
		orb.position = orb_pos
		add_child(orb)

func _spawn_hazards(start_pos: Vector2, gate_pos: Vector2) -> void:
	var hazard_type = world_info.get("hazard_type", LevelData.HazardType.NONE)

	match hazard_type:
		LevelData.HazardType.ICY_DEBRIS:
			# Neptune icy debris in flight corridor + strong headwind streams
			var ice_count = world_info.get("ice_chunk_count", 24)
			for i in range(ice_count):
				var debris = ring_debris_scene.instantiate()
				var dx = randf_range(start_pos.x + 350.0, gate_pos.x - 200.0)
				var dy = randf_range(start_pos.y - 320.0, start_pos.y + 320.0)
				debris.position = Vector2(dx, dy)
				debris.drift_velocity = Vector2(randf_range(-80.0, -20.0), randf_range(-25.0, 25.0))
				add_child(debris)
				if "poly" in debris and is_instance_valid(debris.poly):
					debris.poly.color = Color(0.4, 0.85, 1.0, 0.9)

			# Neptune wind streams
			var stream_count = 4
			for w in range(stream_count):
				var zone = wind_zone_scene.instantiate()
				var wx = lerpf(start_pos.x + 800.0, gate_pos.x - 600.0, float(w) / float(stream_count))
				var wy = randf_range(start_pos.y - 400.0, start_pos.y + 400.0)
				zone.position = Vector2(wx, wy)
				zone.wind_force = Vector2(-160.0, 30.0)
				add_child(zone)

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

	if landing_started and not landing_complete:
		_update_landing(delta)
		return

	if not surface_mode and not world_info.get("is_space", false):
		var approach_x = world_info.get("player_start", Vector2.ZERO).x + level_bounds.size.x * 0.22
		if player.position.x >= approach_x and player.velocity.x >= 0.0:
			_begin_planet_landing()
			return

	if surface_mode:
		_update_surface_camera(delta)
		_update_surface_hud()
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

func _begin_planet_landing() -> void:
	if landing_started or surface_mode:
		return

	landing_started = true
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	if devourer and is_instance_valid(devourer):
		devourer.is_active = false
	var exhaust = player.get_node_or_null("ExhaustParticles")
	if exhaust:
		exhaust.emitting = true
	landing_speed = 0.0
	landing_surface_y = clampf(player.position.y + 520.0, 700.0, level_bounds.end.y - 300.0)
	var landing_x = clampf(player.position.x, 300.0, level_bounds.end.x - 300.0)
	player.position.x = landing_x
	_create_landing_pad(landing_x, landing_surface_y)
	SoundManager.play("boost", 0.08)
	GameState.show_toast("PLANET APPROACH", "Automatic landing burn engaged", 2.5)

func _create_landing_pad(pad_x: float, pad_y: float) -> void:
	landing_pad = StaticBody2D.new()
	landing_pad.name = "LandingPad"
	landing_pad.collision_layer = 2
	landing_pad.collision_mask = 1
	var shape = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(520.0, 44.0)
	shape.shape = rectangle
	shape.position = Vector2(0.0, 22.0)
	landing_pad.add_child(shape)
	var pad_visual = Polygon2D.new()
	pad_visual.color = world_info.get("accent_color", Color(0.3, 0.9, 1.0, 1.0))
	pad_visual.polygon = PackedVector2Array([
		Vector2(-260.0, 0.0), Vector2(260.0, 0.0), Vector2(220.0, 44.0), Vector2(-220.0, 44.0)
	])
	landing_pad.add_child(pad_visual)
	landing_pad.position = Vector2(pad_x, pad_y)
	add_child(landing_pad)

func _update_landing(delta: float) -> void:
	if not player or not is_instance_valid(player):
		return
	landing_speed = minf(landing_speed + 900.0 * delta, 360.0)
	var collision = player.move_and_collide(Vector2(0.0, landing_speed * delta))
	if collision:
		player.velocity = Vector2.ZERO
		var exhaust = player.get_node_or_null("ExhaustParticles")
		if exhaust:
			exhaust.emitting = false
		landing_complete = true
		SoundManager.play("portal", 0.08)
		GameState.show_toast("TOUCHDOWN", "Surface landing confirmed", 2.0)
		_build_surface_level()

func _build_surface_level() -> void:
	surface_mode = true
	var planet_id = world_info.get("id", "earth")
	var config = PlanetConfig.get_surface_config(planet_id)
	surface_origin_y = landing_surface_y
	player.remove_from_group("player")
	player.set_physics_process(false)
	player.visible = false
	player.position = Vector2(player.position.x, landing_surface_y)

	surface_root = Node2D.new()
	surface_root.name = "PlanetSurface"
	add_child(surface_root)
	_create_surface_backdrop(config)
	_create_surface_terrain(config)
	_spawn_surface_astronaut(config)
	_spawn_surface_objectives(config)
	_spawn_surface_hazards(config)

	launch_gate = exit_rocket_scene.instantiate()
	launch_gate.name = "SurfaceExitRocket"
	launch_gate.position = Vector2(player.position.x, landing_surface_y - 30.0)
	launch_gate.set_resources_needed(config.get("mandatory_count", 5))
	launch_gate.boarding_started.connect(_on_surface_boarding_started)
	launch_gate.takeoff_complete.connect(_on_surface_takeoff_complete)
	surface_root.add_child(launch_gate)
	camera.position = surface_astronaut.position
	GameState.show_toast("WELCOME TO " + str(config.get("surface_name", "PLANET SURFACE")), "Exit the rocket and recover the required samples", 4.0)

func _surface_profile(planet_id: String) -> Dictionary:
	var profiles = {
		"neptune": {"start": 180.0, "gate": 4200.0, "steps": [Vector2(700, -130), Vector2(1240, -260), Vector2(1880, -90), Vector2(2550, -310), Vector2(3260, -150)]},
		"mars": {"start": 240.0, "gate": 4700.0, "steps": [Vector2(860, -280), Vector2(1420, 40), Vector2(2050, -360), Vector2(2940, -80), Vector2(3780, -300)]},
		"saturn": {"start": 160.0, "gate": 5000.0, "steps": [Vector2(720, -220), Vector2(1320, -430), Vector2(2100, -180), Vector2(2920, -420), Vector2(3860, -240)]},
		"jupiter": {"start": 260.0, "gate": 4450.0, "steps": [Vector2(780, -90), Vector2(1360, -210), Vector2(1940, -70), Vector2(2620, -230), Vector2(3480, -100)]},
		"earth": {"start": 220.0, "gate": 3600.0, "steps": [Vector2(720, -160), Vector2(1260, -40), Vector2(1840, -220), Vector2(2450, -80), Vector2(3020, -180)]},
		"uranus": {"start": 200.0, "gate": 4600.0, "steps": [Vector2(660, -260), Vector2(1180, -90), Vector2(1810, -340), Vector2(2520, -170), Vector2(3400, -380)]},
		"mercury": {"start": 280.0, "gate": 4300.0, "steps": [Vector2(760, -70), Vector2(1440, -300), Vector2(2180, -110), Vector2(2860, -340), Vector2(3600, -120)]},
		"venus": {"start": 190.0, "gate": 4800.0, "steps": [Vector2(720, -190), Vector2(1280, -360), Vector2(1940, -120), Vector2(2740, -290), Vector2(3620, -160)]},
		"pluto": {"start": 150.0, "gate": 5200.0, "steps": [Vector2(720, -340), Vector2(1400, -120), Vector2(2180, -430), Vector2(3120, -200), Vector2(4100, -380)]},
	}
	return profiles.get(planet_id, {"start": 200.0, "gate": 3800.0, "steps": [Vector2(760, -150), Vector2(1400, -260), Vector2(2100, -90), Vector2(2860, -220)]})

func _surface_gate_position(config: Dictionary) -> Vector2:
	var profile = _surface_profile(world_info.get("id", "earth"))
	return Vector2(profile.get("gate", config.get("surface_width", 4000.0) - 300.0), surface_origin_y - 30.0)

func _create_surface_backdrop(config: Dictionary) -> void:
	var backdrop = Polygon2D.new()
	backdrop.color = config.get("sky_gradient_bottom", Color(0.06, 0.08, 0.18, 1.0))
	backdrop.polygon = PackedVector2Array([
		Vector2(-500.0, surface_origin_y - 900.0), Vector2(6200.0, surface_origin_y - 900.0),
		Vector2(6200.0, surface_origin_y + 80.0), Vector2(-500.0, surface_origin_y + 80.0)
	])
	backdrop.z_index = -10
	surface_root.add_child(backdrop)
	var particles = CPUParticles2D.new()
	particles.amount = 90
	particles.lifetime = 5.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(3000.0, 420.0)
	particles.position = Vector2(2500.0, surface_origin_y - 420.0)
	particles.gravity = Vector2(0.0, 18.0)
	particles.initial_velocity_min = 8.0
	particles.initial_velocity_max = 24.0
	particles.color = config.get("particle_color", Color(0.5, 0.7, 1.0, 0.2))
	surface_root.add_child(particles)

func _create_surface_terrain(config: Dictionary) -> void:
	var profile = _surface_profile(world_info.get("id", "earth"))
	_create_surface_platform(Vector2(2500.0, surface_origin_y + 22.0), Vector2(5600.0, 44.0), config.get("ground_color", Color(0.2, 0.25, 0.3)))
	for step in profile.get("steps", []):
		_create_surface_platform(Vector2(step.x, surface_origin_y + step.y), Vector2(360.0, 28.0), config.get("platform_color", Color(0.3, 0.6, 0.8)))

func _create_surface_platform(platform_position: Vector2, platform_size: Vector2, color: Color) -> void:
	var platform = StaticBody2D.new()
	platform.collision_layer = 2
	platform.collision_mask = 1
	platform.position = platform_position
	var shape_node = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.size = platform_size
	shape_node.shape = rectangle
	platform.add_child(shape_node)
	var visual = Polygon2D.new()
	visual.color = color
	visual.polygon = PackedVector2Array([
		Vector2(-platform_size.x * 0.5, -platform_size.y * 0.5),
		Vector2(platform_size.x * 0.5, -platform_size.y * 0.5),
		Vector2(platform_size.x * 0.5, platform_size.y * 0.5),
		Vector2(-platform_size.x * 0.5, platform_size.y * 0.5)
	])
	platform.add_child(visual)
	surface_root.add_child(platform)

func _spawn_surface_astronaut(config: Dictionary) -> void:
	surface_astronaut = surface_astronaut_scene.instantiate()
	surface_astronaut.configure(config)
	surface_astronaut.surface_width = config.get("surface_width", 4000.0)
	surface_astronaut.surface_floor_y = surface_origin_y
	var profile = _surface_profile(world_info.get("id", "earth"))
	surface_astronaut.position = Vector2(player.position.x + profile.get("start", 200.0), surface_origin_y - 48.0)
	surface_astronaut.astronaut_died.connect(_on_surface_astronaut_died)
	surface_root.add_child(surface_astronaut)

func _spawn_surface_objectives(config: Dictionary) -> void:
	var profile = _surface_profile(world_info.get("id", "earth"))
	var count = config.get("mandatory_count", 5)
	var route_start = player.position.x + profile.get("start", 200.0)
	var route_end = profile.get("gate", 4000.0) - 180.0
	for index in range(count):
		var resource = surface_resource_scene.instantiate()
		var progress = float(index + 1) / float(count + 1)
		var x = lerpf(route_start, route_end, progress)
		var y = surface_origin_y - 70.0 - float((index % 3) * 85)
		resource.position = Vector2(x, y)
		resource.set_resource_info(config.get("resource_name", "Surface Resource"), config.get("resource_icon", "*"), world_info.get("accent_color", Color(0.3, 1.0, 0.6)))
		surface_root.add_child(resource)

func _spawn_surface_hazards(config: Dictionary) -> void:
	var effects = config.get("env_effects", [])
	var hazard_kind = -1
	if effects.has(PlanetConfig.EnvEffect.ACID_RAIN):
		hazard_kind = SurfaceHazard.HazardKind.ACID
	elif effects.has(PlanetConfig.EnvEffect.TOXIC):
		hazard_kind = SurfaceHazard.HazardKind.TOXIC
	elif effects.has(PlanetConfig.EnvEffect.FIRE) or effects.has(PlanetConfig.EnvEffect.HEAT_WAVES):
		hazard_kind = SurfaceHazard.HazardKind.FIRE
	elif effects.has(PlanetConfig.EnvEffect.ICE):
		hazard_kind = SurfaceHazard.HazardKind.ICE_PATCH
	elif effects.has(PlanetConfig.EnvEffect.WIND) or effects.has(PlanetConfig.EnvEffect.DUST_STORM):
		hazard_kind = SurfaceHazard.HazardKind.WIND_GUST
	if hazard_kind < 0:
		return

	var damage = maxf(config.get("hazard_damage", 0.0), 0.0)
	for index in range(4):
		var hazard = surface_hazard_scene.instantiate()
		hazard.hazard_kind = hazard_kind
		hazard.damage_per_tick = damage
		hazard.zone_width = 180.0
		hazard.position = Vector2(player.position.x + 900.0 + index * 720.0, surface_origin_y - 22.0)
		surface_root.add_child(hazard)

func _update_surface_camera(delta: float) -> void:
	if surface_astronaut and is_instance_valid(surface_astronaut):
		camera.position = camera.position.lerp(surface_astronaut.position + Vector2(0.0, -120.0), 5.0 * delta)

func _update_surface_hud() -> void:
	if not surface_astronaut or not is_instance_valid(surface_astronaut) or not launch_gate:
		return
	var offset_to_gate = launch_gate.position - surface_astronaut.position
	hud.update_radar(offset_to_gate.length(), offset_to_gate.angle(), surface_astronaut.has_all_resources, -1.0, surface_astronaut.resources_collected, surface_astronaut.resources_required)

func _on_surface_astronaut_died(reason: String) -> void:
	GameState.fail_level(reason)

func _on_surface_boarding_started() -> void:
	if surface_root:
		for child in surface_root.get_children():
			if child != launch_gate:
				child.set_process(false)
				child.set_physics_process(false)

func _on_surface_takeoff_complete() -> void:
	GameState.complete_level()

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
	var required_cells = world_info.get("fuel_cell_count", 0)
	var has_resources = GameState.fuel_cells_collected >= required_cells

	var dist_devourer = -1.0
	if devourer and is_instance_valid(devourer):
		dist_devourer = (devourer.position - player.position).length()

	hud.update_radar(dist_gate, angle_gate, has_min and has_resources, dist_devourer, GameState.fuel_cells_collected, required_cells)
