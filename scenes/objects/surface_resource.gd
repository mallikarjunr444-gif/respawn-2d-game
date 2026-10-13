extends Area2D

# ═══════════════════════════════════════════════════════════════
# Surface Resource — Mandatory collectible placed on planet surfaces.
# Must be collected before the astronaut can board the exit rocket.
# ═══════════════════════════════════════════════════════════════

@export var resource_name: String = "Resource"
@export var resource_icon: String = "💎"
var collected: bool = false
var time_offset: float = 0.0

@onready var glow: PointLight2D = $GlowLight
@onready var particles: CPUParticles2D = $CollectParticles
@onready var label: Label = $Label

func _ready() -> void:
	time_offset = randf() * TAU
	body_entered.connect(_on_body_entered)
	_draw_resource()
	if label:
		label.text = resource_icon
		label.visible = true

func set_resource_info(r_name: String, icon: String, color: Color = Color(0.3, 1.0, 0.6)) -> void:
	resource_name = r_name
	resource_icon = icon
	if label:
		label.text = icon
	# Tint the glow to match
	if glow:
		glow.color = color

func _draw_resource() -> void:
	# Diamond shape
	var poly = Polygon2D.new()
	poly.color = Color(0.3, 0.95, 0.7, 0.9)
	poly.polygon = PackedVector2Array([
		Vector2(0, -16), Vector2(12, 0), Vector2(0, 16), Vector2(-12, 0)
	])
	add_child(poly)

	# Inner sparkle
	var inner = Polygon2D.new()
	inner.color = Color(0.5, 1.0, 0.8, 0.5)
	inner.polygon = PackedVector2Array([
		Vector2(0, -9), Vector2(7, 0), Vector2(0, 9), Vector2(-7, 0)
	])
	add_child(inner)

	# Outline
	var outline = Line2D.new()
	outline.points = PackedVector2Array([
		Vector2(0, -16), Vector2(12, 0), Vector2(0, 16), Vector2(-12, 0), Vector2(0, -16)
	])
	outline.default_color = Color(0.4, 1.0, 0.8, 1.0)
	outline.width = 2.0
	add_child(outline)

func _process(delta: float) -> void:
	if collected:
		return
	# Gentle hover bob
	var bob = sin(Time.get_ticks_msec() * 0.004 + time_offset) * 5.0
	position.y += bob * 0.015

	# Sparkle rotation
	rotation = sin(Time.get_ticks_msec() * 0.002 + time_offset) * 0.15

	# Pulse glow
	if glow:
		glow.energy = 1.0 + sin(Time.get_ticks_msec() * 0.005 + time_offset) * 0.4

	# Magnetic pull toward nearby astronaut
	var astronauts = get_tree().get_nodes_in_group("astronaut")
	if astronauts.size() > 0:
		var a = astronauts[0]
		if is_instance_valid(a):
			var d = a.global_position - global_position
			var dist = d.length()
			if dist < 100.0 and dist > 0.0:
				global_position += d.normalized() * (200.0 * delta)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("astronaut") and not collected:
		collected = true
		if body.has_method("collect_resource"):
			body.collect_resource()
		if particles:
			particles.emitting = true
		# Collect animation
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.1)
		tween.tween_property(self, "scale", Vector2(0.01, 0.01), 0.15)
		tween.tween_callback(queue_free)
