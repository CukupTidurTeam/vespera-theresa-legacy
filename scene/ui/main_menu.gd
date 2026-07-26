extends Control

@onready var main_buttons_container: Control = %MainButtonsContainer
@onready var save_slot_panel: SaveSlotPanel = %SaveSlotPanel
@onready var option_panel: OptionPanel = %OptionPanel
@onready var key_map_panel: KeyMapPanel = %KeyMapPanel
@onready var extras_panel: ExtrasPanel = %ExtrasPanel

func _ready() -> void:
	_show_main_buttons()

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
