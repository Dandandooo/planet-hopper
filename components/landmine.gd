class_name Landmine
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_kill_player)

func _kill_player(node: Node2D):
	var player = node as Wabbit
	if player:
		player.explode()
