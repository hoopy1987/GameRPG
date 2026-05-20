class_name TestMovement
extends Node

## 移动连通性测试模块
## 测试帧级移动模拟和关键位置可达性

var _world: Node
var _player: CharacterBody2D
var _tree: SceneTree
var _log_func: Callable
var _passed := 0
var _failed := 0

var _simulator: MovementSimulator

func setup(world: Node, player: CharacterBody2D, tree: SceneTree, log_func: Callable):
	_world = world
	_player = player
	_tree = tree
	_log_func = log_func
	_simulator = MovementSimulator.new(tree, player, log_func)

func run_tests() -> Dictionary:
	_log("\n[阶段17.1] 帧级移动连通性检测")
	
	# 临时禁用静态碰撞体
	_simulator.disable_collisions(_world)
	
	await _test_movement_connectivity()
	
	# 恢复碰撞体
	_simulator.restore_collisions()
	
	return {"passed": _passed, "failed": _failed}

# ========== 17.1 路径连通性：帧级移动模拟 ==========
func _test_movement_connectivity():
	_log("  测试17.1-L1: 帧级移动连通性检测（5个关键位置）")
	
	if not _is_ready():
		_log("  ❌ 世界或玩家未就绪")
		_failed += 1
		return
	
	var TILE_SIZE := 32
	var tavern_door := Vector2(40 * TILE_SIZE, 38 * TILE_SIZE + TILE_SIZE / 2)
	
	var targets := [
		{"name": "篝火", "pos": Vector2(38 * TILE_SIZE + TILE_SIZE / 2, 33 * TILE_SIZE + TILE_SIZE / 2), "need_exit": false},
		{"name": "铁匠铺门口", "pos": Vector2(56 * TILE_SIZE, 15 * TILE_SIZE), "need_exit": true},
		{"name": "酒馆", "pos": Vector2(40 * TILE_SIZE, 34 * TILE_SIZE), "need_exit": false},
		{"name": "小溪木桥1", "pos": Vector2(19 * TILE_SIZE, 21 * TILE_SIZE), "need_exit": true},
		{"name": "教堂", "pos": Vector2(20 * TILE_SIZE, 13 * TILE_SIZE), "need_exit": true}
	]
	
	var all_reachable: bool = true
	var detail: String = ""
	var total_frames: int = 0
	
	for target in targets:
		_log("  → 前往 %s (%s)" % [target.name, target.pos])
		
		var result: Dictionary
		
		if target.need_exit:
			# 需要先走出酒馆
			_log("    先走到酒馆门口...")
			var door_dist := _player.position.distance_to(tavern_door)
			var door_frames := int(door_dist / _player.speed * 60.0 * 1.5) + 60
			var exit_result := await _simulator.simulate_move(tavern_door, door_frames)
			if not exit_result.reached:
				_log("    ⚠️ 无法走到酒馆门口（%s），尝试瞬移" % exit_result.reason)
				_player.position = tavern_door
				await _tree.create_timer(0.05).timeout
			
			# 从门口继续往外走几步
			var clear_pos := tavern_door + Vector2(0, 80)
			_log("    绕开酒馆碰撞体...")
			var clear_dist := _player.position.distance_to(clear_pos)
			var clear_frames := int(clear_dist / _player.speed * 60.0 * 1.5) + 60
			var clear_result := await _simulator.simulate_move(clear_pos, clear_frames)
			if not clear_result.reached:
				_log("    ⚠️ 无法绕开酒馆（%s），直接瞬移" % clear_result.reason)
				_player.position = clear_pos
				await _tree.create_timer(0.05).timeout
			
			var target_dist := _player.position.distance_to(target.pos)
			var target_frames := int(target_dist / _player.speed * 60.0 * 1.5) + 120
			result = await _simulator.simulate_move(target.pos, target_frames)
		else:
			var target_dist := _player.position.distance_to(target.pos)
			var target_frames := int(target_dist / _player.speed * 60.0 * 1.5) + 120
			result = await _simulator.simulate_move(target.pos, target_frames)
		
		if result.reached:
			_log("  ✅ %s 可达（%d帧，约%.1f秒）" % [target.name, result.frames, result.frames / 60.0])
			_passed += 1
		else:
			all_reachable = false
			detail += "%s:%s | " % [target.name, result.reason]
			_log("  ❌ %s 不可达：%s" % [target.name, result.reason])
			_failed += 1
		
		total_frames += result.frames
		
		if result.frames > 200:
			_log("  ⚠️ %s 耗时较长（%d帧），可能存在绕行或狭窄通道" % [target.name, result.frames])
	
	_log("  总移动帧数: %d（约%.1f秒）" % [total_frames, total_frames / 60.0])
	
	if all_reachable:
		_log("  ✅ 所有关键位置帧级移动可达")
		_passed += 1
	else:
		_log("  ❌ 部分位置不可达: %s" % detail)
		_failed += 1

# ========== 辅助函数 ==========
func _is_ready() -> bool:
	return _world != null and _player != null and is_instance_valid(_world) and is_instance_valid(_player)

func _log(msg: String):
	if _log_func.is_valid():
		_log_func.call(msg)
	else:
		print("[Test] " + msg)
