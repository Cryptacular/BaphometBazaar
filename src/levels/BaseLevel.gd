tool
extends Node2D

signal gameover

const SCREEN_RATIO = 16.0 / 9.0
const GUTTER = 108
const ACTIVE_AREA_WIDTH = 1080.0 - (108 * 2)

onready var root := get_tree().get_root()
onready var safe_area := OS.get_window_safe_area()

var grid_position: Vector2


func _ready() -> void:
	$Orders.inventory = $Inventory
	
	$Grid.connect("tiles_matched", $Inventory, "on_tiles_matched")
	$Grid.connect("tiles_matched", self, "screen_shake")
	
	$Inventory.connect("inventory_updated", $Orders, "on_inventory_updated")
	$Orders.connect("order_fulfilled", $Inventory, "on_order_fulfilled")
	
	layout()
	root.connect("size_changed", self, "on_root_size_changed")


func layout():
	if Engine.editor_hint:
		return
	
	var grid = $Grid
	var game_timer = $GameTimer
	var orders = $Orders
	var inventory = $Inventory
	
	if root.size.y / root.size.x < SCREEN_RATIO:
		var scale = 1920 / root.size.y
		var upscaled_size = root.size * scale
		var offset_x = GUTTER + floor((upscaled_size.x - 1080) / 2)
		var offset_x_right = upscaled_size.x - offset_x
		
		grid.position.x = offset_x
		game_timer.margin_right = offset_x_right
		orders.position.x = offset_x
		inventory.position.x = offset_x
	else:
		grid.position.x = GUTTER
		orders.position.x = GUTTER
		inventory.position.x = GUTTER

	game_timer.margin_top = safe_area.position.y + GUTTER
	game_timer.margin_bottom = game_timer.margin_top + 80
	orders.position.y += floor(safe_area.position.y * 0.75)
	inventory.position.y += floor(safe_area.position.y * 0.5)

	var grid_width = 32 * grid.width
	var grid_scale = ACTIVE_AREA_WIDTH / grid_width
	grid.scale = Vector2(grid_scale, grid_scale)
	
	grid_position = grid.position


func on_root_size_changed() -> void:
	layout()


func screen_shake(_type: String, _amount: int) -> void:
	var grid = $Grid
	var shake_amount = 20
	
	for _i in range(4):
		var x = randi() % shake_amount - (shake_amount / 2)
		var y = randi() % shake_amount - (shake_amount / 2)
		grid.position = grid_position + Vector2(x, y)
		
		yield(get_tree().create_timer(0.1), "timeout")
	
	grid.position = grid_position


func _on_GameTimer_timeout():
	emit_signal("gameover")
