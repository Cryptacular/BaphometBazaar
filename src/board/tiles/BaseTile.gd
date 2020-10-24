extends Node2D

class_name BaseTile

signal start_dragging
signal is_being_dragged

var Type: String
var target_position: Vector2
var spawn_delay: float = 0.0
var state = states.INIT

enum states {
	INIT,
	SPAWNING,
	IDLE
}


func _ready() -> void:
	assert(Type != null and len(Type) > 0)
	assert(target_position != null)
	state = states.SPAWNING
	var sprite: AnimatedSprite = $AnimatedSprite
	sprite.modulate = Color(1, 1, 1, 0)


func _set_animation_idle():
	var sprite = $AnimatedSprite
	sprite.play("idle")
	var starting_frame := floor(rand_range(0, sprite.frames.get_frame_count("idle")))
	sprite.frame = starting_frame
	sprite.disconnect("animation_finished", self, "_set_animation_idle")


func spawn_in():
	var sprite = $AnimatedSprite
	sprite.modulate = Color(1, 1, 1, 1)
	sprite.play("spawning")
	sprite.connect("animation_finished", self, "_set_animation_idle")


func move() -> void:
	yield(get_tree().create_timer(spawn_delay), "timeout")
	self.spawn_delay = 0.0
	
	if state == states.SPAWNING:
		spawn_in()
	
	var tween = $MoveTween
	tween.interpolate_property(self, "position", self.position, target_position, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()
	
	state = states.IDLE


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


func _on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventScreenTouch and event.is_pressed():
		emit_signal("start_dragging")
	elif event is InputEventScreenDrag:
		emit_signal("is_being_dragged")
