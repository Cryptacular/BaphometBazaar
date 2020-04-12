extends Node2D

class_name BaseTile

export (String) var Type = ""

func move(current_position: Vector2, target_position: Vector2):
	var tween = $MoveTween
	tween.interpolate_property(self, "position", current_position, target_position, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()
