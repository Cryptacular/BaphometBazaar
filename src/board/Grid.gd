extends Node

class_name Grid

var _width: int
var _height: int
var _rows = []


func _init(width: int, height: int):
	_width = width
	_height = height
	
	for y in height:
		var cells = []
		
		for x in width:
			cells.append(null)
		
		_rows.append(cells)
	
	for y in height:
		for x in width:
			var cell = Cell.new()
			set_cell(x, y, cell)


func get_cell(x: int, y: int):
	return _rows[y][x]


func set_cell(x: int, y: int, cell: Cell):
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
	if y < (_height - 1):
		down = get_cell(x, y + 1)
		if down != null: down.set_up(cell)
	if x < (_width - 1):
		right = get_cell(x + 1, y)
		if right != null: right.set_left(cell)
	
	cell.set_neighbours(left, right, up, down)

	_rows[y][x] = cell


func move_player(dir: Vector2):
	var player_position = _find_player_position()
	
	if player_position == null:
		return
	
	var swapping_tile_position = player_position + dir
	
	_swap_tiles(player_position, swapping_tile_position)
	clear_matches()


func clear_matches():
	_detect_matches()
	
	for x in _width:
		for y in _height:
			var cell = get_cell(x, y)
			cell.clear()


func _find_player_position():
	for y in len(_rows):
		var row = _rows[y]
		for x in len(row):
			var cell = row[x]
			if cell.is_player():
				return Vector2(x, y)


func _detect_matches():
	var cells_to_clear = []
	
	for x in _width:
		for y in _height:
			var cell: Cell = get_cell(x, y)
			if cell.does_match_neighbours_x():
				cells_to_clear.append(cell)
				cells_to_clear.append(get_cell(x - 1, y))
				cells_to_clear.append(get_cell(x + 1, y))
			if cell.does_match_neighbours_y():
				cells_to_clear.append(cell)
				cells_to_clear.append(get_cell(x, y - 1))
				cells_to_clear.append(get_cell(x, y + 1))
	
	for cell in cells_to_clear:
		cell.mark_to_clear()


func _swap_tiles(a, b):
	if a == null or b == null:
		return
	if a.y >= len(_rows):
		a.y = 0
	if b.y >= len(_rows):
		b.y = 0
	if a.x >= len(_rows[a.y]):
		a.x = 0
	if b.x >= len(_rows[b.y]):
		b.x = 0
	
	var a_cell: Cell = get_cell(a.x, a.y)
	var b_cell: Cell = get_cell(b.x, b.y)
	
	var a_tile: BaseTile = a_cell.get_tile()
	var b_tile: BaseTile = b_cell.get_tile()
	
	a_cell.set_tile(b_tile)
	b_cell.set_tile(a_tile)
