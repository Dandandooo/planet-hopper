extends Control

func _on_button_pressed() -> void:
	print("restart level pressed")
	get_tree().change_scene_to_file(GameState.get_current_level())
