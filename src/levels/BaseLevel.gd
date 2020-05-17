extends Node2D


func _ready() -> void:
	$Grid.connect("tiles_matched", $Inventory, "on_tiles_matched")
