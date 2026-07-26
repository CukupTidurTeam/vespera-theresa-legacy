extends Node
class_name ZombieAnimator

## ============================================================
## ENEMY ANIMATOR — Component: HANYA memutuskan animasi.
## ============================================================

## Kalau sprite kamu KELIHATAN JALAN MUNDUR (moonwalk), berarti gambar
## default sprite-mu menghadap KIRI, bukan kanan. Uncheck kotak ini.
@export var sprite_faces_right_by_default: bool = true

var sprite: AnimatedSprite2D
var movement: ZombieMovement
var combat: ZombieCombat

var _is_attacking: bool = false


func setup(anim_sprite: AnimatedSprite2D, owner_movement: ZombieMovement, owner_combat: ZombieCombat) -> void:
	sprite = anim_sprite
	movement = owner_movement
	combat = owner_combat

	combat.died.connect(_on_died)
	combat.attacked.connect(_on_attacked)
	sprite.animation_finished.connect(_on_animation_finished)


func _on_died() -> void:
	_is_attacking = false
	sprite.play(Constants.ANIM_DEATH)


func _on_attacked() -> void:
	_is_attacking = true
	sprite.play(Constants.ANIM_ATTACK)


func _on_animation_finished() -> void:
	# Kalau animasi attack sudah selesai diputar sekali, balik ke
	# animasi normal (run/idle) di update_animation() berikutnya.
	if sprite.animation == Constants.ANIM_ATTACK:
		_is_attacking = false


func _update_facing() -> void:
	if sprite_faces_right_by_default:
		sprite.flip_h = movement.facing_dir < 0
	else:
		sprite.flip_h = movement.facing_dir > 0


func update_animation() -> void:
	if combat.is_dead():
		return

	_update_facing()

	# Selama animasi attack masih main, jangan diganggu sama run/idle/jump.
	if _is_attacking:
		return

	if movement.is_moving_horizontally():
		sprite.play(Constants.ANIM_RUN)
	else:
		sprite.play(Constants.ANIM_IDLE)
