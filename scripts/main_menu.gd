extends Control

@onready var title_label: Label = $TitleLabel
@onready var start_button: Button = $MenuPanel/VBoxContainer/StartButton
@onready var load_button: Button = $MenuPanel/VBoxContainer/LoadButton
@onready var settings_button: Button = $MenuPanel/VBoxContainer/SettingsButton
@onready var quit_button: Button = $MenuPanel/VBoxContainer/QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start)
	load_button.pressed.connect(_on_load)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	
	# Check if save exists
	var save_mgr = get_tree().get_first_node_in_group("save_manager") as Node
	if save_mgr and save_mgr.has_method("has_any_save"):
		load_button.disabled = not save_mgr.has_any_save()
	else:
		load_button.disabled = true

func _on_start() -> void:
	var fader = get_tree().get_first_node_in_group("scene_fader")
	if fader and fader.has_method("fade_out"):
		await fader.fade_out(0.5)
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_load() -> void:
	var save_ui = get_tree().get_first_node_in_group("save_ui")
	if save_ui and save_ui.has_method("open"):
		save_ui.open()
	else:
		# Fallback: direct load slot 0
		var fader = get_tree().get_first_node_in_group("scene_fader")
		if fader and fader.has_method("fade_out"):
			await fader.fade_out(0.5)
		
		var err := get_tree().change_scene_to_file("res://scenes/world.tscn")
		if err != OK:
			push_error("切换场景失败: %d" % err)
			return
		
		# 等待新场景完全加载
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		
		# 确保player节点已就绪
		var attempts := 0
		var player = get_tree().get_first_node_in_group("player") as Node2D
		while not player and attempts < 10:
			await get_tree().process_frame
			player = get_tree().get_first_node_in_group("player") as Node2D
			attempts += 1
		
		if not player:
			push_error("读取存档失败：找不到player节点")
			return
		
		var save_mgr = get_tree().get_first_node_in_group("save_manager") as Node
		if save_mgr and save_mgr.has_method("load_game"):
			var success: bool = save_mgr.load_game(0)
			if not success:
				push_error("load_game返回失败")

func _on_settings() -> void:
	var settings = get_tree().get_first_node_in_group("settings_ui")
	if settings:
		settings.visible = true
	else:
		push_warning("Settings UI not found")

func _on_quit() -> void:
	get_tree().quit()
