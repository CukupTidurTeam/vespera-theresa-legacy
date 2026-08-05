extends CharacterBody2D
class_name ZombieEnemy

## ============================================================
## ZOMBIE ENEMY — Orchestrator tipis, sama filosofinya dengan Player.gd:
## cuma wiring component, semua logic ada di EnemyMovement /
## EnemyCombat / EnemyAnimator.
## ============================================================

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_hitbox: Hitbox = $AttackArea/Hitbox
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var hurtbox: Hurtbox = $Hurtbox

@onready var movement: ZombieMovement = $EnemyMovement
@onready var combat: ZombieCombat = $EnemyCombat
@onready var animator: ZombieAnimator = $EnemyAnimator


func _ready() -> void:
	add_to_group(Constants.GROUP_ENEMY)

	movement.setup(self)
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


## TODO (untuk yang mengerjakan Enemy 1/2, terpisah dari dual-bar
## Player): Enemy sekarang masih pakai combat.take_damage(int) generik
## dengan angka mentah dari Hurtbox — ini BELUM sesuai GDD (Enemy py
## 1 bar attribute yang JADI HP-nya, dengan damage_same/damage_diff
## dari Hitbox penyerang, bukan angka tetap). Untuk konsistensi
## dengan pola PlayerAttributes (lihat entities/player/player_attributes.gd
## sebagai referensi pola yang sudah dipakai), pertimbangkan bikin
## EnemyAttribute component serupa: 1 bar, attribute tetap (Light
## atau Dark, di-set lewat @export di Inspector per instance Enemy),
## fungsi take_damage_from_hitbox(hitbox: Hitbox) yang panggil
## hitbox.get_damage_for(my_attribute) untuk hitung damage yang benar.
func _on_hurt(attacker_attribute: int, _source: Node2D, hitbox: Hitbox) -> void:
	# FIX SEMENTARA: signature disesuaikan dengan Hurtbox versi baru
	# (lihat components/hurtbox.gd) supaya tidak error saat testing
	# Player, TAPI logic damage di bawah ini masih pakai pola lama
	# (combat.take_damage sebagai int generik) — belum menghitung
	# damage_same/damage_diff sesuai GDD. Ganti sesuai TODO di atas.
	combat.take_damage(int(hitbox.damage_same))


func _on_died() -> void:
	set_physics_process(false)
	detection_area.set_deferred("monitoring", false)
	attack_area.set_deferred("monitoring", false)
	await get_tree().create_timer(1.0).timeout
	queue_free()
