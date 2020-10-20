extends Node2D

const TILE_GUTTER = 40


func _ready() -> void:
	_spawn_tiles()
	
	$SpawnButton.connect("pressed", self, "_spawn_tiles")
	$DeathButton.connect("pressed", self, "_kill_tiles")


func _kill_tiles():
	for tile in $Tiles.get_children():
		(tile as BaseTile).clear()


func _spawn_tiles():
	_remove_tiles()
	
	var ingredients = IngredientFactory.Ingredients
	
	var i := 0
	for ingredient in ingredients:
		var tile := IngredientFactory.get_tile(ingredient)
		$Tiles.add_child(tile)
		tile.spawn_in()
		tile.position = Vector2((TILE_GUTTER * i) % (TILE_GUTTER * 10), i / 10 * TILE_GUTTER)
		i += 1


func _remove_tiles():
	for tile in $Tiles.get_children():
		if tile != null: tile.queue_free()
