extends Node2D

export (String) var Type

var _amount := 0


func _process(_delta):
	$AmountLabel.text = str(_amount)


func add(number: int = 1):
	_amount += number


func remove(number: int = 1):
	_amount -= number
