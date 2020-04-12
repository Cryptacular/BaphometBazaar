extends Node

class_name Cell

const TILE_SIZE = 32

var _position: Vector2
var _tile: BaseTile
var _up: Cell
var _down: Cell
var _left: Cell
var _right: Cell
var _is_player = false


func _init(position: Vector2, tile: BaseTile):
	set_position(position)
	set_tile(tile)


func get_tile():
	return _tile


func set_position(position: Vector2):
	_position = position


func set_tile(tile: BaseTile):
	_tile = tile
	_is_player = is_player()
	
	var new_position = _grid_to_pixel(_position)
	
	if new_position != _tile.position:
		_tile.move(_tile.position, new_position)


func set_neighbours(left: Cell, right: Cell, up: Cell, down: Cell):
	_left = left
	_right = right
	_up = up
	_down = down


func is_player():
	return _tile.Type == "Player"


func _grid_to_pixel(pos: Vector2):
	return Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
