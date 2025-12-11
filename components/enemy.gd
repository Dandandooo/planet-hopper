class_name Enemy
extends Node2D

var centroid: Vector2
var orbit_radius: float = 250.0
var orbit_speed: float = 100.0

var villager_sound = preload("res://assets/sound/minecraft-villager-289282.mp3")
var audio_player: AudioStreamPlayer2D
var next_sound_time: float = 0.0

func _ready() -> void:
	# Create audio player for villager sounds
	audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = villager_sound
	add_child(audio_player)
	_schedule_next_sound()
	$Area2D.body_entered.connect(_on_collision)
	var planet = get_parent()
	if not planet is Planet:
		push_error("Enemy must be a child of a Planet node")
		return

	centroid = planet.global_position

	var offset = global_position - centroid
	if offset.length() > 0:
		orbit_radius = offset.length()
		
	$AnimatedSprite2D.play()

func _process(delta: float) -> void:
	var planet = get_parent()
	if planet is Planet:
		centroid = planet.global_position

		var pos = global_position - centroid
		var angle = atan2(pos.y, pos.x)
		angle += orbit_speed / orbit_radius * delta
		global_rotation = angle + PI/2
		global_position = centroid + orbit_radius * Vector2(cos(angle), sin(angle))

	# Random sound timer
	next_sound_time -= delta
	if next_sound_time <= 0:
		_play_random_sound()

func _on_collision(node: Node):
	var player = node as Wabbit
	if player:
		player.explode()


func _schedule_next_sound() -> void:
	# Random delay between 3 and 10 seconds
	next_sound_time = randf_range(3.0, 10.0)


func _play_random_sound() -> void:
	if not audio_player.playing:
		audio_player.play()
	_schedule_next_sound()
