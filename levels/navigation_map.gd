extends Node2D

var hovered_button: TextureButton = null
var shine_time: float = 0.0
var selected_index: int = 1  # Currently selected level (1-10)
var unlocked_levels: Array[int] = []  # List of unlocked level indices

func _ready() -> void:
	# Connect all level buttons
	# Buttons are named: LevelButton_1, LevelButton_2, etc.

	for i in range(1, 11):
		var btn = get_node_or_null("LevelButton_%d" % i)
		if btn:
			# Check if level is unlocked (level i is at index i in GameState.levels)
			if i <= GameState.highest_level_unlocked:
				unlocked_levels.append(i)
				btn.pressed.connect(_on_level_button_pressed.bind(i))
				# Create click mask from texture alpha so only non-transparent pixels are clickable
				if btn.texture_normal:
					var image = btn.texture_normal.get_image()
					var bitmap = BitMap.new()
					bitmap.create_from_image_alpha(image)
					btn.texture_click_mask = bitmap
				# Add hover brightness effect
				btn.mouse_entered.connect(_on_button_hover.bind(btn, i))
				btn.mouse_exited.connect(_on_button_unhover.bind(btn))
			else:
				# Level not unlocked - hide the button
				btn.visible = false

	var back_btn = get_node_or_null("BackButton")
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)

	# Select first unlocked level by default
	if unlocked_levels.size() > 0:
		selected_index = unlocked_levels[0]
		_select_button(selected_index)


func _input(event: InputEvent) -> void:
	if unlocked_levels.size() == 0:
		return

	var current_pos = unlocked_levels.find(selected_index)

	# Navigate with arrow keys or WASD
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		# Move to next level
		if current_pos < unlocked_levels.size() - 1:
			_select_button(unlocked_levels[current_pos + 1])
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
		# Move to previous level
		if current_pos > 0:
			_select_button(unlocked_levels[current_pos - 1])
	elif event.is_action_pressed("ui_accept"):
		# Enter/Space to select current level
		_on_level_button_pressed(selected_index)


func _select_button(level_index: int) -> void:
	# Unhover previous button
	if hovered_button:
		hovered_button.modulate = Color(1.0, 1.0, 1.0)
		hovered_button = null

	selected_index = level_index
	var btn = get_node_or_null("LevelButton_%d" % level_index)
	if btn:
		hovered_button = btn
		shine_time = 0.0


func _on_level_button_pressed(level_number: int) -> void:
	# LevelButton_1 goes to index 1 (level1.tscn), etc.
	GameState.go_to_level(level_number - 1)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/main_menu.tscn")


func _on_button_hover(btn: TextureButton, level_index: int) -> void:
	_select_button(level_index)


func _on_button_unhover(btn: TextureButton) -> void:
	# Don't unhover if it's the selected button (keep keyboard selection)
	pass


func _process(delta: float) -> void:
	if hovered_button:
		shine_time += delta * 3.0  # Speed of pulsing
		# Oscillate between 0.7 (dim) and 1.3 (bright)
		var brightness = 1.0 + 0.3 * sin(shine_time)
		hovered_button.modulate = Color(brightness, brightness, brightness)
