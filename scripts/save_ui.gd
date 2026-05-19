extends CanvasLayer

@onready var slot_container: VBoxContainer = $Panel/SlotContainer

var slot_nodes: Array = []
const MAX_SLOTS: int = 3

func _ready() -> void:
	refresh_slots()
	visible = false

func refresh_slots() -> void:
	for node in slot_nodes:
		node.queue_free()
	slot_nodes.clear()
	
	for i in range(MAX_SLOTS):
		var slot_ui := _create_slot_ui(i)
		slot_container.add_child(slot_ui)
		slot_nodes.append(slot_ui)

func _create_slot_ui(slot: int) -> Control:
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(360, 80)
	panel.size = Vector2(360, 80)
	
	var info: Dictionary = SaveManager.get_save_info(slot) if SaveManager and SaveManager.has_method("get_save_info") else {}
	var has_data: bool = SaveManager.has_save(slot) if SaveManager and SaveManager.has_method("has_save") else false
	
	# Slot number label
	var num_label := Label.new()
	num_label.position = Vector2(8, 4)
	num_label.size = Vector2(40, 20)
	num_label.add_theme_font_size_override("font_size", 16)
	num_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	num_label.text = "#%d" % (slot + 1)
	panel.add_child(num_label)
	
	if has_data and not info.is_empty():
		# Has save data
		var level_label := Label.new()
		level_label.position = Vector2(50, 4)
		level_label.size = Vector2(120, 20)
		level_label.add_theme_font_size_override("font_size", 14)
		level_label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
		level_label.text = "等级%d" % info.get("level", 1)
		panel.add_child(level_label)
		
		var gold_label := Label.new()
		gold_label.position = Vector2(170, 4)
		gold_label.size = Vector2(100, 20)
		gold_label.add_theme_font_size_override("font_size", 14)
		gold_label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
		gold_label.text = "💰 %d" % info.get("gold", 0)
		panel.add_child(gold_label)
		
		var time_label := Label.new()
		time_label.position = Vector2(50, 28)
		time_label.size = Vector2(200, 20)
		time_label.add_theme_font_size_override("font_size", 11)
		time_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
		time_label.text = info.get("timestamp", "未知")
		panel.add_child(time_label)
		
		var hp_label := Label.new()
		hp_label.position = Vector2(50, 48)
		hp_label.size = Vector2(120, 20)
		hp_label.add_theme_font_size_override("font_size", 11)
		hp_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1))
		hp_label.text = "生命值 %d/%d" % [info.get("hp", 0), info.get("max_hp", 100)]
		panel.add_child(hp_label)
		
		# Action buttons
		var load_btn := Button.new()
		load_btn.position = Vector2(260, 8)
		load_btn.size = Vector2(80, 28)
		load_btn.text = "读取"
		load_btn.pressed.connect(_on_load_slot.bind(slot))
		panel.add_child(load_btn)
		
		var overwrite_btn := Button.new()
		overwrite_btn.position = Vector2(260, 42)
		overwrite_btn.size = Vector2(80, 28)
		overwrite_btn.text = "覆盖"
		overwrite_btn.pressed.connect(_on_overwrite_slot.bind(slot))
		panel.add_child(overwrite_btn)
		
		var delete_btn := Button.new()
		delete_btn.position = Vector2(345, 8)
		delete_btn.size = Vector2(40, 28)
		delete_btn.text = "删"
		delete_btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
		delete_btn.pressed.connect(_on_delete_slot.bind(slot))
		panel.add_child(delete_btn)
	else:
		# Empty slot
		var empty_label := Label.new()
		empty_label.position = Vector2(50, 28)
		empty_label.size = Vector2(200, 20)
		empty_label.add_theme_font_size_override("font_size", 13)
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		empty_label.text = "空存档槽"
		panel.add_child(empty_label)
		
		var new_btn := Button.new()
		new_btn.position = Vector2(260, 24)
		new_btn.size = Vector2(80, 32)
		new_btn.text = "新建"
		new_btn.pressed.connect(_on_new_slot.bind(slot))
		panel.add_child(new_btn)
	
	return panel

func _on_new_slot(slot: int) -> void:
	if SaveManager and SaveManager.has_method("save_game"):
		SaveManager.save_game(slot)
	refresh_slots()

func _on_overwrite_slot(slot: int) -> void:
	if SaveManager and SaveManager.has_method("save_game"):
		SaveManager.save_game(slot)
	refresh_slots()

func _on_load_slot(slot: int) -> void:
	visible = false
	var fader = get_tree().get_first_node_in_group("scene_fader")
	if fader and fader.has_method("fade_out"):
		await fader.fade_out(0.5)
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	await get_tree().process_frame
	if SaveManager and SaveManager.has_method("load_game"):
		SaveManager.load_game(slot)

func _on_delete_slot(slot: int) -> void:
	if SaveManager and SaveManager.has_method("delete_save"):
		SaveManager.delete_save(slot)
	refresh_slots()

func open() -> void:
	refresh_slots()
	visible = true

func _on_close() -> void:
	visible = false
