extends Area2D

class_name BaseOrder

signal order_fulfilled(order, ingredients, worth)
signal order_expired(order)

export (String) var order_name
export (int) var worth
export (int) var expiry_seconds
export (Array, String) var ingredients = []
export (Vector2) var target_position

const PROGRESS_BAR_ANIMATION_FRAMES = 68
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
	assert(order_name != null and len(order_name) > 0)
	assert(ingredients != null and len(ingredients) > 0)
	assert(target_position != null)
	assert(worth != null and worth > 0)
	assert(expiry_seconds != null and expiry_seconds > 0)
	
	modulate.a = 0
	
	$Title.text = order_name
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
	_start_progress_bar()
	move_to_target_position()
	
	_check_against_inventory(inventory.state)
	
	get_tree().create_timer(expiry_seconds).connect("timeout", self, "_expire")


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


func _start_progress_bar():
	var progress_bar = $ProgressBar
	progress_bar.speed_scale = float(PROGRESS_BAR_ANIMATION_FRAMES) / float(expiry_seconds)
	progress_bar.play()


func _expire():
	if state == States.GAMEOVER:
		return
	
	var tween = $DeathTween
	var start_color = Color(1, 1, 1, 1)
	var finish_color = Color(1, 1, 1, 0)
	tween.interpolate_property(self, "modulate", start_color, finish_color, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(self, "position", position, Vector2(position.x, -20), 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()
	
	yield(tween, "tween_completed")
	
	emit_signal("order_expired", self)
	queue_free()


func _fulfill():
	state = States.FULFILLING
	emit_signal("order_fulfilled", self, required_ingredients, worth)
	
	var tween = $DeathTween
	var start_color = Color(1, 1, 1, 1)
	var finish_color = Color(1, 1, 1, 0)
	tween.interpolate_property(self, "modulate", start_color, finish_color, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(self, "position", position, Vector2(position.x, -20), 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()
	
	yield(tween, "tween_completed")
	
	queue_free()


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


func _on_order_clicked(viewport, event: InputEvent, shape_idx):
	if state != States.FULFILLABLE:
		return
	
	if event is InputEventScreenTouch and event.is_pressed():
		_fulfill()


func on_game_over():
	$ProgressBar.stop()
	state = States.GAMEOVER
