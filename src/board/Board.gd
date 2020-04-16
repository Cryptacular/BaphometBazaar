extends Node2D

var _width: int
var _height: int
var _player_initial_position: Vector2
var _available_tiles: Array

var grid: Grid
var player_tile = preload("res://src/board/tiles/Player.tscn")

enum states { INIT, IDLE, BUSY }

var state = states.INIT


func init(width: int, height: int, player_initial_position: Vector2, available_tiles: Array):
	_width = width
	_height = height
	_player_initial_position = player_initial_position
	_available_tiles = available_tiles


func _ready():
	randomize()
	initalise_board()
	state = states.IDLE


func _process(delta: float):
	if state == states.INIT:
		pass
	elif state == states.IDLE:
		process_idle(delta)
	elif state == states.BUSY:
		process_busy(delta)


func process_idle(_delta: float):
	if Input.is_action_just_pressed("ui_left"):
		move_player(Vector2(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		move_player(Vector2(1, 0))
	elif Input.is_action_just_pressed("ui_up"):
		move_player(Vector2(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		move_player(Vector2(0, 1))

func process_busy(_delta: float):
	pass


func initalise_board():
	grid = Grid.new(_width, _height)
	
	for x in _width:
		for y in _height:
			var pos = Vector2(x, y)
			var tile_scene
			
			if pos == _player_initial_position:
				tile_scene = player_tile
			else:
				tile_scene = get_random_tile()
			
			var tile = tile_scene.instance()
			add_child(tile)
			
			var cell: Cell = grid.get_cell(x, y)
			cell.set_tile(tile)


func move_player(dir: Vector2):
	grid.move_player(dir)


func position_to_key(pos: Vector2):
	return str(pos.x) + "x" + str(pos.y)


func key_to_position(key: String):
	var positions = key.split("x")
	var x = int(positions[0])
	var y = int(positions[1])
	return Vector2(x, y)


func get_random_tile():
	var number_of_tiles_available = _available_tiles.size()
	var rand = floor(rand_range(0, number_of_tiles_available))
	return _available_tiles[rand]
