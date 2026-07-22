extends Node
class_name PlayerCombat

## PLAYER COMBAT - Component: HANYA menangani attack input, penentuan arah serang, dan aktivasi Hitbox yang sesuai.

# Exported variables for attack parameters
@export var attack_cooldown: float = 0.35
@export var attack_duration: float = 0.2

# Internal state variables
var _can_attack: bool = true
var _is_attacking: bool = false
var _current_direction: int = Constants.AttackDirection.RIGHT

# Timers for managing attack cooldown and duration
var movement: PlayerMovement # di-inject oleh Player.gd
var hitboxes: Dictionary = {} # diisi oleh Player.gd: {AttackDirection: Hitbox}

# Timers for managing attack cooldown and duration
var cooldown_timer: Timer
var duration_timer: Timer

# Setup function to initialize the PlayerCombat component with references to the PlayerMovement component, hitboxes, and timers
signal attack_started(attribute: int, direction: int)
signal attack_ended

# Function to setup the PlayerCombat component with necessary references
func setup(owner_movement: PlayerMovement, hitbox_dict: Dictionary, cd_timer: Timer, dur_timer: Timer) -> void:
	# Setup the PlayerCombat component with references to the PlayerMovement component, hitboxes, and timers
	movement = owner_movement
	hitboxes = hitbox_dict
	cooldown_timer = cd_timer
	duration_timer = dur_timer
 
	# Configure the timers for attack cooldown and duration
	cooldown_timer.wait_time = attack_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	
	# Configure the duration timer for attack duration
	duration_timer.wait_time = attack_duration
	duration_timer.one_shot = true
	duration_timer.timeout.connect(_on_duration_timeout)

# Start an attack with the specified attribute and direction, activating the corresponding hitbox and starting the duration timer
func process_input() -> void:
	if not _can_attack or _is_attacking:
		return
	
	# Check for attack input and determine the attribute type (light or dark)
	var attribute := -1
	if Input.is_action_just_pressed("attack_light"):
		attribute = Constants.AttributeType.LIGHT
	elif Input.is_action_just_pressed("attack_dark"):
		attribute = Constants.AttributeType.DARK
 
	if attribute == -1:
		return
	
	# Determine the attack direction based on player input
	_start_attack(attribute, _resolve_direction())

# Resolve the attack direction based on player input, returning the appropriate attack direction constant
func _resolve_direction() -> int:
	# Resolve the attack direction based on player input, returning the appropriate attack direction constant
	if Input.is_action_pressed("look_up"):
		return Constants.AttackDirection.UP
	if Input.is_action_pressed("look_down"):
		return Constants.AttackDirection.DOWN
	return Constants.AttackDirection.RIGHT if movement.facing_dir > 0 else Constants.AttackDirection.LEFT

# Start an attack with the specified attribute and direction, activating the corresponding hitbox and starting the duration timer
func _start_attack(attribute: int, direction: int) -> void:
	# Start an attack with the specified attribute and direction, activating the corresponding hitbox and starting the duration timer
	_is_attacking = true
	_can_attack = false
	_current_direction = direction
	movement.is_movement_locked = true
	
	# Activate the corresponding hitbox for the attack direction and set its attribute
	var hb: Hitbox = hitboxes[direction]
	hb.attribute = attribute
	hb.monitoring = true
	
	# Emit the attack_started signal with the attribute and direction, and start the duration and cooldown timers
	attack_started.emit(attribute, direction)
	duration_timer.start()
	cooldown_timer.start()

# Callback function for when the attack duration timer times out, deactivating the hitbox and unlocking movement
func _on_duration_timeout() -> void:
	# Callback function for when the attack duration timer times out, deactivating the hitbox and unlocking movement
	hitboxes[_current_direction].monitoring = false
	_is_attacking = false
	movement.is_movement_locked = false
	attack_ended.emit()

# Callback function for when the attack cooldown timer times out, allowing the player to attack again
func _on_cooldown_timeout() -> void:
	_can_attack = true

# Function to check if the player is currently attacking, returning a boolean value
func is_attacking() -> bool:
	return _is_attacking
