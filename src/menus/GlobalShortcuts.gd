extends Node


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
