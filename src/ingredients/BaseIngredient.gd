extends Sprite

export (String) var Name

func _ready():
	assert(Name != null and len(Name) > 0)
