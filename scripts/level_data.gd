class_name LevelData
extends RefCounted

# World definitions and level layout data

static func get_world_info(world_idx: int) -> Dictionary:
	var worlds = [
		{
			"id": "moon",
			"name": "WORLD 1 — THE FRACTURED MOON",
			"sub": "Outrun the Devourer. Forge the Energy Sword. Break the seal.",
			"length": 4500.0,
			"sky_top": Color("05071a"),
			"sky_bottom": Color("1a1250"),
			"nebula_color": Color(0.47, 0.24, 0.86, 0.35),
			"rock_color": Color("2b2457"),
			"rim_color": Color("7a6cff"),
			"planet_color": Color("e8a05a"),
			"planet_texture": "res://assets/planets/fractured_moon.svg",
			"bg_texture": "res://assets/backgrounds/world1_fractured_moon.svg",
			"hole_speed": 115.0,
			"meteor_rate": 3.0,
			"has_forge": true,
			"forge_x": 2400.0,
			"has_barrier": true,
			"barrier_x": 3400.0,
			"pod_x": 4200.0,
			"slip": false,
			"has_vents": false,
			"has_boss": false,
			"enemy_count": 8
		},
		{
			"id": "aether",
			"name": "WORLD 2 — AETHER-7",
			"sub": "A Sentinel guards the launch gate. Crystals hide on high plateaus.",
			"length": 4400.0,
			"sky_top": Color("031a1c"),
			"sky_bottom": Color("0e4a52"),
			"nebula_color": Color(0.24, 1.0, 0.82, 0.3),
			"rock_color": Color("2a6a66"),
			"rim_color": Color("7dffe0"),
			"planet_color": Color("ffd166"),
			"planet_texture": "res://assets/planets/aether_7.svg",
			"bg_texture": "res://assets/backgrounds/world2_aether7.svg",
			"hole_speed": 125.0,
			"meteor_rate": 2.8,
			"has_forge": false,
			"forge_x": 0.0,
			"has_barrier": false,
			"barrier_x": 0.0,
			"pod_x": 4200.0,
			"slip": false,
			"has_vents": false,
			"has_boss": true,
			"boss_type": "sentinel",
			"boss_x": 3800.0,
			"boss_hp": 10,
			"enemy_count": 7
		},
		{
			"id": "cinder",
			"name": "WORLD 3 — CINDER MOON",
			"sub": "Thermal vents erupt on a timer. Recover the Plasma Blaster.",
			"length": 4600.0,
			"sky_top": Color("1a0503"),
			"sky_bottom": Color("4a1208"),
			"nebula_color": Color(1.0, 0.31, 0.12, 0.35),
			"rock_color": Color("5a2a20"),
			"rim_color": Color("ff7a2e"),
			"planet_color": Color("ff9a4a"),
			"planet_texture": "res://assets/planets/cinder_moon.svg",
			"bg_texture": "res://assets/backgrounds/world3_cinder_moon.svg",
			"hole_speed": 135.0,
			"meteor_rate": 2.0,
			"has_forge": true,
			"forge_x": 2300.0,
			"has_barrier": false,
			"barrier_x": 0.0,
			"pod_x": 4350.0,
			"slip": false,
			"has_vents": true,
			"has_boss": false,
			"enemy_count": 9
		},
		{
			"id": "cryos",
			"name": "WORLD 4 — CRYOS",
			"sub": "Slick glacial ice. Unlock the Phase Shield before the frost consumes you.",
			"length": 4700.0,
			"sky_top": Color("04122a"),
			"sky_bottom": Color("123c6a"),
			"nebula_color": Color(0.47, 0.78, 1.0, 0.3),
			"rock_color": Color("7fb2d8"),
			"rim_color": Color("d8f4ff"),
			"planet_color": Color("b8e6ff"),
			"planet_texture": "res://assets/planets/cryos.svg",
			"bg_texture": "res://assets/backgrounds/world4_cryos.svg",
			"hole_speed": 140.0,
			"meteor_rate": 2.5,
			"has_forge": true,
			"forge_x": 2400.0,
			"has_barrier": false,
			"barrier_x": 0.0,
			"pod_x": 4450.0,
			"slip": true,
			"has_vents": false,
			"has_boss": false,
			"enemy_count": 10
		},
		{
			"id": "vortex",
			"name": "WORLD 5 — VORTEX PRIME",
			"sub": "Wield the Gravity Lance. Destroy the Vortex Guardian.",
			"length": 4900.0,
			"sky_top": Color("0a0220"),
			"sky_bottom": Color("2a0a5a"),
			"nebula_color": Color(0.71, 0.31, 1.0, 0.4),
			"rock_color": Color("3a2570"),
			"rim_color": Color("c58bff"),
			"planet_color": Color("6a3fd0"),
			"planet_texture": "res://assets/planets/vortex_prime.svg",
			"bg_texture": "res://assets/backgrounds/world5_vortex_prime.svg",
			"hole_speed": 150.0,
			"meteor_rate": 2.2,
			"has_forge": true,
			"forge_x": 2200.0,
			"has_barrier": false,
			"barrier_x": 0.0,
			"pod_x": 4650.0,
			"slip": false,
			"has_vents": false,
			"has_boss": true,
			"boss_type": "vortex",
			"boss_x": 4000.0,
			"boss_hp": 22,
			"enemy_count": 11
		},
		{
			"id": "earth",
			"name": "WORLD 6 — EARTH",
			"sub": "Home horizon. The Devourer is at your heels. Sprint to the bunker!",
			"length": 4200.0,
			"sky_top": Color("0a1f4a"),
			"sky_bottom": Color("3d86d0"),
			"nebula_color": Color(1.0, 1.0, 1.0, 0.2),
			"rock_color": Color("3a6b4a"),
			"rim_color": Color("9dffb8"),
			"planet_color": Color("ffd166"),
			"planet_texture": "res://assets/planets/earth.svg",
			"bg_texture": "res://assets/backgrounds/world6_earth.svg",
			"hole_speed": 160.0,
			"meteor_rate": 1.8,
			"has_forge": false,
			"forge_x": 0.0,
			"has_barrier": false,
			"barrier_x": 0.0,
			"pod_x": 3950.0,
			"slip": false,
			"has_vents": true,
			"has_boss": false,
			"enemy_count": 14
		}
	]
	
	if world_idx < 0 or world_idx >= 6:
		return {}

	var route_order: Array[int] = [1, 2, 3, 4, 5, 0]
	var info: Dictionary = worlds[route_order[world_idx]].duplicate()
	var route_names: Array[String] = ["AETHER-7", "CINDER", "CRYOS", "VORTEX", "SYLVA", "OBSIDIAN"]
	var forge_rewards: Array[String] = ["blaster", "shield", "lance", "blaster", "shield", "lance"]
	info["id"] = route_names[world_idx].to_lower()
	info["name"] = "WORLD %d — %s" % [world_idx + 1, route_names[world_idx]]
	info["has_forge"] = true
	info["forge_x"] = [1450.0, 1600.0, 1500.0, 1650.0, 1400.0, 1550.0][world_idx]
	info["forge_reward"] = forge_rewards[world_idx]

	if world_idx == 0:
		info["sub"] = "A crystal world humming with a signal beneath its broken spires."
	elif world_idx == 1:
		info["sub"] = "A volcanic moon where thermal vents erupt across the black glass."
	elif world_idx == 2:
		info["sub"] = "Cross slick glacial shelves beneath the Cryos stormfront."
	elif world_idx == 3:
		info["sub"] = "Gravity folds the Vortex terrain around a guarded extraction route."
	elif world_idx == 4:
		info["sub"] = "An alien canopy surrounds the overgrown remnants of a lost colony."
		info["sky_top"] = Color("071b16")
		info["sky_bottom"] = Color("174c36")
		info["nebula_color"] = Color(0.24, 0.92, 0.48, 0.3)
		info["rock_color"] = Color("28533a")
		info["rim_color"] = Color("9dff9a")
		info["planet_color"] = Color("a8f28c")
		info["has_vents"] = false
	else:
		info["sub"] = "Ancient obsidian ruins conceal a final route through the fractured dark."
		info["sky_top"] = Color("090c16")
		info["sky_bottom"] = Color("29243a")
		info["nebula_color"] = Color(0.62, 0.52, 0.72, 0.28)
		info["rock_color"] = Color("34313c")
		info["rim_color"] = Color("d1b8ff")
		info["planet_color"] = Color("b6a4c8")
		info["has_vents"] = false
		info["has_barrier"] = true
		info["barrier_x"] = 3400.0
		info["has_boss"] = false
	return info
