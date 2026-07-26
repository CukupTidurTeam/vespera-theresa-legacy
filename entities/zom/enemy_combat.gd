extends Node
class_name ZombieCombat

## ============================================================
## ENEMY COMBAT — Component: deteksi player, serang, dan simpan
## health. Men-set `movement.target` supaya EnemyMovement tahu
## kapan harus chase, tapi tidak menyentuh logic gerak itu sendiri.
## ============================================================

@export var max_health: int = 30
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0

var _health: int
var _can_attack: bool = true
var _is_dead: bool = false

var movement: ZombieMovement
var detection_area: Area2D
var attack_area: Area2D
var attack_hitbox: Hitbox
var cooldown_timer: Timer

signal died
signal damaged(current_health: int, max_health: int)
signal attacked


func setup(owner_movement: ZombieMovement, det_area: Area2D, atk_area: Area2D, hitbox: Hitbox, cd_timer: Timer) -> void:
	movement = owner_movement
	detection_area = det_area
	attack_area = atk_area
	attack_hitbox = hitbox
	cooldown_timer = cd_timer

	_health = max_health

	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)
	attack_area.body_entered.connect(_on_attack_area_entered)

	cooldown_timer.wait_time = attack_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(func(): _can_attack = true)


func _on_detection_entered(body: Node2D) -> void:
	if _is_dead:
		return
	if body.is_in_group(Constants.GROUP_PLAYER):
		movement.target = body


func _on_detection_exited(body: Node2D) -> void:
	if body == movement.target:
		movement.target = null


func _on_attack_area_entered(body: Node2D) -> void:
	if _is_dead or not _can_attack:
		return
	if not body.is_in_group(Constants.GROUP_PLAYER):
		return

	_can_attack = false
	cooldown_timer.start()
	attacked.emit()
	attack_hitbox.damage = attack_damage
	attack_hitbox.monitoring = true
	# Hitbox dimatikan lagi oleh timer pendek — lihat catatan di
	# EnemyCombat.setup jika ingin durasi aktif yang berbeda.
	get_tree().create_timer(0.15).timeout.connect(func(): attack_hitbox.monitoring = false)


func take_damage(amount: int) -> void:
	if _is_dead:
		return
	_health -= amount
	damaged.emit(_health, max_health)
	if _health <= 0:
		_is_dead = true
		died.emit()


func is_dead() -> bool:
	return _is_dead
