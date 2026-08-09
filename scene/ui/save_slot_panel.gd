extends PanelContainer
class_name SaveSlotPanel

## SAVE SLOT PANEL - Panel untuk pilih slot save/load game. Dipakai di MainMenu, bisa di-reuse di scene lain kalau perlu.

signal back_pressed
signal slot_selected(slot_index: int)

enum Mode { SAVE, LOAD }

@export var game_scene_path: String = "res://levels/game.tscn"
@export var mode: Mode = Mode.LOAD

@onready var slot_buttons: Array[Button] = [
	$MarginContainer/VBoxContainer/SlotsVBox/Slot1Button,
	$MarginContainer/VBoxContainer/SlotsVBox/Slot2Button,
	$MarginContainer/VBoxContainer/SlotsVBox/Slot3Button,
	$MarginContainer/VBoxContainer/SlotsVBox/Slot4Button,
]


func _ready() -> void:
	for i in slot_buttons.size():
		var slot_number := i + 1
		if not slot_buttons[i].pressed.is_connected(_on_slot_button_pressed):
			slot_buttons[i].pressed.connect(_on_slot_button_pressed.bind(slot_number))


func set_mode(new_mode: Mode) -> void:
	mode = new_mode
	refresh_slot_labels()


## Dipanggil dari MainMenu saat panel ini muncul, untuk refresh label slot sesuai data save terbaru. Caller WAJIB cek dulu apakah Player ada di scene tree sebelum panggil ini, karena ini cuma baca data dari PlayerAttributes.
func refresh_slot_labels() -> void:
	for i in slot_buttons.size():
		var slot_number := i + 1
		var button := slot_buttons[i]

		# Kalau mode LOAD, slot kosong tetap bisa diklik (New Game), jadi jangan disable tombolnya. Kalau mode SAVE, tombol slot kosong juga bisa diklik (Save ke slot itu), jadi tetap enable juga.
		button.disabled = false

		if SaveManager.has_save(slot_number):
			var summary: Dictionary = SaveManager.get_slot_summary(slot_number)
			var stage_name: String = summary.get("stage", "").get_file().get_basename()
			var playtime: String = _format_playtime(summary.get("playtime_seconds", 0.0))
			button.text = "Slot %d — %s (%s)" % [slot_number, stage_name, playtime]
		else:
			button.text = "Slot %d — Kosong" % slot_number


func _on_slot_button_pressed(slot_index: int) -> void:
	slot_selected.emit(slot_index)

	if mode == Mode.LOAD and SaveManager.has_save(slot_index):
		SaveManager.load_game(slot_index)
		if game_scene_path != "":
			get_tree().change_scene_to_file(game_scene_path)
	# Mode.SAVE tidak melakukan apa pun sendiri selain emit signal slot_selected, parent yang dengarkan dan urus SaveManager.save_game() sendiri (mis. kasih konfirmasi overwrite dulu kalau perlu).


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _format_playtime(seconds: float) -> String:
	var total_seconds: int = int(seconds)
	@warning_ignore("integer_division")
	var hours: int = total_seconds / 3600
	@warning_ignore("integer_division")
	var minutes: int = (total_seconds % 3600) / 60
	return "%dh %dm" % [hours, minutes]