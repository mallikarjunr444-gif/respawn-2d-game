extends Node2D

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var camera: Camera2D = $Camera2D
@onready var hud: CanvasLayer = $HUD
@onready var puzzle_modal: CanvasLayer = $PuzzleModal
@onready var parallax_bg: ParallaxBackground = $ParallaxBackground
@onready var planet_sprite: Sprite2D = $ParallaxBackground/ParallaxLayerPlanet/PlanetSprite
@onready var sky_rect: ColorRect = $ParallaxBackground/ParallaxLayerSky/SkyRect

var player_scene = preload("res://scenes/player.tscn")
var devourer_scene = preload("res://scenes/devourer.tscn")
var voidling_scene = preload("res://scenes/enemies/voidling.tscn")
var boss_scene = preload("res://scenes/enemies/boss.tscn")
var crystal_scene = preload("res://scenes/objects/crystal.tscn")
var health_pack_scene = preload("res://scenes/objects/health_pack.tscn")
var meteor_scene = preload("res://scenes/objects/meteor.tscn")
var barrier_scene = preload("res://scenes/objects/crystal_barrier.tscn")
var forge_scene = preload("res://scenes/objects/forge_terminal.tscn")
var pod_scene = preload("res://scenes/objects/escape_pod.tscn")

var player: CharacterBody2D = null
var devourer: Node2D = null
var world_info: Dictionary = {}
var meteor_timer: float = 3.0
var screen_shake: float = 0.0

const GROUND_Y = 560.0

func _ready() -> void:
	world_info = LevelData.get_world_info(GameState.current_world_idx)
	_setup_environment()
	_generate_level()
	
	GameState.level_completed.connect(_on_level_completed)
	hud.set_sector_title(world_info["name"])
	GameState.show_toast(world_info["name"], world_info["sub"], 4.5)

func _setup_environment() -> void:
	sky_rect.color = world_info["sky_top"]
	if ResourceLoader.exists(world_info["planet_texture"]):
		planet_sprite.texture = load(world_info["planet_texture"])
		planet_sprite.modulate = world_info["planet_color"]

func _generate_level() -> void:
	var level_len = world_info["length"]
	
	# Spawn Player
	player = player_scene.instantiate()
	player.position = Vector2(180.0, GROUND_Y - 40.0)
	player.is_slippery = world_info.get("slip", false)
	add_child(player)
	
	# Spawn Devourer
	devourer = devourer_scene.instantiate()
	devourer.position = Vector2(player.position.x - 780.0, GROUND_Y - 80.0)
	devourer.speed = world_info["hole_speed"]
	devourer.target_player = player
	add_child(devourer)
	
	# Ground segments & pits
	var x = -400.0
	while x < level_len:
		var seg_len = randf_range(500.0, 950.0)
		_create_ground_segment(x, x + seg_len, GROUND_Y)
		
		# Spawn floating platforms above
		var plat_count = randi_range(1, 3)
		for p in range(plat_count):
			var plat_x = x + randf_range(100.0, seg_len - 100.0)
			var plat_y = GROUND_Y - randf_range(120.0, 220.0)
			_create_platform(plat_x, plat_y, randf_range(120.0, 180.0))
			
		x += seg_len + randf_range(120.0, 240.0) # gap / pit
		
	# Final safe extraction pad ground
	_create_ground_segment(level_len - 400.0, level_len + 600.0, GROUND_Y)
	
	# Spawn Forge
	if world_info["has_forge"]:
		var forge = forge_scene.instantiate()
		forge.position = Vector2(world_info["forge_x"], GROUND_Y)
		var rewards = ["sword", "blaster", "shield", "lance"]
		forge.reward = rewards[clampi(GameState.current_world_idx, 0, 3)]
		forge.puzzle_requested.connect(_on_forge_puzzle_requested)
		add_child(forge)
		
	# Spawn Barrier
	if world_info["has_barrier"]:
		var barrier = barrier_scene.instantiate()
		barrier.position = Vector2(world_info["barrier_x"], GROUND_Y)
		add_child(barrier)
		
	# Spawn Boss
	if world_info["has_boss"]:
		var boss = boss_scene.instantiate()
		boss.boss_type = world_info.get("boss_type", "sentinel")
		boss.position = Vector2(world_info["boss_x"], GROUND_Y - 140.0)
		boss.target_player = player
		add_child(boss)
		
	# Spawn Escape Pod
	var pod = pod_scene.instantiate()
	pod.position = Vector2(world_info["pod_x"], GROUND_Y)
	add_child(pod)
	
	# Spawn Enemies (Voidlings)
	for i in range(world_info["enemy_count"]):
		var enemy = voidling_scene.instantiate()
		var ex = randf_range(600.0, level_len - 600.0)
		enemy.position = Vector2(ex, GROUND_Y - 90.0)
		add_child(enemy)
		
	# Spawn Crystals & Health Packs
	for c in range(24):
		var crystal = crystal_scene.instantiate()
		crystal.position = Vector2(randf_range(300.0, level_len - 200.0), GROUND_Y - randf_range(40.0, 180.0))
		add_child(crystal)
		
	for h in range(3):
		var hp_pack = health_pack_scene.instantiate()
		hp_pack.position = Vector2(randf_range(800.0, level_len - 800.0), GROUND_Y - 160.0)
		add_child(hp_pack)

