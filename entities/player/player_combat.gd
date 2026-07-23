extends Node
class_name PlayerCombat

## ============================================================
## PLAYER COMBAT — Component: HANYA menangani attack input,
## penentuan arah serang, dan aktivasi Hitbox yang sesuai.
## Tidak tahu apa-apa soal gravity/movement/animasi — cuma
## berkomunikasi lewat `movement.is_movement_locked` dan signal.
##
## Asumsi desain (BELUM dikonfirmasi ke lead design, lihat catatan
## di respons chat): Attack 1 = Cahaya, Attack 2 = Kegelapan, arah
## (kanan/kiri/atas/bawah) ditentukan tombol arah yang ditekan saat
## menyerang, bukan 4 attack independen.
## ============================================================

@export var attack_cooldown: float = 0.35
@export var attack_duration: float = 0.2

var _can_attack: bool = true
var _is_attacking: bool = false
var _current_direction: int = 0 # di-set ulang ke Constants.AttackDirection.RIGHT di setup()

var movement: PlayerMovement # di-inject oleh Player.gd
var hitboxes: Dictionary = {} # diisi oleh Player.gd: {AttackDirection: Hitbox}

var cooldown_timer: Timer
var duration_timer: Timer

## Dipancarkan tiap kali attack dimulai — PlayerAnimator dengarkan ini
## untuk memutuskan animasi apa yang diputar. Combat tidak tahu apa-apa
## soal AnimatedSprite2D.
signal attack_started(attribute: int, direction: int)
signal attack_ended


func setup(owner_movement: PlayerMovement, hitbox_dict: Dictionary, cd_timer: Timer, dur_timer: Timer) -> void:
	movement = owner_movement
	hitboxes = hitbox_dict
	cooldown_timer = cd_timer
	duration_timer = dur_timer
	_current_direction = Constants.AttackDirection.RIGHT

	cooldown_timer.wait_time = attack_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

	duration_timer.wait_time = attack_duration
	duration_timer.one_shot = true
	duration_timer.timeout.connect(_on_duration_timeout)


func process_input() -> void:
	if not _can_attack or _is_attacking:
		return

	var attribute := -1
	if Input.is_action_just_pressed("attack_light"):
		attribute = Constants.AttributeType.LIGHT
	elif Input.is_action_just_pressed("attack_dark"):
		attribute = Constants.AttributeType.DARK

	if attribute == -1:
		return

	_start_attack(attribute, _resolve_direction())


func _resolve_direction() -> int:
	if Input.is_action_pressed("look_up"):
		return Constants.AttackDirection.UP
	if Input.is_action_pressed("look_down"):
		return Constants.AttackDirection.DOWN
	return Constants.AttackDirection.RIGHT if movement.facing_dir > 0 else Constants.AttackDirection.LEFT


func _start_attack(attribute: int, direction: int) -> void:
	_is_attacking = true
	_can_attack = false
	_current_direction = direction
	movement.is_movement_locked = true

	var hb: Hitbox = hitboxes[direction]
	hb.attribute = attribute
	hb.monitoring = true

	attack_started.emit(attribute, direction)
	duration_timer.start()
	cooldown_timer.start()


func _on_duration_timeout() -> void:
	hitboxes[_current_direction].monitoring = false
	_is_attacking = false
	movement.is_movement_locked = false
	attack_ended.emit()


func _on_cooldown_timeout() -> void:
	_can_attack = true


func is_attacking() -> bool:
	return _is_attacking
