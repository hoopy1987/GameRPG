extends SceneTree

func _initialize():
	var world = load("res://scenes/world.tscn").instantiate()
	self.root.add_child(world)
	await create_timer(1.5).timeout
	
	var npcs = get_nodes_in_group("npc")
	print("NPC count: " + str(npcs.size()))
	for npc in npcs:
		var anim = npc.get_node_or_null("AnimatedSprite2D")
		if anim:
			print("NPC: " + npc.name + " | sprite_frames null: " + str(anim.sprite_frames == null))
			if anim.sprite_frames:
				var names = anim.sprite_frames.get_animation_names()
				print("  animations: " + str(names))
				for n in names:
					print("  " + n + " frames: " + str(anim.sprite_frames.get_frame_count(n)))
			else:
				print("  NO sprite_frames!")
		else:
			print("NPC: " + npc.name + " | NO AnimatedSprite2D!")
	quit(0)
