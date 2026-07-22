extends Node
class_name PlayerMovement

## PLAYER MOVEMENT - Component: HANYA menangani gerak fisik (gravity, run, jump)

# Exported variables for movement parameters
@export var move_speed: float = 220.0
@export var acceleration: float = 1400.0
@export var friction: float = 1600.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 900.0

var facing_dir: int = 1 # 1 = kanan, -1 = kiri, dibaca oleh PlayerCombat
var is_movement_locked: bool = false # dikunci PlayerCombat saat attack

# butuh akses body induknya untuk baca/tulis `velocity` dan cek `is_on_floor()`
var body: CharacterBody2D

# Setup function to initialize the PlayerMovement component with a reference to the parent CharacterBody2D node
func setup(owner_body: CharacterBody2D) -> void:
	body = owner_body

# Physics update function to be called from the parent node's _physics_process
func physics_update(delta: float) -> void:
	_apply_gravity(delta)
	_handle_horizontal(delta)
	_handle_jump()

# Apply gravity to the player's vertical velocity, ensuring it doesn't exceed the maximum fall speed
func _apply_gravity(delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
		body.velocity.y = min(body.velocity.y, max_fall_speed)
	else:
		body.velocity.y = 0.0

# Handle horizontal movement input and apply acceleration/friction
func _handle_horizontal(delta: float) -> void:
	# Handle horizontal movement input and apply acceleration/friction
	var input_dir := 0.0
	if Input.is_action_pressed("move_right"):
		input_dir += 1.0
	if Input.is_action_pressed("move_left"):
		input_dir -= 1.0
	
	# If movement is locked (e.g., during an attack), apply friction to slow down the player and return early
	if is_movement_locked:
		body.velocity.x = move_toward(body.velocity.x, 0.0, friction * delta)
		return
	
	# Update velocity based on input direction
	if input_dir != 0.0:
		body.velocity.x = move_toward(body.velocity.x, input_dir * move_speed, acceleration * delta)
		facing_dir = sign(input_dir)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0.0, friction * delta)

# Handle jump input and apply jump velocity if the player is on the floor
func _handle_jump() -> void:
	if is_movement_locked:
		return
	if Input.is_action_just_pressed("jump") and body.is_on_floor():
		body.velocity.y = jump_velocity

# Utility function to check if the player is moving horizontally
func is_moving_horizontally() -> bool:
	return abs(body.velocity.x) > 10.0
