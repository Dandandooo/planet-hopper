extends Node2D

@export var audio_stream: AudioStream
@export_range(100, 2000, 50) var max_hearing_distance: float = 500.0
@export_range(0, 80, 1) var min_volume_db: float = 40.0

var default_sound = preload("res://assets/sound/radio_noise.wav")

var planet: Planet = null
var surface_distance: float = 200.0
var surface_angle: float = 0.0
var audio_player: AudioStreamPlayer2D
var wabbit: Wabbit = null

func _ready() -> void:
	planet = get_parent() as Planet
	if not planet:
		push_error("RadioStation must be a child of a Planet node")
		return

	# Calculate initial position relative to planet surface
	var offset = global_position - planet.global_position
	if offset.length() > 0:
		surface_distance = offset.length()
		surface_angle = atan2(offset.y, offset.x)

	# Position on planet surface
	_update_position()

	# Find wabbit in the scene
	var root = get_tree().root
	wabbit = _find_wabbit(root)

	# Set up audio player
	audio_player = $AudioStreamPlayer2D
	# Use custom audio stream if provided, otherwise use default
	var using_default = false
	if not audio_stream:
		audio_stream = default_sound
		using_default = true
	audio_player.stream = audio_stream
	audio_player.volume_db = -min_volume_db

	# Connect finished signal for looping
	audio_player.finished.connect(_on_audio_finished)

	# If using default sound, start at random timestamp
	if using_default and audio_stream:
		var stream_length = audio_stream.get_length()
		var random_start = randf() * stream_length
		audio_player.play(random_start)

func _process(delta: float) -> void:
	if planet:
		_update_position()

	if wabbit and audio_stream:
		_update_audio()

func _update_position() -> void:
	# Keep radio station fixed at the same angle on planet surface
	var planet_pos = planet.global_position
	global_position = planet_pos + surface_distance * Vector2(cos(surface_angle), sin(surface_angle))

	# Rotate to align with planet surface (pointing away from center)
	global_rotation = surface_angle + PI / 2

func _update_audio() -> void:
	var distance = global_position.distance_to(wabbit.global_position)

	if distance <= max_hearing_distance:
		# Calculate volume based on distance
		# At collision (distance ~0), volume is 0 dB (normal)
		# At max_hearing_distance, volume is -min_volume_db
		var volume_factor = 1.0 - (distance / max_hearing_distance)
		audio_player.volume_db = lerp(-min_volume_db, 0.0, volume_factor)

		if not audio_player.playing:
			audio_player.play()
	else:
		if audio_player.playing:
			audio_player.stop()

func _on_audio_finished() -> void:
	# Loop the audio by restarting it
	if audio_player.stream:
		audio_player.play()

func _find_wabbit(node: Node) -> Wabbit:
	if node is Wabbit:
		return node
	for child in node.get_children():
		var result = _find_wabbit(child)
		if result:
			return result
	return null
