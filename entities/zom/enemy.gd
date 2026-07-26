extends CharacterBody2D
class_name ZombieEnemy

## ============================================================
## ENEMY — Orchestrator tipis, sama filosofinya dengan Player.gd:
## cuma wiring component, semua logic ada di EnemyMovement /
## EnemyCombat / EnemyAnimator.
## ============================================================

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var ledge_check: RayCast2D = $LedgeCheck
@onready var attack_area: Area2D = $AttackArea
@onready var attack_hitbox: Hitbox = $AttackArea/Hitbox
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var hurtbox: Hurtbox = $Hurtbox

@onready var movement: ZombieMovement = $EnemyMovement
@onready var combat: ZombieCombat = $EnemyCombat
@onready var animator: ZombieAnimator = $EnemyAnimator


func _ready() -> void:
	add_to_group(Constants.GROUP_ENEMY)

	movement.setup(self, ledge_check)
	combat.setup(movement, detection_area, attack_area, attack_hitbox, attack_cooldown_timer)
	animator.setup(anim_sprite, movement, combat)

	hurtbox.hurt.connect(_on_hurt)
	combat.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if combat.is_dead():
		return
	movement.physics_update(delta, false)
	move_and_slide()
	animator.update_animation()


func _on_hurt(amount: int, _attribute: int, _source: Node2D) -> void:
	combat.take_damage(amount)


func _on_died() -> void:
	set_physics_process(false)
	detection_area.set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)
	await get_tree().create_timer(1.0).timeout
	queue_free()
