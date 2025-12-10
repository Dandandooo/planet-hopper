@tool
extends TextureButton

enum StarState { LOCKED, UNLOCKED, COMPLETED, CURRENT }

@export var level_index: int = 0
@export var level_name: String = "Level"

var state: StarState = StarState.LOCKED

signal star_selected(level_index: int)

# Colors for different states
const COLOR_LOCKED = Color(0.3, 0.3, 0.3, 0.5)  # Gray/dim
const COLOR_UNLOCKED = Color(1.0, 1.0, 0.8, 1.0)  # Bright yellow/white
const COLOR_COMPLETED = Color(0.5, 1.0, 0.5, 1.0)  # Green
const COLOR_CURRENT = Color(0.3, 0.8, 1.0, 1.0)  # Blue

@onready var label = get_parent().get_node("Label") if get_parent() and get_parent().has_node("Label") else null
@onready var star_visual = get_parent().get_child(0) if get_parent() else null


func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	# Make button transparent so the ColorRect shows through
	modulate = Color(1, 1, 1, 0)
	update_visual()


func set_state(new_state: StarState) -> void:
	state = new_state
	update_visual()


func update_visual() -> void:
	if not is_node_ready():
		return

	# Apply color to the visual star (ColorRect), not the button
	if star_visual:
		match state:
			StarState.LOCKED:
				star_visual.modulate = COLOR_LOCKED
				disabled = true
			StarState.UNLOCKED:
				star_visual.modulate = COLOR_UNLOCKED
				disabled = false
			StarState.COMPLETED:
				star_visual.modulate = COLOR_COMPLETED
				disabled = false
			StarState.CURRENT:
				star_visual.modulate = COLOR_CURRENT
				disabled = false

	if label:
		label.text = level_name


func _on_pressed() -> void:
	if Engine.is_editor_hint():
		return
	if state != StarState.LOCKED:
		star_selected.emit(level_index)


func _on_hover() -> void:
	if state != StarState.LOCKED and star_visual:
		star_visual.scale = Vector2(1.2, 1.2)


func _on_unhover() -> void:
	if star_visual:
		star_visual.scale = Vector2(1.0, 1.0)
