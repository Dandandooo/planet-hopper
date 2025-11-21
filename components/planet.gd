class_name Planet
extends Celestial

@export var is_destination: bool = false

var centroid: Vector2
var orbit_speed: float
var orbit: bool

func _ready() -> void:
	var star = get_parent() as Star
	if not star:
		push_error("Planet object must be nested beneath star")
	
	centroid = star.global_position
	orbit_speed = star.orbit_speed
	orbit = star.planets_orbit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if orbit:
		var pos = global_position - centroid
		var radius = pos.length()
		var angle = atan2(pos.y, pos.x)
		angle += orbit_speed / radius * delta
		global_position = centroid + radius * Vector2(cos(angle), sin(angle))
	
