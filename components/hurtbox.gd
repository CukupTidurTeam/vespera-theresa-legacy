extends Area2D
class_name Hurtbox

## HURTBOX - Component reusable untuk entity mana pun yang bisa menerima damage (Player, Enemy, destructible object, dst).

# Dipancarkan saat kena Hitbox lawan. Listener (mis. combat component) yang memutuskan bagaimana damage diproses.
signal hurt(amount: int, attribute: int, source: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	# Pastikan area yang masuk adalah Hitbox
	if area is Hitbox:
		var hb: Hitbox = area
		hurt.emit(hb.damage, hb.attribute, hb.get_parent())  # Emit sinyal hurt dengan informasi damage, attribute, dan sumber (parent dari hitbox)