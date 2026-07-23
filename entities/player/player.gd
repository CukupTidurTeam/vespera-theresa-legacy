extends CharacterBody2D
class_name Player

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var attack_duration_timer: Timer = $AttackDurationTimer
@onready var hurtbox: Hurtbox = $Hurtbox

@onready var hitbox_right: Hitbox = $HitboxRight
@onready var hitbox_left: Hitbox = $HitboxLeft
@onready var hitbox_up: Hitbox = $HitboxUp
@onready var hitbox_down: Hitbox = $HitboxDown

@onready var movement: PlayerMovement = $PlayerMovement
@onready var combat : PlayerCombat = $PlayerCombat
@onready var animator : PlayerAnimator = $PlayerAnimator

var current_health: int = 100
@export var max_health: int = 100

signal died

func _ready() -> void:
	add_to_group(Constants.GROUP_PLAYER)
	current_health = max_health

	# Setup hitbox dictionary for combat system
	var hitbox_dict := {
		Constants.AttackDirection.RIGHT: hitbox_right,
		Constants.AttackDirection.LEFT: hitbox_left,
		Constants.AttackDirection.UP: hitbox_up,
		Constants.AttackDirection.DOWN: hitbox_down,
	}

	movement.setup(self)
	combat.setup(movement, hitbox_dict, attack_cooldown_timer, attack_duration_timer)
	animator.setup(anim_sprite, movement, combat)
 
	# Connect the hurt signal from the hurtbox to the _on_hurt function
	hurtbox.hurt.connect(_on_hurt)

func _physics_process(delta: float) -> void:
	movement.physics_update(delta)
	combat.process_input()
	move_and_slide()
	animator.update_animation()

func _on_hurt(amount: int, _attribute: int, _source: Node2D) -> void:
	# health generik sebagai placeholder sampai nanti diimplementasi sistem dual bar
	current_health -= amount
	if current_health <= 0:
		_die()

func _die() -> void:
	died.emit()

	# TODO: state mati / respawn / game over, menyusul.
