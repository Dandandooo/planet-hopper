extends Sprite2D

var velocity: Vector2
var rotation_speed: float
var screen_size: Vector2

func _ready() -> void:
	# Get viewport size
	screen_size = get_viewport_rect().size

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

func _process(delta: float) -> void:
	# Update position
	position += velocity * delta

	# Update rotation
	rotation += rotation_speed * delta

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
