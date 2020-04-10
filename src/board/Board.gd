extends Node2D

const TILE_SIZE = 32

export (int) var width
export (int) var height
export (Vector2) var player_initial_position

var board = {}
var player_tile = preload("res://src/board/tiles/Player.tscn")
var available_tiles = [
	preload("res://src/board/tiles/PentagramTile.tscn"),
	preload("res://src/board/tiles/VialRoundTile.tscn"),
	preload("res://src/board/tiles/VialAngularTile.tscn"),
	preload("res://src/board/tiles/TongueTile.tscn"),
]
var tile_spawn = preload("res://src/board/tiles/TileSpawn.tscn")

enum states { INIT, IDLE, BUSY }

var state = states.INIT


func _ready():
	randomize()
	initalise_board()
	state = states.IDLE


func _process(delta: float):
	if state == states.INIT:
		pass
	elif state == states.IDLE:
		process_idle(delta)
	elif state == states.BUSY:
		process_busy(delta)


func process_idle(_delta: float):
	pass


func process_busy(_delta: float):
	pass


func initalise_board():
	for x in width:
		for y in height:
			var pos = Vector2(x, y)
			var tile_scene
			
			if pos == player_initial_position:
				tile_scene = player_tile
			else:
				tile_scene = get_random_tile()
			
			var up = null
			var left = null
			
			if y > 0:
				up = board[position_to_key(Vector2(x, y - 1))]
			if x > 0:
				left = board[position_to_key(Vector2(x - 1, y))]
			
			var cell = create_cell(pos, tile_scene, up, null, left, null)
			board[position_to_key(pos)] = cell


func position_to_key(pos: Vector2):
	return str(pos.x) + "x" + str(pos.y)


func key_to_position(key: String):
	var positions = key.split("x")
	var x = int(positions[0])
	var y = int(positions[1])
	return Vector2(x, y)


func create_cell(position: Vector2, 
			tile_scene: PackedScene, 
			up: Cell = null, 
			down: Cell = null, 
			left: Cell = null, 
			right: Cell = null):
	var tile_instance = tile_scene.instance()
	tile_instance.position = grid_to_pixel(position)
	add_child(tile_instance)
	
	var cell = Cell.new(position, tile_instance, up, down, left, right)
	
	if up != null:
		up.set_down(cell)
	if down != null:
		down.set_up(cell)
	if left != null:
		left.set_right(cell)
	if right != null:
		right.set_left(cell)
	
	return cell


func get_random_tile():
	var number_of_tiles_available = available_tiles.size()
	var rand = floor(rand_range(0, number_of_tiles_available))
	return available_tiles[rand]


func grid_to_pixel(pos):
	return Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
