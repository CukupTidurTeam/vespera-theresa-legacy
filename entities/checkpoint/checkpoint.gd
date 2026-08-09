extends Area2D
class_name Checkpoint

## CHECKPOINT - Area2D untuk checkpoint. Dipakai di scene game, bisa di-reuse di scene lain kalau perlu.

@export var checkpoint_id: String = "" # opsional, untuk nanti kalau perlu bedakan checkpoint mana yang terakhir dipakai

signal activated(checkpoint: Checkpoint)

@onready var visual_sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(Constants.GROUP_PLAYER):
		return

	_activate(body)


func _activate(player: Node2D) -> void:
	var attributes: PlayerAttributes = player.get_node_or_null("PlayerAttributes")
	if attributes != null:
		attributes.set_bars(attributes.max_bar, attributes.max_bar)

	var success: bool = SaveManager.save_to_active_slot()
	if not success:
		push_warning("Checkpoint '%s': save gagal — cek apakah active slot sudah di-set dari MainMenu." % checkpoint_id)

	activated.emit(self)
	# TODO: efek visual/audio checkpoint aktif (belum ada asset),
	# dan UI feedback "Game Saved" sekilas ke pemain.