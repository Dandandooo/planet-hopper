extends Node2D

@export var launch_strength = 1000

var geyser_audio = preload("res://assets/sound/geyser.mp3")

@onready var beam: Sprite2D = $GeyserBeam
@onready var timer: Timer = $Timer
@export_range(0, 3, 0.1) var geyser_duration: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.body_entered.connect(_launch_player)
	timer.wait_time = geyser_duration
	$AudioStreamPlayer2D.stream = geyser_audio

func _launch_player(body: Node2D) -> void:
	var player: Wabbit = body as Wabbit
	if player:
		player.launch(global_rotation - PI/2, launch_strength, true)
		beam.visible = true
		timer.start()
		$AudioStreamPlayer2D.play()
		await timer.timeout
		beam.visible = false
	
