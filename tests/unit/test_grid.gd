extends "res://addons/gut/test.gd"

var baseTile = load("res://src/board/tiles/BaseTile.tscn")
var playerTile = load("res://src/board/tiles/Player.tscn")


func test_grid_creates_correct_number_of_rows_and_columns():
	var width = 3
	var height  = 8

	var grid = Grid.new(width, height, Vector2(-1, -1), [baseTile], Node2D.new())

	assert_eq(len(grid._rows), 8)
	assert_eq(len(grid._rows[0]), 3)


func test_grid_cells_point_to_neighbours():
	var grid = Grid.new(2, 2, Vector2(-1, -1), [baseTile], Node2D.new())

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
	var grid = Grid.new(10, 8, Vector2(-1, -1), [baseTile], Node2D.new())
	
	var cell = grid.get_cell(3, 4)
	
	assert_eq(cell, grid._rows[4][3])


func test_set_cell_updates_correct_cell():
	var grid = Grid.new(3, 4, Vector2(-1, -1), [baseTile], Node2D.new())
	var cell = Cell.new()
	
	grid.set_cell(2, 3, cell)
	
	assert_eq(grid.get_cell(2, 3), cell)


func test_set_cell_updates_neighbours():
	var grid = Grid.new(5, 5, Vector2(-1, -1), [baseTile], Node2D.new())
	var cell = Cell.new()
	
	grid.set_cell(2, 3, cell)
	
	assert_eq(grid.get_cell(2, 2)._down, cell)
	assert_eq(grid.get_cell(1, 3)._right, cell)
	assert_eq(grid.get_cell(3, 3)._left, cell)
	assert_eq(grid.get_cell(2, 4)._up, cell)


func test_swap_tiles_swaps_position_of_two_tiles():
	var grid = Grid.new(9, 9, Vector2(-1, -1), [baseTile], Node2D.new())
	var tile_1 = baseTile.instance()
	var tile_2 = baseTile.instance()
	grid.get_cell(0, 0).set_tile(tile_1)
	grid.get_cell(1, 0).set_tile(tile_2)
	
	grid._swap_tiles({ "x": 0, "y": 0 }, { "x": 1, "y": 0 })
	
	assert_eq(grid.get_cell(0, 0)._tile, tile_2)


func test_move_player_right_swaps_with_tile_on_the_right():
	var grid = Grid.new(9, 9, Vector2(-1, -1), [baseTile], Node2D.new())
	var player = playerTile.instance()
	grid.get_cell(4, 4).set_tile(player)
	
	grid.move_player(Vector2(1, 0))
	
	assert_eq(grid.get_cell(5, 4)._tile, player)


func test_move_player_left_swaps_with_tile_on_the_left():
	var grid = Grid.new(9, 9, Vector2(-1, -1), [baseTile], Node2D.new())
	var player = playerTile.instance()
	grid.get_cell(4, 4).set_tile(player)
	
	grid.move_player(Vector2(-1, 0))
	
	assert_eq(grid.get_cell(3, 4)._tile, player)


func test_move_player_up_swaps_with_tile_above():
	var grid = Grid.new(9, 9, Vector2(-1, -1), [baseTile], Node2D.new())
	var player = playerTile.instance()
	grid.get_cell(4, 4).set_tile(player)
	
	grid.move_player(Vector2(0, -1))
	
	assert_eq(grid.get_cell(4, 3)._tile, player)


func test_move_player_down_swaps_with_tile_below():
	var grid = Grid.new(9, 9, Vector2(-1, -1), [baseTile], Node2D.new())
	var player = playerTile.instance()
	grid.get_cell(4, 4).set_tile(player)
	
	grid.move_player(Vector2(0, 1))
	
	assert_eq(grid.get_cell(4, 5)._tile, player)


func test_move_player_at_edge_swaps_with_tile_on_the_other_side():
	var grid = Grid.new(9, 9, Vector2(-1, -1), [baseTile], Node2D.new())
	var player = playerTile.instance()
	grid.get_cell(8, 4).set_tile(player)
	
	grid.move_player(Vector2(1, 0))
	
	assert_eq(grid.get_cell(0, 4)._tile, player)


func test_clear_matches_does_not_remove_non_matching_tiles():
	var grid: Grid = Grid.new(3, 1, Vector2(-1, -1), [baseTile], Node2D.new())
	var cell_0: Cell = grid.get_cell(0, 0)
	var cell_1: Cell = grid.get_cell(1, 0)
	var cell_2: Cell = grid.get_cell(2, 0)
	var tile_0 = baseTile.instance()
	tile_0.Type = "A"
	var tile_1 = baseTile.instance()
	tile_0.Type = "B"
	var tile_2 = baseTile.instance()
	tile_0.Type = "C"
	cell_0.set_tile(tile_0)
	cell_1.set_tile(tile_1)
	cell_2.set_tile(tile_2)
	
	grid.clear_matches()
	
	assert_false(cell_0.is_marked_to_clear())
	assert_false(cell_1.is_marked_to_clear())
	assert_false(cell_2.is_marked_to_clear())


func test_clear_matches_removes_matching_tiles():
	var grid: Grid = Grid.new(3, 1, Vector2(-1, -1), [baseTile], Node2D.new())
	var cell_0: Cell = grid.get_cell(0, 0)
	var cell_1: Cell = grid.get_cell(1, 0)
	var cell_2: Cell = grid.get_cell(2, 0)
	
	grid.clear_matches()
	
	assert_null(cell_0.get_tile())
	assert_null(cell_1.get_tile())
	assert_null(cell_2.get_tile())
