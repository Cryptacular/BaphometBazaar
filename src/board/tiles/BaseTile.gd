extends Node2D

class_name BaseTile

export (String) var Type = ""


func move(current_position: Vector2, target_position: Vector2):
	var tween = $MoveTween
	var distance = (target_position - current_position).length() / 32
	tween.interpolate_property(self, "position", current_position, target_position, distance * 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()


func clear():
	var timer: Timer = $DeathTimer
	_animate_death()
	timer.connect("timeout", self, "_kill")
	timer.start()


func _animate_death():
	var tween = $DeathTween
	var sprite = $Sprite
	tween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()


func _kill():
	var timer: Timer = $DeathTimer
	timer.disconnect("timeout", self, "_kill")
	queue_free()
