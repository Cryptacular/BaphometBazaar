extends Node

var Ingredients := _generate_ingredients_dictionary()


func _ready():
	for ingredient in Ingredients:
		assert(is_valid(ingredient))


func is_valid(type: String) -> bool:
	return _tiles.has(type) and _inventory.has(type) and _ingredients.has(type)


func _generate_ingredients_dictionary() -> Dictionary:
	var ingredients_array = [
		"Pentagram",
		"Tongue",
		"Bat",
		"Alkahest",
		"Tooth",
		"Blood",
		"Necronomicon"
	]
	
	var dictionary: Dictionary = {}
	
	for ing in ingredients_array:
		dictionary[ing] = ing
	
	return dictionary


func get_tile(type: String) -> BaseTile:
	if not _tiles.has(type):
		return null
	
	var tile = _tiles.get(type).instance()
	tile.Type = type
	
	return tile

func get_ingredient(type: String) -> BaseIngredient:
	if not _ingredients.has(type):
		return null
	
	var ingredient = _ingredients.get(type).instance()
	ingredient.Type = type
	
	return ingredient


func get_inventory_item(type: String) -> InventoryItem:
	if not _inventory.has(type):
		return null
	
	var inventory_item = _inventory.get(type).instance()
	inventory_item.Type = type
	
	return inventory_item

var _tiles: Dictionary = {
	Ingredients.Pentagram: preload("res://src/board/tiles/PentagramTile.tscn"),
	Ingredients.Tongue: preload("res://src/board/tiles/TongueTile.tscn"),
	Ingredients.Bat: preload("res://src/board/tiles/BatTile.tscn"),
	Ingredients.Alkahest: preload("res://src/board/tiles/VialRoundTile.tscn"),
	Ingredients.Tooth: preload("res://src/board/tiles/ToothTile.tscn"),
	Ingredients.Blood: preload("res://src/board/tiles/VialAngularTile.tscn"),
	Ingredients.Necronomicon: preload("res://src/board/tiles/NecronomiconTile.tscn"),
}

var _ingredients: Dictionary = {
	Ingredients.Pentagram: preload("res://src/ingredients/Pentagram.tscn"),
	Ingredients.Tongue: preload("res://src/ingredients/Tongue.tscn"),
	Ingredients.Bat: preload("res://src/ingredients/Bat.tscn"),
	Ingredients.Alkahest: preload("res://src/ingredients/Alkahest.tscn"),
	Ingredients.Tooth: preload("res://src/ingredients/Tooth.tscn"),
	Ingredients.Blood: preload("res://src/ingredients/Blood.tscn"),
	Ingredients.Necronomicon: preload("res://src/inventory/tiles/Necronomicon.tscn"),
}

var _inventory: Dictionary = {
	Ingredients.Pentagram: preload("res://src/inventory/tiles/Pentagram.tscn"),
	Ingredients.Tongue: preload("res://src/inventory/tiles/Tongue.tscn"),
	Ingredients.Bat: preload("res://src/inventory/tiles/Bat.tscn"),
	Ingredients.Alkahest: preload("res://src/inventory/tiles/Alkahest.tscn"),
	Ingredients.Tooth: preload("res://src/inventory/tiles/Tooth.tscn"),
	Ingredients.Blood: preload("res://src/inventory/tiles/Blood.tscn"),
	Ingredients.Necronomicon: preload("res://src/inventory/tiles/Necronomicon.tscn"),
}
