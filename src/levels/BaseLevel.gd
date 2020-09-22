tool
extends Node2D

signal gameover

const SCREEN_RATIO = 16.0 / 9.0
const GUTTER = 108
const ACTIVE_AREA_WIDTH = 1080.0 - (108 * 2)

onready var root := get_tree().get_root()
onready var safe_area := OS.get_window_safe_area()
onready var in_game_stats_width = $InGameStats.rect_size.x

var grid_position: Vector2


func _ready() -> void:
	for element in [$InGameStats, $Orders, $Inventory]:
		fade_in(element)
	
	$Orders.inventory = $Inventory
	
	$Grid.connect("tiles_matched", $Inventory, "on_tiles_matched")
	$Grid.connect("tiles_matched", self, "screen_shake")
	
	$Inventory.connect("inventory_updated", $Orders, "on_inventory_updated")
	$Orders.connect("order_fulfilled", $Inventory, "on_order_fulfilled")
	$Orders.connect("order_fulfilled", $InGameStats, "on_order_fulfilled")
	
	layout()
	root.connect("size_changed", self, "on_root_size_changed")


func fade_in(element: Node2D):
	var tween = $FadeInTween
	var start_color = Color(1, 1, 1, 0)
	var finish_color = Color(1, 1, 1, 1)
	
	tween.interpolate_property(element, "modulate", start_color, finish_color, 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()


func layout():
	if Engine.editor_hint:
		return
	
	var grid = $Grid
	var in_game_stats = $InGameStats
	var orders = $Orders
	var inventory = $Inventory
	
	if root.size.y / root.size.x < SCREEN_RATIO:
		var scale = 1920 / root.size.y
		var upscaled_size = root.size * scale
		var offset_x = GUTTER + floor((upscaled_size.x - 1080) / 2)
		var offset_x_right = upscaled_size.x - offset_x
		
		grid.position.x = offset_x
		in_game_stats.margin_right = offset_x_right
		in_game_stats.margin_left = offset_x_right - in_game_stats_width
		orders.position.x = offset_x
		inventory.position.x = offset_x
	else:
		grid.position.x = GUTTER
		orders.position.x = GUTTER
		inventory.position.x = GUTTER

	in_game_stats.margin_top = safe_area.position.y + GUTTER / 2
	in_game_stats.margin_bottom = in_game_stats.margin_top + 80
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


func _on_InGameStats_timeout():
	emit_signal("gameover")
