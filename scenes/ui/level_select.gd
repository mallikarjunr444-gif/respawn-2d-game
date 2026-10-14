extends CanvasLayer

# ═══════════════════════════════════════════════════════════════
# Planet Selection Screen — Choose from 10 planets
# ═══════════════════════════════════════════════════════════════

@onready var grid_container: GridContainer = $Margin/VBox/Scroll/Grid
@onready var back_btn: Button = $Margin/VBox/BackBtn
@onready var total_score_label: Label = $Margin/VBox/HeaderBox/TotalScoreLabel

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	total_score_label.text = "Fleet Credits: " + str(GameState.total_score)
	_populate_planets()

func _populate_planets() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	var count = LevelData.get_planet_count()
	for i in range(count):
		var info = LevelData.get_world_info(i)
		var is_unlocked = GameState.is_level_unlocked(i)
		var is_completed = GameState.is_level_completed_flag(i)
		var best_score = GameState.level_best_scores.get(i, 0)

		var card = Button.new()
		card.custom_minimum_size = Vector2(280, 110)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var status = " [CLEARED]" if is_completed else (" [AVAILABLE]" if is_unlocked else " [LOCKED]")
		var text = info.get("name", "PLANET " + str(i + 1)) + status + "\n"
		text += info.get("subtitle", "") + "\n"
		if is_unlocked:
			text += "Best: " + str(best_score) + " pts | Min Fuel: " + str(int(info.get("min_fuel_to_launch", 25.0))) + "%"
		else:
			text += "Complete previous sector to unlock"

		card.text = text
		card.disabled = not is_unlocked

		var planet_idx = i
		card.pressed.connect(func(): _on_planet_selected(planet_idx))
		grid_container.add_child(card)

func _on_planet_selected(idx: int) -> void:
	SoundManager.play("upgrade", 0.05)
	GameState.start_level(idx)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
