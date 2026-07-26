extends PanelContainer
class_name ExtrasPanel

signal back_pressed

func _on_back_button_pressed() -> void:
	back_pressed.emit()
