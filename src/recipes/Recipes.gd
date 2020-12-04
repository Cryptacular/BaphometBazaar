tool
extends Node2D

class_name Recipes

signal recipe_fulfilled(type, ingredients, worth)

export (Array, PackedScene) var recipe_types

var inventory
var available_recipes = []
var state = states.ACTIVE

const RECIPE_WIDTH = 300

enum states {
	ACTIVE,
	GAMEOVER,
}


func _ready():
	assert(recipe_types != null and len(recipe_types) > 0)
	
	for recipe in recipe_types:
		_spawn_recipe(recipe)

func _spawn_recipe(recipe_type: PackedScene):
	var i = len(available_recipes)
	var recipe: BaseRecipe = recipe_type.instance()
	recipe.position = Vector2(1080, 0)
	recipe.target_position = Vector2(i * RECIPE_WIDTH, 0)
	recipe.inventory = inventory
	
	$Rows/Recipes.add_child(recipe)
	available_recipes.append(recipe)
	
	recipe.connect("recipe_fulfilled", self, "_on_recipe_fulfilled")


func _layout():
	if state == states.GAMEOVER:
		return
	
	for i in available_recipes.size():
		var recipe: BaseRecipe = available_recipes[i]
		recipe.target_position = Vector2(i * RECIPE_WIDTH, 0)
		recipe.move_to_target_position()


func on_inventory_updated(ingredients: Dictionary) -> void:
	if state == states.GAMEOVER:
		return
	
	for recipe in available_recipes:
		if recipe == null:
			return
		recipe.on_inventory_updated(ingredients)


func _on_recipe_fulfilled(recipe: BaseRecipe, items: Dictionary, worth: int):
	if state == states.GAMEOVER:
		return
	
	emit_signal("recipe_fulfilled", recipe, items, worth)


func _on_gameover():
	state = states.GAMEOVER
	
	for recipe in available_recipes:
		recipe.disconnect("recipe_fulfilled", self, "_on_recipe_fulfilled")
		recipe.on_game_over()
