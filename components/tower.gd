class_name Tower
extends Node2D

@export_file_path var next_scene: String
var player: Wabbit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not next_scene:
		push_error("Please select a next scene for this tower")
	player = get_tree().get_first_node_in_group("Player")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("radio"):
		print("pressed")
		print($Area2D.get_overlapping_bodies())
		for node in $Area2D.get_overlapping_bodies():
			var wab = node as Wabbit
			if wab:
				GameState.advance_to_next_level()
		#if player in $Area2D.get_overlapping_bodies():
			
			#get_tree().change_scene_to_file(next_scene)
