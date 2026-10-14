extends Area2D

# ═══════════════════════════════════════════════════════════════
# Heat Zone — Solar radiation / acid cloud hazard
# Drains fuel and inflicts environmental damage to player.
# ═══════════════════════════════════════════════════════════════

@export var drain_rate: float = 4.0      # Fuel drain per second
@export var damage_rate: float = 1.0     # Damage tick interval if fuel is low
@export var zone_color: Color = Color(1.0, 0.4, 0.1, 0.25)
@export var hazard_name: String = "SOLAR RADIATION"

var player_in_zone: CharacterBody2D = null
var damage_timer: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var poly: Polygon2D = $Polygon2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if poly:
		poly.color = zone_color

func _process(delta: float) -> void:
	if player_in_zone and is_instance_valid(player_in_zone):
		# Continuous extra fuel drain from heat/corrosion
		GameState.consume_fuel(drain_rate * delta)

		damage_timer += delta
		if damage_timer >= damage_rate:
			damage_timer = 0.0
			# If fuel is depleted, player takes direct hull damage
			if GameState.is_fuel_empty():
				if player_in_zone.has_method("take_damage"):
					player_in_zone.take_damage(1, hazard_name)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = body as CharacterBody2D
		SoundManager.play("alert", 0.05, -3.0)

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		player_in_zone = null
		damage_timer = 0.0
