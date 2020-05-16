extends Node2D


func _ready() -> void:
	$Grid.connect("tiles_matched", self, "_on_tiles_matched")


func _on_tiles_matched(type: String, amount: int):
	print(str(amount) + "x " + type)
