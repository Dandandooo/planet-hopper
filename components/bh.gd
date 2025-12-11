class_name BlackHole
extends Celestial


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mass = 500
	$Area2D.body_entered.connect(_win)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _win(body: Node) -> void:
	if body as Wabbit:
		get_tree().change_scene_to_file("res://levels/ending_scene.tscn")
