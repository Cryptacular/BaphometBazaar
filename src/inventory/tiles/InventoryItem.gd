tool
extends VBoxContainer

class_name InventoryItem

var Type: String
var _amount := 0 setget set_amount, get_amount


func _ready() -> void:
	assert(Type != null and len(Type) > 0)
	modulate = Color(1, 1, 1, 0)
	fade_in(1)


func _process(_delta) -> void:
	$AmountLabel.text = str(_amount)


func get_amount() -> int:
	return _amount


func set_amount(amount: int) -> void:
	_amount = amount


func fade_in(duration: float) -> void:
	var tween = $FadeInTween
	var start_color = Color(1, 1, 1, 0)
	var finish_color = Color(1, 1, 1, 1)
	
	tween.interpolate_property(self, "modulate", start_color, finish_color, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	if !tween.is_active():
		tween.start()
	
	$AnimationPlayer.play("SlideUp")
