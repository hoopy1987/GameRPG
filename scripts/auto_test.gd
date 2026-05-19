extends Node

# 自测日志记录器 — 启动时自动运行测试序列

var log_file: FileAccess
var test_results: Array = []
var test_start_time: float = 0.0

func _ready() -> void:
	test_start_time = Time.get_unix_time_from_system()
	_open_log()
	_log("=== 炭火村项目自测开始 ===")
	_log("时间: " + Time.get_datetime_string_from_system(false, true))
	
	# 延迟执行测试，确保所有节点就绪
	call_deferred("_run_tests")

func _open_log() -> void:
	var log_dir := "user://logs"
	var log_path := log_dir + "/test_log.txt"
	if not DirAccess.dir_exists_absolute(log_dir):
		DirAccess.make_dir_recursive_absolute(log_dir)
	log_file = FileAccess.open(log_path, FileAccess.WRITE)
	if log_file:
		log_file.store_line("=== 炭火村项目自测日志 ===")
		log_file.store_line("开始时间: " + Time.get_datetime_string_from_system(false, true))
		log_file.store_line("")

func _log(msg: String) -> void:
	var line := "[%s] %s" % [Time.get_time_string_from_system(), msg]
	print(line)
	if log_file:
		log_file.store_line(line)
		log_file.flush()

func _run_tests() -> void:
	_log("\n--- 测试1: 数据加载 ---")
	_test_data_loader()
	
	_log("\n--- 测试2: 场景节点检查 ---")
	_test_scene_nodes()
	
	_log("\n--- 测试3: 玩家系统 ---")
	_test_player()
	
	_log("\n--- 测试4: 敌人系统 ---")
	_test_enemies()
	
	_log("\n--- 测试5: NPC与商人 ---")
	_test_npcs()
	
	_log("\n--- 测试6: 任务系统 ---")
	_test_quest()
	
	_log("\n--- 测试7: 保存系统 ---")
	_test_save()
	
	_log("\n--- 测试8: 村庄生成 ---")
	_test_village()
	
	_log("\n--- 测试9: UI面板检查 ---")
	_test_ui_panels()
	
	_log("\n--- 测试10: 中文内容检查 ---")
	_test_chinese_content()
	
	# 汇总
	_log("\n=== 自测汇总 ===")
	var passed := 0
	var failed := 0
	for r in test_results:
		var status := "✅" if r.ok else "❌"
		_log("  %s %s — %s" % [status, r.name, r.detail])
		if r.ok:
			passed += 1
		else:
			failed += 1
	_log("\n通过: %d / 失败: %d / 总计: %d" % [passed, failed, test_results.size()])
	_log("耗时: %.1f 秒" % (Time.get_unix_time_from_system() - test_start_time))
	_log("=== 自测结束 ===")
	
	if log_file:
		log_file.flush()
		log_file.close()
		log_file = null
	
	# 延迟3秒后退出（让日志有时间写入）
	await get_tree().create_timer(3.0).timeout
	get_tree().quit(0 if failed == 0 else 1)

func _check(name: String, condition: bool, detail: String = "") -> void:
	test_results.append({"name": name, "ok": condition, "detail": detail})
	var status := "✅" if condition else "❌"
	var msg := "%s %s" % [status, name]
	if not condition and detail != "":
		msg += " — " + detail
	_log(msg)

func _test_data_loader() -> void:
	var dl = get_node_or_null("/root/DataLoader")
	_check("DataLoader存在", dl != null, "节点不存在")
	if dl == null:
		return
	
	var enemies: Array = dl.get_enemies() if dl.has_method("get_enemies") else []
	var items: Array = dl.get_items() if dl.has_method("get_items") else []
	var quests: Array = dl.get_quests() if dl.has_method("get_quests") else []
	
	_check("敌人JSON加载", enemies.size() > 0, "数量=%d" % enemies.size())
	_check("物品JSON加载", items.size() > 0, "数量=%d" % items.size())
	_check("任务JSON加载", quests.size() > 0, "数量=%d" % quests.size())
	
	# 检查中文化
	var has_chinese: bool = false
	for e in enemies:
		if e.get("name", "").find("史莱姆") >= 0:
			has_chinese = true
			break
	_check("敌人名称已汉化", has_chinese, "")

func _test_scene_nodes() -> void:
	var root := get_tree().current_scene
	if not root:
		root = get_node_or_null("/root/World")
	
	_check("当前场景存在", root != null, "场景未加载")
	if not root:
		return
	
	var tilemap := root.get_node_or_null("TileMapLayer")
	_check("TileMapLayer存在", tilemap != null, "")
	
	var player := root.get_node_or_null("Player")
	_check("Player节点存在", player != null, "")
	
	var npcs := root.get_node_or_null("NPCs")
	_check("NPCs节点存在", npcs != null, "")

