extends MarginContainer

signal timeout

export (int) var duration_seconds = 180

onready var time_left: int = duration_seconds

func _ready():
	$TimeRemaining.text = _format_time_remaining(time_left)
	$Timer.connect("timeout", self, "_on_second_passed")


func _on_second_passed():
	time_left -= 1
	$TimeRemaining.text = _format_time_remaining(time_left)
	
	if time_left == 0:
		$Timer.disconnect("timeout", self, "_on_second_passed")
		emit_signal("timeout")


func _format_time_remaining(total_seconds: int) -> String:
	var minutes := floor(total_seconds / 60)
	var seconds := total_seconds % 60
	
	if seconds < 10:
		return str(minutes) + ":0" + str(seconds)
	else:
		return str(minutes) + ":" + str(seconds)
