extends CharacterBody2D

@export var max_hp: int = 20
@export var speed: float = 80.0
@export var attack_damage: int = 3
@export var attack_range: float = 32.0
@export var detection_range: float = 120.0
@export var texture_path: String = "res://assets/generated/char_enemy.png"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar

var current_hp: int
var target: Node2D = null
var state: String = "patrol"
var patrol_direction: Vector2 = Vector2.RIGHT
var patrol_timer: float = 0.0
var attack_cooldown: float = 2.0
var attack_windup: float = 0.0
const ATTACK_WINDUP_DURATION: float = 0.3
var is_dying: bool = false
var attack_indicator: Sprite2D

func _ready() -> void:
	current_hp = max_hp
	setup_sprite()
	setup_attack_indicator()
	update_health_bar()
	patrol_direction = Vector2(randf() - 0.5, randf() - 0.5).normalized()

func setup_attack_indicator() -> void:
	attack_indicator = Sprite2D.new()
	attack_indicator.visible = false
	attack_indicator.modulate = Color(1, 0, 0, 0.5)
	# Create a simple red circle texture
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 0, 0, 0.5))
	# Draw a hollow circle
	for x in range(64):
		for y in range(64):
			var cx := float(x) - 32.0
			var cy := float(y) - 32.0
			var dist := sqrt(cx * cx + cy * cy)
			if dist > 28.0 and dist < 32.0:
				img.set_pixel(x, y, Color(1, 0.2, 0.2, 0.7))
			else:
				img.set_pixel(x, y, Color(1, 0, 0, 0.0))
	var tex := ImageTexture.create_from_image(img)
	attack_indicator.texture = tex
	attack_indicator.scale = Vector2(attack_range / 32.0, attack_range / 32.0)
	add_child(attack_indicator)

func setup_sprite() -> void:
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

func _physics_process(delta: float) -> void:
	if is_dying or current_hp <= 0 or not is_inside_tree():
		return
	
	find_target()
	
	match state:
		"patrol":
			patrol(delta)
		"chase":
			chase(delta)
		"attack":
			attack(delta)
	
	update_animation()
	move_and_slide()

func find_target() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D as Node2D
	if not player:
		target = null
		state = "patrol"
		return
	
	var dist := global_position.distance_to(player.global_position)
	
	if dist <= attack_range:
		target = player
		state = "attack"
	elif dist <= detection_range:
		target = player
		state = "chase"
	else:
		target = null
		state = "patrol"

func patrol(delta: float) -> void:
	patrol_timer += delta
	if patrol_timer > 2.0:
		patrol_timer = 0.0
		patrol_direction = Vector2(randf() - 0.5, randf() - 0.5).normalized()
	
	velocity = patrol_direction * speed * 0.5

func chase(delta: float) -> void:
	if not target:
		return
	var dir := (target.global_position - global_position).normalized()
	velocity = dir * speed

func attack(delta: float) -> void:
	velocity = Vector2.ZERO
	
	attack_cooldown -= delta
	
	# Attack windup indicator
	if attack_cooldown <= ATTACK_WINDUP_DURATION and attack_cooldown > 0.0:
		attack_indicator.visible = true
		var pulse := 1.0 + sin(attack_cooldown * 30.0) * 0.3
		attack_indicator.scale = Vector2(pulse * attack_range / 32.0, pulse * attack_range / 32.0)
	else:
		attack_indicator.visible = false
	
	if attack_cooldown <= 0.0:
		attack_cooldown = 1.0
		attack_indicator.visible = false
		perform_attack()

func perform_attack() -> void:
	if target and target.has_method("take_damage"):
		# Trace
		if GameTrace and GameTrace.has_method("log_event"):
			GameTrace.log_event("enemy_attack", {"damage": attack_damage, "target_pos": str(target.global_position) if target else "none"})
		target.take_damage(attack_damage)
		if SoundManager and SoundManager.has_method("play_sfx"):
			SoundManager.play_sfx("hit_damage")

func take_damage(amount: int) -> void:
	if is_dying:
		return
	current_hp -= amount
	update_health_bar()
	
	var tween := create_tween()
	sprite.modulate = Color(1, 0.3, 0.3, 1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.2)
	
	if current_hp <= 0:
		die()

func die() -> void:
	is_dying = true
	velocity = Vector2.ZERO
	
	# Trace
	if GameTrace and GameTrace.has_method("log_event"):
		GameTrace.log_event("enemy_die", {"type": get_meta("enemy_type", ""), "pos": str(global_position)})
	
	# Enemy die sound
	if SoundManager and SoundManager.has_method("play_sfx"):
		SoundManager.play_sfx("enemy_die")
	
	# Load enemy data from JSON
	var type_id: String = get_meta("enemy_type", "")
	var data: Dictionary = DataLoader.get_enemy(type_id) if type_id != "" else {}
	var xp_reward: int = data.get("xp_reward", 25)
	var gold_reward: int = data.get("gold_reward", 5)
	
	# Drop gold coin
	var coin_scene := preload("res://scenes/item_pickup.tscn") as PackedScene
	var coin := coin_scene.instantiate() as Node2D
	if coin:
		coin.position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		coin.item_name = "金币"
		coin.item_type = "gold"
		coin.item_icon = "res://assets/generated/item_coin.png"
		coin.description = "一枚闪亮的金币"
		coin.heal_amount = 0
		coin.damage_bonus = 0
		get_parent().add_child(coin)
		coin.set_meta("gold_amount", gold_reward)
	
	# Grant XP to player
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player and player.has_method("add_xp"):
		player.add_xp(xp_reward)
	
	# Show floating text
	var ftm = get_tree().get_first_node_in_group("floating_text_manager") as Node
	if ftm and ftm.has_method("show_xp"):
		ftm.show_xp(global_position, xp_reward)
	if ftm and ftm.has_method("show_gold"):
		ftm.show_gold(global_position, gold_reward)
	
	# Register kill for quest
	var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node
	if quest_mgr and quest_mgr.has_method("register_kill"):
		quest_mgr.register_kill()
	queue_free()

func update_health_bar() -> void:
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp
		health_bar.visible = true
		# Color coding: green > 50%, yellow 30-50%, red < 30%
		var ratio: float = float(current_hp) / float(max_hp)
		if ratio > 0.5:
			health_bar.modulate = Color(0.2, 1, 0.2, 1)
		elif ratio > 0.3:
			health_bar.modulate = Color(1, 1, 0.2, 1)
		else:
			health_bar.modulate = Color(1, 0.2, 0.2, 1)

func update_animation() -> void:
	if not sprite.sprite_frames:
		return
	
	var dir := velocity.normalized()
	var is_moving: bool = velocity.length_squared() > 10.0
	var anim_name := "idle_" if not is_moving else "walk_"
	
	if abs(dir.x) > abs(dir.y):
		anim_name += "right" if dir.x > 0 else "left"
		sprite.flip_h = dir.x < 0
		anim_name = anim_name.replace("left", "right") if is_moving else anim_name
		if is_moving:
			anim_name = "walk_right"
	else:
		anim_name += "down" if dir.y > 0 else "up"
		sprite.flip_h = false
	
	if sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)
