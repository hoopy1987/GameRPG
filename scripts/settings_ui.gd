extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var master_slider: HSlider = $Panel/VBoxContainer/MasterSlider
@onready var bgm_slider: HSlider = $Panel/VBoxContainer/BGMSlider
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/SFXSlider
@onready var fullscreen_check: CheckBox = $Panel/VBoxContainer/FullscreenCheck
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

const SETTINGS_PATH := "user://settings.json"

func _ready() -> void:
	panel.visible = false
	
	# Ensure audio buses exist
	ensure_audio_buses()
	
	master_slider.value_changed.connect(_on_master_changed)
	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_changed)
	close_button.pressed.connect(_on_close)
	
	load_settings()

func ensure_audio_buses() -> void:
	var bgm_idx := AudioServer.get_bus_index("BGM")
	if bgm_idx < 0:
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "BGM")
		AudioServer.set_bus_send(1, "Master")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx < 0:
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "SFX")
		AudioServer.set_bus_send(2, "Master")

func _on_master_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))

func _on_bgm_changed(value: float) -> void:
	var bus_idx := AudioServer.get_bus_index("BGM")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

func _on_sfx_changed(value: float) -> void:
	var bus_idx := AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))

func _on_fullscreen_changed(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_close() -> void:
	save_settings()
	panel.visible = false

func save_settings() -> void:
	var settings := {
		"master_volume": master_slider.value,
		"bgm_volume": bgm_slider.value,
		"sfx_volume": sfx_slider.value,
		"fullscreen": fullscreen_check.button_pressed
	}
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		return
	var settings := json.data as Dictionary
	if settings.has("master_volume"):
		master_slider.value = settings["master_volume"]
		_on_master_changed(master_slider.value)
	if settings.has("bgm_volume"):
		bgm_slider.value = settings["bgm_volume"]
		_on_bgm_changed(bgm_slider.value)
	if settings.has("sfx_volume"):
		sfx_slider.value = settings["sfx_volume"]
		_on_sfx_changed(sfx_slider.value)
	if settings.has("fullscreen"):
		fullscreen_check.button_pressed = settings["fullscreen"]
		_on_fullscreen_changed(fullscreen_check.button_pressed)

func open_settings() -> void:
	panel.visible = true
