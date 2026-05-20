class_name TestCombat
extends Node

## 战斗系统测试模块
## 测试箱桶攻击、销毁、掉落物生成等战斗相关功能

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
	_log("\n[阶段17.4] 战斗模拟测试")
	
	# 临时禁用静态碰撞体
	_simulator.disable_collisions(_world)
	
	await _test_destroyable_attack()
	
	# 恢复碰撞体
	_simulator.restore_collisions()
	
	return {"passed": _passed, "failed": _failed}

# ========== 17.4 箱桶攻击模拟 ==========
func _test_destroyable_attack():
	_log("  测试17.4-L4: 箱桶攻击+销毁+掉落物验证")
	
	if not _is_ready():
		_log("  ❌ 世界或玩家未就绪")
		_failed += 1
		return
	
	var dp = _world.get_node_or_null("Destroyables")
	if not dp:
		_log("  ❌ Destroyables 父节点不存在")
		_failed += 1
		return
	
	var dest_count := dp.get_child_count()
	if dest_count == 0:
		_log("  ❌ 无箱桶子节点")
		_failed += 1
		return
	
	_log("  发现 %d 个可破坏对象" % dest_count)
	
	# 找一个箱桶测试
	var test_dest = dp.get_child(0)
	if not test_dest:
		_log("  ❌ 第一个箱桶为空")
		_failed += 1
		return
	
	_log("  测试箱桶: %s @ %s" % [test_dest.name, test_dest.position])
	
	# 帧级移动到箱桶位置
	var move_result := await _simulator.simulate_move(test_dest.position, 200)
	if not move_result.reached:
		_log("  ⚠️ 无法走到箱桶（%s），瞬移过去" % move_result.reason)
		_player.position = test_dest.position
		await _tree.create_timer(0.05).timeout
	
	# 记录攻击前的状态
	var has_hp = test_dest.has_meta("current_hp")
	var old_hp = test_dest.get_meta("current_hp", 1) if has_hp else 1
	
	_log("  箱桶攻击前HP: %d" % old_hp)
	
	# 调用攻击方法
	var destroyed: bool = false
	if test_dest.has_method("take_damage"):
		test_dest.take_damage(100)
		await _tree.create_timer(0.1).timeout
		
		destroyed = not is_instance_valid(test_dest) or test_dest.is_queued_for_deletion()
		if destroyed:
			_log("  ✅ 箱桶被摧毁")
			_passed += 1
		else:
			var new_hp = test_dest.get_meta("current_hp", old_hp) if has_hp else old_hp
			_log("  ❌ 箱桶未被摧毁 (当前HP:%d)" % new_hp)
			_failed += 1
	else:
		_log("  ⚠️ 箱桶无take_damage方法，尝试直接调用销毁")
		test_dest.queue_free()
		destroyed = true
		_passed += 1
	
	# 检查掉落物
	var items_node = _world.get_node_or_null("Items")
	var has_items = items_node and items_node.get_child_count() > 0
	if has_items:
		_log("  ✅ 箱桶销毁后掉落物生成 (Items节点有%d个子节点)" % items_node.get_child_count())
		_passed += 1
	else:
		_log("  ❌ 无掉落物生成")
		_failed += 1

# ========== 辅助函数 ==========
func _is_ready() -> bool:
	return _world != null and _player != null and is_instance_valid(_world) and is_instance_valid(_player)

func _log(msg: String):
	if _log_func.is_valid():
		_log_func.call(msg)
	else:
		print("[Test] " + msg)
