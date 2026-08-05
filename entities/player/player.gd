extends CharacterBody2D
class_name Player

## ============================================================
## PLAYER — Orchestrator tipis.
## Semua LOGIC ada di component (PlayerMovement, PlayerCombat, PlayerAnimator, PlayerAttributes)

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var attack_phase_timer: Timer = $AttackDurationTimer # node sama, sekarang berperan sebagai phase timer (prep/action/recovery)
@onready var hurtbox: Hurtbox = $Hurtbox

@onready var hitbox_right: Hitbox = $HitboxRight
@onready var hitbox_left: Hitbox = $HitboxLeft
@onready var hitbox_up: Hitbox = $HitboxUp
@onready var hitbox_down: Hitbox = $HitboxDown

@onready var movement: PlayerMovement = $PlayerMovement
@onready var combat: PlayerCombat = $PlayerCombat
@onready var animator: PlayerAnimator = $PlayerAnimator
@onready var attributes: PlayerAttributes = $PlayerAttributes

signal died


func _ready() -> void:
	add_to_group(Constants.GROUP_PLAYER)

	var hitbox_dict := {
		Constants.AttackDirection.RIGHT: hitbox_right,
		Constants.AttackDirection.LEFT: hitbox_left,
		Constants.AttackDirection.UP: hitbox_up,
		Constants.AttackDirection.DOWN: hitbox_down,
	}

	movement.setup(self)
	combat.setup(movement, attributes, hitbox_dict, attack_cooldown_timer, attack_phase_timer)
	animator.setup(anim_sprite, movement, combat)

	hurtbox.hurt.connect(_on_hurt)
	attributes.died.connect(_on_died)

	# Koneksi signal hitbox ke Player untuk mendeteksi serangan yang berhasil mendarat ke musuh.
	for hb: Hitbox in hitbox_dict.values():
		hb.landed.connect(_on_hitbox_landed)


func _physics_process(delta: float) -> void:
	movement.physics_update(delta)
	combat.process_input()
	move_and_slide()
	animator.update_animation()


func _on_hitbox_landed(hurtbox_hit: Hurtbox) -> void:
	# Kalau Player berhasil menyerang musuh, regen bar attribute lawan sesuai GDD: Enemy Light -> +3 Dark bar Player, Enemy Dark -> +3 Light bar Player.
	if hurtbox_hit.get_parent().is_in_group(Constants.GROUP_ENEMY):
		var opposite := Constants.AttributeType.DARK if combat.get_current_attack_attribute() == Constants.AttributeType.LIGHT else Constants.AttributeType.LIGHT
		attributes.regen(opposite, 3.0)
		print("HIT ENEMY -> regen bar: ", opposite, " | Light: ", attributes.light_bar, " Dark: ", attributes.dark_bar)


func _on_hurt(attacker_attribute: int, _source: Node2D, _hitbox: Hitbox) -> void:
	# Attack musuh mengenai Player: kurangi bar attribute Player yang berlawanan dengan attribute musuh. Nilai damage sesuai GDD: Enemy Attack = 10.
	attributes.take_damage_from_enemy(attacker_attribute, 10.0)
	print("PLAYER KENA HIT dari attribute: ", attacker_attribute, " | Light: ", attributes.light_bar, " Dark: ", attributes.dark_bar)

func _on_died() -> void:
	died.emit()
	# TODO: state mati / respawn / game over, menyusul.