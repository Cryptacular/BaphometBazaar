extends Control

signal out_of_moves

export (int) var max_moves = 120

onready var remaining_moves: int = max_moves

func _ready():
	$StatsContainer/Row/MovesRemaining/Label.text = str(remaining_moves)


func valid_move_started():
	remaining_moves -= 1
	$StatsContainer/Row/MovesRemaining/Label.text = str(remaining_moves)


func valid_move_finished():
	if remaining_moves == 0:
		emit_signal("out_of_moves")
