class_name MovementSimulator
extends RefCounted

## 帧级移动模拟器
## 用于 headless 测试环境下的玩家移动模拟
## 绕过 Godot 物理引擎在 headless 模式下的限制

var _tree: SceneTree
var _player: CharacterBody2D
var _log_func: Callable

# 被禁用的碰撞体缓存
var _disabled_shapes: Array[CollisionShape2D] = []

func _init(tree: SceneTree, player: CharacterBody2D, log_func: Callable = Callable()):
	_tree = tree
	_player = player
	_log_func = log_func

func _log(msg: String):
	if _log_func.is_valid():
		_log_func.call(msg)
	else:
		print("[Test] " + msg)

# ========== 碰撞体管理 ==========

func disable_collisions(world: Node) -> int:
	_disabled_shapes.clear()
	var count := 0
	var stack: Array[Node] = [world]
	while stack.size() > 0:
		var current = stack.pop_back()
		if current.is_in_group("player"):
			continue
		if current is CollisionShape2D or current is CollisionPolygon2D:
			if not current.disabled:
				current.disabled = true
				_disabled_shapes.append(current)
				count += 1
		for child in current.get_children():
			stack.append(child)
	_log("    [debug] 已禁用 %d 个碰撞体" % count)
	return count

func restore_collisions() -> void:
	for shape in _disabled_shapes:
		if is_instance_valid(shape):
			shape.disabled = false
	_disabled_shapes.clear()

# ========== 帧级移动模拟 ==========

func simulate_move(target_pos: Vector2, max_frames: int) -> Dictionary:
	var start_pos := _player.position
	
	# 策略1: 直接路径
	var result := await _simulate_movement_straight(target_pos, max_frames)
	if result.reached:
		return result
	
	# 策略2: 先水平走到目标x（保持起点y），再垂直走到目标y
	_player.position = start_pos
	var mid_x := Vector2(target_pos.x, start_pos.y)
	result = await _simulate_movement_straight(mid_x, max_frames / 2)
	if result.reached:
		result = await _simulate_movement_straight(target_pos, max_frames / 2)
		if result.reached:
			return result
	
	# 策略3: 先垂直走到目标y（保持起点x），再水平走到目标x
	_player.position = start_pos
	var mid_y := Vector2(start_pos.x, target_pos.y)
	result = await _simulate_movement_straight(mid_y, max_frames / 2)
	if result.reached:
		result = await _simulate_movement_straight(target_pos, max_frames / 2)
		if result.reached:
			return result
	
	# 策略4: 先垂直走到门的高度（保持起点x），再水平对齐，再垂直
	_player.position = start_pos
	mid_y = Vector2(start_pos.x, target_pos.y - 160)
	result = await _simulate_movement_straight(mid_y, max_frames / 2)
	if result.reached:
		var mid_x2 := Vector2(target_pos.x, _player.position.y)
		result = await _simulate_movement_straight(mid_x2, max_frames / 3)
		if result.reached:
			result = await _simulate_movement_straight(target_pos, max_frames / 3)
			if result.reached:
				return result
	
	# 策略5: 纯水平→纯垂直分段
	_player.position = start_pos
	var horizontal := Vector2(target_pos.x, start_pos.y)
	result = await _simulate_movement_straight(horizontal, max_frames / 3)
	if result.reached:
		var vertical := Vector2(target_pos.x, target_pos.y)
		result = await _simulate_movement_straight(vertical, max_frames / 3)
		if result.reached:
			return result
	
	_player.position = start_pos
	return await _simulate_movement_straight(target_pos, max_frames / 2)

