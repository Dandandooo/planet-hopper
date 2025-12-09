class_name Tower
extends Node2D

@export_file_path var next_scene: String
@export var audio_stream: AudioStream
@export_range(100, 2000, 50) var max_hearing_distance: float = 500.0
@export_range(0, 80, 1) var min_volume_db: float = 20.0

var default_sound = preload("res://assets/sound/radio_noise.wav")
var other_default_sound = preload("res://assets/sound/lonely_music_station.mp3")
var tutorial_sound = preload("res://assets/sound/evac_broadcast_simple.mp3")
var level1_sound = preload("res://assets/sound/science_channel_distorted.mp3")
var player: Wabbit
var audio_player: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not next_scene:
		push_error("Please select a next scene for this tower")
	player = get_tree().get_first_node_in_group("Player")

	# Set up audio player
	audio_player = $AudioStreamPlayer2D
	# Use custom audio stream if provided, otherwise use default or level-specific sound
	var using_default = false
	if not audio_stream:
		# Check which level we're in
		var current_scene = get_tree().current_scene.scene_file_path
		if current_scene.contains("tutorial_level"):
			audio_stream = tutorial_sound
		elif current_scene.contains("level1"):
			audio_stream = level1_sound
		else:
			# Randomize between the two default sounds
			if randf() < 0.5:
				audio_stream = default_sound
			else:
				audio_stream = other_default_sound
		using_default = true
	audio_player.stream = audio_stream
	audio_player.volume_db = -min_volume_db

	# Connect finished signal for looping with delay
	audio_player.finished.connect(_on_audio_finished)

	# Start playing immediately (audio always plays, volume changes with distance)
	if audio_stream:
		if using_default:
			# Start at random timestamp for variety
			var stream_length = audio_stream.get_length()
			var random_start = randf() * stream_length
			audio_player.play(random_start)
		else:
			audio_player.play()


func _process(_delta: float) -> void:
	if player and audio_stream:
		_update_audio()

	if Input.is_action_just_pressed("radio"):
		print("pressed")
		print($Area2D.get_overlapping_bodies())
		for node in $Area2D.get_overlapping_bodies():
			var wab = node as Wabbit
			if wab:
				GameState.advance_to_next_level()
		#if player in $Area2D.get_overlapping_bodies():

			#get_tree().change_scene_to_file(next_scene)


func _update_audio() -> void:
	var distance = global_position.distance_to(player.global_position)

	# Calculate volume based on distance (audio always plays, volume changes)
	# At collision (distance ~0), volume is 0 dB (normal)
	# At max_hearing_distance and beyond, volume is -min_volume_db (very quiet)
	var volume_factor = 1.0 - min(distance / max_hearing_distance, 1.0)
	audio_player.volume_db = lerp(-min_volume_db, 0.0, volume_factor)


func _on_audio_finished() -> void:
	# Loop the audio with a random 2-5 second gap
	if audio_player and audio_player.stream:
		# Random delay between 2 and 5 seconds
		var delay = randf_range(2.0, 5.0)
		await get_tree().create_timer(delay).timeout
		# Make sure the audio player still exists after the delay
		if audio_player and audio_player.stream:
			audio_player.play()
