extends Sprite2D

var velocity: Vector2
var rotation_speed: float
var screen_size: Vector2

# Static variables to persist state between scenes
static var saved_position: Vector2 = Vector2.ZERO
static var saved_velocity: Vector2 = Vector2.ZERO
static var saved_rotation: float = 0.0
static var saved_rotation_speed: float = 0.0
static var is_initialized: bool = false

func _ready() -> void:
	# Get viewport size
	screen_size = get_viewport_rect().size

	# Restore state if it was previously saved, otherwise initialize randomly
	if is_initialized:
		position = saved_position
		velocity = saved_velocity
		rotation = saved_rotation
		rotation_speed = saved_rotation_speed
	else:
		# Random initial velocity
		var speed = randf_range(100, 200)
		var angle = randf() * TAU
		velocity = Vector2(cos(angle), sin(angle)) * speed

		# Slow initial rotation
		rotation_speed = randf_range(-0.5, 0.5)

		# Random starting position
		position = Vector2(
			randf_range(0, screen_size.x),
			randf_range(0, screen_size.y)
		)

		is_initialized = true

func _process(delta: float) -> void:
	# Update position
	position += velocity * delta

	# Update rotation
	rotation += rotation_speed * delta

	# Save state continuously for scene transitions
	saved_position = position
	saved_velocity = velocity
	saved_rotation = rotation
	saved_rotation_speed = rotation_speed

	# Get sprite bounds
	var sprite_width = texture.get_width() * scale.x
	var sprite_height = texture.get_height() * scale.y
	var half_width = sprite_width / 2
	var half_height = sprite_height / 2

	# Bounce off edges
	if position.x - half_width <= 0:
		position.x = half_width
		velocity.x = abs(velocity.x)
		_apply_bounce_rotation()
	elif position.x + half_width >= screen_size.x:
		position.x = screen_size.x - half_width
		velocity.x = -abs(velocity.x)
		_apply_bounce_rotation()

	if position.y - half_height <= 0:
		position.y = half_height
		velocity.y = abs(velocity.y)
		_apply_bounce_rotation()
	elif position.y + half_height >= screen_size.y:
		position.y = screen_size.y - half_height
		velocity.y = -abs(velocity.y)
		_apply_bounce_rotation()

func _apply_bounce_rotation() -> void:
	# Change rotation direction and speed slightly on bounce
	rotation_speed = -rotation_speed * randf_range(0.8, 1.2)
