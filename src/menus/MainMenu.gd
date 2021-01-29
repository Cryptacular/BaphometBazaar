extends CenterContainer


func _on_PlayButton_pressed():
	get_tree().change_scene("res://src/levels/PhaseOneTest.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
