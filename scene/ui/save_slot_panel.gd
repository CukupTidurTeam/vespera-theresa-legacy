extends PanelContainer
class_name SaveSlotPanel

signal back_pressed
signal slot_selected(slot_index: int)

@export var game_scene_path: String = "res://levels/game.tscn"

func _on_slot_button_pressed(slot_index: int) -> void:
	slot_selected.emit(slot_index)
	if game_scene_path != "":
		get_tree().change_scene_to_file(game_scene_path)

func _on_back_button_pressed() -> void:
	back_pressed.emit()
