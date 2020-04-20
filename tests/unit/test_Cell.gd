extends "res://addons/gut/test.gd"

var baseTile = load("res://src/board/tiles/BaseTile.tscn")

func test_does_match_neighbours_returns_false_if_neighbours_null():
	var cell = Cell.new()
	
	assert_false(cell.does_match_neighbours())


func test_does_match_neighbours_returns_false_if_dont_match():
	var left_cell = Cell.new()
	var left_tile = baseTile.instance()
	left_tile.Type = "A"
	left_cell.set_tile(left_tile)
	
	var right_cell = Cell.new()
	var right_tile = baseTile.instance()
	right_tile.Type = "A"
	right_cell.set_tile(right_tile)
	
	var middle_cell = Cell.new()
	var middle_tile = baseTile.instance()
	middle_tile.Type = "B"
	middle_cell.set_tile(middle_tile)
	
	assert_false(middle_cell.does_match_neighbours())


func test_does_match_neighbours_returns_true_if_neighbours_match():
	var left_cell = Cell.new()
	var left_tile = baseTile.instance()
	left_tile.Type = "A"
	left_cell.set_tile(left_tile)
	
	var right_cell = Cell.new()
	var right_tile = baseTile.instance()
	right_tile.Type = "A"
	right_cell.set_tile(right_tile)
	
	var middle_cell = Cell.new()
	var middle_tile = baseTile.instance()
	middle_tile.Type = "A"
	middle_cell.set_tile(middle_tile)
	
	left_cell.set_right(middle_cell)
	middle_cell.set_left(left_cell)
	middle_cell.set_right(right_cell)
	right_cell.set_left(middle_cell)
	
	var actual = middle_cell.does_match_neighbours()
	
	assert_true(actual)

