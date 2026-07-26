extends CanvasLayer

@export var main_menu_scene_path: String = "res://scene/ui/main_menu.tscn"

@onready var color_rect_overlay: ColorRect = %ColorRectOverlay
@onready var pause_buttons_container: Control = %PauseButtonsContainer
@onready var option_panel: OptionPanel = %OptionPanel
@onready var key_map_panel: KeyMapPanel = %KeyMapPanel

var is_paused: bool = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		visible = is_paused
		if is_paused:
			_show_pause_buttons()

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		is_paused = !is_paused
		get_viewport().set_input_as_handled()

func _hide_all_panels() -> void:
	pause_buttons_container.hide()
	option_panel.hide()
	key_map_panel.hide()

func _show_pause_buttons() -> void:
	_hide_all_panels()
	pause_buttons_container.show()

func _on_resume_button_pressed() -> void:
	is_paused = false

func _on_option_button_pressed() -> void:
	_hide_all_panels()
	option_panel.show()

func _on_quit_to_menu_button_pressed() -> void:
	is_paused = false
	get_tree().change_scene_to_file(main_menu_scene_path)

# --- Sub-panel Signal Handlers ---

func _on_option_panel_back_pressed() -> void:
	_show_pause_buttons()

func _on_option_panel_key_map_pressed() -> void:
	_hide_all_panels()
	key_map_panel.show()

func _on_key_map_panel_back_pressed() -> void:
	_hide_all_panels()
	option_panel.show()
