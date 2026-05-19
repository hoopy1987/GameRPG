extends SceneTree

# ============================================================
# 完整项目自测脚本 (test_full.gd) —— 覆盖10大模块42+项测试
# 继承SceneTree以适配godot --script模式运行
# ============================================================

func _initialize() -> void:
	print("\n[Test] ============================================================")
	print("[Test] RPG项目全量自动化测试")
	print("[Test] ============================================================\n")
	
	var total = 0
	var passed = 0
	
	# 阶段1: 基础运行环境
	var r1 = _test_environment()
	passed += r1[0]; total += r1[1]
	
	# 阶段2: 场景加载
	var r2 = _test_scene_loading()
	passed += r2[0]; total += r2[1]
	
	# 阶段3: 玩家系统
	var r3 = _test_player_system()
	passed += r3[0]; total += r3[1]
	
	# 阶段4: 敌人系统
	var r4 = _test_enemy_system()
	passed += r4[0]; total += r4[1]
	
	# 阶段5: NPC系统
	var r5 = _test_npc_system()
	passed += r5[0]; total += r5[1]
	
	# 阶段6: 物品系统
	var r6 = _test_item_system()
	passed += r6[0]; total += r6[1]
	
	# 阶段7: 存档系统
	var r7 = _test_save_system()
	passed += r7[0]; total += r7[1]
	
	# 阶段8: UI系统
	var r8 = _test_ui_system()
	passed += r8[0]; total += r8[1]
	
	# 阶段9: 任务系统
	var r9 = _test_quest_system()
	passed += r9[0]; total += r9[1]
	
	# 阶段10: 音效系统
	var r10 = _test_audio_system()
	passed += r10[0]; total += r10[1]
	
	# 阶段11: 矿洞内容测试
	var r11 = _test_cave_content()
	passed += r11[0]; total += r11[1]
	
	# 报告
	print("\n============================================================")
	print("[Test] 测试完成报告")
	print("[Test] ============================================================")
	print("[Test] 通过: %d" % passed)
	print("[Test] 失败: %d" % (total - passed))
	print("[Test] 总计: %d" % total)
	print("[Test] 通过率: %.1f%%" % (float(passed) / total * 100 if total > 0 else 0))
	print("")
	if passed == total:
		print("✅ 所有测试通过！")
	else:
		print("❌ 有测试失败，请检查日志")
	print("[Test] ============================================================\n")
	
	quit()

