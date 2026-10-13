class_name LevelData
extends RefCounted

# Space Odyssey — 10 Planet Campaign Data
# Each planet defines unique gravity, wind, hazards, visual themes, and gameplay.
# Gas/ice giants are atmospheric flight courses, not solid-surface landings.

enum HazardType {
	NONE,
	ASTEROIDS,       # Black Space — floating rocks pulled by black hole
	ICY_DEBRIS,      # Neptune — frozen chunks + wind
	DUST_STORM,      # Mars — reduced visibility + rocky obstacles
	RING_DEBRIS,     # Saturn — orbiting ice fragments in ring bands
	STORM_WINDS,     # Jupiter — powerful wind zones + moving storms
	SATELLITES,      # Earth — satellite debris, recovery checkpoint
	SIDEWAYS_WIND,   # Uranus — unusual wind direction + icy passages
	HEAT_ZONES,      # Mercury — sun-lit danger zones + shadow safe zones
	ACID_CLOUDS,     # Venus — corrosive zones + turbulent air
	ICE_CAVES,       # Pluto — low gravity, narrow icy passages
}

static func get_planet_count() -> int:
	return 10

static func get_world_info(world_idx: int) -> Dictionary:
	var worlds = [
		# ═══════════════════════════════════════════════════════════════
		# LEVEL 1 — BLACK SPACE (Tutorial + Black Hole Mechanic)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "black_space",
			"name": "LEVEL 1 — BLACK SPACE",
			"subtitle": "Escape the gravitational pull. Learn to fly.",
			"is_space": true,
			"level_width": 6000.0,
			"level_height": 4000.0,

			# Visual theme
			"sky_color": Color(0.01, 0.01, 0.04, 1.0),
			"nebula_color": Color(0.15, 0.05, 0.30, 0.3),
			"star_color": Color(0.7, 0.7, 1.0, 0.8),
			"accent_color": Color(0.6, 0.2, 1.0),
			"atmosphere_particles": Color(0.4, 0.1, 0.8, 0.15),

			# Physics
			"gravity_strength": 200.0,    # Gentle cosmic downward drift
			"wind_strength": 0.0,
			"wind_direction": Vector2.ZERO,
			"drag_coefficient": 0.015,

			# Black hole (Level 1 ONLY — Positioned BEHIND player on left)
			"has_black_hole": true,
			"black_hole_position": Vector2(500.0, 2000.0),
			"black_hole_pull_radius": 2200.0,
			"black_hole_pull_strength": 420.0,
			"black_hole_kill_radius": 180.0,

			# Hazards
			"hazard_type": HazardType.ASTEROIDS,
			"asteroid_count": 25,
			"comet_count": 5,
			"meteor_rate": 4.0,

			# Collectibles
			"fuel_cell_count": 30,
			"energy_orb_count": 8,
			"bonus_fuel_route": true,

			# Gate — Escape Route to the RIGHT
			"launch_gate_position": Vector2(5500.0, 2000.0),
			"min_fuel_to_launch": 15.0,  # Forgiving percentage to avoid stranding

			# Spawn — Astronaut starts 900px to the RIGHT of black hole, facing RIGHT
			"player_start": Vector2(1200.0, 2000.0),
		},

		# ═══════════════════════════════════════════════════════════════
		# LEVEL 2 — NEPTUNE (Azure Gas Giant)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "neptune",
			"name": "LEVEL 2 — NEPTUNE",
			"subtitle": "Azure atmosphere. Icy debris and high-velocity wind streams.",
			"is_space": false,
			"level_width": 7000.0,
			"level_height": 4500.0,

			"sky_color": Color(0.01, 0.04, 0.18, 1.0),
			"nebula_color": Color(0.12, 0.28, 0.75, 0.4),
			"star_color": Color(0.6, 0.8, 1.0, 0.7),
			"accent_color": Color(0.25, 0.65, 1.0),
			"planet_texture": "res://assets/planets/cryos.svg",
			"background_texture": "res://assets/backgrounds/world4_cryos.svg",
			"atmosphere_particles": Color(0.2, 0.6, 1.0, 0.35),

			"gravity_strength": 220.0,
			"wind_strength": 140.0,
			"wind_direction": Vector2(-1.0, 0.2).normalized(),
			"drag_coefficient": 0.02,

			"has_black_hole": false,

			"hazard_type": HazardType.ICY_DEBRIS,
			"asteroid_count": 20,
			"comet_count": 0,
			"meteor_rate": 5.0,
			"ice_chunk_count": 22,
			"visibility_range": 750.0,

			"fuel_cell_count": 32,
			"energy_orb_count": 8,
			"bonus_fuel_route": true,

			"launch_gate_position": Vector2(6200.0, 2200.0),
			"min_fuel_to_launch": 15.0,
			"player_start": Vector2(600.0, 2200.0),
		},

		# ═══════════════════════════════════════════════════════════════
		# LEVEL 3 — MARS (Rust-Red Terrain)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "mars",
			"name": "LEVEL 3 — MARS",
			"subtitle": "Dust storms and rocky canyons. Time your bursts.",
			"level_width": 6500.0,
			"level_height": 4000.0,

			"sky_color": Color(0.18, 0.06, 0.02, 1.0),
			"nebula_color": Color(0.6, 0.15, 0.05, 0.35),
			"star_color": Color(1.0, 0.7, 0.5, 0.4),
			"accent_color": Color(0.9, 0.3, 0.1),
			"atmosphere_particles": Color(0.7, 0.25, 0.08, 0.25),

			"gravity_strength": 500.0,  # Stronger surface gravity feel
			"wind_strength": 120.0,
			"wind_direction": Vector2(1.0, 0.0),
			"drag_coefficient": 0.03,

			"has_black_hole": false,

			"hazard_type": HazardType.DUST_STORM,
			"asteroid_count": 15,
			"comet_count": 0,
			"meteor_rate": 3.5,
			"dust_storm_count": 4,
			"rocky_obstacle_count": 20,

			"fuel_cell_count": 26,
			"energy_orb_count": 7,
			"bonus_fuel_route": true,

			"launch_gate_position": Vector2(5900.0, 900.0),
			"min_fuel_to_launch": 25.0,
			"player_start": Vector2(400.0, 3200.0),
		},

		# ═══════════════════════════════════════════════════════════════
		# LEVEL 4 — SATURN (Golden Rings)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "saturn",
			"name": "LEVEL 4 — SATURN",
			"subtitle": "Fly through the golden rings. Dodge orbiting ice.",
			"level_width": 8000.0,
			"level_height": 5000.0,

			"sky_color": Color(0.12, 0.08, 0.02, 1.0),
			"nebula_color": Color(0.7, 0.5, 0.15, 0.3),
			"star_color": Color(1.0, 0.9, 0.6, 0.6),
			"accent_color": Color(1.0, 0.75, 0.2),
			"atmosphere_particles": Color(0.8, 0.6, 0.15, 0.15),

			"gravity_strength": 320.0,
			"wind_strength": 80.0,
			"wind_direction": Vector2(0.0, -1.0),
			"drag_coefficient": 0.025,

			"has_black_hole": false,

			"hazard_type": HazardType.RING_DEBRIS,
			"asteroid_count": 12,
			"comet_count": 0,
			"meteor_rate": 6.0,
			"ring_band_count": 5,
			"ring_debris_per_band": 8,

			"fuel_cell_count": 32,
			"energy_orb_count": 10,
			"bonus_fuel_route": true,

			"launch_gate_position": Vector2(7400.0, 1500.0),
			"min_fuel_to_launch": 20.0,
			"player_start": Vector2(400.0, 2500.0),
		},

		# ═══════════════════════════════════════════════════════════════
		# LEVEL 5 — JUPITER (Storms)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "jupiter",
			"name": "LEVEL 5 — JUPITER",
			"subtitle": "Powerful storms and crushing winds. Hold your course.",
			"level_width": 8500.0,
			"level_height": 5500.0,

			"sky_color": Color(0.14, 0.08, 0.03, 1.0),
			"nebula_color": Color(0.8, 0.45, 0.15, 0.35),
			"star_color": Color(1.0, 0.85, 0.5, 0.5),
			"accent_color": Color(1.0, 0.6, 0.2),
			"atmosphere_particles": Color(0.9, 0.5, 0.1, 0.2),

			"gravity_strength": 550.0,  # Strongest gravity
			"wind_strength": 280.0,     # Very strong winds
			"wind_direction": Vector2(-1.0, -0.5).normalized(),
			"drag_coefficient": 0.05,

			"has_black_hole": false,

			"hazard_type": HazardType.STORM_WINDS,
			"asteroid_count": 10,
			"comet_count": 0,
			"meteor_rate": 3.0,
			"storm_zone_count": 6,
			"wind_gust_strength": 400.0,

			"fuel_cell_count": 30,
			"energy_orb_count": 8,
			"bonus_fuel_route": true,

			"launch_gate_position": Vector2(7800.0, 1400.0),
			"min_fuel_to_launch": 30.0,
			"player_start": Vector2(400.0, 2800.0),
		},

		# ═══════════════════════════════════════════════════════════════
		# LEVEL 6 — EARTH (Recovery Checkpoint)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "earth",
			"name": "LEVEL 6 — EARTH",
			"subtitle": "Home. Refuel, repair, and prepare for the outer rim.",
			"level_width": 5500.0,
			"level_height": 3500.0,

			"sky_color": Color(0.03, 0.08, 0.2, 1.0),
			"nebula_color": Color(0.2, 0.5, 0.9, 0.2),
			"star_color": Color(0.9, 0.95, 1.0, 0.7),
			"accent_color": Color(0.3, 0.7, 1.0),
			"atmosphere_particles": Color(0.4, 0.7, 1.0, 0.1),

			"gravity_strength": 420.0,
			"wind_strength": 60.0,
			"wind_direction": Vector2(0.5, 0.0),
			"drag_coefficient": 0.03,

			"has_black_hole": false,

			"hazard_type": HazardType.SATELLITES,
			"asteroid_count": 8,
			"comet_count": 0,
			"meteor_rate": 8.0,
			"satellite_count": 12,
			"is_checkpoint_level": true,  # Bonus refuel

			"fuel_cell_count": 40,  # Extra generous — recovery level
			"energy_orb_count": 12,
			"bonus_fuel_route": true,

			"launch_gate_position": Vector2(4900.0, 800.0),
			"min_fuel_to_launch": 15.0,  # Lower threshold — recovery
			"player_start": Vector2(400.0, 1800.0),
		},

		# ═══════════════════════════════════════════════════════════════
		# LEVEL 7 — URANUS (Pale Cyan)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "uranus",
			"name": "LEVEL 7 — URANUS",
			"subtitle": "Sideways winds and narrow icy passages.",
			"level_width": 7500.0,
			"level_height": 5000.0,

			"sky_color": Color(0.04, 0.12, 0.16, 1.0),
			"nebula_color": Color(0.3, 0.7, 0.8, 0.25),
			"star_color": Color(0.7, 0.9, 1.0, 0.6),
			"accent_color": Color(0.4, 0.9, 0.95),
			"atmosphere_particles": Color(0.5, 0.85, 0.9, 0.15),

			"gravity_strength": 360.0,
			"wind_strength": 200.0,
			"wind_direction": Vector2(0.0, 1.0),  # Sideways (vertical push)
			"drag_coefficient": 0.035,

			"has_black_hole": false,

			"hazard_type": HazardType.SIDEWAYS_WIND,
			"asteroid_count": 14,
			"comet_count": 0,
			"meteor_rate": 5.0,
			"ice_passage_count": 6,
			"narrow_gap_width": 180.0,

			"fuel_cell_count": 26,
			"energy_orb_count": 7,
			"bonus_fuel_route": true,

			"launch_gate_position": Vector2(6900.0, 1300.0),
			"min_fuel_to_launch": 25.0,
			"player_start": Vector2(400.0, 2500.0),
		},

		# ═══════════════════════════════════════════════════════════════
		# LEVEL 8 — MERCURY (Extreme Heat)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "mercury",
			"name": "LEVEL 8 — MERCURY",
			"subtitle": "Scorching sunlight and deep craters. Manage heat and fuel.",
			"level_width": 6000.0,
			"level_height": 4000.0,

			"sky_color": Color(0.08, 0.04, 0.02, 1.0),
			"nebula_color": Color(0.9, 0.4, 0.1, 0.3),
			"star_color": Color(1.0, 0.9, 0.7, 0.5),
			"accent_color": Color(1.0, 0.5, 0.1),
			"atmosphere_particles": Color(1.0, 0.6, 0.2, 0.15),

			"gravity_strength": 480.0,
			"wind_strength": 0.0,    # No atmosphere
			"wind_direction": Vector2.ZERO,
			"drag_coefficient": 0.01,  # Near-vacuum

			"has_black_hole": false,

			"hazard_type": HazardType.HEAT_ZONES,
			"asteroid_count": 16,
			"comet_count": 0,
			"meteor_rate": 4.0,
			"heat_zone_count": 8,
			"shadow_zone_count": 5,  # Safe zones in shadow
			"heat_damage_rate": 2.0,  # Fuel drain per second in heat

			"fuel_cell_count": 28,
			"energy_orb_count": 6,
			"bonus_fuel_route": true,

			"launch_gate_position": Vector2(5400.0, 1100.0),
			"min_fuel_to_launch": 30.0,
			"player_start": Vector2(400.0, 2000.0),
		},

		# ═══════════════════════════════════════════════════════════════
		# LEVEL 9 — VENUS (Turbulent Atmosphere)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "venus",
			"name": "LEVEL 9 — VENUS",
			"subtitle": "Corrosive clouds and violent air currents. Find the safe route.",
			"level_width": 7000.0,
			"level_height": 4500.0,

			"sky_color": Color(0.16, 0.1, 0.02, 1.0),
			"nebula_color": Color(0.9, 0.6, 0.1, 0.4),
			"star_color": Color(1.0, 0.8, 0.4, 0.3),
			"accent_color": Color(1.0, 0.7, 0.15),
			"atmosphere_particles": Color(0.9, 0.65, 0.1, 0.25),

			"gravity_strength": 440.0,
			"wind_strength": 250.0,  # Very turbulent
			"wind_direction": Vector2(-0.7, -0.7).normalized(),
			"drag_coefficient": 0.06,  # Dense atmosphere

			"has_black_hole": false,

			"hazard_type": HazardType.ACID_CLOUDS,
			"asteroid_count": 10,
			"comet_count": 0,
			"meteor_rate": 4.5,
			"acid_cloud_count": 10,
			"turbulence_zone_count": 6,
			"acid_damage_rate": 3.0,  # Fuel drain in acid zones

			"fuel_cell_count": 30,
			"energy_orb_count": 8,
			"bonus_fuel_route": true,

			"launch_gate_position": Vector2(6400.0, 1000.0),
			"min_fuel_to_launch": 30.0,
			"player_start": Vector2(400.0, 2200.0),
		},

		# ═══════════════════════════════════════════════════════════════
		# LEVEL 10 — PLUTO (Endgame)
		# ═══════════════════════════════════════════════════════════════
		{
			"id": "pluto",
			"name": "LEVEL 10 — PLUTO",
			"subtitle": "The frozen edge. Low gravity, icy caverns, the final portal.",
			"level_width": 7500.0,
			"level_height": 5000.0,

			"sky_color": Color(0.02, 0.03, 0.08, 1.0),
			"nebula_color": Color(0.3, 0.4, 0.7, 0.2),
			"star_color": Color(0.8, 0.85, 1.0, 0.9),
			"accent_color": Color(0.6, 0.8, 1.0),
			"atmosphere_particles": Color(0.5, 0.6, 0.9, 0.1),

			"gravity_strength": 180.0,   # Very low gravity
			"wind_strength": 40.0,
			"wind_direction": Vector2(0.3, -0.1).normalized(),
			"drag_coefficient": 0.01,    # Nearly no atmosphere

			"has_black_hole": false,

			"hazard_type": HazardType.ICE_CAVES,
			"asteroid_count": 20,
			"comet_count": 3,
			"meteor_rate": 6.0,
			"ice_wall_count": 15,
			"narrow_passage_count": 8,
			"is_endgame": true,

			"fuel_cell_count": 24,
			"energy_orb_count": 10,
			"bonus_fuel_route": true,

			"launch_gate_position": Vector2(6900.0, 1200.0),
			"min_fuel_to_launch": 35.0,  # Hardest requirement
			"player_start": Vector2(400.0, 2500.0),
		},
	]

	if world_idx < 0 or world_idx >= worlds.size():
		return worlds[0]
	return worlds[world_idx]
