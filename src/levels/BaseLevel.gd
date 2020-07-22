extends Node2D

const SCREEN_RATIO = 16.0 / 9.0
const GUTTER = 108
const ACTIVE_AREA_WIDTH = 1080.0 - (108 * 2)

onready var root = get_tree().get_root()

func _ready() -> void:
	$Grid.connect("tiles_matched", $Inventory, "on_tiles_matched")
	
	var root := get_tree().get_root()
	layout()
	root.connect("size_changed", self, "on_root_size_changed")


func layout():
	var grid = $Grid
	
	if root.size.y / root.size.x < SCREEN_RATIO:
		var scale = 1920 / root.size.y
		var upscaled_size = root.size * scale
		var offset_x = GUTTER + floor((upscaled_size.x - 1080) / 2)
		
		grid.position.x = offset_x
		$Inventory.position.x = offset_x
	else:
		grid.position.x = GUTTER
		$Inventory.position.x = GUTTER

	var grid_width = 32 * grid.width
	var grid_scale = ACTIVE_AREA_WIDTH / grid_width
	grid.scale = Vector2(grid_scale, grid_scale)

func on_root_size_changed() -> void:
	layout()