# ============================================================
# 阶段1: 基础运行环境 (4项)
# ============================================================
func _test_environment() -> Array:
	print("[阶段1] 基础运行环境测试")
	var passed = 0
	var total = 0
	
	# 1.1 Godot版本检查
	print("[Test]   测试1.1: Godot版本")
	var version_str: String = Engine.get_version_info()["string"]
	print("[Test]   当前版本: %s" % version_str)
	var is_4x: bool = version_str.begins_with("4.")
	_assert(is_4x, "Godot 4.x版本")
	passed += int(is_4x); total += 1
	
	# 1.2 项目文件结构
	print("[Test]   测试1.2: 项目文件结构")
	var required_paths = [
		"project.godot",
		"scenes/main_menu.tscn",
		"scenes/world.tscn",
		"scenes/player.tscn",
		"scripts/player.gd",
		"scripts/save_manager.gd",
		"data/enemies.json",
		"data/items.json"
	]
	var all_exist = true
	for path in required_paths:
		var exists = FileAccess.file_exists("res://" + path)
		if not exists:
			print("[Test]   ❌ 缺失: %s" % path)
			all_exist = false
	_assert(all_exist, "核心项目文件存在")
	passed += int(all_exist); total += 1
	
	# 1.3 .godot导入缓存
	print("[Test]   测试1.3: 导入缓存完整性")
	var import_dir = "res://.godot/imported/"
	var import_files = ["icon.svg"]
	var import_ok = DirAccess.dir_exists_absolute(import_dir)
	if import_ok:
		var dir = DirAccess.open(import_dir)
		if dir:
			var count: int = 0
			while true:
				var file = dir.get_next()
				if file.is_empty():
					break
				if not file.begins_with("."):
					count += 1
			import_ok = count > 0
			dir.list_dir_end()
		else:
			import_ok = false
	_assert(import_ok, "导入缓存存在")
	passed += int(import_ok); total += 1
	
	# 1.4 assets资源完整性
	print("[Test]   测试1.4: 资源完整性")
	var asset_dirs = ["assets", "assets/generated"]
	var assets_ok = true
	for dir_path in asset_dirs:
		if not DirAccess.dir_exists_absolute("res://" + dir_path):
			print("[Test]   ❌ 资源目录缺失: %s" % dir_path)
			assets_ok = false
	_assert(assets_ok, "资源目录存在")
	passed += int(assets_ok); total += 1
	
	print("[Test]   阶段1结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段2: 场景加载 (4项)
# ============================================================
func _test_scene_loading() -> Array:
	print("[阶段2] 场景加载测试")
	var passed = 0
	var total = 0
	
	# 2.1 主菜单场景
	print("[Test]   测试2.1: 主菜单场景")
	var main_menu_scene: PackedScene = load("res://scenes/main_menu.tscn")
	var main_menu_ok = main_menu_scene != null
	_assert(main_menu_ok, "主菜单场景可加载")
	passed += int(main_menu_ok); total += 1
	
	# 2.2 世界场景
	print("[Test]   测试2.2: 世界场景")
	var world_scene: PackedScene = load("res://scenes/world.tscn")
	var world_ok = world_scene != null
	_assert(world_ok, "世界场景可加载")
	passed += int(world_ok); total += 1
	
	# 2.3 玩家场景
	print("[Test]   测试2.3: 玩家场景")
	var player_scene: PackedScene = load("res://scenes/player.tscn")
	var player_ok = player_scene != null
	_assert(player_ok, "玩家场景可加载")
	passed += int(player_ok); total += 1
	
	# 2.4 场景实例化
	print("[Test]   测试2.4: 场景实例化")
	var can_instantiate = false
	if world_scene:
		var world_inst = world_scene.instantiate()
		can_instantiate = world_inst != null
		if world_inst:
			world_inst.queue_free()
	_assert(can_instantiate, "世界场景可实例化")
	passed += int(can_instantiate); total += 1
	
	print("[Test]   阶段2结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段3: 玩家系统 (5项)
# ============================================================
func _test_player_system() -> Array:
	print("[阶段3] 玩家系统测试")
	var passed = 0
	var total = 0
	
	# 3.1 玩家脚本加载
	print("[Test]   测试3.1: 玩家脚本")
	var player_script: GDScript = load("res://scripts/player.gd")
	var script_ok = player_script != null
	_assert(script_ok, "玩家脚本可加载")
	passed += int(script_ok); total += 1
	
	# 3.2 玩家属性存在性
	print("[Test]   测试3.2: 玩家属性")
	var has_props = false
	if player_script:
		var player_inst = player_script.new()
		var required_props = ["speed", "current_hp", "max_hp", "attack_damage", "inventory", "gold", "xp", "level"]
		var missing = []
		for prop in required_props:
			if not prop in player_inst:
				missing.append(prop)
		has_props = missing.is_empty()
		if not has_props:
			print("[Test]   ❌ 缺失属性: %s" % str(missing))
		player_inst.queue_free()
	_assert(has_props, "玩家属性完整")
	passed += int(has_props); total += 1
	
	# 3.3 玩家方法存在性
	print("[Test]   测试3.3: 玩家方法")
	var has_methods = false
	if player_script:
		var player_inst = player_script.new()
		var required_methods = ["_ready", "_physics_process", "_input", "update_hp_bar"]
		var missing_methods = []
		for method in required_methods:
			if not player_inst.has_method(method):
				missing_methods.append(method)
		has_methods = missing_methods.is_empty()
		if not has_methods:
			print("[Test]   ❌ 缺失方法: %s" % str(missing_methods))
		player_inst.queue_free()
	_assert(has_methods, "玩家方法完整")
	passed += int(has_methods); total += 1
	
	# 3.4 移动系统
	print("[Test]   测试3.4: 移动系统")
	var move_ok = false
	if player_script:
		var player_inst = player_script.new()
		if "speed" in player_inst and player_inst.speed > 0:
			move_ok = true
		player_inst.queue_free()
	_assert(move_ok, "移动系统可用")
	passed += int(move_ok); total += 1
	
	# 3.5 攻击系统
	print("[Test]   测试3.5: 攻击系统")
	var attack_ok = false
	if player_script:
		var player_inst = player_script.new()
		if "base_attack_damage" in player_inst and player_inst.base_attack_damage > 0:
			attack_ok = true
		player_inst.queue_free()
	_assert(attack_ok, "攻击系统可用")
	passed += int(attack_ok); total += 1
	
	print("[Test]   阶段3结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段4: 敌人系统 (5项)
# ============================================================
func _test_enemy_system() -> Array:
	print("[阶段4] 敌人系统测试")
	var passed = 0
	var total = 0
	
	# 4.1 敌人数据文件
	print("[Test]   测试4.1: 敌人数据")
	var enemies_file = FileAccess.open("res://data/enemies.json", FileAccess.READ)
	var enemies_ok = enemies_file != null
	_assert(enemies_ok, "敌人数据文件存在")
	passed += int(enemies_ok); total += 1
	
	# 4.2 敌人数据解析
	print("[Test]   测试4.2: 敌人数据解析")
	var enemies_parsed = false
	var enemy_count = 0
	var enemy_json_data = null
	if enemies_file:
		var json = JSON.new()
		var err = json.parse(enemies_file.get_as_text())
		enemies_parsed = err == OK and json.data is Array
		if enemies_parsed:
			enemy_count = json.data.size()
			enemy_json_data = json.data
		enemies_file.close()
	_assert(enemies_parsed, "敌人数据可解析")
	passed += int(enemies_parsed); total += 1
	
	# 4.3 敌人数据完整性
	print("[Test]   测试4.3: 敌人数据完整性")
	var enemy_data_ok = false
	if enemies_parsed and enemy_count > 0:
		var first_enemy = enemy_json_data[0] if enemy_json_data is Array and enemy_json_data.size() > 0 else null
		if first_enemy is Dictionary:
			var required_fields = ["id", "name", "max_hp", "speed", "attack_damage", "texture_path"]
			var missing = []
			for field in required_fields:
				if not first_enemy.has(field):
						missing.append(field)
			enemy_data_ok = missing.is_empty()
			if not enemy_data_ok:
					print("[Test]   ❌ 敌人缺失字段: %s" % str(missing))
	_assert(enemy_data_ok, "敌人数据字段完整")
	passed += int(enemy_data_ok); total += 1
	
	# 4.4 敌人种类数量
	print("[Test]   测试4.4: 敌人种类数量")
	var enemy_types_ok = enemy_count >= 5
	print("[Test]   敌人种类数: %d (要求>=5)" % enemy_count)
	_assert(enemy_types_ok, "敌人种类>=5")
	passed += int(enemy_types_ok); total += 1
	
	# 4.5 敌人脚本
	print("[Test]   测试4.5: 敌人脚本")
	var enemy_script: GDScript = load("res://scripts/enemy.gd")
	var enemy_script_ok = enemy_script != null
	_assert(enemy_script_ok, "敌人脚本可加载")
	passed += int(enemy_script_ok); total += 1
	
	print("[Test]   阶段4结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段5: NPC系统 (4项)
# ============================================================
func _test_npc_system() -> Array:
	print("[阶段5] NPC系统测试")
	var passed = 0
	var total = 0
	
	# 5.1 NPC脚本
	print("[Test]   测试5.1: NPC脚本")
	var npc_script: GDScript = load("res://scripts/npc.gd")
	var npc_ok = npc_script != null
	_assert(npc_ok, "NPC脚本可加载")
	passed += int(npc_ok); total += 1
	
	# 5.2 NPC场景
	print("[Test]   测试5.2: NPC场景")
	var npc_scene: PackedScene = load("res://scenes/npc.tscn")
	var npc_scene_ok = npc_scene != null
	_assert(npc_scene_ok, "NPC场景可加载")
	passed += int(npc_scene_ok); total += 1
	
	# 5.3 NPC属性
	print("[Test]   测试5.3: NPC属性")
	var npc_props_ok = false
	if npc_script:
		var npc_inst = npc_script.new()
		var required = ["npc_name", "dialogue_lines"]
		var missing = []
		for prop in required:
			if not prop in npc_inst:
				missing.append(prop)
		npc_props_ok = missing.is_empty()
		if not npc_props_ok:
			print("[Test]   ❌ NPC缺失属性: %s" % str(missing))
		npc_inst.queue_free()
	_assert(npc_props_ok, "NPC属性完整")
	passed += int(npc_props_ok); total += 1
	
	# 5.4 世界场景NPC数量
	print("[Test]   测试5.4: 世界场景NPC")
	var world_npcs_ok = false
	var world_scene: PackedScene = load("res://scenes/world.tscn")
	if world_scene:
		var world_inst = world_scene.instantiate()
		if world_inst:
			var npc_count: int = 0
			for child in world_inst.get_children():
				if child.is_in_group("npc") or child.name.begins_with("NPC"):
					npc_count += 1
				# Also check grandchildren (NPCs inside NPCs node)
				for grandchild in child.get_children():
					if grandchild.is_in_group("npc") or grandchild.name.begins_with("NPC"):
						npc_count += 1
			world_npcs_ok = npc_count >= 1
			print("[Test]   世界场景NPC数: %d" % npc_count)
			world_inst.queue_free()
	_assert(world_npcs_ok, "世界场景有NPC")
	passed += int(world_npcs_ok); total += 1
	
	print("[Test]   阶段5结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段6: 物品系统 (4项)
# ============================================================
func _test_item_system() -> Array:
	print("[阶段6] 物品系统测试")
	var passed = 0
	var total = 0
	
	# 6.1 物品数据文件
	print("[Test]   测试6.1: 物品数据文件")
	var items_file = FileAccess.open("res://data/items.json", FileAccess.READ)
	var items_ok = items_file != null
	_assert(items_ok, "物品数据文件存在")
	passed += int(items_ok); total += 1
	
	# 6.2 物品数据解析
	print("[Test]   测试6.2: 物品数据解析")
	var items_parsed = false
	var item_count = 0
	var item_json_data = null
	if items_file:
		var json = JSON.new()
		var err = json.parse(items_file.get_as_text())
		items_parsed = err == OK and json.data is Array
		if items_parsed:
			item_count = json.data.size()
			item_json_data = json.data
		items_file.close()
	_assert(items_parsed, "物品数据可解析")
	passed += int(items_parsed); total += 1
	
	# 6.3 物品数据完整性
	print("[Test]   测试6.3: 物品数据完整性")
	var item_data_ok = false
	if items_parsed and item_count > 0:
		var first_item = item_json_data[0] if item_json_data is Array and item_json_data.size() > 0 else null
		if first_item is Dictionary:
			var required_fields = ["id", "name", "type", "icon"]
			var missing = []
			for field in required_fields:
				if not first_item.has(field):
					missing.append(field)
			item_data_ok = missing.is_empty()
			if not item_data_ok:
				print("[Test]   ❌ 物品缺失字段: %s" % str(missing))
	_assert(item_data_ok, "物品数据字段完整")
	passed += int(item_data_ok); total += 1
	
	# 6.4 物品种类数量
	print("[Test]   测试6.4: 物品种类数量")
	var item_types_ok = item_count >= 5
	print("[Test]   物品种类数: %d (要求>=5)" % item_count)
	_assert(item_types_ok, "物品种类>=5")
	passed += int(item_types_ok); total += 1
	
	print("[Test]   阶段6结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段7: 存档系统 (4项)
# ============================================================
func _test_save_system() -> Array:
	print("[阶段7] 存档系统测试")
	var passed = 0
	var total = 0
	
	# 7.1 存档管理器脚本
	print("[Test]   测试7.1: 存档管理器")
	var save_script: GDScript = load("res://scripts/save_manager.gd")
	var save_ok = save_script != null
	_assert(save_ok, "存档管理器脚本可加载")
	passed += int(save_ok); total += 1
	
	# 7.2 存档方法存在性
	print("[Test]   测试7.2: 存档方法")
	var save_methods_ok = false
	if save_script:
		var save_inst = save_script.new()
		var required = ["save_game", "load_game", "has_save", "get_save_info"]
		var missing = []
		for method in required:
			if not save_inst.has_method(method):
				missing.append(method)
		save_methods_ok = missing.is_empty()
		if not save_methods_ok:
			print("[Test]   ❌ 存档缺失方法: %s" % str(missing))
		save_inst.queue_free()
	_assert(save_methods_ok, "存档方法完整")
	passed += int(save_methods_ok); total += 1
	
	# 7.3 存档UI场景
	print("[Test]   测试7.3: 存档UI")
	var save_ui_scene: PackedScene = load("res://scenes/save_ui.tscn")
	var save_ui_ok = save_ui_scene != null
	_assert(save_ui_ok, "存档UI场景可加载")
	passed += int(save_ui_ok); total += 1
	
	# 7.4 存档目录可写
	print("[Test]   测试7.4: 存档目录")
	var user_dir = OS.get_user_data_dir()
	var dir_ok = DirAccess.dir_exists_absolute(user_dir)
	_assert(dir_ok, "用户数据目录可访问")
	passed += int(dir_ok); total += 1
	
	print("[Test]   阶段7结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段8: UI系统 (4项)
# ============================================================
func _test_ui_system() -> Array:
	print("[阶段8] UI系统测试")
	var passed = 0
	var total = 0
	
	# 8.1 浮动文字管理器
	print("[Test]   测试8.1: 浮动文字管理器")
	var ftm_script: GDScript = load("res://scripts/floating_text_manager.gd")
	var ftm_ok = ftm_script != null
	_assert(ftm_ok, "浮动文字管理器可加载")
	passed += int(ftm_ok); total += 1
	
	# 8.2 提示管理器
	print("[Test]   测试8.2: 提示管理器")
	var toast_script: GDScript = load("res://scripts/toast_manager.gd")
	var toast_ok = toast_script != null
	_assert(toast_ok, "提示管理器可加载")
	passed += int(toast_ok); total += 1
	
	# 8.3 对话气泡
	print("[Test]   测试8.3: 对话气泡")
	var dialogue_script: GDScript = load("res://scripts/dialogue_bubble.gd")
	var dialogue_ok = dialogue_script != null
	_assert(dialogue_ok, "对话气泡可加载")
	passed += int(dialogue_ok); total += 1
	
	# 8.4 UI资源
	print("[Test]   测试8.4: UI资源")
	var ui_files = ["assets/ui/heart_icon.png"]
	var ui_ok = true
	for file in ui_files:
		if not FileAccess.file_exists("res://" + file):
			print("[Test]   ❌ UI资源缺失: %s" % file)
			ui_ok = false
	_assert(ui_ok, "核心UI资源存在")
	passed += int(ui_ok); total += 1
	
	print("[Test]   阶段8结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段9: 任务系统 (4项)
# ============================================================
func _test_quest_system() -> Array:
	print("[阶段9] 任务系统测试")
	var passed = 0
	var total = 0
	
	# 9.1 任务管理器
	print("[Test]   测试9.1: 任务管理器")
	var quest_script: GDScript = load("res://scripts/quest_manager.gd")
	var quest_ok = quest_script != null
	_assert(quest_ok, "任务管理器可加载")
	passed += int(quest_ok); total += 1
	
	# 9.2 任务数据
	print("[Test]   测试9.2: 任务数据加载")
	var quests_file = FileAccess.open("res://data/quests.json", FileAccess.READ)
	var quests_file_ok = quests_file != null
	var quests_parsed = false
	var quest_count = 0
	var quest_json_data = null
	if quests_file:
		var json = JSON.new()
		var err = json.parse(quests_file.get_as_text())
		quests_parsed = err == OK and json.data is Array
		if quests_parsed:
			quest_count = json.data.size()
			quest_json_data = json.data
		quests_file.close()
	_assert(quests_file_ok, "任务数据文件存在")
	passed += int(quests_file_ok); total += 1
	_assert(quests_parsed, "任务数据可解析")
	passed += int(quests_parsed); total += 1
	print("[Test]   任务数: %d" % quest_count)
	
	# 9.3 任务追踪UI
	print("[Test]   测试9.3: 任务追踪UI")
	var quest_ui: PackedScene = load("res://scenes/quest_tracker_ui.tscn")
	var quest_ui_ok = quest_ui != null
	_assert(quest_ui_ok, "任务追踪UI可加载")
	passed += int(quest_ui_ok); total += 1
	
	print("[Test]   阶段9结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段10: 音效系统 (4项)
# ============================================================
func _test_audio_system() -> Array:
	print("[阶段10] 音效系统测试")
	var passed = 0
	var total = 0
	
	# 10.1 音效管理器
	print("[Test]   测试10.1: 音效管理器")
	var sound_script: GDScript = load("res://scripts/sound_manager.gd")
	var sound_ok = sound_script != null
	_assert(sound_ok, "音效管理器可加载")
	passed += int(sound_ok); total += 1
	
	# 10.2 AudioBus配置
	print("[Test]   测试10.2: AudioBus配置")
	var bus_count = AudioServer.get_bus_count()
	var has_master = false
	var has_sfx = false
	var has_bgm = false
	for i in range(bus_count):
		var name = AudioServer.get_bus_name(i)
		if name == "Master":
			has_master = true
		if name == "SFX":
			has_sfx = true
		if name == "BGM":
			has_bgm = true
	print("[Test]   AudioBus: Master=%s, SFX=%s, BGM=%s" % [has_master, has_sfx, has_bgm])
	var bus_ok = has_master and has_sfx and has_bgm
	_assert(bus_ok, "AudioBus配置完整")
	passed += int(bus_ok); total += 1
	
	# 10.3 音效文件存在性
	print("[Test]   测试10.3: 音效文件存在")
	var sound_dir = "res://assets/sounds/"
	var has_sounds = false
	if DirAccess.dir_exists_absolute(sound_dir):
		var dir = DirAccess.open(sound_dir)
		if dir:
			var count: int = 0
			while true:
				var file = dir.get_next()
				if file.is_empty():
					break
				if file.ends_with(".wav") or file.ends_with(".ogg") or file.ends_with(".mp3"):
					count += 1
			has_sounds = count > 0
			dir.list_dir_end()
			print("[Test]   音效文件数: %d" % count)
	_assert(has_sounds, "有音效文件")
	passed += int(has_sounds); total += 1
	
	print("[Test]   阶段10结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 阶段11: 矿洞内容测试 (新增)
# ============================================================
func _test_cave_content() -> Array:
	print("[阶段11] 矿洞内容测试")
	var passed = 0
	var total = 0
	
	# 11.1 矿洞场景可加载
	print("[Test]   测试11.1: 矿洞场景")
	var cave_scene: PackedScene = load("res://scenes/cave.tscn")
	var cave_ok = cave_scene != null
	_assert(cave_ok, "矿洞场景可加载")
	passed += int(cave_ok); total += 1
	
	# 11.2 矿洞生成器脚本
	print("[Test]   测试11.2: 矿洞生成器")
	var cave_gen_script: GDScript = load("res://scripts/cave_generator.gd")
	var cave_gen_ok = cave_gen_script != null
	_assert(cave_gen_ok, "矿洞生成器脚本可加载")
	passed += int(cave_gen_ok); total += 1
	
	# 11.3 场景切换管理器
	print("[Test]   测试11.3: 场景切换管理器")
	var st_script: GDScript = load("res://scripts/scene_transition.gd")
	var st_ok = st_script != null
	_assert(st_ok, "场景切换管理器可加载")
	passed += int(st_ok); total += 1
	
	# 11.4 石像鬼敌人数据
	print("[Test]   测试11.4: 石像鬼敌人数据")
	var has_gargoyle = false
	var enemies_file = FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if enemies_file:
		var json = JSON.new()
		var err = json.parse(enemies_file.get_as_text())
		if err == OK and json.data is Array:
			for enemy in json.data:
				if enemy is Dictionary and enemy.get("id") == "gargoyle":
					has_gargoyle = true
					break
		enemies_file.close()
	_assert(has_gargoyle, "石像鬼敌人数据存在")
	passed += int(has_gargoyle); total += 1
	
	# 11.5 矿洞任务数据
	print("[Test]   测试11.5: 矿洞任务数据")
	var has_mine_quest = false
	var quests_file = FileAccess.open("res://data/quests.json", FileAccess.READ)
	if quests_file:
		var json = JSON.new()
		var err = json.parse(quests_file.get_as_text())
		if err == OK and json.data is Array:
			for quest in json.data:
				if quest is Dictionary and quest.get("id") == "mine_rescue":
					has_mine_quest = true
					break
		quests_file.close()
	_assert(has_mine_quest, "矿洞救援任务存在")
	passed += int(has_mine_quest); total += 1
	
	# 11.6 矿洞相关道具
	print("[Test]   测试11.6: 矿洞道具数据")
	var has_cave_items = false
	var items_file = FileAccess.open("res://data/items.json", FileAccess.READ)
	if items_file:
		var json = JSON.new()
		var err = json.parse(items_file.get_as_text())
		if err == OK and json.data is Array:
			var cave_item_ids = ["gargoyle_stone", "vein_heart"]
			var found = 0
			for item in json.data:
				if item is Dictionary and item.get("id") in cave_item_ids:
					found += 1
			has_cave_items = found >= 2
		items_file.close()
	_assert(has_cave_items, "矿洞道具数据完整")
	passed += int(has_cave_items); total += 1
	
	# 11.7 project.godot中SceneTransition autoload
	print("[Test]   测试11.7: SceneTransition Autoload")
	var has_autoload = false
	var pg_file = FileAccess.open("res://project.godot", FileAccess.READ)
	if pg_file:
		var content = pg_file.get_as_text()
		has_autoload = content.find("SceneTransition=") != -1
		pg_file.close()
	_assert(has_autoload, "SceneTransition已注册为Autoload")
	passed += int(has_autoload); total += 1
	
	# 11.8 世界场景有矿洞入口
	print("[Test]   测试11.8: 世界场景矿洞入口")
	var has_entrance = false
	var world_scene: PackedScene = load("res://scenes/world.tscn")
	if world_scene:
		var world_inst = world_scene.instantiate()
		if world_inst:
			if world_inst.has_node("CaveEntrance"):
				has_entrance = true
			world_inst.queue_free()
	_assert(has_entrance, "世界场景有矿洞入口")
	passed += int(has_entrance); total += 1
	
	print("[Test]   阶段11结果: %d/%d\n" % [passed, total])
	return [passed, total]

# ============================================================
# 辅助函数
# ============================================================
func _assert(condition: bool, message: String) -> void:
	if condition:
		print("[Test]   ✅ %s" % message)
	else:
		print("[Test]   ❌ %s" % message)
