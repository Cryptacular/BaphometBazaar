extends Node2D

export (Array, PackedScene) var available_tiles = []

var TILE_SIZE := 16
var GUTTER_SIZE := 4
var tiles := {}

func _ready() -> void:
	var i = 0
	for scene in available_tiles:
		var tile: Node2D = scene.instance()
		tile.position = Vector2(i * (TILE_SIZE + GUTTER_SIZE) * 4, 0)
		
		var type: String = tile.Type
		tiles[type] = tile
		
		add_child(tile)
		i += 1


func on_tiles_matched(type: String, amount: int) -> void:
	if not tiles.keys().has(type):
		return
	
	var tile = tiles[type]
	tile.add()
