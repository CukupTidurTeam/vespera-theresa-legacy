extends CharacterBody2D
class_name Player

## PLAYER - Node utama Player, menggabungkan movement, combat, animator, dan attributes. Dipanggil dari scene game saat Player spawn.

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

	# Koneksi signal landed() dari semua hitbox ke _on_hitbox_landed() supaya bisa regen bar attribute lawan saat Player kena musuh.
	for hb: Hitbox in hitbox_dict.values():
		hb.landed.connect(_on_hitbox_landed)

	_apply_pending_load_if_any()
	SaveManager.start_playtime_tracking()


func _apply_pending_load_if_any() -> void:
	# Kalau ada load-game pending, ambil data dari SaveManager dan restore posisi Player + bar attribute. Caller (SaveManager) WAJIB cek dulu apakah Player ada di scene tree sebelum panggil ini, karena ini cuma baca data dari PlayerAttributes.
	var data := SaveManager.consume_pending_load()
	if data.is_empty():
		return

	global_position = Vector2(data.get("position_x", global_position.x), data.get("position_y", global_position.y))
	attributes.set_bars(data.get("light_bar", attributes.max_bar), data.get("dark_bar", attributes.max_bar))


func _physics_process(delta: float) -> void:
	movement.physics_update(delta)
	combat.process_input()
	move_and_slide()
	animator.update_animation()


func _on_hitbox_landed(hurtbox_hit: Hurtbox) -> void:
	# Hanya regen bar attribute lawan kalau yang kena adalah musuh (bukan Player sendiri atau friendly NPC). Caller (Hitbox) WAJIB cek dulu apakah target valid sebelum emit landed() signal.
	if hurtbox_hit.get_parent().is_in_group(Constants.GROUP_ENEMY):
		var opposite := Constants.AttributeType.DARK if combat.get_current_attack_attribute() == Constants.AttributeType.LIGHT else Constants.AttributeType.LIGHT
		attributes.regen(opposite, 3.0)


func _on_hurt(attacker_attribute: int, _source: Node2D, _hitbox: Hitbox) -> void:
	attributes.take_damage_from_enemy(attacker_attribute, 10.0)


func _on_died() -> void:
	died.emit()
	# TODO: state mati / respawn / game over, menyusul.
