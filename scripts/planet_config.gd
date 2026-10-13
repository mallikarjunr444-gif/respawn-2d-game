class_name PlanetConfig
extends RefCounted

# ═══════════════════════════════════════════════════════════════
# SPACE ODYSSEY — Planet Surface Configuration
# Maps each existing planet to unique surface environments,
# hazards, resource types, and gameplay modifiers.
# Used by the surface level generator to build playable areas.
# ═══════════════════════════════════════════════════════════════

enum EnvEffect {
	NONE,
	WIND,          # Pushes astronaut, affects jumping
	FIRE,          # Damages astronaut, timed hazard zones
	ICE,           # Reduces friction, slippery surfaces
	TOXIC,         # Consumes suit protection / oxygen
	LOW_GRAVITY,   # Floaty jumps, slow falling
	HIGH_GRAVITY,  # Short jumps, fast falling
	DUST_STORM,    # Reduced visibility, random pushes
	ACID_RAIN,     # Periodic damage from above
	HEAT_WAVES,    # Alternating safe/danger zones
}

enum ResourceType {
	CRYSTAL,       # Generic collectible
	FUEL_CELL,     # Fuel for rocket
	DATA_CORE,     # Ancient data fragments
	MINERAL,       # Rare mineral deposit
	ICE_SAMPLE,    # Frozen specimen
	ENERGY_SHARD,  # Power source
}

