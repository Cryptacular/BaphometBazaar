extends "res://addons/gut/test.gd"

var grid_scene = load("res://src/board/Grid.tscn")
var available_tiles = IngredientFactory.Ingredients.keys()


func create_grid(width: int, height: int, available_tiles: Array):
	var grid = grid_scene.instance()
	grid.width = width
	grid.height = height
	grid.available_tiles = available_tiles
	grid.initialise()
	add_child(grid)
	return grid


func test_grid_creates_correct_number_of_rows_and_columns():
	var width = 3
	var height  = 8

	var grid = create_grid(width, height, available_tiles)

	assert_eq(len(grid._rows), 8)
	assert_eq(len(grid._rows[0]), 3)


func test_grid_cells_point_to_neighbours():
	var grid = create_grid(2, 2, available_tiles)

	var cell_0_0 = grid.get_cell(0, 0)
	var cell_0_1 = grid.get_cell(0, 1)
	var cell_1_0 = grid.get_cell(1, 0)
	var cell_1_1 = grid.get_cell(1, 1)

	assert_eq(cell_0_0._down, cell_0_1)
	assert_eq(cell_0_0._right, cell_1_0)
	
	assert_eq(cell_1_0._down, cell_1_1)
	assert_eq(cell_1_0._left, cell_0_0)
	
	assert_eq(cell_0_1._up, cell_0_0)
	assert_eq(cell_0_1._right, cell_1_1)
	
	assert_eq(cell_1_1._up, cell_1_0)
	assert_eq(cell_1_1._left, cell_0_1)


func test_get_cell_returns_correct_cell():
	var grid = create_grid(10, 8, available_tiles)
	
	var cell = grid.get_cell(3, 4)
	
	assert_eq(cell, grid._rows[4][3])


func test_set_cell_updates_correct_cell():
	var grid = create_grid(3, 4, available_tiles)
	var cell = Cell.new()
	
	grid.set_cell(2, 3, cell)
	
	assert_eq(grid.get_cell(2, 3), cell)


func test_set_cell_updates_neighbours():
	var grid = create_grid(5, 5, available_tiles)
	var cell = Cell.new()
	
	grid.set_cell(2, 3, cell)
	
	assert_eq(grid.get_cell(2, 2)._down, cell)
	assert_eq(grid.get_cell(1, 3)._right, cell)
	assert_eq(grid.get_cell(3, 3)._left, cell)
	assert_eq(grid.get_cell(2, 4)._up, cell)


func test_swap_tiles_swaps_position_of_two_tiles():
	var grid = create_grid(9, 9, available_tiles)
	var tile_1 = IngredientFactory.get_tile(available_tiles[0])
	var tile_2 = IngredientFactory.get_tile(available_tiles[0])
	grid.get_cell(0, 0).set_tile(tile_1)
	grid.get_cell(1, 0).set_tile(tile_2)
	
	grid._swap_tiles(Vector2(0, 0), Vector2(1, 0))
	
	assert_eq(grid.get_cell(0, 0)._tile, tile_2)


func test_clear_matches_does_not_remove_non_matching_tiles():
	var grid = create_grid(3, 1, available_tiles)
	var cell_0: Cell = grid.get_cell(0, 0)
	var cell_1: Cell = grid.get_cell(1, 0)
	var cell_2: Cell = grid.get_cell(2, 0)
	var tile_0 = IngredientFactory.get_tile(available_tiles[0])
	var tile_1 = IngredientFactory.get_tile(available_tiles[1])
	var tile_2 = IngredientFactory.get_tile(available_tiles[2])
	cell_0.set_tile(tile_0)
	cell_1.set_tile(tile_1)
	cell_2.set_tile(tile_2)
	
	grid.clear_matches()
	
	assert_false(cell_0.is_marked_to_clear())
	assert_false(cell_1.is_marked_to_clear())
	assert_false(cell_2.is_marked_to_clear())
