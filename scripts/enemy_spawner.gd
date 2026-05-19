extends Node2D

@export var enemy_scene: PackedScene
@export var enemy_count: int = 2
@export var spawn_area: Rect2 = Rect2(200, 100, 800, 500)
@export var enemy_types: Array[String] = ["slime", "slime", "goblin"]

func _ready() -> void:
	spawn_enemies()

func spawn_enemies() -> void:
	if not enemy_scene:
		push_warning("敌人生成器：未分配敌人场景")
		return
	
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var safe_distance: float = 120.0  # 安全距离，避免出生即战斗
	
	for i in range(enemy_count):
		var enemy := enemy_scene.instantiate()
		if enemy:
			# 找安全位置（离玩家至少 safe_distance）
			var pos := Vector2.ZERO
			var attempts: int = 0
			while attempts < 50:
				pos = Vector2(
					randf_range(spawn_area.position.x, spawn_area.end.x),
					randf_range(spawn_area.position.y, spawn_area.end.y)
				)
				if player and pos.distance_to(player.global_position) >= safe_distance:
					break
				attempts += 1
			
			enemy.position = pos
			
			# Load enemy data from JSON
			var type_id := enemy_types[i % enemy_types.size()]
			var data: Dictionary = DataLoader.get_enemy(type_id)
			if not data.is_empty():
				if "texture_path" in enemy:
					enemy.texture_path = data.get("texture_path", enemy.texture_path)
				if "max_hp" in enemy:
					enemy.max_hp = data.get("max_hp", enemy.max_hp)
				if "speed" in enemy:
					enemy.speed = data.get("speed", enemy.speed)
				if "attack_damage" in enemy:
					enemy.attack_damage = data.get("attack_damage", enemy.attack_damage)
				if "attack_range" in enemy:
					enemy.attack_range = data.get("attack_range", enemy.attack_range)
				if "detection_range" in enemy:
					enemy.detection_range = data.get("detection_range", enemy.detection_range)
				# Store metadata for death rewards
				enemy.set_meta("enemy_type", type_id)
				
			add_child(enemy)
	
	print("已生成 %d 个敌人" % enemy_count)
