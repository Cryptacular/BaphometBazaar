extends Node2D

export (int) var width
export (int) var height
export (Vector2) var player_initial_position
export (Array, PackedScene) var available_tiles

var Board = preload("res://src/board/Board.tscn")

func _ready() -> void:
	var board = Board.instance()
	board.init(width, height, player_initial_position, available_tiles)
	board.position = Vector2(164, 32)
	add_child(board)
