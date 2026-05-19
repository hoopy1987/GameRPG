extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var save_button: Button = $Panel/VBoxContainer/SaveButton
@onready var load_button: Button = $Panel/VBoxContainer/LoadButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton

var is_paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	
	resume_button.pressed.connect(_on_resume)
	save_button.pressed.connect(_on_save)
	load_button.pressed.connect(_on_load)
	settings_button.pressed.connect(_on_settings)
	main_menu_button.pressed.connect(_on_main_menu)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	panel.visible = is_paused

func _on_resume() -> void:
	toggle_pause()

func _on_save() -> void:
	if SaveUI and SaveUI.has_method("open"):
		SaveUI.open()
	else:
		var save_mgr = get_tree().get_first_node_in_group("save_manager") as Node
		if save_mgr and save_mgr.has_method("save_game"):
			save_mgr.save_game(0)

func _on_load() -> void:
	if SaveUI and SaveUI.has_method("open"):
		SaveUI.open()
	else:
		var save_mgr = get_tree().get_first_node_in_group("save_manager") as Node
		if save_mgr and save_mgr.has_method("load_game"):
			# 检查当前是否已经在world场景中
			var current_scene := get_tree().current_scene
			var is_in_world := current_scene and current_scene.scene_file_path == "res://scenes/world.tscn"
			
			if not is_in_world:
				var err := get_tree().change_scene_to_file("res://scenes/world.tscn")
				if err != OK:
					push_error("切换场景失败: %d" % err)
					return
				await get_tree().process_frame
				await get_tree().process_frame
				await get_tree().process_frame
			
			# 确保player就绪
			var attempts := 0
			var player = get_tree().get_first_node_in_group("player") as Node2D
			while not player and attempts < 10:
				await get_tree().process_frame
				player = get_tree().get_first_node_in_group("player") as Node2D
				attempts += 1
			
			if not player:
				push_error("读取存档失败：找不到player节点")
				return
			
			var success: bool = save_mgr.load_game(0)
			if success:
				toggle_pause()

func _on_settings() -> void:
	var settings = get_tree().get_first_node_in_group("settings_ui")
	if settings:
		settings.visible = true

func _on_main_menu() -> void:
	get_tree().paused = false
	var fader = get_tree().get_first_node_in_group("scene_fader")
	if fader and fader.has_method("fade_out"):
		await fader.fade_out(0.5)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
