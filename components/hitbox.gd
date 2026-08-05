extends Area2D
class_name Hitbox

## HITBOX — Component reusable untuk sumber damage (attack player,
## serangan enemy, proyektil, dst). Pasang ke Area2D child, lalu
## nyalakan `monitoring = true` sesaat saat menyerang.


@export var damage_same: float = 10.0
@export var damage_diff: float = 12.0
@export var attribute: int = 0 # gunakan Constants.AttributeType (LIGHT=0/DARK=1)

## Signal untuk Player.gd agar bisa mendeteksi kapan attack berhasil mendarat ke musuh.
signal landed(hurtbox: Hurtbox)


func _ready() -> void:
	monitoring = false # default nonaktif; combat component yang menyalakan
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		landed.emit(area)


func get_damage_for(target_attribute: int) -> float:
	return damage_same if target_attribute == attribute else damage_diff