static func get_surface_config(planet_id: String) -> Dictionary:
	var configs = {
		# ═══════════════════════════════════════════════════════════
		# BLACK SPACE — Tutorial: Low gravity, floating platforms
		# ═══════════════════════════════════════════════════════════
		"black_space": {
			"surface_name": "Singularity Station Wreckage",
			"env_effects": [EnvEffect.LOW_GRAVITY],
			"gravity_mult": 0.4,
			"friction": 0.85,
			"wind_force": Vector2.ZERO,
			"wind_variance": 0.0,
			"resource_type": ResourceType.ENERGY_SHARD,
			"resource_name": "Energy Shard",
			"resource_icon": "⚡",
			"mandatory_count": 5,
			"bonus_count": 3,
			"hazard_damage": 0.0,
			"hazard_interval": 0.0,
			"oxygen_drain": 0.0,
			"platform_count": 12,
			"platform_gap_min": 180.0,
			"platform_gap_max": 320.0,
			"ground_color": Color(0.15, 0.1, 0.25),
			"platform_color": Color(0.3, 0.2, 0.5, 0.9),
			"hazard_color": Color(0.6, 0.2, 1.0, 0.4),
			"sky_gradient_top": Color(0.01, 0.01, 0.04),
			"sky_gradient_bottom": Color(0.08, 0.04, 0.15),
			"particle_color": Color(0.5, 0.3, 0.9, 0.15),
			"surface_width": 4000.0,
			"surface_height": 2000.0,
		},

		# ═══════════════════════════════════════════════════════════
		# NEPTUNE — Ice platforms, strong wind, slippery
		# ═══════════════════════════════════════════════════════════
		"neptune": {
			"surface_name": "Neptune Frozen Crust",
			"env_effects": [EnvEffect.ICE, EnvEffect.WIND],
			"gravity_mult": 0.75,
			"friction": 0.35,  # Very slippery ice
			"wind_force": Vector2(-120.0, 0.0),
			"wind_variance": 60.0,
			"resource_type": ResourceType.ICE_SAMPLE,
			"resource_name": "Ice Core Sample",
			"resource_icon": "❄️",
			"mandatory_count": 7,
			"bonus_count": 4,
			"hazard_damage": 0.0,
			"hazard_interval": 0.0,
			"oxygen_drain": 0.0,
			"platform_count": 16,
			"platform_gap_min": 140.0,
			"platform_gap_max": 280.0,
			"ground_color": Color(0.15, 0.3, 0.55),
			"platform_color": Color(0.4, 0.7, 1.0, 0.85),
			"hazard_color": Color(0.3, 0.6, 1.0, 0.3),
			"sky_gradient_top": Color(0.01, 0.04, 0.18),
			"sky_gradient_bottom": Color(0.1, 0.25, 0.5),
			"particle_color": Color(0.5, 0.8, 1.0, 0.2),
			"surface_width": 5000.0,
			"surface_height": 2200.0,
		},

		# ═══════════════════════════════════════════════════════════
		# MARS — Dust storms, rocky terrain, wind gusts
		# ═══════════════════════════════════════════════════════════
		"mars": {
			"surface_name": "Mars Canyon Outpost",
			"env_effects": [EnvEffect.DUST_STORM, EnvEffect.WIND],
			"gravity_mult": 0.9,
			"friction": 0.8,
			"wind_force": Vector2(80.0, 0.0),
			"wind_variance": 100.0,
			"resource_type": ResourceType.MINERAL,
			"resource_name": "Martian Ore",
			"resource_icon": "🪨",
			"mandatory_count": 8,
			"bonus_count": 4,
			"hazard_damage": 0.5,
			"hazard_interval": 3.0,  # Dust storm damage tick
			"oxygen_drain": 0.0,
			"platform_count": 14,
			"platform_gap_min": 160.0,
			"platform_gap_max": 300.0,
			"ground_color": Color(0.5, 0.18, 0.06),
			"platform_color": Color(0.6, 0.25, 0.1, 0.9),
			"hazard_color": Color(0.7, 0.3, 0.1, 0.35),
			"sky_gradient_top": Color(0.18, 0.06, 0.02),
			"sky_gradient_bottom": Color(0.4, 0.15, 0.05),
			"particle_color": Color(0.7, 0.35, 0.12, 0.25),
			"surface_width": 5200.0,
			"surface_height": 2000.0,
		},

		# ═══════════════════════════════════════════════════════════
		# SATURN — Ring debris falling, moderate gravity
		# ═══════════════════════════════════════════════════════════
		"saturn": {
			"surface_name": "Saturn Ring Platform",
			"env_effects": [EnvEffect.LOW_GRAVITY],
			"gravity_mult": 0.6,
			"friction": 0.7,
			"wind_force": Vector2(0.0, -30.0),
			"wind_variance": 20.0,
			"resource_type": ResourceType.CRYSTAL,
			"resource_name": "Ring Crystal",
			"resource_icon": "💎",
			"mandatory_count": 9,
			"bonus_count": 5,
			"hazard_damage": 1.0,
			"hazard_interval": 5.0,  # Falling debris interval
			"oxygen_drain": 0.0,
			"platform_count": 18,
			"platform_gap_min": 200.0,
			"platform_gap_max": 380.0,
			"ground_color": Color(0.35, 0.28, 0.12),
			"platform_color": Color(0.7, 0.55, 0.2, 0.85),
			"hazard_color": Color(0.9, 0.7, 0.2, 0.25),
			"sky_gradient_top": Color(0.12, 0.08, 0.02),
			"sky_gradient_bottom": Color(0.3, 0.22, 0.08),
			"particle_color": Color(0.8, 0.65, 0.2, 0.15),
			"surface_width": 5500.0,
			"surface_height": 2400.0,
		},

		# ═══════════════════════════════════════════════════════════
		# JUPITER — Massive storms, extreme wind, high gravity
		# ═══════════════════════════════════════════════════════════
		"jupiter": {
			"surface_name": "Jupiter Storm Station",
			"env_effects": [EnvEffect.WIND, EnvEffect.HIGH_GRAVITY],
			"gravity_mult": 1.5,
			"friction": 0.75,
			"wind_force": Vector2(-200.0, -60.0),
			"wind_variance": 150.0,
			"resource_type": ResourceType.ENERGY_SHARD,
			"resource_name": "Storm Core",
			"resource_icon": "⚡",
			"mandatory_count": 8,
			"bonus_count": 4,
			"hazard_damage": 1.0,
			"hazard_interval": 2.5,  # Storm damage interval
			"oxygen_drain": 0.0,
			"platform_count": 14,
			"platform_gap_min": 120.0,
			"platform_gap_max": 240.0,
			"ground_color": Color(0.35, 0.2, 0.08),
			"platform_color": Color(0.6, 0.4, 0.15, 0.9),
			"hazard_color": Color(1.0, 0.6, 0.15, 0.3),
			"sky_gradient_top": Color(0.14, 0.08, 0.03),
			"sky_gradient_bottom": Color(0.35, 0.2, 0.08),
			"particle_color": Color(0.9, 0.55, 0.15, 0.2),
			"surface_width": 4800.0,
			"surface_height": 2000.0,
		},

		# ═══════════════════════════════════════════════════════════
		# EARTH — Safe haven, mild conditions, generous resources
		# ═══════════════════════════════════════════════════════════
		"earth": {
			"surface_name": "Earth Recovery Base",
			"env_effects": [EnvEffect.NONE],
			"gravity_mult": 1.0,
			"friction": 0.9,
			"wind_force": Vector2(20.0, 0.0),
			"wind_variance": 15.0,
			"resource_type": ResourceType.DATA_CORE,
			"resource_name": "Mission Data",
			"resource_icon": "📡",
			"mandatory_count": 6,
			"bonus_count": 6,
			"hazard_damage": 0.0,
			"hazard_interval": 0.0,
			"oxygen_drain": 0.0,
			"platform_count": 12,
			"platform_gap_min": 130.0,
			"platform_gap_max": 250.0,
			"ground_color": Color(0.15, 0.3, 0.15),
			"platform_color": Color(0.3, 0.6, 0.35, 0.85),
			"hazard_color": Color(0.3, 0.7, 1.0, 0.15),
			"sky_gradient_top": Color(0.03, 0.08, 0.2),
			"sky_gradient_bottom": Color(0.1, 0.25, 0.5),
			"particle_color": Color(0.4, 0.7, 1.0, 0.1),
			"surface_width": 4000.0,
			"surface_height": 1800.0,
		},

		# ═══════════════════════════════════════════════════════════
		# URANUS — Sideways wind, icy passages, toxic atmosphere
		# ═══════════════════════════════════════════════════════════
		"uranus": {
			"surface_name": "Uranus Methane Fields",
			"env_effects": [EnvEffect.TOXIC, EnvEffect.WIND, EnvEffect.ICE],
			"gravity_mult": 0.8,
			"friction": 0.4,
			"wind_force": Vector2(0.0, 140.0),  # Sideways (vertical push)
			"wind_variance": 80.0,
			"resource_type": ResourceType.ICE_SAMPLE,
			"resource_name": "Methane Crystal",
			"resource_icon": "🧊",
			"mandatory_count": 8,
			"bonus_count": 3,
			"hazard_damage": 0.0,
			"hazard_interval": 0.0,
			"oxygen_drain": 2.0,  # Toxic atmosphere drains suit
			"platform_count": 16,
			"platform_gap_min": 140.0,
			"platform_gap_max": 300.0,
			"ground_color": Color(0.1, 0.25, 0.3),
			"platform_color": Color(0.3, 0.65, 0.7, 0.85),
			"hazard_color": Color(0.2, 0.8, 0.7, 0.3),
			"sky_gradient_top": Color(0.04, 0.12, 0.16),
			"sky_gradient_bottom": Color(0.12, 0.3, 0.35),
			"particle_color": Color(0.4, 0.85, 0.9, 0.15),
			"surface_width": 5200.0,
			"surface_height": 2200.0,
		},

		# ═══════════════════════════════════════════════════════════
		# MERCURY — Extreme heat, fire zones, shadow safe zones
		# ═══════════════════════════════════════════════════════════
		"mercury": {
			"surface_name": "Mercury Solar Wastes",
			"env_effects": [EnvEffect.FIRE, EnvEffect.HEAT_WAVES],
			"gravity_mult": 0.95,
			"friction": 0.85,
			"wind_force": Vector2.ZERO,
			"wind_variance": 0.0,
			"resource_type": ResourceType.MINERAL,
			"resource_name": "Solar Ore",
			"resource_icon": "☀️",
			"mandatory_count": 9,
			"bonus_count": 4,
			"hazard_damage": 1.5,
			"hazard_interval": 2.0,
			"oxygen_drain": 0.0,
			"platform_count": 15,
			"platform_gap_min": 150.0,
			"platform_gap_max": 280.0,
			"ground_color": Color(0.4, 0.2, 0.08),
			"platform_color": Color(0.55, 0.3, 0.1, 0.9),
			"hazard_color": Color(1.0, 0.5, 0.1, 0.35),
			"sky_gradient_top": Color(0.08, 0.04, 0.02),
			"sky_gradient_bottom": Color(0.3, 0.15, 0.05),
			"particle_color": Color(1.0, 0.65, 0.2, 0.15),
			"surface_width": 5000.0,
			"surface_height": 2000.0,
		},

		# ═══════════════════════════════════════════════════════════
		# VENUS — Acid clouds, toxic atmosphere, turbulence
		# ═══════════════════════════════════════════════════════════
		"venus": {
			"surface_name": "Venus Acid Caverns",
			"env_effects": [EnvEffect.TOXIC, EnvEffect.ACID_RAIN],
			"gravity_mult": 1.1,
			"friction": 0.7,
			"wind_force": Vector2(-60.0, -30.0),
			"wind_variance": 80.0,
			"resource_type": ResourceType.DATA_CORE,
			"resource_name": "Ancient Probe",
			"resource_icon": "🛰️",
			"mandatory_count": 10,
			"bonus_count": 4,
			"hazard_damage": 1.0,
			"hazard_interval": 3.5,  # Acid rain interval
			"oxygen_drain": 3.0,   # Corrosive atmosphere
			"platform_count": 16,
			"platform_gap_min": 130.0,
			"platform_gap_max": 260.0,
			"ground_color": Color(0.35, 0.25, 0.08),
			"platform_color": Color(0.5, 0.35, 0.1, 0.9),
			"hazard_color": Color(0.9, 0.65, 0.1, 0.3),
			"sky_gradient_top": Color(0.16, 0.1, 0.02),
			"sky_gradient_bottom": Color(0.4, 0.28, 0.06),
			"particle_color": Color(0.9, 0.7, 0.15, 0.2),
			"surface_width": 5500.0,
			"surface_height": 2200.0,
		},

		# ═══════════════════════════════════════════════════════════
		# PLUTO — Endgame: Extremely low gravity, icy, dark
		# ═══════════════════════════════════════════════════════════
		"pluto": {
			"surface_name": "Pluto Deep Caverns",
			"env_effects": [EnvEffect.LOW_GRAVITY, EnvEffect.ICE],
			"gravity_mult": 0.3,
			"friction": 0.3,
			"wind_force": Vector2(15.0, -5.0),
			"wind_variance": 10.0,
			"resource_type": ResourceType.CRYSTAL,
			"resource_name": "Void Crystal",
			"resource_icon": "🔮",
			"mandatory_count": 12,
			"bonus_count": 5,
			"hazard_damage": 0.0,
			"hazard_interval": 0.0,
			"oxygen_drain": 0.0,
			"platform_count": 20,
			"platform_gap_min": 220.0,
			"platform_gap_max": 400.0,
			"ground_color": Color(0.08, 0.1, 0.2),
			"platform_color": Color(0.25, 0.35, 0.6, 0.85),
			"hazard_color": Color(0.4, 0.5, 0.9, 0.2),
			"sky_gradient_top": Color(0.02, 0.03, 0.08),
			"sky_gradient_bottom": Color(0.06, 0.08, 0.18),
			"particle_color": Color(0.5, 0.6, 0.9, 0.1),
			"surface_width": 6000.0,
			"surface_height": 2600.0,
		},
	}

	if configs.has(planet_id):
		return configs[planet_id]
	# Fallback
	return configs["earth"]
