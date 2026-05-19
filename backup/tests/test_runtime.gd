extends Node

const LOG_PATH := "user://runtime_test_log.txt"

var log_file: FileAccess = null
var test_passed: int = 0
var test_failed: int = 0
var player_ref: Node = null

func _ready() -> void:
	# Delay to ensure scene fully loaded
	await get_tree().create_timer(0.3).timeout
	
	if FileAccess.file_exists(LOG_PATH):
		DirAccess.remove_absolute(LOG_PATH)
	
	log_file = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if not log_file:
		push_error("Failed to open runtime test log")
		return
	
	_log_line("=== RPG Runtime Test Report ===")
	_log_line("Date: " + Time.get_datetime_string_from_system(false, true))
	_log_line("")
	
	player_ref = get_tree().get_first_node_in_group("player")
	
	_test_player_init()
	_test_enemy_spawn()
	_test_combat_system()
	_test_merchant()
	_test_inventory_system()
	_test_quest_system()
	_test_save_system()
	_test_ui_system()
	_test_scene_fader()
	_test_sound_system()
	_test_data_loader()
	
	_log_line("")
	_log_line("=== Summary ===")
	_log_line("Passed: %d" % test_passed)
	_log_line("Failed: %d" % test_failed)
	_log_line("Overall: %s" % ("ALL PASS" if test_failed == 0 else "HAS FAILURES"))
	log_file.close()
	
	print("=== Test Complete ===")
	print("Passed: %d, Failed: %d" % [test_passed, test_failed])
	print("Log: %s" % LOG_PATH)
	
	# Exit game after test (for automated runs)
	if test_failed == 0:
		print("ALL TESTS PASSED - Exiting")
	else:
		print("SOME TESTS FAILED - Exiting with report")
	
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func _log_line(text: String) -> void:
	if log_file:
		log_file.store_line(text)
	print(text)

func _test(name: String, condition: bool, detail: String = "") -> void:
	var status := "PASS" if condition else "FAIL"
	var line := "[%s] %s" % [status, name]
	if detail != "":
		line += " | %s" % detail
	_log_line(line)
	if condition:
		test_passed += 1
	else:
		test_failed += 1

func _test_player_init() -> void:
	_log_line("--- 1. Player Initialization ---")
	if not player_ref:
		_test("Player exists", false, "Not found in scene")
		return
	
	_test("Player exists", true)
	_test("Player HP > 0", player_ref.current_hp > 0, "HP=%d" % player_ref.current_hp)
	_test("Player max_hp > 0", player_ref.max_hp > 0, "max_hp=%d" % player_ref.max_hp)
	_test("Player position valid", player_ref.global_position.length() > 0, "pos=%s" % str(player_ref.global_position))
	_test("Player level >= 1", player_ref.level >= 1, "level=%d" % player_ref.level)
	_test("Player gold >= 0", player_ref.gold >= 0, "gold=%d" % player_ref.gold)
	_test("Player invincible on start", player_ref.invincible_timer > 0, "timer=%.1f" % player_ref.invincible_timer)
	_test("Player has collision", player_ref.has_node("CollisionShape2D"))
	_test("Player has sprite", player_ref.has_node("AnimatedSprite2D"))

func _test_enemy_spawn() -> void:
	_log_line("--- 2. Enemy Spawn ---")
	var enemies := get_tree().get_nodes_in_group("enemy")
	_test("Enemies spawned", enemies.size() > 0, "count=%d" % enemies.size())
	_test("Enemy count <= 2", enemies.size() <= 2, "count=%d" % enemies.size())
	
	if enemies.size() > 0 and player_ref:
		for e in enemies:
			var dist := e.global_position.distance_to(player_ref.global_position) as float
			_test("Enemy safe distance", dist >= 100.0, "dist=%.1f" % dist)
			_test("Enemy HP > 0", e.current_hp > 0 if "current_hp" in e else false, "hp=%d" % (e.current_hp if "current_hp" in e else 0))
			_test("Enemy has sprite", e.has_node("AnimatedSprite2D") if e else false)

