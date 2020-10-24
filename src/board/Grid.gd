tool
extends Node2D

signal tiles_matched(type, amount)

const TILE_SIZE = 32
enum states { INIT, IDLE, BUSY, GAMEOVER }

export (int) var width
export (int) var height

var available_tiles
var state = states.INIT
var _rows := []
var drag_start := Vector2()


func _ready() -> void:
	assert(width != null and width > 0)
	assert(height != null and height > 0)
	
	randomize()


func initialise() -> void:
	assert(available_tiles != null and len(available_tiles) > 0)
	state = states.IDLE
	
	var tiles_matched_timer := $TilesMovedTimer
	tiles_matched_timer.connect("timeout", self, "clear_matches")
	
	var tiles_cleared_timer := $TilesClearedTimer
	tiles_cleared_timer.connect("timeout", self, "_refill_columns")
	
	for y in height:
		var cells := []
		
		for x in width:
			cells.append(null)
		
		_rows.append(cells)
	
	for y in height:
		for x in width:
			var pos := Vector2(x, y)
			var cell := Cell.new()
			set_cell(x, y, cell)
			
			var tile_scene: BaseTile
			
			tile_scene = _get_random_tile()
			while cell.would_match_neighbours(tile_scene.Type):
				tile_scene = _get_random_tile()
			
			var time_scale = 0.3
			var height_scale = (height - y) / floor(height)
			var width_scale = (width - x) / floor(width)
			var spawn_delay = (height_scale + width_scale) * time_scale
			
			spawn_tile(x, y, tile_scene, spawn_delay)


func _screen_position_to_grid_position(pos: Vector2) -> Vector2:
	var relative_pos = pos - position
	var x := floor(relative_pos.x / scale.x / TILE_SIZE)
	var y := floor(relative_pos.y / scale.y / TILE_SIZE)
	return Vector2(x, y)


func spawn_tile(x: int, y: int, tile: BaseTile, delay: float = 0.0) -> void:
	tile.position = Vector2(x * TILE_SIZE, -1 * TILE_SIZE)
	add_child(tile)
	
	var cell := get_cell(x, y)
	cell.set_tile(tile, delay)


func swap(from: Vector2, to: Vector2) -> void:
	if state != states.IDLE:
		return
	
	for a in [from.x, from.y, to.x, to.y]:
		if a < 0 or a >= width or a >= height:
			return
	
	var x_movement = to.x - from.x
	var y_movement = to.y - from.y
	
	if abs(x_movement) > 0 and abs(y_movement) > 0:
		return
	
	if abs(x_movement) > 1 or abs(y_movement) > 1:
		return
	
	state = states.BUSY
	
	var from_cell = get_cell(from.x, from.y)
	var to_cell = get_cell(to.x, to.y)
	
	if _would_match_after_swap(from, to):
		_swap_tiles(from, to)
		$TilesMovedTimer.start()
	else:
		if to.x - from.x > 0:
			from_cell.swap_and_return("right")
			to_cell.swap_and_return("left")
		elif to.x - from.x < 0:
			from_cell.swap_and_return("left")
			to_cell.swap_and_return("right")
		elif to.y - from.y > 0:
			from_cell.swap_and_return("down")
			to_cell.swap_and_return("up")
		elif to.y - from.y < 0:
			from_cell.swap_and_return("up")
			to_cell.swap_and_return("down")
		
		yield(get_tree().create_timer(0.2), "timeout")
		post_move()


func get_cell(x: int, y: int) -> Cell:
	return _rows[y][x]


func set_cell(x: int, y: int, cell: Cell) -> void:
	cell.set_position(x, y)
	
	var left: Cell
	var right: Cell
	var up: Cell
	var down: Cell
	
	if y > 0:
		up = get_cell(x, y - 1)
		if up != null: up.set_down(cell)
	if x > 0:
		left = get_cell(x - 1, y)
		if left != null: left.set_right(cell)
	if y < (height - 1):
		down = get_cell(x, y + 1)
		if down != null: down.set_up(cell)
	if x < (width - 1):
		right = get_cell(x + 1, y)
		if right != null: right.set_left(cell)
	
	cell.set_neighbours(left, right, up, down)
	cell.connect("tile_starts_being_dragged", self, "_on_tile_start_dragging")
	cell.connect("tile_being_dragged", self, "_on_tile_dragged")

	_rows[y][x] = cell


