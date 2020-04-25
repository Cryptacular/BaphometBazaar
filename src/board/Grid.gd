extends Node

class_name Grid

const TILE_SIZE = 32
enum states { INIT, IDLE, BUSY }

export (int) var width
export (int) var height
export (Vector2) var player_initial_position
export (Array) var available_tiles

var state = states.INIT
var _rows = []
var _player_tile = preload("res://src/board/tiles/Player.tscn")
var _player_move_queue = PlayerMoveQueue.new(false, Vector2())


func _ready():
	randomize()
	
	state = states.IDLE
	
	var timer = $TileClearedTimer
	timer.connect("timeout", self, "_refill_columns")
	
	for y in height:
		var cells = []
		
		for x in width:
			cells.append(null)
		
		_rows.append(cells)
	
	for y in height:
		for x in width:
			var pos = Vector2(x, y)
			var cell = Cell.new()
			
			var tile_scene
			
			if pos == player_initial_position:
				tile_scene = _player_tile
			else:
				tile_scene = _get_random_tile()
			
			set_cell(x, y, cell)
			spawn_tile(x, y, tile_scene)
	
	clear_matches()


func spawn_tile(x: int, y: int, tile_scene: PackedScene):
	var tile = tile_scene.instance()
	tile.position = Vector2(x * TILE_SIZE, -1 * TILE_SIZE)
	add_child(tile)
	
	var cell = get_cell(x, y)
	cell.set_tile(tile)


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
	if y < (height - 1):
		down = get_cell(x, y + 1)
		if down != null: down.set_up(cell)
	if x < (width - 1):
		right = get_cell(x + 1, y)
		if right != null: right.set_left(cell)
	
	cell.set_neighbours(left, right, up, down)

	_rows[y][x] = cell


func move_player(dir: Vector2):
	if state != states.IDLE:
		_player_move_queue = PlayerMoveQueue.new(true, dir)
		return
	
	var player_position = _find_player_position()
	
	if player_position == null:
		return
	
	state = states.BUSY
	
	var swapping_tile_position = player_position + dir
	
	_swap_tiles(player_position, swapping_tile_position)


func clear_matches():
	var has_matches = _detect_matches()
	
	if !has_matches:
		post_player_move()
		return
	
	for x in width:
		for y in height:
			var cell: Cell = get_cell(x, y)
			if cell.is_marked_to_clear():
				cell.clear()
	
	var timer = $TileClearedTimer
	timer.start()
	
	clear_matches()


func post_player_move():
	state = states.IDLE
	if _player_move_queue.is_queued:
		move_player(_player_move_queue.direction)
		_player_move_queue.is_queued = false


func _refill_columns():
	for x in width:
		_refill_column(x)
	clear_matches()


func _refill_column(x: int):
	if x >= width:
		return
	
	var number_of_tiles_to_spawn = 0
	
	for y in height:
		var cell: Cell = get_cell(x, height - y - 1)
		if cell.has_tile():
			continue
		
		var next_cell = cell.get_next_cell_with_tile()
		
		if next_cell == null:
			number_of_tiles_to_spawn = number_of_tiles_to_spawn + 1
			continue
		
		_swap_tiles(cell.get_position(), next_cell.get_position())
	
	for y in number_of_tiles_to_spawn:
		var tile_scene = _get_random_tile()
		spawn_tile(x, y, tile_scene)


func _get_random_tile():
	var number_of_tiles_available = available_tiles.size()
	var rand = floor(rand_range(0, number_of_tiles_available))
	return available_tiles[rand]


func _find_player_position():
	for y in len(_rows):
		var row = _rows[y]
		for x in len(row):
			var cell = row[x]
			if cell.is_player():
				return Vector2(x, y)


func _detect_matches():
	var cells_to_clear = []
	
	for x in width:
		for y in height:
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
	
	return cells_to_clear.size() > 0


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


class PlayerMoveQueue:
	var is_queued: bool
	var direction: Vector2
	
	func _init(_is_queued: bool, _direction: Vector2):
		is_queued = _is_queued
		direction = _direction
