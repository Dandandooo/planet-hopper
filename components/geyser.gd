extends Node2D

@export var launch_strength = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var area = find_child("Area2D") as Area2D
	if area:
		area.body_entered.connect(_launch_player)
	else:
		print("CANNOT FIND CHILD AREA!")

func _launch_player(body: Node2D) -> void:
	var player: Wabbit = body as Wabbit
	if player:
		player.launch(global_rotation - PI/2, launch_strength)
	
