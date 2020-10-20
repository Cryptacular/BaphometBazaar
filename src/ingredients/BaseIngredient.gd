tool
extends MarginContainer

class_name BaseIngredient

var Type: String

func _ready():
	assert(Type != null and len(Type) > 0)
