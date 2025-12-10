@tool
extends Control

# Preload the level star scene (you'll create this in Godot)
const LevelStar = preload("res://components/level_star.gd")
const EarthTexture = preload("res://assets/character_sprite/Hello-World-earth.svg")

# Star positions in a constellation pattern (x, y coordinates)
# Adjust these to create your desired star map layout
var star_positions = [
	Vector2(200, 400),   # Tutorial
	Vector2(350, 300),   # Level 1
	Vector2(500, 350),   # Level 2
	Vector2(650, 250),   # Level 3
	Vector2(800, 300),   # Level 4
	# Add more positions as needed
]

var level_stars: Array = []


func _ready() -> void:
	create_star_map()
	if not Engine.is_editor_hint():
		update_star_states()
	create_back_button()


func create_star_map() -> void:
	# Clear existing stars first (useful for editor updates)
	for star in level_stars:
		if is_instance_valid(star) and star.get_parent():
			star.get_parent().queue_free()
	level_stars.clear()

	# Get level count (use a default in editor if GameState not available)
	var level_count = 5 if Engine.is_editor_hint() else GameState.get_level_count()

	# Create a star for each level
	for i in range(level_count):
		# Create container for the planet button
		var star_container = Control.new()
		star_container.name = "LevelButton_" + str(i)
		star_container.custom_minimum_size = Vector2(80, 80)

		# Create the visual planet sprite
		var star_visual = Sprite2D.new()
		star_visual.texture = EarthTexture
		star_visual.position = Vector2(40, 40)  # Center in container
		star_visual.scale = Vector2(0.15, 0.15)  # Scale down the earth sprite

		# Create a button for interaction
		var star = TextureButton.new()
		star.custom_minimum_size = Vector2(80, 80)
		star.script = LevelStar

		# Set position
		if i < star_positions.size():
			star_container.position = star_positions[i]
		else:
			# Fallback: arrange in a grid if we run out of predefined positions
			star_container.position = Vector2(200 + (i % 4) * 150, 200 + int(i / 4) * 150)

		# Set level info
		star.level_index = i
		star.level_name = "Level " + str(i + 1) if i > 0 else "Tutorial"

		# Connect signal
		star.star_selected.connect(_on_star_selected)

		# Build hierarchy
		star_container.add_child(star_visual)
		star_container.add_child(star)

		# Create a label for the star
		var label = Label.new()
		label.name = "Label"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.position = Vector2(0, 65)
		label.custom_minimum_size = Vector2(80, 20)
		label.add_theme_font_size_override("font_size", 14)
		star_container.add_child(label)

		# Add to scene
		add_child(star_container)

		# Set owner for editor visibility
		if Engine.is_editor_hint() and get_tree():
			var root = get_tree().edited_scene_root
			if root:
				star_container.owner = root
				star_visual.owner = root
				star.owner = root
				label.owner = root

		level_stars.append(star)


func update_star_states() -> void:
	# Skip in editor since GameState might not be initialized
	if Engine.is_editor_hint():
		return

	for i in range(level_stars.size()):
		var star = level_stars[i]

		if i == GameState.current_level_index:
			star.set_state(LevelStar.StarState.CURRENT)
		elif i > GameState.highest_level_unlocked:
			star.set_state(LevelStar.StarState.LOCKED)
		elif i < GameState.current_level_index:
			star.set_state(LevelStar.StarState.COMPLETED)
		else:
			star.set_state(LevelStar.StarState.UNLOCKED)


func _on_star_selected(level_index: int) -> void:
	# Skip in editor
	if Engine.is_editor_hint():
		return

	# Player clicked on a star
	GameState.go_to_level(level_index)
	# Use scene manager for smooth transition, or direct change
	get_tree().change_scene_to_file(GameState.get_current_level())
	# Or with scene manager: SceneManager.transition_to(GameState.get_current_level())


func create_back_button() -> void:
	var back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = "Back to Menu"
	back_button.position = Vector2(20, 20)
	back_button.custom_minimum_size = Vector2(150, 40)
	back_button.pressed.connect(_on_back_pressed)
	add_child(back_button)

	# Set owner for editor visibility
	if Engine.is_editor_hint() and get_tree():
		var root = get_tree().edited_scene_root
		if root:
			back_button.owner = root


func _on_back_pressed() -> void:
	# Skip in editor
	if Engine.is_editor_hint():
		return

	get_tree().change_scene_to_file("res://levels/main_menu.tscn")
