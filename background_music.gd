extends Node

var audio_player: AudioStreamPlayer
var background_music = preload("res://assets/sound/space_ambient.wav")


func _ready() -> void:
	# Create audio player
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = background_music
	audio_player.autoplay = true
	audio_player.bus = "Master"
	audio_player.volume_db = -15.0  # Lower volume (0 dB is normal, negative is quieter)

	# Add to scene tree
	add_child(audio_player)

	# Connect finished signal for looping
	audio_player.finished.connect(_on_audio_finished)

	# Start playing
	audio_player.play()


func _on_audio_finished() -> void:
	# Loop the music by restarting it
	audio_player.play()
