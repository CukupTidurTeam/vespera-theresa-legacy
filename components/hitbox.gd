extends Area2D
class_name Hitbox

## HITBOX - Component reusable untuk sumber damage (attack player, serangan enemy, proyektil, dst).

@export var damage: int = 10
@export var attribute: int = 0  # pake Constants.AttributeType (LIGHT=0/DARK=1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitoring = false # Nonaktifkan monitoring saat awal, akan diaktifkan saat attack
