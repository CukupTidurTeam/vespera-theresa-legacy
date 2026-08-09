extends Node

## SAVE MANAGER - Autoload singleton untuk handle save/load game. Menyimpan data ke file JSON di user://saves/slot_X.json, di mana X adalah nomor slot (1-4). Dipakai di MainMenu, Checkpoint, dan PlayerAttributes.

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 4

## Diisi oleh load_game() saat Player pilih slot di MainMenu, dibaca oleh Player.gd saat _ready() untuk restore posisi Player + bar attribute. Kosong kalau tidak ada load-game pending (mis. New Game biasa). Caller WAJIB cek dulu apakah Player ada di scene tree sebelum panggil ini, karena ini cuma baca data dari PlayerAttributes.
var pending_load_data: Dictionary = {}

## Diisi oleh set_active_slot() saat Player pilih slot di MainMenu, dibaca oleh Checkpoint.gd saat Player masuk area checkpoint. -1 berarti belum ada active slot (belum pilih slot di MainMenu).
var _active_slot: int = -1

var _playtime_seconds: float = 0.0
var _playtime_active: bool = false


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _process(delta: float) -> void:
	if _playtime_active:
		_playtime_seconds += delta


func start_playtime_tracking() -> void:
	_playtime_active = true


func stop_playtime_tracking() -> void:
	_playtime_active = false


func get_playtime_seconds() -> float:
	return _playtime_seconds


## Dipanggil dari MainMenu saat Player pilih slot kosong (New Game) atau slot terisi (Load Game). Caller WAJIB cek dulu apakah Player ada di scene tree sebelum panggil ini, karena ini cuma baca data dari PlayerAttributes.
func set_active_slot(slot: int) -> void:
	_active_slot = slot
	_playtime_seconds = 0.0


func get_active_slot() -> int:
	return _active_slot


## Dipanggil dari Checkpoint.gd saat Player masuk area checkpoint. Caller WAJIB cek dulu apakah Player ada di scene tree sebelum panggil ini, karena ini cuma baca data dari PlayerAttributes.
func save_to_active_slot() -> bool:
	if _active_slot == -1:
		push_error("SaveManager.save_to_active_slot: tidak ada active slot — set_active_slot() belum pernah dipanggil (kemungkinan masuk scene game tanpa lewat MainMenu New Game/Load Game dulu).")
		return false
	return save_game(_active_slot)


## Dipanggil dari Checkpoint.gd saat Player masuk area checkpoint. Caller WAJIB cek dulu apakah Player ada di scene tree sebelum panggil ini, karena ini cuma baca data dari PlayerAttributes.
func save_game(slot: int) -> bool:
	if slot < 1 or slot > MAX_SLOTS:
		push_error("SaveManager.save_game: slot %d di luar rentang 1-%d" % [slot, MAX_SLOTS])
		return false

	var player: Node = get_tree().get_first_node_in_group(Constants.GROUP_PLAYER)
	if player == null:
		push_error("SaveManager.save_game: tidak ada Player di scene tree — save cuma bisa dilakukan saat in-game.")
		return false

	var attributes: PlayerAttributes = player.get_node_or_null("PlayerAttributes")
	if attributes == null:
		push_error("SaveManager.save_game: Player tidak punya node PlayerAttributes.")
		return false

	var data := {
		"stage": get_tree().current_scene.scene_file_path,
		"position_x": player.global_position.x,
		"position_y": player.global_position.y,
		"playtime_seconds": _playtime_seconds,
		"light_bar": attributes.light_bar,
		"dark_bar": attributes.dark_bar,
		"timestamp": Time.get_datetime_string_from_system(),
	}

	var file := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager.save_game: gagal membuka file untuk ditulis di slot %d" % slot)
		return false

	file.store_string(JSON.stringify(data))
	file.close()
	return true


## Dipanggil dari MainMenu saat Player pilih slot TERISI untuk Load Game.
func load_game(slot: int) -> bool:
	var data := _read_slot(slot)
	if data.is_empty():
		return false

	pending_load_data = data
	_playtime_seconds = data.get("playtime_seconds", 0.0)
	_active_slot = slot
	return true


## Dipanggil dari Player.gd saat _ready() untuk ambil data load-game yang pending (kalau ada) dan restore posisi Player + bar attribute. Caller WAJIB cek dulu apakah Player ada di scene tree sebelum panggil ini, karena ini cuma baca data dari PlayerAttributes
func consume_pending_load() -> Dictionary:
	var data := pending_load_data
	pending_load_data = {}
	return data


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


func get_slot_summary(slot: int) -> Dictionary:
	var data := _read_slot(slot)
	if data.is_empty():
		return {}
	return {
		"stage": data.get("stage", ""),
		"playtime_seconds": data.get("playtime_seconds", 0.0),
		"timestamp": data.get("timestamp", ""),
	}


func delete_save(slot: int) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(_slot_path(slot))


func _read_slot(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}

	var file := FileAccess.open(_slot_path(slot), FileAccess.READ)
	if file == null:
		return {}

	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		push_error("SaveManager: file save slot %d korup atau format tidak valid." % slot)
		return {}

	return parsed


func _slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot