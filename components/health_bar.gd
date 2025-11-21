extends ProgressBar

@export var character_path: NodePath
@onready var character = get_node(character_path) as Wabbit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("PATH = ", character_path)
	print("NODE = ", character)
	if character == null:
		await get_tree().process_frame
		character = get_node_or_null(character_path) as Wabbit
	if character == null:
		print("HealthBar: character_path does not point to a valid node!")
		return
	
	print("CHARACTER TYPE = ", character.get_class())
	print("HAS SCRIPT = ", character.get_script())
	
	value = character.health
	max_value = character.max_health
	
	character.connect("damaged", Callable(self, "_on_character_damage_taken"))
	

func _on_character_damage_taken():
	# Update health bar according to character's current HP
	value = character.health
	max_value = character.max_health
	# do something else ...

func _process(delta: float) -> void:
	if character == null:
		character = get_node(character_path) as Wabbit
		print("No character, tried again")
	
	else:
		value = character.health
		max_value = character.max_health
	
