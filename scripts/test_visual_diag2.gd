extends SceneTree

# 快速视觉诊断 - 箱桶/小溪/建筑

func _initialize():
	var world = load("res://scenes/world.tscn").instantiate()
	self.root.add_child(world)
	await create_timer(1.5).timeout
	
	print("\n========== 箱桶诊断 ==========")
	var dest_parent = world.get_node_or_null("Destroyables")
	if dest_parent:
		print("Destroyables 子节点数: %d" % dest_parent.get_child_count())
		for d in dest_parent.get_children():
			var sprite = d.get_node_or_null("Sprite2D")
			var col = d.get_node_or_null("CollisionShape2D")
			var tex = sprite.texture if sprite else null
			print("%s | pos=%s | visible=%s | Sprite2D=%s | texture=%s | Collision=%s" % [
				d.name, str(d.position), d.visible,
				"有" if sprite else "无", "有" if tex else "null",
				"有" if col else "无"
			])
			if sprite:
				print("  sprite.scale=%s | modulate=%s | z_index=%d" % [str(sprite.scale), str(sprite.modulate), sprite.z_index])
	else:
		print("❌ Destroyables 不存在")
	
	print("\n========== 小溪诊断 ==========")
	var tile_map = world.get_node_or_null("TileMapLayer")
	if tile_map:
		var water_count = 0
		var water_range = {"min_x":999,"max_x":0,"min_y":999,"max_y":0}
		for x in range(80):
			for y in range(45):
				if tile_map.get_cell_atlas_coords(Vector2i(x,y)) == Vector2i(3,0):
					water_count += 1
					water_range.min_x = min(water_range.min_x, x)
					water_range.max_x = max(water_range.max_x, x)
					water_range.min_y = min(water_range.min_y, y)
					water_range.max_y = max(water_range.max_y, y)
		print("水域tile: %d | 范围: (%d,%d)~(%d,%d)" % [water_count, water_range.min_x, water_range.min_y, water_range.max_x, water_range.max_y])
		var bridge1_cells = []
		for x in range(18, 21):
			bridge1_cells.append(tile_map.get_cell_atlas_coords(Vector2i(x, 21)))
		print("桥1(18-20,21): %s" % str(bridge1_cells))
		var bridge2_cells = []
		for x in range(37, 40):
			bridge2_cells.append(tile_map.get_cell_atlas_coords(Vector2i(x, 40)))
		print("桥2(37-39,40): %s" % str(bridge2_cells))
	else:
		print("❌ TileMapLayer 不存在")
	
	print("\n========== 建筑细节诊断 ==========")
	if tile_map:
		print("砧台(54,9): %s" % str(tile_map.get_cell_atlas_coords(Vector2i(54,9))))
		print("燃料(58,13): %s | (59,13): %s" % [str(tile_map.get_cell_atlas_coords(Vector2i(58,13))), str(tile_map.get_cell_atlas_coords(Vector2i(59,13)))])
		var bar = 0
		for x in range(35,46):
			if tile_map.get_cell_atlas_coords(Vector2i(x,31)) == Vector2i(2,0):
				bar += 1
		print("吧台STONE: %d tiles" % bar)
		var stage = false
		for x in range(43,47):
			for y in range(35,38):
				if tile_map.get_cell_atlas_coords(Vector2i(x,y)) == Vector2i(2,0):
					stage = true
		print("舞台: %s" % str(stage))
		print("祭坛(13,9):%s (14,9):%s (13,10):%s (14,10):%s" % [
			str(tile_map.get_cell_atlas_coords(Vector2i(13,9))),
			str(tile_map.get_cell_atlas_coords(Vector2i(14,9))),
			str(tile_map.get_cell_atlas_coords(Vector2i(13,10))),
			str(tile_map.get_cell_atlas_coords(Vector2i(14,10)))
		])
		print("长椅(10,12):%s (16,14):%s" % [str(tile_map.get_cell_atlas_coords(Vector2i(10,12))), str(tile_map.get_cell_atlas_coords(Vector2i(16,14)))])
	
	print("\n========== 篝火粒子诊断 ==========")
	var campfire = world.get_node_or_null("Campfire")
	if campfire:
		var fp = campfire.get_node_or_null("FireParticles")
		if fp:
			print("FireParticles: emitting=%s | amount=%d | lifetime=%.1f | texture=%s" % [fp.emitting, fp.amount, fp.lifetime, "有" if fp.texture else "null"])
			print("  color=%s | position=%s" % [str(fp.color), str(fp.position)])
		else:
			print("❌ 无 FireParticles")
	else:
		print("❌ 无 Campfire")
	
	print("\n========== 诊断结束 ==========\n")
	quit(0)
