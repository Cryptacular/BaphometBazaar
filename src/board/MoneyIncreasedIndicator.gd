extends Control

export (int) var amount
const timeout: float = 1.75


func _ready():
	assert(amount != null)
	
	if amount <= 0:
		queue_free()
		return
	
	$Label.text = "+" + str(amount)
	
	fade_out(timeout)
	move_up(timeout)
	
	yield(get_tree().create_timer(timeout + 0.5), "timeout")
	queue_free()


func fade_out(duration: float):
	var tween = $FadeOutTween
	var start_color = Color(1, 1, 1, 1)
	var finish_color = Color(1, 1, 1, 0)
	
	tween.interpolate_property(self, "modulate", start_color, finish_color, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()


func move_up(duration: float):
	var tween = $MoveTween
	var start = 0.0
	var finish = -100.0
	
	tween.interpolate_property(self, "margin_top", start, finish, duration, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	
	if !tween.is_active():
		tween.start()
