class_name Star
extends Celestial

@export var orbit_speed: float = 500
@export var planets_orbit: bool = true

func _draw() -> void:
	var planets: Array[Node] = find_children("*", "Planet")
	var color = Color("dimgray")
	for node in planets:
		var planet = node as Planet
		var radius = (planet.global_position - global_position).length()
		draw_circle(Vector2(0,0), radius, color, false)