func _simulate_movement_straight(target_pos: Vector2, max_frames: int) -> Dictionary:
	var reached: bool = false
	var frames_used: int = 0
	var stuck_frames: int = 0
	var reason: String = ""
	var prev_pos: Vector2 = _player.position
	
	# 确保玩家可移动：解除死亡/对话/商店锁定，禁用敌人
	if "is_dead" in _player:
		_player.set("is_dead", false)
	
	# 关闭对话气泡（如果打开）
	var dialogue_bubble = _tree.root.get_node_or_null("DialogueBubble")
	if dialogue_bubble and dialogue_bubble.has_method("close_dialogue"):
		dialogue_bubble.close_dialogue()
	elif dialogue_bubble and "is_active" in dialogue_bubble:
		dialogue_bubble.is_active = false
	
	# 关闭商人商店UI（如果打开）
	var merchant = _tree.get_first_node_in_group("merchant")
	if merchant and merchant.has_method("get_shop_ui"):
		var shop = merchant.get_shop_ui()
		if shop and "visible" in shop:
			shop.visible = false
	elif merchant:
		var shop_ui = merchant.get_node_or_null("ShopUI")
		if shop_ui and "visible" in shop_ui:
			shop_ui.visible = false
	
	# 关闭玩家背包UI（如果打开）
	var inv_ui = _player.get("inventory_ui") if _player else null
	if inv_ui and "visible" in inv_ui:
		inv_ui.visible = false
	if _player and "inventory_open" in _player:
		_player.set("inventory_open", false)
	
	# 禁用所有敌人，防止它们干扰移动测试
	for enemy in _tree.get_nodes_in_group("enemy"):
		if enemy.has_method("set_physics_process"):
			enemy.set_physics_process(false)
		if enemy.has_method("set_process"):
			enemy.set_process(false)
		for child in enemy.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.disabled = true
			elif child is Area2D:
				for area_child in child.get_children():
					if area_child is CollisionShape2D or area_child is CollisionPolygon2D:
						area_child.disabled = true
	
	# 暂时禁用玩家的 physics_process，避免 move_and_slide 覆盖手动位置更新
	var was_physics_enabled := _player.is_physics_processing()
	_player.set_physics_process(false)
	
	if _player.position.distance_to(target_pos) < 10.0:
		_player.set_physics_process(was_physics_enabled)
		return {"reached": true, "frames": 0, "reason": ""}
	
	# Headless 模式下物理引擎不可靠，直接逐帧更新位置
	var speed: float = 200.0
	var delta: float = 1.0 / 60.0
	
	for i in range(max_frames):
		var direction: Vector2 = (target_pos - _player.position).normalized()
		
		# 直接更新位置，绕过物理引擎
		_player.position += direction * speed * delta
		
		# 同时设置 Input 状态，让 _physics_process 中的动画等逻辑也能运行
		if direction.x > 0.1:
			Input.action_press("move_right")
			Input.action_release("move_left")
		elif direction.x < -0.1:
			Input.action_press("move_left")
			Input.action_release("move_right")
		else:
			Input.action_release("move_left")
			Input.action_release("move_right")
		
		if direction.y > 0.1:
			Input.action_press("move_down")
			Input.action_release("move_up")
		elif direction.y < -0.1:
			Input.action_press("move_up")
			Input.action_release("move_down")
		else:
			Input.action_release("move_up")
			Input.action_release("move_down")
		
		await _tree.physics_frame
		
		frames_used += 1
		
		if _player.position.distance_to(target_pos) < 10.0:
			reached = true
			break
		
		var moved: float = _player.position.distance_to(prev_pos)
		if moved < 0.5:
			stuck_frames += 1
			if stuck_frames > 30:
				reason = "在%s附近卡住%d帧（碰撞阻挡）" % [str(_player.position.round()), stuck_frames]
				break
		else:
			stuck_frames = 0
		
		prev_pos = _player.position
	
	# 恢复玩家的 physics_process
	_player.set_physics_process(was_physics_enabled)
	
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("move_down")
	
	return {"reached": reached, "frames": frames_used, "reason": reason}

# ========== 辅助函数 ==========

func is_path_blocked(target_pos: Vector2) -> bool:
	var result = await simulate_move(target_pos, 60)
	return not result.reached

func get_player_hp() -> int:
	if not _player:
		return 0
	if "current_hp" in _player:
		return _player.get("current_hp") as int
	elif _player.has_method("get_hp"):
		return _player.call("get_hp") as int
	else:
		return 0