func _test_combat_system() -> void:
	_log_line("--- 3. Combat System ---")
	if not player_ref:
		_test("Player for combat", false, "Not found")
		return
	
	_test("Player has attack_damage", "attack_damage" in player_ref, "damage=%d" % (player_ref.attack_damage if "attack_damage" in player_ref else 0))
	_test("Player has attack_range", "attack_range" in player_ref, "range=%.1f" % (player_ref.attack_range if "attack_range" in player_ref else 0))
	_test("Player has INVINCIBLE_DURATION", "INVINCIBLE_DURATION" in player_ref, "duration=%.2f" % (player_ref.INVINCIBLE_DURATION if "INVINCIBLE_DURATION" in player_ref else 0))
	
	var enemies := get_tree().get_nodes_in_group("enemy")
	if enemies.size() > 0:
		var e = enemies[0]
		_test("Enemy has attack_damage", "attack_damage" in e, "damage=%d" % (e.attack_damage if "attack_damage" in e else 0))
		_test("Enemy has attack_range", "attack_range" in e, "range=%.1f" % (e.attack_range if "attack_range" in e else 0))
		_test("Enemy has attack_cooldown", "attack_cooldown" in e, "cooldown=%.1f" % (e.attack_cooldown if "attack_cooldown" in e else 0))
	else:
		_test("Enemy for combat test", false, "No enemies")

func _test_merchant() -> void:
	_log_line("--- 4. Merchant System ---")
	var merchants := get_tree().get_nodes_in_group("merchant")
	_test("Merchant exists", merchants.size() > 0, "count=%d" % merchants.size())
	
	if merchants.size() > 0:
		var m = merchants[0]
		_test("Merchant has shop_ui", m.has_node("ShopUI") if m else false)
		_test("Merchant has collision", m.has_node("CollisionShape2D") if m else false)
		
		var shop_ui = m.get_node_or_null("ShopUI")
		if shop_ui and shop_ui.has_method("setup_shop"):
			_test("ShopUI setup method", true)
			var items := shop_ui.shop_items as Array if "shop_items" in shop_ui else []
			_test("Shop has items", items.size() > 0, "count=%d" % items.size())
		else:
			_test("ShopUI setup", false, "Missing")

func _test_inventory_system() -> void:
	_log_line("--- 5. Inventory System ---")
	if not player_ref:
		_test("Player for inventory", false)
		return
	
	_test("Inventory array", "inventory" in player_ref and player_ref.inventory is Array, "size=%d" % player_ref.inventory.size())
	_test("Equipment dict", "equipment" in player_ref and player_ref.equipment is Dictionary)
	_test("Gold count", "gold" in player_ref, "gold=%d" % player_ref.gold)
	_test("add_item method", player_ref.has_method("add_item"))
	_test("equip_item method", player_ref.has_method("equip_item"))
	_test("unequip_slot method", player_ref.has_method("unequip_slot"))
	
	var inv_ui = get_tree().get_first_node_in_group("inventory_ui")
	_test("InventoryUI exists", inv_ui != null)
	if inv_ui:
		var grid = inv_ui.get_node_or_null("Panel/ScrollContainer/ItemGrid")
		_test("Inventory grid", grid != null)
		_test("Equip slots", inv_ui.equip_slots.size() == 4 if "equip_slots" in inv_ui else false, "slots=%d" % (inv_ui.equip_slots.size() if "equip_slots" in inv_ui else 0))

func _test_quest_system() -> void:
	_log_line("--- 6. Quest System ---")
	var quest_mgr := get_tree().get_first_node_in_group("quest_manager")
	_test("QuestManager exists", quest_mgr != null)
	
	if quest_mgr:
		_test("Quest name set", quest_mgr.quest_name != "" if "quest_name" in quest_mgr else false, "name=%s" % (quest_mgr.quest_name if "quest_name" in quest_mgr else "N/A"))
		_test("Quest not completed", not quest_mgr.completed if "completed" in quest_mgr else false)
		_test("Quest kill_count", quest_mgr.kill_count >= 0 if "kill_count" in quest_mgr else false, "kills=%d" % (quest_mgr.kill_count if "kill_count" in quest_mgr else 0))
		_test("Quest required_kills", quest_mgr.required_kills > 0 if "required_kills" in quest_mgr else false, "req=%d" % (quest_mgr.required_kills if "required_kills" in quest_mgr else 0))
		_test("Quest register_kill method", quest_mgr.has_method("register_kill"))
		_test("Quest register_npc_talk method", quest_mgr.has_method("register_npc_talk"))
	
	var qt := get_tree().get_first_node_in_group("quest_tracker_ui")
	_test("QuestTrackerUI exists", qt != null)

func _test_save_system() -> void:
	_log_line("--- 7. Save System ---")
	var save_mgr := get_tree().get_first_node_in_group("save_manager")
	_test("SaveManager exists", save_mgr != null)
	
	if save_mgr:
		_test("SaveManager save_game method", save_mgr.has_method("save_game"))
		_test("SaveManager load_game method", save_mgr.has_method("load_game"))
		_test("SaveManager has_save method", save_mgr.has_method("has_save"))
		_test("SaveManager delete_save method", save_mgr.has_method("delete_save"))
		_test("SaveManager get_save_info method", save_mgr.has_method("get_save_info"))
		_test("SaveManager has_any_save method", save_mgr.has_method("has_any_save"))
	
	var save_ui = get_tree().get_first_node_in_group("save_ui")
	_test("SaveUI exists", save_ui != null)
	if save_ui:
		_test("SaveUI hidden initially", not save_ui.visible)

