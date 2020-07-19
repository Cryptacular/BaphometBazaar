extends Node2D

const SCREEN_RATIO = 16.0 / 9.0
const BASE_OFFSET_X = 108

onready var root = get_tree().get_root()

func _ready() -> void:
	$Grid.connect("tiles_matched", $Inventory, "on_tiles_matched")
	
	var root := get_tree().get_root()
	centre_elements()
	root.connect("size_changed", self, "on_root_size_changed")


func centre_elements():
	if root.size.y / root.size.x < SCREEN_RATIO:
		var scale = 1920 / root.size.y
		var upscaled_size = root.size * scale
		var offset_x = BASE_OFFSET_X + floor((upscaled_size.x - 1080) / 2)
		
		$Grid.position.x = offset_x
		$Inventory.position.x = offset_x
	else:
		$Grid.position.x = BASE_OFFSET_X
		$Inventory.position.x = BASE_OFFSET_X


func on_root_size_changed() -> void:
	centre_elements()
