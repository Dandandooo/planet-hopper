extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_button_pressed():
	print("new_game_button_pressed")
	get_tree().change_scene_to_file("res://levels/tutorial_level.tscn")


func _on_load_level_button_pressed():
	print("load level button pressed")
	get_tree().change_scene_to_file("res://levels/navigation_map.tscn")


func _on_info_button_pressed():
	print("info button pressed")
	get_tree().change_scene_to_file("res://levels/info_page.tscn")


func _on_exit_button_pressed():
	print("exit button pressed")
	get_tree().quit()
