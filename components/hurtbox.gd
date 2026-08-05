extends Area2D
class_name Hurtbox

## HURTBOX — Component reusable untuk entity mana pun yang bisa
## menerima damage (Player, Enemy, destructible object, dst).
## Attach script ini ke sebuah Area2D child dalam scene entity.

## Signal yang dipancarkan saat Hurtbox menerima damage dari Hitbox lawan.
signal hurt(attacker_attribute: int, source: Node2D, hitbox: Hitbox)

## Dipancarkan saat kena Hitbox lawan. `attacker_attribute` adalah
## attribute milik Hitbox penyerang — listener (mis. PlayerAttributes
## via Player.gd) yang memutuskan bar mana yang terpengaruh, karena
## aturan itu beda antara Player<-Enemy vs Enemy<-Player (lihat
## catatan di player_attributes.gd dan brief dual-bar system).
@export var owner_attribute: int = -1


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hb: Hitbox = area
		hurt.emit(hb.attribute, hb.get_parent(), hb)