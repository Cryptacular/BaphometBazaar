tool
extends VBoxContainer

class_name InventoryItem

var Type: String
var _amount := 0 setget set_amount, get_amount


func _ready() -> void:
	assert(Type != null and len(Type) > 0)


func _process(_delta) -> void:
	$AmountLabel.text = str(_amount)


func get_amount() -> int:
	return _amount


func set_amount(amount: int) -> void:
	_amount = amount
