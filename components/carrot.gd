extends Node2D

var sound = preload("res://assets/sound/munch.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.body_entered.connect(_eaten)
	$AudioStreamPlayer2D.stream = sound

func _eaten(eater: Node2D) -> void:
	var player = eater as Wabbit
	if player:
		$AudioStreamPlayer2D.play()
		$Area2D.queue_free()
		player.double_jumps = 1
		player.double_jumps_remaining = 1
