extends PanelContainer
class_name OptionPanel

signal back_pressed
signal key_map_pressed

@onready var resolution_option_button: OptionButton = %ResolutionOptionButton
@onready var fullscreen_check_button: CheckButton = %FullscreenCheckButton
@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720)
]

func _ready() -> void:
	_setup_resolutions()
	_load_current_settings()

func _setup_resolutions() -> void:
	if resolution_option_button.item_count == 0:
		for res in RESOLUTIONS:
			resolution_option_button.add_item("%d x %d" % [res.x, res.y])

func _load_current_settings() -> void:
	# Fullscreen state
	var mode := DisplayServer.window_get_mode()
	fullscreen_check_button.button_pressed = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	# Current window size match
	var current_size := DisplayServer.window_get_size()
	for i in range(RESOLUTIONS.size()):
		if RESOLUTIONS[i] == current_size:
			resolution_option_button.selected = i
			break

	# Audio Volumes
	_init_bus_volume("Master", master_volume_slider)
	_init_bus_volume("Music", music_volume_slider)
	_init_bus_volume("SFX", sfx_volume_slider)

func _init_bus_volume(bus_name: String, slider: HSlider) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		var db := AudioServer.get_bus_volume_db(bus_idx)
		slider.value = db_to_linear(db)

func _set_bus_volume(bus_name: String, value: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_resolution_option_button_item_selected(index: int) -> void:
	var res := RESOLUTIONS[index]
	DisplayServer.window_set_size(res)

func _on_fullscreen_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_master_volume_slider_value_changed(value: float) -> void:
	_set_bus_volume("Master", value)

func _on_music_volume_slider_value_changed(value: float) -> void:
	_set_bus_volume("Music", value)

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	_set_bus_volume("SFX", value)

func _on_key_map_button_pressed() -> void:
	key_map_pressed.emit()

func _on_back_button_pressed() -> void:
	back_pressed.emit()
