extends CharacterBody2D

var centroid: Vector2
var orbit_radius: float = 250.0
var orbit_speed: float = 100.0

func _ready() -> void:
	var planet = get_parent()
	if not planet is Planet:
		push_error("Enemy must be a child of a Planet node")
		return

	centroid = planet.global_position

	var offset = global_position - centroid
	if offset.length() > 0:
		orbit_radius = offset.length()

func _process(delta: float) -> void:
	var planet = get_parent()
	if planet is Planet:
		centroid = planet.global_position

		var pos = global_position - centroid
		var angle = atan2(pos.y, pos.x)
		angle += orbit_speed / orbit_radius * delta
		global_position = centroid + orbit_radius * Vector2(cos(angle), sin(angle))
