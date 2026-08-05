extends Node
class_name PlayerAttributes

## PLAYER ATTRIBUTES — Component: pemilik data Light bar dan Dark bar.

@export var max_bar: float = 100.0

var light_bar: float
var dark_bar: float
var _is_dead: bool = false

## Dipancarkan tiap kali salah satu bar berubah - UI nanti dengarkan
signal bar_changed(light: float, dark: float)
signal died
 
 
func _ready() -> void:
	light_bar = max_bar
	dark_bar = max_bar
 
 
func consume_skill(attribute: int, amount: float) -> void:
	# Skill Player mengurangi bar-nya sendiri, dengan multiplier same/diff.
	_consume(attribute, amount)
 
 
func take_damage_from_enemy(enemy_attribute: int, amount: float) -> void:
	# Damage dari musuh mengurangi bar yang berlawanan dengan attribute musuh.
	var target_bar := Constants.AttributeType.DARK if enemy_attribute == Constants.AttributeType.LIGHT else Constants.AttributeType.LIGHT
	_consume(target_bar, amount)
 
 
func regen(attribute: int, amount: float) -> void:
	if _is_dead:
		return
 
	match attribute:
		Constants.AttributeType.LIGHT:
			light_bar = min(max_bar, light_bar + amount)
		Constants.AttributeType.DARK:
			dark_bar = min(max_bar, dark_bar + amount)
 
	bar_changed.emit(light_bar, dark_bar)
 
 
func _consume(attribute: int, amount: float) -> void:
	if _is_dead:
		return
 
 	# Mengurangi bar yang bersangkutan dengan jumlah amount, tidak boleh kurang dari 0.
	match attribute:
		Constants.AttributeType.LIGHT:
			light_bar = max(0.0, light_bar - amount)
		Constants.AttributeType.DARK:
			dark_bar = max(0.0, dark_bar - amount)
 
	bar_changed.emit(light_bar, dark_bar)
	_check_death()
 
 
func _check_death() -> void:
	if _is_dead:
		return
	if light_bar <= 0.0 or dark_bar <= 0.0:
		_is_dead = true
		died.emit()
 
 
func can_afford(attribute: int, amount: float) -> bool:
	# Mengecek apakah bar yang bersangkutan cukup untuk mengurangi sejumlah amount.
	match attribute:
		Constants.AttributeType.LIGHT:
			return light_bar >= amount
		Constants.AttributeType.DARK:
			return dark_bar >= amount
	return false
 
 
func is_dead() -> bool:
	return _is_dead
 