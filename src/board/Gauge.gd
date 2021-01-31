extends Control


func set_progress(percentage_completed: float) -> void:
	var tween = $RotateTween
	
	var start_angle = $Hand.rect_rotation
	var finish_angle = 230 - (percentage_completed * 230) - 25
	
	tween.interpolate_property($Hand, "rect_rotation", start_angle, finish_angle, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property($HandShadow, "rect_rotation", start_angle, finish_angle, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()
