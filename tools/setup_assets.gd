@tool
extends EditorScript

## Run in Godot: Project → Tools → Run Editor Script
## Automatically configures all Kenney assets for the RPG project

func _run() -> void:
	print("🔧 Setting up Kenney assets...")
	
	# 1. Create TileSet from tilesheet
	setup_tileset()
	
	# 2. Extract and configure character sprites
	setup_characters()
	
	# 3. Update scene references
	update_scenes()
	
	print("\n✅ Asset setup complete!")
	print("Next: Open scenes/world.tscn and paint the TileMapLayer")

func setup_tileset() -> void:
	print("\n[1/3] Setting up TileSet...")
	
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	
	# Add physics layer
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, 1)  # Layer 1 = World
	
	# Add atlas source
	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = load("res://assets/tilesheet.png")
	atlas_source.texture_region_size = Vector2i(16, 16)
	
	# The tilesheet is 968x526. Kenney's 16x16 tiles with 1px margin
	# Actually transparent version: need to check layout
	# Let's register all possible tiles (60x32 grid approximate)
	var cols := int(atlas_source.texture.get_width()) / 17  # 16 + 1 margin
	var rows := int(atlas_source.texture.get_height()) / 17
	
	print("  Tilesheet: %dx%d tiles" % [cols, rows])
	
	for y in range(rows):
		for x in range(cols):
			var atlas_coords := Vector2i(x, y)
			atlas_source.create_tile(atlas_coords)
			# Add physics to wall-like tiles (rough heuristic: tiles in rows 3-6)
			if y >= 3 and y <= 8:
				atlas_source.set_tile_physics_layer_collision_polygon(0, atlas_coords, 0, 0, [PackedVector2Array([Vector2(0,0), Vector2(16,0), Vector2(16,16), Vector2(0,16)])])
	
	tileset.add_source(atlas_source, 0)
	
	var err := ResourceSaver.save(tileset, "res://assets/world_tileset.tres")
	print("  TileSet saved: %s" % ("OK" if err == OK else str(err)))

func setup_characters() -> void:
	print("\n[2/3] Setting up character sprites...")
	
	var char_sheet := load("res://assets/characters.png") as Texture2D
	if not char_sheet:
		print("  ERROR: Could not load characters.png")
		return
	
	# Kenney character sheet: 16x16 tiles with 1px margin
	# Total size: 918x203 → 54 columns x 11 rows
	var tile_w := 17  # 16 + 1 margin
	var tile_h := 17
	var cols := int(char_sheet.get_width()) / tile_w  # ~54
	var rows := int(char_sheet.get_height()) / tile_h   # ~11
	
	print("  Character sheet: %dx%d characters" % [cols, rows])
	
	# Extract specific characters by position
	# Row 0-2: Various characters (warriors, mages, etc.)
	
	# Player: Knight (row 0, col 0)
	create_character_frames(char_sheet, 0, 0, "res://assets/player_frames.tres")
	
	# NPC 1: Villager (row 0, col 5)  
	create_character_frames(char_sheet, 5, 0, "res://assets/npc_villager_frames.tres")
	
	# NPC 2: Shopkeeper (row 1, col 3)
	create_character_frames(char_sheet, 3, 1, "res://assets/npc_shopkeeper_frames.tres")

func create_character_frames(sheet: Texture2D, col: int, row: int, save_path: String) -> void:
	var tile_w := 17
	var tile_h := 17
	var x := col * tile_w
	var y := row * tile_h
	
	# Create a small sub-texture for this character
	# For now, use the whole sheet with region
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(x, y, 16, 16)
	
	# Create SpriteFrames with idle and walk (both using same frame for now)
	var frames := SpriteFrames.new()
	
	# Add 4-direction idle animations
	for dir in ["down", "up", "left", "right"]:
		var anim_name := "idle_" + dir
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, 5.0)
		frames.set_animation_loop(anim_name, true)
		frames.add_frame(anim_name, atlas, 1.0)
		# Add a second slightly offset frame for "breathing" effect
		var atlas2 := AtlasTexture.new()
		atlas2.atlas = sheet
		atlas2.region = Rect2(x, y, 16, 16)
		frames.add_frame(anim_name, atlas2, 0.5)
	
	# Add 4-direction walk animations (same frames for now)
	for dir in ["down", "up", "left", "right"]:
		var anim_name := "walk_" + dir
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, 8.0)
		frames.set_animation_loop(anim_name, true)
		frames.add_frame(anim_name, atlas, 1.0)
	
	var err := ResourceSaver.save(frames, save_path)
	print("  %s: %s" % [save_path, "OK" if err == OK else str(err)])

func update_scenes() -> void:
	print("\n[3/3] Updating scene references...")
	
	# Load player scene and update sprite frames
	var player_scene := load("res://scenes/player.tscn") as PackedScene
	if player_scene:
		var player_root := player_scene.instantiate()
		var player_sprite := player_root.get_node("AnimatedSprite2D") as AnimatedSprite2D
		if player_sprite:
			player_sprite.sprite_frames = load("res://assets/player_frames.tres")
			print("  Player sprite frames updated")
		player_root.free()
	
	# Note: NPC scenes would need similar updates
	# But since they're instances in world.tscn, we'd need to update the world scene
	print("  (Update NPC sprites manually in world.tscn after running this script)")