func _create_ground_segment(x0: float, x1: float, y: float) -> void:
	var body = StaticBody2D.new()
	body.collision_layer = 2
	body.collision_mask = 1
	
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	var w = x1 - x0
	shape.size = Vector2(w, 240.0)
	col.shape = shape
	col.position = Vector2((x0 + x1) * 0.5, y + 120.0)
	body.add_child(col)
	
	var poly = Polygon2D.new()
	poly.color = world_info["rock_color"]
	poly.polygon = PackedVector2Array([
		Vector2(x0, y), Vector2(x1, y),
		Vector2(x1, y + 240.0), Vector2(x0, y + 240.0)
	])
	body.add_child(poly)
	
	# Neon rim
	var rim = Line2D.new()
	rim.points = PackedVector2Array([Vector2(x0, y), Vector2(x1, y)])
	rim.default_color = world_info["rim_color"]
	rim.width = 4.0
	body.add_child(rim)
	
	add_child(body)

func _create_platform(px: float, py: float, pw: float) -> void:
	var body = StaticBody2D.new()
	body.collision_layer = 2
	body.collision_mask = 1
	
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(pw, 16.0)
	col.shape = shape
	col.position = Vector2(px + pw * 0.5, py + 8.0)
	body.add_child(col)
	
	var poly = Polygon2D.new()
	poly.color = world_info["rock_color"]
	poly.polygon = PackedVector2Array([
		Vector2(px, py), Vector2(px + pw, py),
		Vector2(px + pw, py + 16.0), Vector2(px, py + 16.0)
	])
	body.add_child(poly)
	
	var rim = Line2D.new()
	rim.points = PackedVector2Array([Vector2(px, py), Vector2(px + pw, py)])
	rim.default_color = world_info["rim_color"]
	rim.width = 3.0
	body.add_child(rim)
	
	add_child(body)

func _process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		return
		
	# Camera tracking with smooth lead
	var target_cam_x = player.position.x + player.facing_dir * 80.0
	camera.position.x = lerp(camera.position.x, target_cam_x, delta * 5.0)
	camera.position.y = lerp(camera.position.y, clampf(player.position.y - 40.0, 200.0, 560.0), delta * 4.0)
	
	# Screen shake
	if screen_shake > 0.0:
		screen_shake -= delta * 15.0
		camera.offset = Vector2(randf_range(-screen_shake, screen_shake), randf_range(-screen_shake, screen_shake))
	else:
		camera.offset = Vector2.ZERO
		
	# Devourer radar distance
	if devourer and is_instance_valid(devourer):
		var dist = player.position.x - devourer.position.x
		hud.update_radar(dist)
		
	# Fall into void check
	if player.position.y > GROUND_Y + 300.0:
		player.take_damage(99, "LOST TO THE VOID")
		
	# Meteors
	meteor_timer -= delta
	if meteor_timer <= 0.0:
		meteor_timer = randf_range(world_info["meteor_rate"] * 0.7, world_info["meteor_rate"] * 1.3)
		_spawn_meteor()

func _spawn_meteor() -> void:
	if not player:
		return
	var m = meteor_scene.instantiate()
	var spawn_x = player.position.x + randf_range(140.0, 480.0)
	m.position = Vector2(spawn_x, -100.0)
	m.target_y = GROUND_Y
	add_child(m)

func _on_forge_puzzle_requested(_reward_type: String) -> void:
	puzzle_modal.open_puzzle()
	puzzle_modal.puzzle_solved.connect(_on_puzzle_solved, CONNECT_ONE_SHOT)

func _on_puzzle_solved() -> void:
	for node in get_tree().get_nodes_in_group("interactables"):
		if node.has_method("unlock_forge"):
			node.unlock_forge()

func _on_level_completed() -> void:
	hud.show_victory()
