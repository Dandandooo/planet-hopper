class_name Wabbit
extends CharacterBody2D

@export var inputs : WabbitInput
@export_range(0, 1000, 50) var movespeed: float = 10
@export_range(0, 1000, 50) var jumpspeed: float = 1000
@export_range(0, 10, 1) var grav_strength: float = 3

var min_gravity: float = 50
var grav_const: float = 1e7
var gravity_enabled: bool = true
var current_planet: Celestial = null
var current_planet_radius: float
var current_planet_angle: float

var planets: Array[Celestial]

@export_range(0, 3, 1) var double_jumps: int = 1
var double_jumps_remaining: int = double_jumps
var thruster_sprite: Sprite2D
var thruster_timer: Timer
@export_range(0, 1, 0.1) var thruster_on_time: float = 0.3

var player_camera: Camera2D
var zoom_max_distance: float = 2500
var zoom_min_distance: float = 500
@export_range(1, 5, 0.5) var zoom_out_factor: float = 4

func _ready() -> void:
	thruster_sprite = find_child("Double Jump") as Sprite2D
	thruster_timer = thruster_sprite.find_child("Timer") as Timer
	player_camera = find_child("Camera2D") as Camera2D
	var nodes: Array[Node] =  get_parent().find_children("*", "Celestial")
	for node in nodes:
		var planet = node as Celestial
		if planet:
			planets.append(planet)

func _physics_process(delta: float) -> void:
	var jump: bool = Input.get_action_strength(inputs.jump) > 0
	
	_zoom_to_planets()
	
	if gravity_enabled:
		_apply_gravity(delta)
		if Input.is_action_just_pressed(inputs.jump):
			_double_jump()
		if move_and_slide():
			gravity_enabled = false
			double_jumps_remaining = double_jumps
			velocity *= 0
			current_planet = _nearest_planet()
			var planet_vector = global_position - current_planet.global_position
			current_planet_radius = planet_vector.length()
			current_planet_angle = atan2(planet_vector.y, planet_vector.x)
	else:
		_walk(delta)
		if Input.is_action_pressed(inputs.jump):
			launch(global_rotation - PI/2, jumpspeed)

func _apply_gravity(delta: float) -> void:
	var grav = Vector2(0, 0)
	for node in planets:
		var planet: Celestial = node as Celestial
		if not planet:
			continue
		var r = planet.global_position - global_position
		grav += max(min_gravity, grav_strength * grav_const * planet.mass / (r.length_squared())) * r.normalized()
		
	velocity += delta * grav
	global_rotation = atan2(grav.y, grav.x) - PI / 2
	
func _nearest_planet() -> Celestial:
	var min_dist: float = INF
	var closest: Celestial = null
	for planet in planets:
		var r = planet.global_position - global_position
		var dist = r.length_squared()
		if dist < min_dist:
			min_dist = dist
			closest = planet
	return closest

func _walk(delta: float) -> void:
	var walk = Input.get_axis(inputs.left, inputs.right)
	
	current_planet_angle += movespeed * walk / current_planet_radius
	
	global_rotation = current_planet_angle + PI / 2
	var new_pos = Vector2(
		cos(current_planet_angle) * current_planet_radius + current_planet.global_position.x,
		sin(current_planet_angle) * current_planet_radius + current_planet.global_position.y
	)
	
	velocity = (new_pos - global_position) / delta
	global_position = new_pos
	
func _double_jump() -> void:
	if double_jumps_remaining == 0:
		return
	double_jumps_remaining -= 1
	thruster_sprite.visible = true
	thruster_timer.start(thruster_on_time)
	launch(global_rotation - PI / 2, jumpspeed)
	await thruster_timer.timeout
	thruster_sprite.visible = false

# optimization idea:
# only zoom based on last landed on planet (current_planet)
func _zoom_to_planets() -> void:
	var distance = (_nearest_planet().global_position - global_position).length()
	var zoom_factor: float
	if distance <= zoom_min_distance:
		zoom_factor = 1.0
	elif distance >= zoom_max_distance:
		zoom_factor = zoom_out_factor
	else:
		# TODO: change from linear curve
		zoom_factor = (distance - zoom_min_distance) / (zoom_max_distance - zoom_min_distance) * (zoom_out_factor - 1) + 1
	player_camera.zoom = Vector2(1, 1) / zoom_factor
 
func launch(angle: float, strength: float, replace: bool = false) -> void:
	var jump = Vector2(1, 0).rotated(angle) * strength
	# extract perpendicular component
	var parr_mag: float = velocity.dot(jump.normalized())
	var perp: Vector2 = velocity - jump.normalized() * velocity.dot(jump.normalized())
	if replace:
		velocity = jump + perp
	else:
		velocity = jump + perp + max(parr_mag, 0) * jump.normalized()
	gravity_enabled = true
