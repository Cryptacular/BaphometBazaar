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
var _marked_to_clear = false


func get_tile():
	return _tile


func get_type():
	return _tile.Type


func is_marked_to_clear():
	return _marked_to_clear


func mark_to_clear():
	_marked_to_clear = true


func clear():
	if not is_marked_to_clear():
		return
	
	var tile: BaseTile = get_tile()
	
	if tile == null:
		return
	
	tile.clear()
	set_tile(null)
	_marked_to_clear = false


func does_match_neighbours_x():
	if _left == null or _right == null:
		return false
	
	var this_tile: BaseTile = get_tile()
	var left_tile: BaseTile = _left.get_tile()
	var right_tile: BaseTile = _right.get_tile()
	
	if this_tile == null or left_tile == null or right_tile == null:
		return false
	
	return this_tile.Type == left_tile.Type and this_tile.Type == right_tile.Type


func does_match_neighbours_y():
	if _up == null or _down == null:
		return false
	
	var this_tile: BaseTile = get_tile()
	var up_tile: BaseTile = _up.get_tile()
	var down_tile: BaseTile = _down.get_tile()
	
	if this_tile == null or up_tile == null or down_tile == null:
		return false
	
	return this_tile.Type == up_tile.Type and this_tile.Type == down_tile.Type


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
