extends ProgressBar

@export var character_path: NodePath = "../CanvasLayer/Wabbit"
@onready var character = get_node(character_path) as Wabbit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("PATH = ", character_path)
	print("NODE = ", character)
	if character == null:
		push_warning("HealthBar: character_path does not point to a valid node!")
		return
	
	value = character.health
	max_value = character.max_health
	
	character.connect("damaged", Callable(self, "_on_character_damage_taken"))
	

func _on_character_damage_taken():
	# Update health bar according to character's current HP
	value = character.health
	max_value = character.max_health
	# do something else ...
