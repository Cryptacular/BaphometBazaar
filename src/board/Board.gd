extends Node2D

var _width: int
var _height: int
var _player_initial_position: Vector2
var _available_tiles: Array

var grid: Grid

enum states { INIT, IDLE, BUSY }

var state = states.INIT


func init(width: int, height: int, player_initial_position: Vector2, available_tiles: Array):
	_width = width
	_height = height
	_player_initial_position = player_initial_position
	_available_tiles = available_tiles


func _ready():
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
		grid.move_player(Vector2(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		grid.move_player(Vector2(1, 0))
	elif Input.is_action_just_pressed("ui_up"):
		grid.move_player(Vector2(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		grid.move_player(Vector2(0, 1))

func process_busy(_delta: float):
	pass


func initalise_board():
	grid = Grid.new(_width, _height, _player_initial_position, _available_tiles, self)
