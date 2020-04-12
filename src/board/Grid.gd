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


func get_cell(x: int, y: int):
	return _rows[y][x]


func set_cell(x: int, y: int, cell: Cell):
	var left: Cell
	var right: Cell
	var up: Cell
	var down: Cell
	
	if y > 0:
		up = get_cell(x, y - 1)
	if x > 0:
		left = get_cell(x - 1, y)
	if y < (_height - 1):
		down = get_cell(x, y + 1)
	if x < (_width - 1):
		right = get_cell(x + 1, y)
	
	cell.set_neighbours(left, right, up, down)

	_rows[y][x] = cell


func move_player(dir: Vector2):
	var player_position
	
	for y in len(_rows):
		var row = _rows[y]
		for x in len(row):
			var cell = row[x]
			if cell.is_player():
				player_position = Vector2(x, y)
				continue
	
	var swapping_tile_position = player_position + dir
	
	_swap_tiles(player_position, swapping_tile_position)
	

func _swap_tiles(a: Vector2, b: Vector2):
	if a == null or b == null:
		return
	if a.y >= len(_rows) or b.y >= len(_rows):
		return
	if a.x >= len(_rows[a.y]) or b.x >= len(_rows[b.y]):
		return
	
	var a_cell: Cell = get_cell(a.x, a.y)
	var b_cell: Cell = get_cell(b.x, b.y)
	
	var a_tile: BaseTile = a_cell.get_tile()
	var b_tile: BaseTile = b_cell.get_tile()
	
	a_cell.set_tile(b_tile)
	b_cell.set_tile(a_tile)
