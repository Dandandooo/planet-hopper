extends Node2D

@export var launch_strength = 1000

var beam: Sprite2D
var timer: Timer
@export_range(0, 3, 0.1) var geyser_duration: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var area = find_child("Area2D") as Area2D
	if area:
		area.body_entered.connect(_launch_player)
	else:
		print("CANNOT FIND CHILD AREA!")
	beam = find_child("GeyserBeam") as Sprite2D
	timer = find_child("Timer") as Timer
	timer.wait_time = geyser_duration

func _launch_player(body: Node2D) -> void:
	var player: Wabbit = body as Wabbit
	if player:
		player.launch(global_rotation - PI/2, launch_strength)
		beam.visible = true
		timer.start()
		await timer.timeout
		beam.visible = false
	
