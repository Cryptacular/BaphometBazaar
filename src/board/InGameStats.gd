extends Control

signal out_of_moves

export (int) var max_moves = 120

onready var remaining_moves: int = max_moves
var money_earned := 0
var money_increased_scene = preload("res://src/board/MoneyIncreasedIndicator.tscn")

func _ready():
	$StatsContainer/Row/MovesRemaining/Label.text = str(remaining_moves)


func on_order_fulfilled(_type, _ingredients, worth: int):
	money_earned += worth
	var money_label = $StatsContainer/Row/Money/Label
	money_label.text = str(money_earned)
	
	var money_increased: Control = money_increased_scene.instance()
	money_increased.amount = worth
	money_increased.set_global_position(Vector2($StatsContainer/Row/Money.margin_right, $StatsContainer/Row/Money.margin_top))
	add_child(money_increased)


func valid_move_started():
	remaining_moves -= 1
	$StatsContainer/Row/MovesRemaining/Label.text = str(remaining_moves)


func valid_move_finished():
	if remaining_moves == 0:
		emit_signal("out_of_moves")
