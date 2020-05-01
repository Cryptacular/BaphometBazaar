extends Node

class_name Cell

const TILE_SIZE := 32

var _position_x: int
var _position_y: int
var _tile: BaseTile
var _up: Cell
var _down: Cell
var _left: Cell
var _right: Cell
var _is_player := false
var _marked_to_clear := false


func has_tile() -> bool:
	return get_tile() != null


func get_tile() -> BaseTile:
	return _tile


func get_type() -> String:
	return _tile.Type


func get_position() -> Vector2:
	return Vector2(_position_x, _position_y)


func is_marked_to_clear() -> bool:
	return _marked_to_clear


func mark_to_clear() -> void:
	_marked_to_clear = true


func clear() -> void:
	if !has_tile():
		return
		
	var tile := get_tile()
	
	tile.clear()
	set_tile(null)
	_marked_to_clear = false


func get_next_cell_with_tile() -> Cell:
	if has_tile():
		return self
	
	if _up == null:
		return null
	
	return _up.get_next_cell_with_tile()


func does_match_neighbours_x() -> bool:
	if _left == null or _right == null:
		return false
	
	if !has_tile() or !_left.has_tile() or !_right.has_tile():
		return false
	
	return _matches(_left) and _matches(_right)


func _matches(cell: Cell) -> bool:
	return get_tile().Type == cell.get_tile().Type


func does_match_neighbours_y() -> bool:
	if _up == null or _down == null:
		return false
	
	var this_tile := get_tile()
	var up_tile := _up.get_tile()
	var down_tile := _down.get_tile()
	
	if this_tile == null or up_tile == null or down_tile == null:
		return false
	
	return this_tile.Type == up_tile.Type and this_tile.Type == down_tile.Type


func would_match_neighbours(type: String) -> bool:
	var would_match := false
	
	if _left == null or _left._left == null:
		return false
	
	if _up == null or _up._up == null:
		return false
	
	if type == _left.get_type() and type == _left._left.get_type():
		would_match = true
	
	if type == _up.get_type() and type == _up._up.get_type():
		would_match = true
	
	return would_match


func set_position(x, y) -> void:
	_position_x = x
	_position_y = y


func set_tile(tile: BaseTile) -> void:
	_tile = tile
	_is_player = is_player()
	
	var new_position_x := _grid_to_pixel(_position_x)
	var new_position_y := _grid_to_pixel(_position_y)
	var new_position := Vector2(new_position_x, new_position_y)
	
	if _tile != null and new_position != _tile.position:
		_tile.move(_tile.position, new_position)


func set_neighbours(left: Cell, right: Cell, up: Cell, down: Cell) -> void:
	_left = left
	_right = right
	_up = up
	_down = down


func set_left(cell: Cell) -> void:
	_left = cell


func set_right(cell: Cell) -> void:
	_right = cell


func set_up(cell: Cell) -> void:
	_up = cell


func set_down(cell: Cell) -> void:
	_down = cell


func is_player() -> bool:
	return _tile != null and _tile.Type == "Player"


func _grid_to_pixel(pos: int) -> int:
	return pos * TILE_SIZE
