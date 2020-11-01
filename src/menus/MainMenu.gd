extends CenterContainer


func _on_PlayButton_pressed():
	get_tree().change_scene("res://src/levels/TestLevel.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
