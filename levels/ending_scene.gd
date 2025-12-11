extends Node2D

@onready var wabbit: Sprite2D = $FloatingWabbit
@onready var congrats_label: Label = $CongratsLabel
@onready var black_overlay: ColorRect = $BlackOverlay
@onready var or_did_you_label: Label = $OrDidYouLabel
@onready var rabbit_image: Sprite2D = $RabbitImage
@onready var robot_rabbit_image: Sprite2D = $RobotRabbitImage
@onready var credits_label: Label = $CreditsLabel
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var dun_dun_player: AudioStreamPlayer = $DunDunPlayer

var wabbit_speed: float = 150.0
var wabbit_start_pos: Vector2
var wabbit_end_pos: Vector2
var screen_size: Vector2

enum State { WABBIT_FLOATING, FADING_TO_BLACK, SHOW_OR_DID_YOU, SWAP_TO_ROBOT, WAIT_AFTER_ROBOT, ROLLING_CREDITS, CREDITS_FINISHED }
var current_state: State = State.WABBIT_FLOATING
var fade_alpha: float = 0.0
var fade_speed: float = 0.5
var wait_timer: float = 0.0
var swap_alpha: float = 0.0
var credits_scroll_speed: float = 50.0
var credits_done_timer: float = 0.0

# Robot rabbit floating variables
var robot_velocity: Vector2
var robot_rotation_speed: float

func _ready() -> void:
	screen_size = get_viewport_rect().size

	# Start from left side, off screen
	wabbit_start_pos = Vector2(-100, screen_size.y / 2)
	# End at right side, off screen
	wabbit_end_pos = Vector2(screen_size.x + 100, screen_size.y / 2)

	wabbit.position = wabbit_start_pos

	# Hide elements initially
	black_overlay.modulate.a = 0.0
	or_did_you_label.visible = false
	rabbit_image.visible = false
	robot_rabbit_image.visible = false
	robot_rabbit_image.modulate.a = 0.0
	credits_label.visible = false

	# Setup credits text with game stats
	_setup_credits_text()

	# Initialize robot floating motion
	robot_velocity = Vector2(80, 60)
	robot_rotation_speed = 0.3

	# Start playing music at the beginning
	music_player.play()

func _setup_credits_text() -> void:
	var minutes = int(GameState.time_spent) / 60
	var seconds = int(GameState.time_spent) % 60
	var time_string = "%d:%02d" % [minutes, seconds]

	credits_label.text = """
YOUR STATS

Deaths: %d

Planets Reached: %d

Carrots Eaten: %d

Time Spent: %s

Jumps: %d

Double Jumps: %d


Thanks for playing!

PLANET HOPPER
""" % [
		GameState.death_count,
		GameState.planets_reached_count,
		GameState.carrots_eaten_count,
		time_string,
		GameState.jumps_count,
		GameState.doublejumps_count
	]

func _process(delta: float) -> void:
	match current_state:
		State.WABBIT_FLOATING:
			# Move wabbit across the screen
			if wabbit.position.x < wabbit_end_pos.x:
				wabbit.position.x += wabbit_speed * delta
				# Gentle rotation while floating
				wabbit.rotation += delta * 0.5
			else:
				# Wabbit has left the screen, start fading to black
				current_state = State.FADING_TO_BLACK

		State.FADING_TO_BLACK:
			fade_alpha += fade_speed * delta
			black_overlay.modulate.a = fade_alpha
			if fade_alpha >= 1.0:
				black_overlay.modulate.a = 1.0
				congrats_label.visible = false
				current_state = State.SHOW_OR_DID_YOU
				or_did_you_label.visible = true
				rabbit_image.visible = true
				wait_timer = 0.0

		State.SHOW_OR_DID_YOU:
			# Wait 2 seconds before swapping
			wait_timer += delta
			if wait_timer >= 2.0:
				current_state = State.SWAP_TO_ROBOT
				robot_rabbit_image.visible = true
				# Stop music when rabbit starts to fade
				music_player.stop()
				# Play dun dun duuun sound effect
				dun_dun_player.play()

		State.SWAP_TO_ROBOT:
			# Crossfade: rabbit fades out, robot fades in
			swap_alpha += fade_speed * delta
			rabbit_image.modulate.a = 1.0 - swap_alpha
			robot_rabbit_image.modulate.a = swap_alpha
			if swap_alpha >= 1.0:
				rabbit_image.visible = false
				robot_rabbit_image.modulate.a = 1.0
				current_state = State.WAIT_AFTER_ROBOT
				wait_timer = 0.0

		State.WAIT_AFTER_ROBOT:
			# Wait 2 seconds after robot fully appears
			wait_timer += delta
			if wait_timer >= 2.0:
				current_state = State.ROLLING_CREDITS
				or_did_you_label.visible = false
				credits_label.visible = true
				# Restart music from beginning for credits
				music_player.play(0.0)

		State.ROLLING_CREDITS:
			# Robot rabbit floats around
			_float_robot_rabbit(delta)

			# Stop scrolling when last line is in center of screen
			var credits_bottom = credits_label.position.y + credits_label.size.y
			var screen_center_y = screen_size.y / 2

			if credits_bottom > screen_center_y:
				# Keep scrolling
				credits_label.position.y -= credits_scroll_speed * delta
			else:
				# Credits finished, wait then go to main menu
				current_state = State.CREDITS_FINISHED
				credits_done_timer = 0.0

		State.CREDITS_FINISHED:
			# Robot rabbit keeps floating
			_float_robot_rabbit(delta)

			# Wait 3 seconds then return to main menu
			credits_done_timer += delta
			if credits_done_timer >= 3.0:
				get_tree().change_scene_to_file("res://levels/main_menu.tscn")

func _float_robot_rabbit(delta: float) -> void:
	# Update position
	robot_rabbit_image.position += robot_velocity * delta

	# Update rotation
	robot_rabbit_image.rotation += robot_rotation_speed * delta

	# Bounce off edges
	var half_size = 50.0  # Approximate half size of sprite

	if robot_rabbit_image.position.x - half_size <= 0:
		robot_rabbit_image.position.x = half_size
		robot_velocity.x = abs(robot_velocity.x)
	elif robot_rabbit_image.position.x + half_size >= screen_size.x:
		robot_rabbit_image.position.x = screen_size.x - half_size
		robot_velocity.x = -abs(robot_velocity.x)

	if robot_rabbit_image.position.y - half_size <= 0:
		robot_rabbit_image.position.y = half_size
		robot_velocity.y = abs(robot_velocity.y)
	elif robot_rabbit_image.position.y + half_size >= screen_size.y:
		robot_rabbit_image.position.y = screen_size.y - half_size
		robot_velocity.y = -abs(robot_velocity.y)
