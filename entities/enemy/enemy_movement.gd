extends Node
class_name EnemyMovement

## ============================================================
## ENEMY MOVEMENT — Component: HANYA patrol & chase.
## Tidak tahu soal deteksi/attack/health — cuma baca `target`
## yang di-set dari luar (oleh EnemyCombat / orchestrator).
## ============================================================

@export var patrol_speed: float = 80.0
@export var chase_speed: float = 130.0
@export var gravity: float = 1200.0
@export var max_fall_speed: float = 900.0
@export var patrol_distance: float = 120.0

## Jarak raycast ledge-check: x = seberapa jauh ke depan, y = seberapa jauh ke bawah
## untuk cek keberadaan tanah. y sebaiknya sedikit lebih besar dari tinggi step normal.
@export var ledge_check_offset: Vector2 = Vector2(16, 24)

## Setelah belok arah (karena jurang/boundary), enemy TIDAK BOLEH cek
## belok lagi selama durasi ini. Ini mencegah enemy "gemetar"/flip-flop
## kalau dia belok persis di tepi dan masih kedeteksi jurang di frame
## berikutnya sebelum sempat benar-benar menjauh.
@export var turn_cooldown_duration: float = 0.3

var body: CharacterBody2D
var target: Node2D = null # di-set oleh EnemyCombat saat player terdeteksi
var ledge_check: RayCast2D

var _patrol_dir: int = 1
var _patrol_origin: Vector2
var _turn_cooldown: float = 0.0
var facing_dir: int = 1


func setup(owner_body: CharacterBody2D, ledge_ray: RayCast2D = null) -> void:
	body = owner_body
	ledge_check = ledge_ray
	_patrol_origin = body.global_position


func physics_update(delta: float, is_locked: bool) -> void:
	_apply_gravity(delta)

	if _turn_cooldown > 0.0:
		_turn_cooldown -= delta

	if is_locked:
		body.velocity.x = 0.0
		return

	if is_instance_valid(target):
		_chase()
	else:
		_patrol()


func _apply_gravity(delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
		body.velocity.y = min(body.velocity.y, max_fall_speed)
	else:
		body.velocity.y = 0.0


func _patrol() -> void:
	body.velocity.x = _patrol_dir * patrol_speed
	facing_dir = _patrol_dir

	if _turn_cooldown > 0.0:
		return

	_update_ledge_check()

	var distance_from_origin: float = body.global_position.x - _patrol_origin.x
	var reached_boundary: bool = abs(distance_from_origin) >= patrol_distance
	var about_to_fall: bool = ledge_check != null and body.is_on_floor() and not ledge_check.is_colliding()

	if reached_boundary or about_to_fall:
		_patrol_dir *= -1
		_turn_cooldown = turn_cooldown_duration


## Posisikan raycast di depan enemy sesuai arah jalan, lalu cek apakah
## masih ada tanah di bawahnya. Kalau tidak colliding -> di depan ada jurang.
func _update_ledge_check() -> void:
	if ledge_check == null:
		return
	ledge_check.position.x = ledge_check_offset.x * _patrol_dir
	ledge_check.target_position = Vector2(0, ledge_check_offset.y)
	ledge_check.force_raycast_update()


func _chase() -> void:
	var direction_x: float = target.global_position.x - body.global_position.x
	var dir: int = 0
	if direction_x > 0.0:
		dir = 1
	elif direction_x < 0.0:
		dir = -1
	body.velocity.x = dir * chase_speed
	if dir != 0:
		facing_dir = dir


func is_moving_horizontally() -> bool:
	return abs(body.velocity.x) > 10.0
