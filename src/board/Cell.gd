extends Node

class_name Cell

signal tile_starts_being_dragged(x, y)
signal tile_being_dragged(x, y)

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
	if _tile == null:
		return ""
	return _tile.Type


func get_position() -> Vector2:
	return Vector2(_position_x, _position_y)


func is_marked_to_clear() -> bool:
	return _marked_to_clear


func mark_to_clear() -> void:
	_marked_to_clear = true
	remove_connections(_tile)


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


func get_matching_cells_x() -> Array:
	var matches := [self]
	
	var type := get_type()
	var left: Cell = _left
	var right: Cell = _right
	
	while (left != null and left.get_type() == type):
		matches.append(left)
		left = left._left
	
	while (right != null and right.get_type() == type):
		matches.append(right)
		right = right._right
	
	return matches


func get_matching_cells_y() -> Array:
	var matches := [self]
	
	var type := get_type()
	var up: Cell = _up
	var down: Cell = _down
	
	while (up != null and up.get_type() == type):
		matches.append(up)
		up = up._up
	
	while (down != null and down.get_type() == type):
		matches.append(down)
		down = down._down
	
	return matches


func _matches(cell: Cell) -> bool:
	return get_type() == cell.get_type()


func would_match_neighbours(type: String) -> bool:
	if _left != null and type == _left.get_type() and _left._left != null and type == _left._left.get_type():
		return true
	
	if _up != null and type == _up.get_type() and _up._up != null and type == _up._up.get_type():
		return true
	
	return false


func set_position(x, y) -> void:
	_position_x = x
	_position_y = y


func set_tile(tile: BaseTile, delay: float = 0.0) -> void:
	remove_connections(_tile)
	remove_connections(tile)
	
	_tile = tile
	
	var new_position_x := _grid_to_pixel(_position_x)
	var new_position_y := _grid_to_pixel(_position_y)
	var new_position := Vector2(new_position_x, new_position_y)
	
	if _tile != null:
		_tile.target_position = new_position
		_tile.spawn_delay = delay
		_tile.connect("start_dragging", self, "_on_tile_start_dragging")
		_tile.connect("is_being_dragged", self, "_on_tile_dragged")
	
	if _tile != null and new_position != _tile.position:
		_tile.move()


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


func swap_and_return(dir: String) -> void:
	if _tile == null:
		return
	_tile.swap_and_return(dir)


func _on_tile_start_dragging():
	emit_signal("tile_starts_being_dragged", _position_x, _position_y)


func _on_tile_dragged():
	emit_signal("tile_being_dragged", _position_x, _position_y)


func _grid_to_pixel(pos: int) -> int:
	return pos * TILE_SIZE


func remove_connections(tile: Node) -> void:
	if tile == null:
		return
	
	if tile.is_connected("start_dragging", self, "_on_tile_start_dragging"):
		tile.disconnect("start_dragging", self, "_on_tile_start_dragging")
	if tile.is_connected("is_being_dragged", self, "_on_tile_dragged"):
		tile.disconnect("is_being_dragged", self, "_on_tile_dragged")
