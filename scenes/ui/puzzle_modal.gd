extends CanvasLayer

signal puzzle_solved()

const COLS = 6
const ROWS = 5
const CELL_SIZE = 64

var mirrors: Dictionary = {
	Vector2i(3, 3): "\\",
	Vector2i(3, 1): "\\",
	Vector2i(5, 1): "/",
	Vector2i(1, 1): "/",
	Vector2i(4, 3): "\\",
	Vector2i(1, 4): "/",
	Vector2i(4, 0): "\\"
}

var solution: Dictionary = {
	Vector2i(3, 3): "/",
	Vector2i(3, 1): "/",
	Vector2i(5, 1): "\\"
}

var beam_points: PackedVector2Array = []
var is_solved: bool = false
var start_pos = Vector2i(0, 3)
var target_pos = Vector2i(5, 4)

@onready var grid_panel: Control = $Center/Panel/GridControl
@onready var status_label: Label = $Center/Panel/StatusLabel

func _ready() -> void:
	visible = false
	grid_panel.draw.connect(_on_grid_draw)
	grid_panel.gui_input.connect(_on_grid_gui_input)

func open_puzzle() -> void:
	is_solved = false
	status_label.text = "ROUTE THE REACTOR BEAM INTO THE FORGE CORE"
	status_label.modulate = Color(0.3, 0.9, 1.0)
	_calculate_beam()
	visible = true
	get_tree().paused = true

func close_puzzle() -> void:
	visible = false
	get_tree().paused = false

func _calculate_beam() -> void:
	beam_points.clear()
	var curr = start_pos
	var dir = Vector2i(1, 0)
	beam_points.append(_cell_to_pixel(curr))
	
	for step in range(30):
		curr += dir
		beam_points.append(_cell_to_pixel(curr))
		if curr.x < 0 or curr.x >= COLS or curr.y < 0 or curr.y >= ROWS:
			break
		if curr == target_pos:
			is_solved = true
			status_label.text = "RESONANCE ACHIEVED — FORGE ONLINE!"
			status_label.modulate = Color(0.2, 1.0, 0.4)
			SoundManager.play("victory", 0.05)
			await get_tree().create_timer(1.2).timeout
			puzzle_solved.emit()
			close_puzzle()
			return
		if mirrors.has(curr):
			var m = mirrors[curr]
			if m == "/":
				dir = Vector2i(-dir.y, -dir.x)
			elif m == "\\":
				dir = Vector2i(dir.y, dir.x)
				
	grid_panel.queue_redraw()

func _cell_to_pixel(cell: Vector2i) -> Vector2:
	return Vector2((cell.x + 0.5) * CELL_SIZE, (cell.y + 0.5) * CELL_SIZE)

func _on_grid_gui_input(event: InputEvent) -> void:
	if is_solved:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell = Vector2i(int(event.position.x / CELL_SIZE), int(event.position.y / CELL_SIZE))
		if mirrors.has(cell):
			mirrors[cell] = "/" if mirrors[cell] == "\\" else "\\"
			SoundManager.play("click", 0.1)
			_calculate_beam()

func _on_grid_draw() -> void:
	# Draw cells and mirrors
	for c in range(COLS):
		for r in range(ROWS):
			var rect = Rect2(c * CELL_SIZE, r * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			grid_panel.draw_rect(rect, Color(0.08, 0.12, 0.25, 0.6), true)
			grid_panel.draw_rect(rect, Color(0.2, 0.4, 0.7, 0.4), false, 1.0)
			
			var cell = Vector2i(c, r)
			if cell == start_pos:
				grid_panel.draw_circle(rect.get_center(), 14.0, Color(0.2, 1.0, 0.8))
			elif cell == target_pos:
				grid_panel.draw_circle(rect.get_center(), 16.0, Color(1.0, 0.8, 0.2))
			elif mirrors.has(cell):
				var m = mirrors[cell]
				var p1 = rect.position + (Vector2(CELL_SIZE - 10, 10) if m == "/" else Vector2(10, 10))
				var p2 = rect.position + (Vector2(10, CELL_SIZE - 10) if m == "/" else Vector2(CELL_SIZE - 10, CELL_SIZE - 10))
				grid_panel.draw_line(p1, p2, Color(0.4, 0.9, 1.0), 4.0)

	# Draw laser beam
	if beam_points.size() > 1:
		for i in range(beam_points.size() - 1):
			grid_panel.draw_line(beam_points[i], beam_points[i + 1], Color(1.0, 0.4, 0.9, 0.9), 3.0)

func _on_close_btn_pressed() -> void:
	close_puzzle()
