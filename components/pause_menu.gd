extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _on_button_pressed() -> void:
#	print("restart level pressed")
#	get_tree().change_scene_to_file(GameState.get_current_level())


func _on_restart_pressed() -> void:
	print("restart level pressed")
	Engine.time_scale = 1
	get_tree().change_scene_to_file(GameState.get_current_level())


func _on_quit_pressed() -> void:
	print("Quit pressed")
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://levels/main_menu.tscn")
