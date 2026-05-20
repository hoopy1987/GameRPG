extends SceneTree

# 视觉诊断脚本 - 检查节点存在但不可见的原因

func _initialize():
	var world = load("res://scenes/world.tscn").instantiate()
	self.root.add_child(world)
	await create_timer(1.5).timeout
	
	print("\n========== 视觉诊断报告 ==========\n")
	
	# 1. 调查点
	print("【调查点 InvestigationPoints】")
	var ip_parent = world.get_node_or_null("InvestigationPoints")
	if ip_parent:
		print("  父节点存在，子节点数: %d" % ip_parent.get_child_count())
		for ip in ip_parent.get_children():
			print("  ├─ %s" % ip.name)
			print("  │   position: %s" % str(ip.position))
			print("  │   visible: %s | modulate: %s | z_index: %d" % [ip.visible, str(ip.modulate), ip.z_index])
			for c in ip.get_children():
				print("  │   ├─ %s (%s)" % [c.name, c.get_class()])
				if c is Label:
					print("  │   │   text: '%s' | font_color: %s | font_size: %d" % [c.text, str(c.get_theme_color("font_color")), c.get_theme_font_size("font_size")])
					print("  │   │   visible: %s | modulate: %s" % [c.visible, str(c.modulate)])
				if c is CollisionShape2D:
					print("  │   │   shape: %s" % str(c.shape))
	else:
		print("  ❌ 父节点不存在")
	
	# 2. 篝火
	print("\n【篝火 Campfire】")
	var campfire = world.get_node_or_null("Campfire")
	if campfire:
		print("  存在 | position: %s | visible: %s | z_index: %d" % [str(campfire.position), campfire.visible, campfire.z_index])
		for c in campfire.get_children():
			print("  ├─ %s (%s)" % [c.name, c.get_class()])
			print("  │   position: %s | visible: %s | modulate: %s" % [str(c.position), c.visible, str(c.modulate)])
			if c is CPUParticles2D:
				print("  │   emitting: %s | amount: %d | texture: %s" % [c.emitting, c.amount, str(c.texture)])
			if c is Label:
				print("  │   text: '%s' | font_color: %s" % [c.text, str(c.get_theme_color("font_color"))])
	else:
		print("  ❌ 不存在")
	
	# 3. 可破坏箱桶
	print("\n【可破坏箱桶 Destroyables】")
	var dest_parent = world.get_node_or_null("Destroyables")
	if dest_parent:
		print("  父节点存在，子节点数: %d" % dest_parent.get_child_count())
		for d in dest_parent.get_children():
			print("  ├─ %s" % d.name)
			print("  │   position: %s | visible: %s | z_index: %d | modulate: %s" % [str(d.position), d.visible, d.z_index, str(d.modulate)])
			var sprite = d.get_node_or_null("Sprite2D")
			if sprite:
				print("  │   Sprite2D: position=%s scale=%s visible=%s texture=%s" % [str(sprite.position), str(sprite.scale), sprite.visible, "有效" if sprite.texture else "null"])
			else:
				print("  │   ❌ 无Sprite2D")
	else:
		print("  ❌ 父节点不存在")
	
	# 4. 小溪 - 检查水域tile位置
	print("\n【小溪/水域 WATER tiles】")
	var tile_map = world.get_node_or_null("TileMapLayer")
	if tile_map:
		var water_positions = []
		for x in range(80):
			for y in range(45):
				var cell = tile_map.get_cell_atlas_coords(Vector2i(x, y))
				if cell == Vector2i(3, 0):  # WATER
					water_positions.append(Vector2i(x, y))
		print("  水域tile数量: %d" % water_positions.size())
		if water_positions.size() > 0:
			print("  水域范围: (%d,%d) ~ (%d,%d)" % [water_positions[0].x, water_positions[0].y, water_positions[-1].x, water_positions[-1].y])
			print("  前5个tile位置: %s" % str(water_positions.slice(0, 5)))
			# 检查桥的位置
			var bridge1 = []
			var bridge2 = []
			for x in range(18, 21):
				bridge1.append(tile_map.get_cell_atlas_coords(Vector2i(x, 21)))
			for x in range(37, 40):
				bridge2.append(tile_map.get_cell_atlas_coords(Vector2i(x, 40)))
			print("  桥1(18-20,21): %s" % str(bridge1))
			print("  桥2(37-39,40): %s" % str(bridge2))
	else:
		print("  ❌ TileMapLayer不存在")
	
	# 5. 建筑细节 - 检查具体tile
	print("\n【建筑内部细节】")
	if tile_map:
		var anvil = tile_map.get_cell_atlas_coords(Vector2i(54, 9))
		var fuel1 = tile_map.get_cell_atlas_coords(Vector2i(58, 13))
		var fuel2 = tile_map.get_cell_atlas_coords(Vector2i(59, 13))
		print("  铁匠铺砧台(54,9): %s" % str(anvil))
		print("  燃料堆(58,13): %s | (59,13): %s" % [str(fuel1), str(fuel2)])
		
		var bar_count = 0
		for x in range(35, 46):
			if tile_map.get_cell_atlas_coords(Vector2i(x, 31)) == Vector2i(2, 0):
				bar_count += 1
		print("  酒馆吧台STONE(y=31): %d tiles" % bar_count)
		
		var stage = false
		for x in range(43, 47):
			for y in range(35, 38):
				if tile_map.get_cell_atlas_coords(Vector2i(x, y)) == Vector2i(2, 0):
					stage = true
		print("  酒馆舞台: %s" % str(stage))
		
		var altar = []
		for x in [13, 14]:
			for y in [9, 10]:
				altar.append(tile_map.get_cell_atlas_coords(Vector2i(x, y)))
		print("  祭坛(13-14,9-10): %s" % str(altar))
		
		var pew1 = tile_map.get_cell_atlas_coords(Vector2i(10, 12))
		var pew2 = tile_map.get_cell_atlas_coords(Vector2i(16, 14))
		print("  长椅(10,12): %s | (16,14): %s" % [str(pew1), str(pew2)])
	
	print("\n========== 诊断结束 ==========\n")
	quit(0)
