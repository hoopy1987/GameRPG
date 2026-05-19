extends Node

## 场景切换管理器 - 处理场景间过渡和玩家状态保持

const FADE_DURATION: float = 0.5

var current_scene_name: String = "world"
var is_transitioning: bool = false
var _pending_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	print("[SceneTransition] 场景切换管理器已加载")

## 切换到指定场景
func change_scene(scene_path: String, target_position: Vector2 = Vector2.ZERO) -> void:
	if is_transitioning:
		push_warning("场景切换正在进行中，忽略重复请求")
		return
	
	is_transitioning = true
	_pending_position = target_position
	
	# 保存玩家状态
	_save_player_state()
	
	# 淡出
	_fade_out()
	await get_tree().create_timer(FADE_DURATION).timeout
	
	# 切换场景
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("场景切换失败: %s" % scene_path)
		is_transitioning = false
		return
	
	# 等待新场景加载完成
	await get_tree().create_timer(0.1).timeout
	
	# 更新当前场景名
	current_scene_name = scene_path.get_file().get_basename()
	
	# 恢复玩家状态
	_restore_player_state()
	
	# 淡入
	_fade_in()
	await get_tree().create_timer(FADE_DURATION).timeout
	
	is_transitioning = false
	print("[SceneTransition] 已切换到场景: %s" % current_scene_name)

func _save_player_state() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	# 将玩家状态存入全局（通过SceneTree的meta）
	get_tree().set_meta("player_hp", player.current_hp if player.get("current_hp") != null else 100)
	get_tree().set_meta("player_max_hp", player.max_hp if player.get("max_hp") != null else 100)
	get_tree().set_meta("player_inventory", player.inventory if player.get("inventory") != null else [])
	get_tree().set_meta("player_equipment", player.equipment if player.get("equipment") != null else {})
	get_tree().set_meta("player_gold", player.gold if player.get("gold") != null else 0)
	get_tree().set_meta("player_xp", player.xp if player.get("xp") != null else 0)
	get_tree().set_meta("player_level", player.level if player.get("level") != null else 1)
	get_tree().set_meta("player_xp_to_next", player.xp_to_next if player.get("xp_to_next") != null else 100)
	get_tree().set_meta("player_base_attack", player.base_attack_damage if player.get("base_attack_damage") != null else 10)
	get_tree().set_meta("player_respawn", player.respawn_position if player.get("respawn_position") != null else Vector2(640, 360))

func _restore_player_state() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	var tree = get_tree()
	if tree.has_meta("player_hp"):
		player.current_hp = tree.get_meta("player_hp")
	if tree.has_meta("player_max_hp"):
		player.max_hp = tree.get_meta("player_max_hp")
	if tree.has_meta("player_inventory"):
		player.inventory = tree.get_meta("player_inventory")
	if tree.has_meta("player_equipment"):
		player.equipment = tree.get_meta("player_equipment")
	if tree.has_meta("player_gold"):
		player.gold = tree.get_meta("player_gold")
	if tree.has_meta("player_xp"):
		player.xp = tree.get_meta("player_xp")
	if tree.has_meta("player_level"):
		player.level = tree.get_meta("player_level")
	if tree.has_meta("player_xp_to_next"):
		player.xp_to_next = tree.get_meta("player_xp_to_next")
	if tree.has_meta("player_base_attack"):
		player.base_attack_damage = tree.get_meta("player_base_attack")
		player.attack_damage = player.base_attack_damage
	if tree.has_meta("player_respawn"):
		player.respawn_position = tree.get_meta("player_respawn")
	
	# 应用位置
	if _pending_position != Vector2.ZERO:
		player.global_position = _pending_position
	
	# 刷新UI
	if player.has_method("update_hp_bar"):
		player.update_hp_bar()
	if player.has_method("update_level_ui"):
		player.update_level_ui()
	if player.has_method("update_equipment_visuals"):
		player.update_equipment_visuals()
	if player.get("inventory_ui") != null and player.inventory_ui != null and player.inventory_ui.has_method("refresh"):
		player.inventory_ui.refresh(player.inventory, player.equipment)
	
	# 1秒无敌保护
	player.invincible_timer = 1.0

func _fade_out() -> void:
	var overlay = _get_or_create_overlay()
	overlay.visible = true
	overlay.modulate = Color(0, 0, 0, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "modulate", Color(0, 0, 0, 1), FADE_DURATION)

func _fade_in() -> void:
	var overlay = _get_or_create_overlay()
	var tween = get_tree().create_tween()
	tween.tween_property(overlay, "modulate", Color(0, 0, 0, 0), FADE_DURATION)
	await tween.finished
	overlay.visible = false

func _get_or_create_overlay() -> ColorRect:
	var existing = get_tree().root.get_node_or_null("TransitionOverlay")
	if existing:
		return existing
	
	var overlay = ColorRect.new()
	overlay.name = "TransitionOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 1)
	overlay.z_index = 9999
	overlay.visible = false
	get_tree().root.add_child(overlay)
	return overlay

## 获取当前场景名称（用于存档）
func get_current_scene_name() -> String:
	return current_scene_name