func _test_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		_check("玩家存在", false, "未找到")
		return
	
	_check("玩家存在", true, "")
	_check("玩家HP > 0", player.get("current_hp") > 0 if "current_hp" in player else false, "")
	_check("玩家max_hp > 0", player.get("max_hp") > 0 if "max_hp" in player else false, "")
	_check("玩家速度 > 0", player.get("speed") > 0 if "speed" in player else false, "")
	_check("玩家有碰撞体", player.has_node("CollisionShape2D"), "")
	_check("玩家有精灵", player.has_node("AnimatedSprite2D"), "")
	
	var hp_bar = player.get("hp_bar_bg")
	_check("玩家HP条存在", hp_bar != null, "")

func _test_enemies() -> void:
	var enemies := get_tree().get_nodes_in_group("enemy")
	_check("敌人已生成", enemies.size() > 0, "数量=%d" % enemies.size())
	_check("敌人数量正确", enemies.size() <= 2, "数量=%d" % enemies.size())
	
	if enemies.size() > 0:
		var e := enemies[0]
		_check("敌人有精灵", e.has_node("AnimatedSprite2D") if e else false, "")
		_check("敌人HP > 0", e.get("current_hp") > 0 if "current_hp" in e else false, "")
		
		var player := get_tree().get_first_node_in_group("player") as Node2D
		if player and e:
			var dist: float = e.global_position.distance_to(player.global_position)
			_check("敌人安全距离", dist >= 80.0, "距离=%.1f" % dist)

func _test_npcs() -> void:
	var merchants := get_tree().get_nodes_in_group("merchant")
	_check("商人存在", merchants.size() > 0, "")
	
	if merchants.size() > 0:
		var m := merchants[0]
		var has_shop := m.has_node("ShopUI") if m else false
		_check("商人有商店UI", has_shop, "")
	
	var npcs := get_tree().get_nodes_in_group("npc")
	_check("NPC存在", npcs.size() > 0, "数量=%d" % npcs.size())

func _test_quest() -> void:
	var qm := get_tree().get_first_node_in_group("quest_manager")
	if not qm:
		_check("任务管理器", false, "未找到")
		return
	
	_check("任务管理器存在", true, "")
	var qname: String = qm.get("quest_name") if "quest_name" in qm else ""
	_check("任务名不为空", qname != "", "任务名=%s" % qname)
	
	var has_chinese: bool = qname.find("启程") >= 0 or qname.find("灰烬委托") >= 0
	_check("任务名称已汉化", has_chinese, "任务名=%s" % qname)

func _test_save() -> void:
	var sm := get_tree().get_first_node_in_group("save_manager")
	_check("存档管理器存在", sm != null, "")
	
	var save_ui := get_tree().get_first_node_in_group("save_ui")
	_check("存档UI存在", save_ui != null, "")

func _test_village() -> void:
	var root := get_tree().current_scene
	if not root:
		_check("村庄场景", false, "场景未加载")
		return
	
	var gen := root.get_node_or_null("TileMapLayer")
	if not gen:
		_check("村庄生成器", false, "节点未找到")
		return
	
	var used: Array = gen.get_used_cells()
	_check("地图有瓦片", used.size() > 0, "瓦片数=%d" % used.size())
	
	# 检查中心广场是否有石砖
	var has_stone: bool = false
	for pos in used:
		if pos.x >= 37 and pos.x <= 42 and pos.y >= 19 and pos.y <= 24:
			var atlas: Vector2i = gen.get_cell_atlas_coords(pos)
			if atlas == Vector2i(2, 0):  # STONE
				has_stone = true
				break
	_check("中心广场有石砖", has_stone, "")

func _test_ui_panels() -> void:
	var inv_ui := get_tree().get_first_node_in_group("inventory_ui")
	_check("背包UI存在", inv_ui != null, "")
	
	var go_ui := get_tree().get_first_node_in_group("game_over_ui")
	_check("死亡面板存在", go_ui != null, "")
	
	var pause := get_tree().get_first_node_in_group("pause_menu")
	_check("暂停菜单存在", pause != null, "")
	
	var settings := get_tree().get_first_node_in_group("settings_ui")
	_check("设置面板存在", settings != null, "")
	
	var qt := get_tree().get_first_node_in_group("quest_tracker_ui")
	_check("任务追踪UI存在", qt != null, "")

func _test_chinese_content() -> void:
	# 检查主菜单场景中的中文文本（如果当前是主菜单）
	var root := get_tree().current_scene
	if root and root.name == "MainMenu":
		var title = root.get_node_or_null("TitleLabel")
		if title:
			var has_cn: bool = title.text.find("中世纪") >= 0
			_check("主菜单标题已汉化", has_cn, "标题=%s" % title.text)
		else:
			_check("主菜单标题已汉化", false, "节点未找到")
	else:
		# 在世界场景中检查
		var merchants := get_tree().get_nodes_in_group("merchant")
		if merchants.size() > 0:
			var m := merchants[0]
			var lines := m.get("dialogue_lines") if "dialogue_lines" in m else []
			var has_cn: bool = false
			for line in lines:
				if line.find("实惠") >= 0 or line.find("剑") >= 0:
					has_cn = true
					break
			_check("商人对话已汉化", has_cn, "对话=%s" % str(lines))
		else:
			_check("商人对话已汉化", false, "商人未找到")

func _exit_tree() -> void:
	if log_file:
		log_file.flush()
		log_file.close()
