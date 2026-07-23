extends Node
class_name PlayerAnimator

## PLAYER ANIMATOR - Component: HANYA memutuskan animasi apa yang diputar,
## berdasar state yang diberitahu movement/combat lewat signal atau method.

# Exported variables for animation parameters
var sprite: AnimatedSprite2D
var movement: PlayerMovement
var combat: PlayerCombat

# Setup function to initialize the PlayerAnimator component with references to the AnimatedSprite2D, PlayerMovement, and PlayerCombat components
func setup(anim_sprite: AnimatedSprite2D, owner_movement: PlayerMovement, owner_combat: PlayerCombat) -> void:
	sprite = anim_sprite
	movement = owner_movement
	combat = owner_combat
 
	combat.attack_started.connect(_on_attack_started)

# Update the animation based on the player's movement and combat state, ensuring that attack animations take precedence over movement animations
func _on_attack_started(attribute: int, _direction: int) -> void:
	var anim: String = Constants.ANIM_ATTACK_LIGHT if attribute == Constants.AttributeType.LIGHT else Constants.ANIM_ATTACK_DARK
	sprite.play(anim)
	# TODO: kalau nanti tiap arah (kanan/kiri/atas/bawah) punya animasi
	# berbeda, ganti baris di atas jadi lookup berdasar (attribute, direction).

# Update the animation based on the player's movement and combat state, ensuring that attack animations take precedence over movement animations
func update_animation() -> void:
	if combat.is_attacking():
		return # animasi attack sudah di-trigger oleh signal, jangan ditimpa
 
	sprite.flip_h = movement.facing_dir < 0
 
	# Update the animation based on the player's movement and combat state, ensuring that attack animations take precedence over movement animations
	if not movement.body.is_on_floor():
		sprite.play(Constants.ANIM_JUMP)
	elif movement.is_moving_horizontally():
		sprite.play(Constants.ANIM_RUN)
	else:
		sprite.play(Constants.ANIM_IDLE)
	
	# animasi lainnya belum dimasukan, dan mungkin ada ketidak cocokan antara animasi dan state, karena ini masih placeholder.
