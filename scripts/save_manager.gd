extends Node

const MAX_SLOTS: int = 3

func _get_save_path(slot: int) -> String:
	return "user://save_%d.json" % slot

func _get_info_path(slot: int) -> String:
	return "user://save_%d_info.json" % slot

func save_game(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("Invalid save slot: %d" % slot)
		return false
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		push_warning("No player found to save")
		return false
	
	var save_data := {
		"player": {
			"position": [player.global_position.x, player.global_position.y],
			"hp": player.current_hp,
			"max_hp": player.max_hp,
			"inventory": player.inventory,
			"equipment": player.equipment,
			"gold": player.gold,
			"xp": player.xp,
			"level": player.level,
			"xp_to_next": player.xp_to_next,
			"base_attack_damage": player.base_attack_damage,
			"respawn_position": [player.respawn_position.x, player.respawn_position.y]
		},
		"enemies_defeated": 0,
		"quest_progress": {}
	}
	
	var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node
	if quest_mgr:
		save_data["quest_progress"] = {
			"kill_count": quest_mgr.kill_count,
			"talked_to_npc": quest_mgr.talked_to_npc,
			"completed": quest_mgr.completed
		}
	
	var file := FileAccess.open(_get_save_path(slot), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("游戏已保存至存档槽 %d" % slot)
		
		# 保存元数据供UI预览
		var info := {
			"timestamp": Time.get_datetime_string_from_system(false, true),
			"level": player.level,
			"gold": player.gold,
			"hp": player.current_hp,
			"max_hp": player.max_hp
		}
		var info_file := FileAccess.open(_get_info_path(slot), FileAccess.WRITE)
		if info_file:
			info_file.store_string(JSON.stringify(info))
			info_file.close()
		
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("存档 %d 已保存!" % (slot + 1), 1.5)
		return true
	else:
		push_error("无法保存游戏")
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("存档失败!", 2.0)
		return false

func load_game(slot: int) -> bool:
	print("[SaveManager] load_game called for slot %d" % slot)
	var path := _get_save_path(slot)
	print("[SaveManager] save path: %s" % path)
	if not FileAccess.file_exists(path):
		print("[SaveManager] ERROR: save file does not exist")
		return false
	
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("无法打开存档文件")
		return false
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		push_error("解析存档文件失败：%s" % json.get_error_message())
		return false
	
	var save_data := json.data as Dictionary
	if not save_data:
		push_error("无效的存档数据")
		return false
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player and save_data.has("player"):
		var player_data := save_data["player"] as Dictionary
		if player_data.has("position"):
			var pos := player_data["position"] as Array
			player.global_position = Vector2(pos[0], pos[1])
		if player_data.has("hp"):
			player.current_hp = player_data["hp"]
		if player_data.has("max_hp"):
			player.max_hp = player_data["max_hp"]
		if player_data.has("inventory"):
			player.inventory = player_data["inventory"]
		if player_data.has("equipment"):
			player.equipment = player_data["equipment"]
		if player_data.has("gold"):
			player.gold = player_data["gold"]
		if player_data.has("xp"):
			player.xp = player_data["xp"]
		if player_data.has("level"):
			player.level = player_data["level"]
		if player_data.has("xp_to_next"):
			player.xp_to_next = player_data["xp_to_next"]
		if player_data.has("base_attack_damage"):
			player.base_attack_damage = player_data["base_attack_damage"]
			player.attack_damage = player.base_attack_damage
			player.recalc_stats()
		if player_data.has("respawn_position"):
			var rpos := player_data["respawn_position"] as Array
			player.respawn_position = Vector2(rpos[0], rpos[1])
		
		player.is_dead = false
		player.sprite.modulate = Color(1, 1, 1, 1)
		player.update_hp_bar()
		player.update_level_ui()
		player.update_equipment_visuals()
		if player.inventory_ui:
			player.inventory_ui.refresh(player.inventory, player.equipment)
	
	var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node
	if quest_mgr and save_data.has("quest_progress"):
		var quest_data := save_data["quest_progress"] as Dictionary
		if quest_data.has("kill_count"):
			quest_mgr.kill_count = quest_data["kill_count"]
		if quest_data.has("talked_to_npc"):
			quest_mgr.talked_to_npc = quest_data["talked_to_npc"]
		if quest_data.has("completed"):
			quest_mgr.completed = quest_data["completed"]
	
	print("游戏已从存档槽 %d 加载" % slot)
	if ToastManager and ToastManager.has_method("show_toast"):
		ToastManager.show_toast("存档 %d 已读取!" % (slot + 1), 1.5)
	return true

func get_save_info(slot: int) -> Dictionary:
	var info_path := _get_info_path(slot)
	if not FileAccess.file_exists(info_path):
		return {}
	var file := FileAccess.open(info_path, FileAccess.READ)
	if not file:
		return {}
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err == OK and json.data is Dictionary:
		return json.data
	return {}

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_get_save_path(slot))

func has_any_save() -> bool:
	for i in range(MAX_SLOTS):
		if has_save(i):
			return true
	return false

func delete_save(slot: int) -> void:
	var path := _get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	var info_path := _get_info_path(slot)
	if FileAccess.file_exists(info_path):
		DirAccess.remove_absolute(info_path)
	print("存档槽 %d 已删除" % slot)
