extends Node

class_name Cell

var _position: Vector2
var _tile: Node2D
var _up: Cell
var _down: Cell
var _left: Cell
var _right: Cell

func _init(position: Vector2, 
		tile: Node2D, 
		up: Cell = null, 
		down: Cell = null, 
		left: Cell = null, 
		right: Cell = null):
	_position = position
	_tile = tile
	_up = up
	_down = down
	_left = left
	_right = right

func set_position(position: Vector2):
	_position = position

func set_tile(tile: Node2D):
	_tile = tile

func set_up(up: Cell):
	_up = up

func set_down(down: Cell):
	_down = down

func set_left(left: Cell):
	_left = left

func set_right(right: Cell):
	_right = right
