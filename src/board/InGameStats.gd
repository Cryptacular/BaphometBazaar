extends MarginContainer

signal timeout

export (int) var duration_seconds = 180

onready var time_left: int = duration_seconds
var money_earned := 0
var money_increased_scene = preload("res://src/board/MoneyIncreasedIndicator.tscn")

func _ready():
	$Row/TimeRemaining.text = _format_time_remaining(time_left)
	$Timer.connect("timeout", self, "_on_second_passed")


func on_order_fulfilled(_type, _ingredients, worth: int):
	money_earned += worth
	$Row/Money.text = "$" + str(money_earned)
	
	var money_increased: Control = money_increased_scene.instance()
	money_increased.amount = worth
	money_increased.set_global_position(Vector2($Row/Money.margin_right, $Row/Money.margin_top))
	add_child(money_increased)


func _on_second_passed():
	time_left -= 1
	$Row/TimeRemaining.text = _format_time_remaining(time_left)
	
	if time_left == 0:
		$Timer.disconnect("timeout", self, "_on_second_passed")
		emit_signal("timeout")


func _format_time_remaining(total_seconds: int) -> String:
	var minutes := floor(total_seconds / 60)
	var seconds := total_seconds % 60
	
	if seconds < 10:
		return str(minutes) + ":0" + str(seconds)
	else:
		return str(minutes) + ":" + str(seconds)
