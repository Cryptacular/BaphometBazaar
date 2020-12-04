extends Area2D

class_name BaseRecipe

signal recipe_fulfilled(recipe, ingredients, worth)

export (String) var recipe_name
export (int) var worth
export (Array, String) var ingredients = []
export (Vector2) var target_position

enum States {
	IDLE,
	FULFILLABLE,
	FULFILLING,
	GAMEOVER
}

var required_ingredients = {}
var state = States.IDLE
var inventory


func _ready():
	assert(recipe_name != null and len(recipe_name) > 0)
	assert(ingredients != null and len(ingredients) > 0)
	assert(target_position != null)
	assert(worth != null and worth > 0)
	
	modulate.a = 0
	
	$Title.text = recipe_name
	$Worth.text = "$" + str(worth)
	
	for i in len(ingredients):
		var type = ingredients[i]
		var ing = IngredientFactory.get_ingredient(type)
		$Ingredients.add_child(ing)
		
		if !required_ingredients.has(type):
			required_ingredients[type] = 1
		else:
			required_ingredients[type] += 1
		
	
	_spawn()
	move_to_target_position()


func move_to_target_position():
	var tween = $MoveTween
	tween.interpolate_property(self, "position", position, target_position, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()


func _spawn():
	var tween = $FadeInTween
	var start_color = Color(1, 1, 1, 0)
	var finish_color = Color(1, 1, 1, 1)
	tween.interpolate_property(self, "modulate", start_color, finish_color, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()


func _fulfill():
	state = States.FULFILLING
	emit_signal("recipe_fulfilled", self, required_ingredients, worth)


func _check_against_inventory(inventory: Dictionary) -> void:
	var bg = $Background
	
	if _has_all_ingredients(inventory):
		bg.play("ready")
		state = States.FULFILLABLE
	else:
		bg.play("default")
		state = States.IDLE


func _has_all_ingredients(inventory: Dictionary) -> bool:
	for ingredient in required_ingredients:
		if !inventory.has(ingredient):
			return false
		
		if inventory[ingredient] < required_ingredients[ingredient]:
			return false
	
	return true


func on_inventory_updated(inventory: Dictionary):
	_check_against_inventory(inventory)


func _on_recipe_clicked(viewport, event: InputEvent, shape_idx):
	if state != States.FULFILLABLE:
		return
	
	if event is InputEventScreenTouch and event.is_pressed():
		_fulfill()


func on_game_over():
	state = States.GAMEOVER
