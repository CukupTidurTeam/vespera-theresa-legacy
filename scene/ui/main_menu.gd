extends Control

@onready var main_buttons_container: Control = %MainButtonsContainer
@onready var save_slot_panel: SaveSlotPanel = %SaveSlotPanel
@onready var option_panel: OptionPanel = %OptionPanel
@onready var key_map_panel: KeyMapPanel = %KeyMapPanel
@onready var extras_panel: ExtrasPanel = %ExtrasPanel

const GAME_SCENE_PATH := "res://levels/game.tscn" # samakan dengan save_slot_panel.gd

func _ready() -> void:
	_show_main_buttons()
	# PENTING: connect signal slot_selected dari SaveSlotPanel ke handler di MainMenu.gd supaya bisa handle klik slot kosong (New Game). Kalau tidak, klik slot kosong tidak akan pindah scene.
	save_slot_panel.slot_selected.connect(_on_save_slot_selected)

func _hide_all_panels() -> void:
	main_buttons_container.hide()
	save_slot_panel.hide()
	option_panel.hide()
	key_map_panel.hide()
	extras_panel.hide()

func _show_main_buttons() -> void:
	_hide_all_panels()
	main_buttons_container.show()

func _on_start_game_button_pressed() -> void:
	_hide_all_panels()
	# PENTING: set mode ke LOAD supaya slot kosong tidak bisa dipilih (tidak ada yang bisa di-load). Caller WAJIB cek dulu apakah Player ada di scene tree sebelum panggil ini, karena ini cuma baca data dari PlayerAttributes.
	save_slot_panel.set_mode(SaveSlotPanel.Mode.LOAD)
	save_slot_panel.refresh_slot_labels()
	save_slot_panel.show()

func _on_option_button_pressed() -> void:
	_hide_all_panels()
	option_panel.show()

func _on_extras_button_pressed() -> void:
	_hide_all_panels()
	extras_panel.show()

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()

# --- Sub-panel Signal Handlers ---

func _on_save_slot_panel_back_pressed() -> void:
	_show_main_buttons()

func _on_option_panel_back_pressed() -> void:
	_show_main_buttons()

func _on_option_panel_key_map_pressed() -> void:
	_hide_all_panels()
	key_map_panel.show()

func _on_key_map_panel_back_pressed() -> void:
	_hide_all_panels()
	option_panel.show()

func _on_extras_panel_back_pressed() -> void:
	_show_main_buttons()

## Dipanggil dari SaveSlotPanel saat Player pilih slot kosong (New Game). Caller WAJIB cek dulu apakah Player ada di scene tree sebelum panggil ini, karena ini cuma baca data dari PlayerAttributes.
func _on_save_slot_selected(slot_index: int) -> void:
	if SaveManager.has_save(slot_index):
		return # sudah dihandle otomatis oleh SaveSlotPanel

	SaveManager.set_active_slot(slot_index)
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
