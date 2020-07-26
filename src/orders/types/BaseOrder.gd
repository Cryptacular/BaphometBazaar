extends Node2D

class_name BaseOrder

signal order_fulfilled(order)
signal order_expired(order)

export (String) var order_name
export (int) var expiry_seconds
export (Array, PackedScene) var ingredients = []
export (Vector2) var target_position

const PROGRESS_BAR_ANIMATION_FRAMES = 68


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
	
	_spawn()
	_start_progress_bar()
	move_to_target_position()
	
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


func _on_ingredient_stashed(ingredient: String):
	pass
