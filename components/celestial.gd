@abstract class_name Celestial
extends StaticBody2D

@export_range(0, 10, 1) var mass: float = 4

func _ready() -> void:
	add_to_group("Celestials")
