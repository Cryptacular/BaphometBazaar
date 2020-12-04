tool
extends Node2D

signal gameover

const SCREEN_RATIO = 16.0 / 9.0
const GUTTER = 108
const ACTIVE_AREA_WIDTH = 1080.0 - (GUTTER * 2)

export (Array, String) var available_ingredients

onready var root := get_tree().get_root()
onready var safe_area := OS.get_window_safe_area()
onready var in_game_stats_width = $InGameStats.rect_size.x

var grid_position: Vector2
var game_over_overlay_scene = preload("res://src/board/GameOverOverlay.tscn")
var game_over_overlay = null


func _ready() -> void:
	assert(available_ingredients != null and len(available_ingredients) > 0)
	
	for ingredient in available_ingredients:
		assert(IngredientFactory.is_valid(ingredient))
	
	var grid = $Grid
	var recipes = $Recipes
	var inventory = $Inventory
	var ingamestats = $InGameStats
	
	grid.available_tiles = available_ingredients
	inventory.available_tiles = available_ingredients
	
	grid.initialise()
	inventory.initialise()
	recipes.inventory = inventory
	
	grid.connect("tiles_matched", inventory, "on_tiles_matched")
	grid.connect("tiles_matched", self, "screen_shake")
	grid.connect("valid_move_started", ingamestats, "valid_move_started")
	grid.connect("valid_move_finished", ingamestats, "valid_move_finished")
	
	inventory.connect("inventory_updated", recipes, "on_inventory_updated")
	recipes.connect("recipe_fulfilled", inventory, "on_recipe_fulfilled")
	recipes.connect("recipe_fulfilled", ingamestats, "on_recipe_fulfilled")
	
	layout()
	root.connect("size_changed", self, "on_root_size_changed")
	
	for element in [recipes, inventory]:
		fade_in(element)


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
	var recipes = $Recipes
	var inventory = $Inventory
	
	if root.size.y / root.size.x < SCREEN_RATIO:
		var scale = 1920 / root.size.y
		var upscaled_size = root.size * scale
		var offset_x = GUTTER + floor((upscaled_size.x - 1080) / 2)
		var offset_x_right = upscaled_size.x - offset_x
		
		in_game_stats.margin_left = offset_x
		in_game_stats.margin_right = offset_x_right
		grid.position.x = offset_x
		recipes.position.x = offset_x
		inventory.position.x = offset_x
	
		if game_over_overlay != null:
			game_over_overlay.margin_right = upscaled_size.x
			game_over_overlay.margin_bottom = upscaled_size.y
	else:
		in_game_stats.margin_left = GUTTER
		in_game_stats.margin_right = GUTTER + ACTIVE_AREA_WIDTH
		grid.position.x = GUTTER
		recipes.position.x = GUTTER
		inventory.position.x = GUTTER
		
		if game_over_overlay != null:
			game_over_overlay.margin_right = 1080
			game_over_overlay.margin_bottom = 1920
	in_game_stats.margin_top = safe_area.position.y + GUTTER / 2
	in_game_stats.margin_bottom = in_game_stats.margin_top + 80
	recipes.position.y += floor(safe_area.position.y * 0.75)
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


func _on_InGameStats_out_of_moves():
	emit_signal("gameover")
	
	game_over_overlay = game_over_overlay_scene.instance()
	
	game_over_overlay.margin_left = 0
	game_over_overlay.margin_top = 0
	game_over_overlay.margin_right = 1080
	game_over_overlay.margin_bottom = 1920
	
	add_child(game_over_overlay)
	layout()
