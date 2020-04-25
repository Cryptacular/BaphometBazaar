extends Node2D

var _width: int
var _height: int
var _player_initial_position: Vector2
var _available_tiles: Array

var grid
var grid_scene = load("res://src/board/Grid.tscn")


func init(width: int, height: int, player_initial_position: Vector2, available_tiles: Array):
	_width = width
	_height = height
	_player_initial_position = player_initial_position
	_available_tiles = available_tiles


func _ready():
	initalise_board()


func _process(_delta: float):
	if Input.is_action_just_pressed("ui_left"):
		grid.move_player(Vector2(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		grid.move_player(Vector2(1, 0))
	elif Input.is_action_just_pressed("ui_up"):
		grid.move_player(Vector2(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		grid.move_player(Vector2(0, 1))


func initalise_board():
	grid = grid_scene.instance()
	grid.width = _width
	grid.height = _height
	grid.player_initial_position = _player_initial_position
	grid.available_tiles = _available_tiles
	add_child(grid)
