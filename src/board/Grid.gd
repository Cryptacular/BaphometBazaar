extends Node

signal tiles_matched(type, amount)

const TILE_SIZE = 32
enum states { INIT, IDLE, BUSY }

export (int) var width
export (int) var height
export (Vector2) var player_initial_position
export (Array, PackedScene) var available_tiles

var state = states.INIT
var _rows := []
var _player_tile := preload("res://src/board/tiles/Player.tscn")
var _player_move_queue := PlayerMoveQueue.new(false, Vector2())


func _ready() -> void:
	randomize()
	
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
			
			if pos == player_initial_position:
				tile_scene = _player_tile.instance()
			else:
				tile_scene = _get_random_tile()
				while cell.would_match_neighbours(tile_scene.Type):
					tile_scene = _get_random_tile()
			
			spawn_tile(x, y, tile_scene)


func _process(_delta: float) -> void:
	if _player_move_queue.is_queued and state == states.IDLE:
		move_player(_player_move_queue.direction)
		_player_move_queue.is_queued = false
	
	if Input.is_action_just_pressed("ui_left"):
		move_player(Vector2(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		move_player(Vector2(1, 0))
	elif Input.is_action_just_pressed("ui_up"):
		move_player(Vector2(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		move_player(Vector2(0, 1))


func spawn_tile(x: int, y: int, tile: BaseTile) -> void:
	tile.position = Vector2(x * TILE_SIZE, -1 * TILE_SIZE)
	add_child(tile)
	
	var cell := get_cell(x, y)
	cell.set_tile(tile)


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

	_rows[y][x] = cell


func move_player(dir: Vector2) -> void:
	if state != states.IDLE:
		_player_move_queue = PlayerMoveQueue.new(true, dir)
		return
	
	var player_position := _find_player_position()
	
	if player_position == Vector2(-1, -1):
		return
	
	state = states.BUSY
	
	var swapping_tile_position := player_position + dir
	
	_swap_tiles(player_position, swapping_tile_position)
	$TilesMovedTimer.start()

func clear_matches() -> void:
	var has_matches := _detect_matches()
	
	if !has_matches:
		post_player_move()
		return
	
	for x in width:
		for y in height:
			var cell := get_cell(x, y)
			if cell.is_marked_to_clear():
				cell.clear()
	
	$TilesClearedTimer.start()


func post_player_move() -> void:
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
	return (available_tiles[rand]).instance()


func _find_player_position() -> Vector2:
	for y in len(_rows):
		var row: Array = _rows[y]
		for x in len(row):
			var cell: Cell = row[x]
			if cell.is_player():
				return Vector2(x, y)
	return Vector2(-1, -1)


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
	if a.y >= len(_rows):
		a.y = 0
	if b.y >= len(_rows):
		b.y = 0
	if a.x >= len(_rows[a.y]):
		a.x = 0
	if b.x >= len(_rows[b.y]):
		b.x = 0
	
	var a_cell := get_cell(a.x, a.y)
	var b_cell := get_cell(b.x, b.y)
	
	var a_tile := a_cell.get_tile()
	var b_tile := b_cell.get_tile()
	
	a_cell.set_tile(b_tile)
	b_cell.set_tile(a_tile)


class PlayerMoveQueue:
	var is_queued: bool
	var direction: Vector2
	
	func _init(_is_queued: bool, _direction: Vector2):
		is_queued = _is_queued
		direction = _direction
