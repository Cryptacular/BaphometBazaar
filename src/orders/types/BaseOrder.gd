tool
extends Area2D

class_name BaseOrder

signal order_fulfilled(order, ingredients)
signal order_expired(order)

export (String) var order_name
export (int) var expiry_seconds
export (Array, PackedScene) var ingredients = []
export (Vector2) var target_position

const PROGRESS_BAR_ANIMATION_FRAMES = 68
enum States {
	IDLE,
	FULFILLABLE
}

var required_ingredients = {}
var state = States.IDLE
var inventory

func _ready():
	assert(order_name != null and len(order_name) > 0)
	assert(ingredients != null and len(ingredients) > 0)
	assert(target_position != null)
	assert(expiry_seconds != null and expiry_seconds > 0)
	
	modulate.a = 0
	
	$Title.text = order_name
	
	for i in len(ingredients):
		var ing = ingredients[i].instance()
		$Ingredients.add_child(ing)
		ing.position = Vector2(56 * i, 0)
		
		if !required_ingredients.has(ing.Name):
			required_ingredients[ing.Name] = 1
		else:
			required_ingredients[ing.Name] += 1
		
	
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


func fulfil():
	var items := {}
	for ingredient in ingredients:
		if items[ingredient.Name]:
			items[ingredient.Name] += 1
		else:
			items[ingredient.Name] = 1
	
	emit_signal("order_fulfilled", order_name, items)


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
	emit_signal("order_fulfilled", self, required_ingredients)
	
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
