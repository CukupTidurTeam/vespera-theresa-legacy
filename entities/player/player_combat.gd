extends Node
class_name PlayerCombat

## PLAYER COMBAT — Component: menangani attack input, penentuan
## arah serang, dan attack sebagai state machine 3 fase:
##
##   PREP -> ACTION -> RECOVERY
##
##   - PREP dan ACTION: gerak terkunci penuh (commitment, tidak
##     bisa dibatalkan).
##   - ACTION: hitbox aktif di fase ini saja.
##   - RECOVERY: bisa di-CANCEL oleh input GERAK (A/D) — begitu
##     Player pindah ke RECOVERY dan menekan arah gerak, recovery
##     langsung dipotong dan gerak terbuka lagi. Ini pattern
##     "animation cancel" ala Soulslike (lihat catatan lead design).
##     Recovery TIDAK bisa di-cancel oleh attack baru — attack
##     berikutnya tetap harus menunggu attack_cooldown penuh
##     berjalan dari _start_attack, supaya tidak jadi spam combo.


enum AttackPhase { NONE, PREP, ACTION, RECOVERY }

@export var attack_cooldown: float = 0.35
@export var prep_duration: float = 0.08
@export var action_duration: float = 0.12
@export var recovery_duration: float = 0.35

var _can_attack: bool = true
var _current_phase: int = AttackPhase.NONE
var _current_attribute: int = 0
var _current_direction: int = 0 # di-set ulang ke Constants.AttackDirection.RIGHT di setup()

var movement: PlayerMovement # di-inject oleh Player.gd
var attributes: PlayerAttributes # di-inject oleh Player.gd
var hitboxes: Dictionary = {} # diisi oleh Player.gd: {AttackDirection: Hitbox}

var cooldown_timer: Timer
var phase_timer: Timer # satu timer, di-restart tiap pindah fase

## Dipancarkan tiap kali attack dimulai (fase PREP) — PlayerAnimator
## dengarkan ini untuk memutuskan animasi apa yang diputar.
signal attack_started(attribute: int, direction: int)
signal attack_ended


func setup(owner_movement: PlayerMovement, owner_attributes: PlayerAttributes, hitbox_dict: Dictionary, cd_timer: Timer, ph_timer: Timer) -> void:
	movement = owner_movement
	attributes = owner_attributes
	hitboxes = hitbox_dict
	cooldown_timer = cd_timer
	phase_timer = ph_timer
	_current_direction = Constants.AttackDirection.RIGHT

	cooldown_timer.wait_time = attack_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

	phase_timer.one_shot = true
	phase_timer.timeout.connect(_on_phase_timeout)


func process_input() -> void:
	# Cancel recovery dengan input gerak: kalau lagi RECOVERY dan
	# Player menekan arah gerak, langsung akhiri attack sepenuhnya.
	if _current_phase == AttackPhase.RECOVERY:
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			_cancel_recovery()

	if not _can_attack or _current_phase != AttackPhase.NONE:
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
	_can_attack = false
	_current_attribute = attribute
	_current_direction = direction
	movement.is_movement_locked = true

	# Mulai fase PREP, emit signal attack_started ke PlayerAnimator, dan mulai cooldown timer.
	_enter_phase(AttackPhase.PREP)
	attack_started.emit(attribute, direction)
	cooldown_timer.start() # cooldown mulai dari awal attack, independen dari fase


func _enter_phase(phase: int) -> void:
	_current_phase = phase

	match phase:
		AttackPhase.PREP:
			phase_timer.wait_time = prep_duration
		AttackPhase.ACTION:
			var hb: Hitbox = hitboxes[_current_direction]
			hb.attribute = _current_attribute
			hb.monitoring = true
			phase_timer.wait_time = action_duration
		AttackPhase.RECOVERY:
			hitboxes[_current_direction].monitoring = false
			phase_timer.wait_time = recovery_duration
			movement.is_movement_locked = false # gerak terbuka lagi begitu masuk recovery

	phase_timer.start()


func _on_phase_timeout() -> void:
	match _current_phase:
		AttackPhase.PREP:
			_enter_phase(AttackPhase.ACTION)
		AttackPhase.ACTION:
			_enter_phase(AttackPhase.RECOVERY)
		AttackPhase.RECOVERY:
			_finish_attack()


func _cancel_recovery() -> void:
	# Cancel recovery: kalau Player menekan arah gerak saat fase RECOVERY, langsung akhiri attack sepenuhnya.
	phase_timer.stop()
	_finish_attack()


func _finish_attack() -> void:
	_current_phase = AttackPhase.NONE
	movement.is_movement_locked = false
	attack_ended.emit()


func _on_cooldown_timeout() -> void:
	_can_attack = true


func is_attacking() -> bool:
	return _current_phase != AttackPhase.NONE


func get_current_phase() -> int:
	return _current_phase


func get_current_attack_attribute() -> int:
	return _current_attribute