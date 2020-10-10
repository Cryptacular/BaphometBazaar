extends Node


func get_tile(ingredient) -> PackedScene:
	if not _tiles.has(ingredient):
		return null
	
	return _tiles.get(ingredient)


func get_ingredient(ingredient) -> PackedScene:
	if not _ingredients.has(ingredient):
		return null
	
	return _ingredients.get(ingredient)


func get_inventory_item(ingredient) -> PackedScene:
	if not _inventory.has(ingredient):
		return null
	
	return _inventory.get(ingredient)

var Ingredients := _generate_ingredients_dictionary()

var _tiles: Dictionary = {
	Ingredients.Pentagram: preload("res://src/board/tiles/PentagramTile.tscn"),
	Ingredients.Tongue: preload("res://src/board/tiles/TongueTile.tscn"),
	Ingredients.Bat: preload("res://src/board/tiles/BatTile.tscn"),
	Ingredients.Alkahest: preload("res://src/board/tiles/VialRoundTile.tscn"),
	Ingredients.Tooth: preload("res://src/board/tiles/ToothTile.tscn"),
	Ingredients.Blood: preload("res://src/board/tiles/VialAngularTile.tscn"),
}

var _ingredients: Dictionary = {
	Ingredients.Pentagram: preload("res://src/ingredients/Pentagram.tscn"),
#	Ingredients.Tongue: preload("res://src/ingredients/Tongue.tscn"),
	Ingredients.Bat: preload("res://src/ingredients/Bat.tscn"),
#	Ingredients.Alkahest: preload("res://src/ingredients/VialAngular.tscn"),
#	Ingredients.Tooth: preload("res://src/ingredients/Tooth.tscn"),
#	Ingredients.Blood: preload("res://src/ingredients/VialRound.tscn"),
}

var _inventory: Dictionary = {
	Ingredients.Pentagram: preload("res://src/inventory/tiles/Pentagram.tscn"),
	Ingredients.Tongue: preload("res://src/inventory/tiles/Tongue.tscn"),
	Ingredients.Bat: preload("res://src/inventory/tiles/Bat.tscn"),
	Ingredients.Alkahest: preload("res://src/inventory/tiles/VialAngular.tscn"),
	Ingredients.Tooth: preload("res://src/inventory/tiles/Tooth.tscn"),
	Ingredients.Blood: preload("res://src/inventory/tiles/VialRound.tscn"),
}


func _generate_ingredients_dictionary() -> Dictionary:
	var ingredients_array = [
		"Pentagram",
		"Tongue",
		"Bat",
		"Alkahest",
		"Tooth",
		"Blood"
	]
	
	var dictionary: Dictionary = {}
	
	for ing in ingredients_array:
		dictionary[ing] = ing
	
	return dictionary