func _on_tile_start_dragging(x: int, y: int):
	var pos = Vector2(x, y)
	drag_start = pos


func _on_tile_dragged(x: int, y: int):
	var pos = Vector2(x, y)
	
	if pos != drag_start:
		swap(drag_start, pos)


func clear_matches() -> void:
	var has_matches := _detect_matches()
	
	if !has_matches:
		post_move()
		return
	
	for x in width:
		for y in height:
			var cell := get_cell(x, y)
			if cell.is_marked_to_clear():
				cell.clear()
	
	$TilesClearedTimer.start()


func post_move() -> void:
	if state != states.GAMEOVER:
		state = states.IDLE


func _refill_columns() -> void:
	for x in width:
		_refill_column(x)
	$TilesMovedTimer.start()


func _refill_column(x: int) -> void:
	if x >= width:
		return
	
	var number_of_tiles_to_spawn := 0
	
	for y in height:
		var cell := get_cell(x, height - y - 1)
		if cell.has_tile():
			continue
		
		var next_cell := cell.get_next_cell_with_tile()
		
		if next_cell == null:
			number_of_tiles_to_spawn = number_of_tiles_to_spawn + 1
			continue
		
		_swap_tiles(cell.get_position(), next_cell.get_position())
	
	for y in number_of_tiles_to_spawn:
		var tile_scene := _get_random_tile()
		spawn_tile(x, y, tile_scene)


func _get_random_tile() -> BaseTile:
	var number_of_tiles_available: int = available_tiles.size()
	var rand := floor(rand_range(0, number_of_tiles_available))
	var ingredient = available_tiles[rand]
	return IngredientFactory.get_tile(ingredient)


func _detect_matches() -> bool:
	var has_cleared_cells := false
	
	for x in width:
		for y in height:
			var cell := get_cell(x, y)
			
			if cell.is_marked_to_clear():
				continue
				
			var matches_x = cell.get_matching_cells_x()
			var matches_y = cell.get_matching_cells_y()
			
			if matches_x.size() >= 3:
				for matched_cell in matches_x:
					matched_cell.mark_to_clear()
			
				has_cleared_cells = true
				emit_signal("tiles_matched", matches_x[0].get_type(), matches_x.size())
			
			if matches_y.size() >= 3:
				for matched_cell in matches_y:
					matched_cell.mark_to_clear()
			
				has_cleared_cells = true
				emit_signal("tiles_matched", matches_y[0].get_type(), matches_y.size())
	
	return has_cleared_cells


func _swap_tiles(a: Vector2, b: Vector2) -> void:
	if a == null or b == null:
		return
	if a.y >= len(_rows) or a.y < 0:
		return
	if b.y >= len(_rows) or b.y < 0:
		return
	if a.x >= len(_rows[a.y]) or a.x < 0:
		return
	if b.x >= len(_rows[b.y]) or b.x < 0:
		return
	
	var a_cell := get_cell(a.x, a.y)
	var b_cell := get_cell(b.x, b.y)
	
	var a_tile := a_cell.get_tile()
	var b_tile := b_cell.get_tile()
	
	a_cell.set_tile(b_tile)
	b_cell.set_tile(a_tile)


func _would_match_after_swap(a: Vector2, b: Vector2) -> bool:
	var type_grid = []
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(get_cell(x, y).get_type())
		type_grid.append(row)
	
	var a_type = type_grid[a.y][a.x]
	var b_type = type_grid[b.y][b.x]
	
	type_grid[a.y][a.x] = b_type
	type_grid[b.y][b.x] = a_type
	
	for y in range(height):
		for x in range(width):
			var current_cell = type_grid[y][x]
			
			if x >= 2:
				var left_1_cell = type_grid[y][x - 1]
				var left_2_cell = type_grid[y][x - 2]

				if current_cell == left_1_cell and current_cell == left_2_cell:
					return true
		
			if y >= 2:
				var up_1_cell = type_grid[y - 1][x]
				var up_2_cell = type_grid[y - 2][x]
				
				if current_cell == up_1_cell and current_cell == up_2_cell:
					return true
	
	return false


func _on_gameover():
	state = states.GAMEOVER
