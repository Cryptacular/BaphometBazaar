tool
extends Node2D

class_name BaseTile

export (String) var Type = ""


func _ready() -> void:
	var sprite = $AnimatedSprite
	sprite.play("spawning")
	sprite.connect("animation_finished", self, "_set_animation_idle")


func _set_animation_idle():
	var sprite = $AnimatedSprite
	sprite.play("idle")
	var starting_frame := floor(rand_range(0, sprite.frames.get_frame_count("idle")))
	sprite.frame = starting_frame
	sprite.disconnect("animation_finished", self, "_set_animation_idle")


func move(current_position: Vector2, target_position: Vector2) -> void:
	var tween = $MoveTween
	tween.interpolate_property(self, "position", current_position, target_position, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()


func swap_and_return(dir: String):
	if dir == "right":
		$AnimationPlayer.play("SwapAndReturnRight")
	elif dir == "left":
		$AnimationPlayer.play("SwapAndReturnLeft")
	elif dir == "up":
		$AnimationPlayer.play("SwapAndReturnUp")
	elif dir == "down":
		$AnimationPlayer.play("SwapAndReturnDown")


func clear() -> void:
	var sprite = $AnimatedSprite
	sprite.play("death")
	sprite.connect("animation_finished", self, "_kill")


func _kill() -> void:
	var sprite = $AnimatedSprite
	sprite.disconnect("animation_finished", self, "_kill")
	queue_free()
