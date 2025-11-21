extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var area = find_child("Area2D") as Area2D
	if area:
		area.body_entered.connect(_end_level)
	else:
		print("CANNOT FIND CHILD AREA!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _end_level(body: Node2D) -> void:
	var player: Wabbit = body as Wabbit
	if player:
		# Go to next level
		print("LEVEL COMPLETE")
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://levels/level2.tscn")
	pass
