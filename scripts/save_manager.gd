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
	
	# 验证player必要属性
	if not player.has_method("get"):
		push_error("Player node missing required properties")
		return false
	
	var save_data := {
		"version": 1,
		"player": {
			"position": _vector2_to_array(player.global_position),
			"hp": player.current_hp,
			"max_hp": player.max_hp,
			"inventory": player.inventory if player.inventory != null else [],
			"equipment": player.equipment if player.equipment != null else {},
			"gold": player.gold,
			"xp": player.xp,
			"level": player.level,
			"xp_to_next": player.xp_to_next,
			"base_attack_damage": player.base_attack_damage,
			"respawn_position": _vector2_to_array(player.respawn_position)
		},
		"current_scene": SceneTransition.get_current_scene_name() if SceneTransition and SceneTransition.has_method("get_current_scene_name") else "world",
		"enemies_defeated": 0,
		"quest_progress": {}
	}
	
	var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node
	if quest_mgr:
		var quest_progress := {}
		if quest_mgr.get("kill_count") != null:
			quest_progress["kill_count"] = quest_mgr.kill_count
		if quest_mgr.get("talked_to_npc") != null:
			quest_progress["talked_to_npc"] = quest_mgr.talked_to_npc
		if quest_mgr.get("completed") != null:
			quest_progress["completed"] = quest_mgr.completed
		save_data["quest_progress"] = quest_progress
	
	var json_string := JSON.stringify(save_data)
	if json_string.is_empty():
		push_error("JSON序列化失败，存档数据为空")
		return false
	
	var file := FileAccess.open(_get_save_path(slot), FileAccess.WRITE)
	if not file:
		push_error("无法保存游戏: 无法打开文件 %s" % _get_save_path(slot))
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("存档失败!", 2.0)
		return false
	
	file.store_string(json_string)
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

func load_game(slot: int) -> bool:
	print("[SaveManager] load_game called for slot %d" % slot)
	var path := _get_save_path(slot)
	print("[SaveManager] save path: %s" % path)
	if not FileAccess.file_exists(path):
		print("[SaveManager] ERROR: save file does not exist")
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("存档 %d 不存在" % (slot + 1), 2.0)
		return false
	
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("无法打开存档文件: %s" % path)
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("无法打开存档", 2.0)
		return false
	
	var json_string := file.get_as_text()
	file.close()
	
	if json_string.is_empty():
		push_error("存档文件为空: %s" % path)
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("存档文件损坏", 2.0)
		return false
	
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		push_error("解析存档文件失败：%s" % json.get_error_message())
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("存档解析失败", 2.0)
		return false
	
	var save_data := json.data as Dictionary
	if not save_data:
		push_error("无效的存档数据: 不是字典类型")
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("存档数据无效", 2.0)
		return false
	
	# 验证存档版本和必要字段
	if not save_data.has("player"):
		push_error("存档数据缺少player字段")
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("存档数据不完整", 2.0)
		return false
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		push_error("读取存档失败：找不到player节点")
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("读取存档失败：找不到玩家", 2.0)
		return false
	
	if save_data.has("player"):
		var player_data := save_data["player"] as Dictionary
		if not player_data:
			push_error("player数据无效")
			return false
		
		if player_data.has("position"):
			var pos := _array_to_vector2(player_data["position"])
			if pos != null:
				player.global_position = pos
			else:
				push_warning("存档position数据格式错误，使用默认位置")
		
		if player_data.has("hp"):
			player.current_hp = player_data["hp"]
		if player_data.has("max_hp"):
			player.max_hp = player_data["max_hp"]
		if player_data.has("inventory"):
			player.inventory = player_data["inventory"] if player_data["inventory"] != null else []
		if player_data.has("equipment"):
			player.equipment = player_data["equipment"] if player_data["equipment"] != null else {}
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
			if player.has_method("recalc_stats"):
				player.recalc_stats()
		if player_data.has("respawn_position"):
			var rpos := _array_to_vector2(player_data["respawn_position"])
			if rpos != null:
				player.respawn_position = rpos
		
		player.is_dead = false
		if "sprite" in player and player.sprite != null:
			player.sprite.modulate = Color(1, 1, 1, 1)
		if player.has_method("update_hp_bar"):
			player.update_hp_bar()
		if player.has_method("update_level_ui"):
			player.update_level_ui()
		if player.has_method("update_equipment_visuals"):
			player.update_equipment_visuals()
		if "inventory_ui" in player and player.inventory_ui != null and player.inventory_ui.has_method("refresh"):
			player.inventory_ui.refresh(player.inventory, player.equipment)
		
		# 处理场景切换
		if save_data.has("current_scene"):
			var saved_scene: String = save_data["current_scene"]
			var current_scene: String = SceneTransition.get_current_scene_name() if SceneTransition and SceneTransition.has_method("get_current_scene_name") else "world"
			if saved_scene != current_scene:
				var scene_path: String = "res://scenes/" + saved_scene + ".tscn"
				var target_pos: Vector2 = player.global_position
				if player_data.has("position"):
					var pos := _array_to_vector2(player_data["position"])
					if pos != null:
						target_pos = pos
				if SceneTransition and SceneTransition.has_method("change_scene"):
					SceneTransition.change_scene(scene_path, target_pos)
					return true
	
	var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node
	if quest_mgr and save_data.has("quest_progress"):
		var quest_data := save_data["quest_progress"] as Dictionary
		if quest_data:
			if quest_data.has("kill_count") and quest_mgr.get("kill_count") != null:
				quest_mgr.kill_count = quest_data["kill_count"]
			if quest_data.has("talked_to_npc") and quest_mgr.get("talked_to_npc") != null:
				quest_mgr.talked_to_npc = quest_data["talked_to_npc"]
			if quest_data.has("completed") and quest_mgr.get("completed") != null:
				quest_mgr.completed = quest_data["completed"]
	
	print("游戏已从存档槽 %d 加载" % slot)
	if ToastManager and ToastManager.has_method("show_toast"):
		ToastManager.show_toast("存档 %d 已读取!" % (slot + 1), 1.5)
	return true

# 辅助函数：Vector2转Array
func _vector2_to_array(v: Vector2) -> Array:
	return [v.x, v.y]

# 辅助函数：Array转Vector2（带错误处理）
func _array_to_vector2(arr) -> Vector2:
	if arr == null:
		push_warning("_array_to_vector2: 输入为null")
		return Vector2.ZERO
	var array := arr as Array
	if not array or array.size() < 2:
		push_warning("_array_to_vector2: 无效数组格式 %s" % str(arr))
		return Vector2.ZERO
	var x = array[0]
	var y = array[1]
	if not (x is float or x is int) or not (y is float or y is int):
		push_warning("_array_to_vector2: 非数字类型 x=%s, y=%s" % [str(x), str(y)])
		return Vector2.ZERO
	return Vector2(float(x), float(y))

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
