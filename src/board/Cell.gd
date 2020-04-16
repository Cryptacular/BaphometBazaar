extends Node

class_name Cell

const TILE_SIZE = 32

var _position_x: int
var _position_y: int
var _tile: BaseTile
var _up: Cell
var _down: Cell
var _left: Cell
var _right: Cell
var _is_player = false


func get_tile():
	return _tile


func get_type():
	return _tile.Type


func set_position(x, y):
	_position_x = x
	_position_y = y


func set_tile(tile: BaseTile):
	_tile = tile
	_is_player = is_player()
	
	var new_position_x = _grid_to_pixel(_position_x)
	var new_position_y = _grid_to_pixel(_position_y)
	var new_position = Vector2(new_position_x, new_position_y)
	
	if _tile != null and new_position != _tile.position:
		_tile.move(_tile.position, new_position)


func set_neighbours(left: Cell, right: Cell, up: Cell, down: Cell):
	_left = left
	_right = right
	_up = up
	_down = down


func set_left(cell: Cell):
	_left = cell


func set_right(cell: Cell):
	_right = cell


func set_up(cell: Cell):
	_up = cell


func set_down(cell: Cell):
	_down = cell


func is_player():
	return _tile != null and _tile.Type == "Player"


func _grid_to_pixel(pos: int):
	return pos * TILE_SIZE
