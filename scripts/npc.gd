extends CharacterBody2D

@export var npc_name: String = "NPC"
@export var texture_path: String = "res://assets/npc_villager.png"
@export_multiline var dialogue_lines: Array[String] = ["你好！", "欢迎来到我们的村庄。"]

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_indicator: Node2D = $InteractionIndicator

var dialogue_index: int = 0
var player_nearby: bool = false

func _ready() -> void:
	interaction_indicator.visible = false
	# Set collision layer to NPC (layer 3)
	collision_layer = 1 << 2
	collision_mask = 0
	
	# Add to npc group for test discovery
	add_to_group("npc")
	
	# Dynamically load texture and create sprite frames
	var tex := load(texture_path) as Texture2D
	if tex:
		var frames := SpriteFrames.new()
		var base_name: String = texture_path.get_file().get_basename()
		
		for dir in ["down", "up", "left", "right"]:
			var idle_anim: String = "idle_" + dir
			frames.add_animation(idle_anim)
			frames.set_animation_speed(idle_anim, 4.0)
			frames.set_animation_loop(idle_anim, true)
			frames.add_frame(idle_anim, tex, 1.0)
			
			var walk_anim: String = "walk_" + dir
			frames.add_animation(walk_anim)
			frames.set_animation_speed(walk_anim, 8.0)
			frames.set_animation_loop(walk_anim, true)
			
			var has_walk_frames: bool = false
			for i in range(4):
				var frame_path: String = "res://assets/animations/%s_walk_f%d.png" % [base_name, i]
				var frame_tex = load(frame_path)
				if frame_tex is Texture2D:
					frames.add_frame(walk_anim, frame_tex, 1.0)
					has_walk_frames = true
			
			if not has_walk_frames:
				frames.add_frame(walk_anim, tex, 1.0)
		
		sprite.sprite_frames = frames
		sprite.play("idle_down")
	else:
		push_warning("Failed to load NPC texture: " + texture_path)

func interact() -> void:
	if dialogue_lines.is_empty():
		return
	
	# Face the player
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		face_toward(player.global_position)
	
	# Show dialogue via AutoLoad
	if DialogueBubble and DialogueBubble.has_method("start_dialogue"):
		# Format lines with NPC name prefix
		var formatted_lines: Array[String] = []
		for line in dialogue_lines:
			formatted_lines.append("%s: %s" % [npc_name, line])
		DialogueBubble.start_dialogue(self, formatted_lines)
		# Register NPC talk for quest
		var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node
		if quest_mgr and quest_mgr.has_method("register_npc_talk"):
			quest_mgr.register_npc_talk(npc_name)
	else:
		# Fallback to console print if UI not available
		var line := dialogue_lines[dialogue_index]
		print("%s: %s" % [npc_name, line])
		dialogue_index = (dialogue_index + 1) % dialogue_lines.size()

func face_toward(target: Vector2) -> void:
	if not sprite.sprite_frames:
		return
	var dir := (target - global_position).normalized()
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			if sprite.sprite_frames.has_animation("idle_right"):
				sprite.play("idle_right")
		else:
			if sprite.sprite_frames.has_animation("idle_left"):
				sprite.play("idle_left")
	else:
		if dir.y > 0:
			if sprite.sprite_frames.has_animation("idle_down"):
				sprite.play("idle_down")
		else:
			if sprite.sprite_frames.has_animation("idle_up"):
				sprite.play("idle_up")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		interaction_indicator.visible = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		interaction_indicator.visible = false
