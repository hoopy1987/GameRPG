@tool
extends EditorScript

## Run this in Godot: Project > Tools > Run Editor Script
## It creates placeholder sprite frames for Player and NPC

func _run() -> void:
	# Create player sprite frames
	var player_sframes := SpriteFrames.new()
	for anim in ["idle_down", "idle_up", "idle_left", "idle_right",
				 "walk_down", "walk_up", "walk_left", "walk_right"]:
		player_sframes.add_animation(anim)
		player_sframes.set_animation_speed(anim, 8.0)
		player_sframes.set_animation_loop(anim, true)
		# Add a single frame (icon texture)
		player_sframes.add_frame(anim, preload("res://icon.svg"), 1.0)
	
	var player_err := ResourceSaver.save(player_sframes, "res://assets/player_frames.tres")
	print("Player frames saved: " + str(player_err == OK))
	
	# Create NPC sprite frames  
	var npc_sframes := SpriteFrames.new()
	for anim in ["idle_down", "idle_up", "idle_left", "idle_right"]:
		npc_sframes.add_animation(anim)
		npc_sframes.set_animation_speed(anim, 4.0)
		npc_sframes.set_animation_loop(anim, true)
		npc_sframes.add_frame(anim, preload("res://icon.svg"), 1.0)
	
	var npc_err := ResourceSaver.save(npc_sframes, "res://assets/npc_frames.tres")
	print("NPC frames saved: " + str(npc_err == OK))
	
	print("\n✅ Setup complete! Now assign these to your AnimatedSprite2D nodes:")
	print("   - Player → assets/player_frames.tres")
	print("   - NPC → assets/npc_frames.tres")
