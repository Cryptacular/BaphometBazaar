extends Node2D

var active_tiles: Array = []


func _ready() -> void:
	_spawn_tiles()
	
	$SpawnButton.connect("pressed", self, "_spawn_tiles")
	$DeathButton.connect("pressed", self, "_kill_tiles")


func _kill_tiles():
	for tile in active_tiles:
		(tile as BaseTile).clear()
	
	active_tiles = []


func _spawn_tiles():
	_remove_tiles()
	
	var tiles = _list_files_in_directory("res://src/board/tiles")
	
	var i := 0
	for tile in tiles:
		if not tile.ends_with(".tscn"):
			continue
		
		var t = load(tile).instance()
		t.scale = Vector2(3, 3)
		t.position = Vector2(32 + 32 * 4 * i, 32 * 4)
		add_child(t)
		active_tiles.append(t)
		
		i += 1


func _remove_tiles():
	for tile in active_tiles:
		if tile != null: tile.queue_free()
	
	active_tiles = []


func _list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(path + "/" + file)

	dir.list_dir_end()

	return files
