class_name Wabbit
extends CharacterBody2D

@export var inputs : WabbitInput
@export_range(0, 1000, 50) var movespeed: float = 10
@export_range(0, 1000, 50) var jumpspeed: float = 1000
@export_range(0, 10, 1) var grav_strength: float = 3

var grav_const: float = 1e7
var gravity_enabled: bool = true
var current_planet: Planet = null

var planets: Array[Planet]

func _ready() -> void:
	var nodes: Array[Node] = get_parent().find_children("*", "Planet")
	for node in nodes:
		var planet = node as Planet
		if planet:
			planets.append(planet)

func _physics_process(delta: float) -> void:
	var jump: bool = Input.get_action_strength(inputs.jump) > 0
	
	if gravity_enabled:
		_apply_gravity(delta)
		if move_and_slide():
			gravity_enabled = false
			velocity *= 0
			current_planet = _nearest_planet()
	else:
		_walk(delta)
		if Input.is_action_pressed(inputs.jump):
			launch(global_rotation - PI/2, jumpspeed)

func _apply_gravity(delta: float) -> void:
	var grav = Vector2(0, 0)
	for node in planets:
		var planet: Planet = node as Planet
		if not planet:
			continue
		var r = planet.global_position - global_position
		grav += grav_strength * grav_const * planet.mass / (r.length_squared()) * r.normalized()
		
	velocity += delta * grav
	global_rotation = atan2(grav.y, grav.x) - PI / 2
	
func _nearest_planet() -> Planet:
	var min_dist: float = INF
	var closest: Planet = null
	for planet in planets:
		var r = planet.global_position - global_position
		var dist = r.length_squared()
		if dist < min_dist:
			min_dist = dist
			closest = planet
	return closest

func _walk(delta: float) -> void:
	var walk = Input.get_axis(inputs.left, inputs.right)
	var direction = Vector2(walk, 0.0).rotated(global_rotation)
	#velocity = movespeed * direction
	
	var pos: Vector2 = global_position - current_planet.global_position
	var radius: float = pos.length()
	var angle: float = atan2(pos.y, pos.x) + (movespeed * walk / radius)
	
	global_rotation = angle + PI / 2
	var new_pos = Vector2(
		cos(angle) * radius + current_planet.global_position.x,
		sin(angle) * radius + current_planet.global_position.y
	)
	
	velocity = (new_pos - global_position) / delta
	global_position = new_pos

 
func launch(angle: float, strength: float) -> void:
	var jump = Vector2(1, 0).rotated(angle) * strength
	# extract perpendicular component
	var perp: Vector2 = velocity - jump.normalized() * velocity.dot(jump.normalized())
	velocity = jump + perp
	gravity_enabled = true
