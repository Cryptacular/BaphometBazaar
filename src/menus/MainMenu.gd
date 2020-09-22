extends CenterContainer

func _ready():
	Button


func _on_PlayButton_pressed():
	get_tree().change_scene("res://src/levels/TestLevel.tscn")
