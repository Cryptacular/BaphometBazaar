extends Node2D

class_name InventoryItem

export (String) var Type

var _amount := 0 setget set_amount, get_amount


func _process(_delta) -> void:
	$AmountLabel.text = str(_amount)


func get_amount() -> int:
	return _amount


func set_amount(amount: int) -> void:
	_amount = amount