func _test_ui_system() -> void:
	_log_line("--- 8. UI System ---")
	
	# GameOverUI
	var game_over = get_tree().get_first_node_in_group("game_over_ui")
	_test("GameOverUI exists", game_over != null)
	if game_over:
		var panel = game_over.get_node_or_null("Panel")
		_test("GameOverUI Panel hidden", not panel.visible if panel else false)
		var overlay = game_over.get_node_or_null("Overlay")
		_test("GameOverUI Overlay hidden", not overlay.visible if overlay else false)
	
	# PauseMenu
	var pause = get_tree().get_first_node_in_group("pause_menu")
	_test("PauseMenu exists", pause != null)
	if pause:
		var pause_panel = pause.get_node_or_null("Panel")
		_test("PauseMenu hidden", not pause_panel.visible if pause_panel else false)
	
	# SettingsUI
	var settings = get_tree().get_first_node_in_group("settings_ui")
	_test("SettingsUI exists", settings != null)
	if settings:
		var settings_panel = settings.get_node_or_null("Panel")
		_test("SettingsUI hidden", not settings_panel.visible if settings_panel else false)
	
	# InventoryUI (attached to player)
	if player_ref and player_ref.has_node("InventoryUI"):
		var inv = player_ref.get_node("InventoryUI")
		_test("Player InventoryUI attached", inv != null)
	else:
		_test("Player InventoryUI attached", false)
	
	# ShopUI (attached to merchant)
	var merchants := get_tree().get_nodes_in_group("merchant")
	if merchants.size() > 0:
		var m = merchants[0]
		var shop = m.get_node_or_null("ShopUI")
		_test("Merchant ShopUI attached", shop != null)
		if shop:
			_test("ShopUI hidden", not shop.visible)
	else:
		_test("Merchant ShopUI", false, "No merchant")

func _test_scene_fader() -> void:
	_log_line("--- 9. Scene Fader ---")
	var fader = get_tree().get_first_node_in_group("scene_fader")
	_test("SceneFader exists", fader != null)
	if fader:
		_test("SceneFader has fade_out", fader.has_method("fade_out"))
		_test("SceneFader has fade_in", fader.has_method("fade_in"))
		_test("SceneFader CanvasLayer", fader is CanvasLayer)
		_test("SceneFader ColorRect", fader.has_node("ColorRect"))
		if fader.has_node("ColorRect"):
			var cr = fader.get_node("ColorRect")
			_test("Fader alpha=0 initially", cr.color.a == 0.0, "a=%.2f" % cr.color.a)

func _test_sound_system() -> void:
	_log_line("--- 10. Sound System ---")
	var sound_mgr := get_tree().get_first_node_in_group("sound_manager")
	if not sound_mgr:
		var root = get_tree().root
		if root.has_node("SoundManager"):
			sound_mgr = root.get_node("SoundManager")
	
	_test("SoundManager exists", sound_mgr != null)
	if sound_mgr:
		_test("SoundManager BGM player", "bgm_player" in sound_mgr)
		_test("SoundManager SFX player", "sfx_player" in sound_mgr)
		_test("SoundManager play_sfx method", sound_mgr.has_method("play_sfx"))
		_test("SoundManager play_bgm method", sound_mgr.has_method("play_bgm"))
		_test("SoundManager set_bgm_volume method", sound_mgr.has_method("set_bgm_volume_db"))
		_test("SoundManager set_sfx_volume method", sound_mgr.has_method("set_sfx_volume_db"))

func _test_data_loader() -> void:
	_log_line("--- 11. Data Loader ---")
	var data_loader := get_tree().get_first_node_in_group("data_loader")
	if not data_loader:
		var root = get_tree().root
		if root.has_node("DataLoader"):
			data_loader = root.get_node("DataLoader")
	
	_test("DataLoader exists", data_loader != null)
	if data_loader and data_loader.has_method("get_enemies"):
		var enemies := data_loader.get_enemies() as Array
		_test("Enemies JSON loaded", enemies.size() > 0, "count=%d" % enemies.size())
		var items := data_loader.get_items() as Array
		_test("Items JSON loaded", items.size() > 0, "count=%d" % items.size())
		var quests := data_loader.get_quests() as Array
		_test("Quests JSON loaded", quests.size() > 0, "count=%d" % quests.size())
	else:
		_test("DataLoader methods", false, "Missing get_enemies")
