tool
extends Node2D

signal inventory_updated(items)

const TILE_SIZE := 16
const GUTTER_SIZE := 4

var available_tiles = []
var tiles := []
var state := {}


func initialise() -> void:
	var i = 0
	
	for ingredient in available_tiles:
		var scene = IngredientFactory.get_inventory_item(ingredient)
		var tile: InventoryItem = scene.instance()
		
		var type: String = tile.Type
		tiles.append(tile)
		
		$Rows/Items.add_child(tile)
		state[type] = 0
		i += 1


func on_tiles_matched(type: String, _amount: int) -> void:
	if state.has(type):
		state[type] += 1
	else:
		state[type] = 1
	
	notify_inventory_updated()
	render()


func on_order_fulfilled(_order: BaseOrder, ingredients: Dictionary, _worth: int) -> void:
	for type in ingredients:
		if state[type] == null:
			return
		
		var amount = ingredients[type]
		
		state[type] -= amount
		
		notify_inventory_updated()
		render()


func render():
	for tile in tiles:
		var type: String = tile.Type
		var amount = state[type]
		tile.set_amount(amount)
		


func notify_inventory_updated():
	emit_signal("inventory_updated", state)
