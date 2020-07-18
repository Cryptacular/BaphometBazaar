extends "res://addons/gut/test.gd"

var baseTile = load("res://src/board/tiles/BaseTile.tscn")
var pentagramTile = load("res://src/board/tiles/PentagramTile.tscn")
var batTile = load("res://src/board/tiles/BatTile.tscn")
var vialRoundTile = load("res://src/board/tiles/VialRoundTile.tscn")
var vialAngularTile = load("res://src/board/tiles/VialAngularTile.tscn")
var playerTile = load("res://src/board/tiles/Player.tscn")

func test_would_match_neighbours_returns_false_if_no_matches_in_row():
	var tile_0 = pentagramTile.instance()
	var tile_1 = batTile.instance()
	
	var cell_0 = Cell.new()
	var cell_1 = Cell.new()
	var cell_2 = Cell.new()
	
	cell_0.set_tile(tile_0)
	cell_1.set_tile(tile_1)
	
	cell_0.set_right(cell_1)
	cell_1.set_left(cell_0)
	cell_1.set_right(cell_2)
	cell_2.set_left(cell_1)
	
	assert_false(cell_2.would_match_neighbours("Batwing"))


func test_would_match_neighbours_returns_true_if_matches_in_row():
	var tile_0 = batTile.instance()
	var tile_1 = batTile.instance()
	
	var cell_0 = Cell.new()
	var cell_1 = Cell.new()
	var cell_2 = Cell.new()
	
	cell_0.set_tile(tile_0)
	cell_1.set_tile(tile_1)
	
	cell_0.set_right(cell_1)
	cell_1.set_left(cell_0)
	cell_1.set_right(cell_2)
	cell_2.set_left(cell_1)
	
	assert_true(cell_2.would_match_neighbours("Batwing"))


func test_would_match_neighbours_returns_false_if_no_matches_in_column():
	var tile_0 = pentagramTile.instance()
	var tile_1 = batTile.instance()
	
	var cell_0 = Cell.new()
	var cell_1 = Cell.new()
	var cell_2 = Cell.new()
	
	cell_0.set_tile(tile_0)
	cell_1.set_tile(tile_1)
	
	cell_0.set_down(cell_1)
	cell_1.set_up(cell_0)
	cell_1.set_down(cell_2)
	cell_2.set_up(cell_1)
	
	assert_false(cell_2.would_match_neighbours("Batwing"))


func test_would_match_neighbours_returns_true_if_matches_in_column():
	var tile_0 = batTile.instance()
	var tile_1 = batTile.instance()
	
	var cell_0 = Cell.new()
	var cell_1 = Cell.new()
	var cell_2 = Cell.new()
	
	cell_0.set_tile(tile_0)
	cell_1.set_tile(tile_1)
	
	cell_0.set_down(cell_1)
	cell_1.set_up(cell_0)
	cell_1.set_down(cell_2)
	cell_2.set_up(cell_1)
	
	assert_true(cell_2.would_match_neighbours("Batwing"))
