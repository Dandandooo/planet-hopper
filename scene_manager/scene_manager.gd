extends CanvasLayer

signal transitioned_in(float)
signal transitioned_out(float)

# Called when the node enters the scene tree for the first time.

func transition_in(speed: float = 1.0) -> void:
	$AnimationPlayer.play("in", -1, speed)
	
func transition_out(speed: float = 1.0) -> void:
	$AnimationPlayer.play("out", -1, speed)

func transition_to(scene: String, out_speed: float = 1.0, in_speed: float = 1.0) -> void:
	#transition_out
	
	var new_scene = load(scene)
	
	var root: Window = get_tree().root
	root.get_child
