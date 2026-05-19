extends CharacterBody2D

@export var speed: float = 200.0
@export var friction: float = 0.8
@export var texture_path: String = "res://assets/generated/char_knight.png"
@export var max_hp: int = 100
@export var base_attack_damage: int = 10
@export var attack_range: float = 40.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weapon_sprite: Sprite2D = $WeaponSprite

var current_hp: int
var attack_damage: int
var facing_direction: Vector2 = Vector2.DOWN
var attack_cooldown: float = 0.0
var invincible_timer: float = 0.0
const INVINCIBLE_DURATION: float = 0.6

# Inventory
var inventory: Array = []
var inventory_open: bool = false
var inventory_ui: Control = null

# Equipment slots
var equipment: Dictionary = {
	"main_hand": {},
	"off_hand": {},
	"helmet": {},
	"armor": {}
}

const SLOT_MAP: Dictionary = {
	"weapon": "main_hand",
	"shield": "off_hand",
	"helmet": "helmet",
	"armor": "armor"
}

const SLOT_LABELS: Dictionary = {
	"main_hand": "主手",
	"off_hand": "副手",
	"helmet": "头盔",
	"armor": "盔甲"
}

# Gold currency (separate from inventory)
var gold: int = 0

# XP / Leveling
var xp: int = 0
var level: int = 1
var xp_to_next: int = 100

# Death / Respawn
var is_dead: bool = false
var respawn_position: Vector2 = Vector2(640, 360)

# UI
var hp_bar_bg: NinePatchRect
var hp_bar_fill: NinePatchRect
var hp_label: Label
var level_label: Label
var xp_bar_bg: NinePatchRect
var xp_bar_fill: NinePatchRect

func _ready() -> void:
	current_hp = max_hp
	attack_damage = base_attack_damage
	setup_sprite()
	setup_weapon_sprite()
	setup_hp_bar()
	setup_inventory_ui()
	# 启动保护：1秒无敌帧，防止出生即死
	invincible_timer = 1.0

func setup_weapon_sprite() -> void:
	weapon_sprite.visible = false
	weapon_sprite.position = Vector2(12, 8)

func setup_hp_bar() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 20
	add_child(canvas)
	
	# HP Bar Background
	hp_bar_bg = NinePatchRect.new()
	hp_bar_bg.texture = load("res://assets/ui/ui_hp_bar_bg.png")
	hp_bar_bg.size = Vector2(64, 12)
	hp_bar_bg.position = Vector2(-1000, -1000)
	canvas.add_child(hp_bar_bg)
	
	hp_bar_fill = NinePatchRect.new()
	hp_bar_fill.texture = load("res://assets/ui/ui_hp_bar_green.png")
	hp_bar_fill.size = Vector2(64, 12)
	hp_bar_fill.position = Vector2(0, 0)
	hp_bar_bg.add_child(hp_bar_fill)
	
	hp_label = Label.new()
	hp_label.position = Vector2(0, -14)
	hp_label.size = Vector2(64, 12)
	hp_label.add_theme_font_size_override("font_size", 10)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_bar_bg.add_child(hp_label)
	
	# Level Label (above HP bar)
	level_label = Label.new()
	level_label.position = Vector2(0, -28)
	level_label.size = Vector2(64, 12)
	level_label.add_theme_font_size_override("font_size", 10)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
	hp_bar_bg.add_child(level_label)
	
	# XP Bar (below HP bar)
	xp_bar_bg = NinePatchRect.new()
	xp_bar_bg.texture = load("res://assets/ui/ui_xp_bar_bg.png")
	xp_bar_bg.size = Vector2(64, 8)
	xp_bar_bg.position = Vector2(0, 14)
	hp_bar_bg.add_child(xp_bar_bg)
	
	xp_bar_fill = NinePatchRect.new()
	xp_bar_fill.texture = load("res://assets/ui/ui_xp_bar_fill.png")
	xp_bar_fill.modulate = Color(0.3, 0.6, 1.0, 1)
	xp_bar_fill.size = Vector2(64, 8)
	xp_bar_fill.position = Vector2(0, 0)
	xp_bar_bg.add_child(xp_bar_fill)
	
	update_hp_bar()
	update_level_ui()

func update_hp_bar() -> void:
	if not hp_bar_bg:
		return
	var ratio: float = float(current_hp) / float(max_hp)
	hp_bar_fill.size.x = max(2, 62 * ratio)
	hp_label.text = "%d/%d" % [current_hp, max_hp]
	
	# Color-coded HP bar texture
	if ratio > 0.5:
		hp_bar_fill.texture = load("res://assets/ui/ui_hp_bar_green.png")
	elif ratio > 0.3:
		hp_bar_fill.texture = load("res://assets/ui/ui_hp_bar_yellow.png")
	else:
		hp_bar_fill.texture = load("res://assets/ui/ui_hp_bar_red.png")
	
	update_level_ui()

func update_level_ui() -> void:
	if level_label:
		level_label.text = "等级%d" % level
	if xp_bar_fill and xp_bar_bg:
		var xp_ratio: float = float(xp) / float(xp_to_next)
		xp_bar_fill.size.x = max(2, 62 * xp_ratio)

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		level_up()
	update_level_ui()

func level_up() -> void:
	level += 1
	max_hp += 10
	current_hp = max_hp
	base_attack_damage += 2
	attack_damage = base_attack_damage
	recalc_stats()
	xp_to_next = int(xp_to_next * 1.5)
	update_hp_bar()
	
	# 升级音效
	if SoundManager and SoundManager.has_method("play_sfx"):
		SoundManager.play_sfx("level_up")
	
	# Show floating level-up text
	var ftm = get_tree().get_first_node_in_group("floating_text_manager") as Node
	if ftm and ftm.has_method("show_level_up"):
		ftm.show_level_up(global_position, level)
	
	print("升级了！当前等级%d | 生命值：%d | 攻击力：%d" % [level, max_hp, attack_damage])

func _process(_delta: float) -> void:
	if hp_bar_bg:
		var viewport_pos: Vector2 = get_global_transform_with_canvas().origin
		hp_bar_bg.position = viewport_pos + Vector2(-32, -36)

func setup_inventory_ui() -> void:
	inventory_ui = preload("res://scenes/inventory_ui.tscn").instantiate()
	inventory_ui.player_ref = self
	add_child(inventory_ui)
	inventory_ui.visible = false

func add_gold(amount: int) -> void:
	gold += amount
	print("金币：%d（+%d）" % [gold, amount])
	if inventory_ui:
		inventory_ui.update_gold(gold)

func add_item(item: Dictionary) -> void:
	if item.get("type", "") == "gold":
		add_gold(item.get("amount", 1))
		return
	
	# Stack consumables with same name
	if item.get("type", "") == "consumable":
		for inv_item in inventory:
			if inv_item["name"] == item["name"] and inv_item.get("type", "") == "consumable":
				inv_item["stack_count"] = inv_item.get("stack_count", 1) + 1
				print("%s已叠加（x%d）" % [item["name"], inv_item["stack_count"]])
				if inventory_ui:
					inventory_ui.refresh(inventory, equipment)
				return
	
	item["stack_count"] = 1
	inventory.append(item)
	print("已加入背包：%s" % item["name"])
	if inventory_ui:
		inventory_ui.refresh(inventory, equipment)

func equip_from_inventory(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return
	var item: Dictionary = inventory[index]
	var slot: String = SLOT_MAP.get(item.get("type", ""), "")
	if slot == "":
		print("无法装备%s" % item["name"])
		return
	
	# Unequip current if any
	if equipment[slot].has("name"):
		inventory.append(equipment[slot])
		print("已卸下%s" % equipment[slot]["name"])
	
	equipment[slot] = item
	inventory.remove_at(index)
	
	print("已将%s装备到%s" % [item["name"], SLOT_LABELS[slot]])
	recalc_stats()
	update_equipment_visuals()
	if inventory_ui:
		inventory_ui.refresh(inventory, equipment)

func unequip_slot(slot: String) -> void:
	if not equipment[slot].has("name"):
		return
	inventory.append(equipment[slot])
	print("已从%s卸下%s" % [equipment[slot]["name"], SLOT_LABELS[slot]])
	equipment[slot] = {}
	recalc_stats()
	update_equipment_visuals()
	if inventory_ui:
		inventory_ui.refresh(inventory, equipment)

func recalc_stats() -> void:
	var bonus: int = 0
	for slot in equipment.keys():
		if equipment[slot].has("damage_bonus"):
			bonus += equipment[slot]["damage_bonus"]
	attack_damage = base_attack_damage + bonus

func update_equipment_visuals() -> void:
	# Main hand weapon
	if equipment["main_hand"].has("name"):
		var tex := load(equipment["main_hand"].get("icon", "res://assets/generated/item_sword.png")) as Texture2D
		if tex:
			weapon_sprite.texture = tex
			weapon_sprite.visible = true
	else:
		weapon_sprite.visible = false
		weapon_sprite.z_index = 0

func use_consumable(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return
	var item: Dictionary = inventory[index]
	if item.get("type", "") == "consumable" and item.has("heal"):
		current_hp = min(current_hp + item["heal"], max_hp)
		update_hp_bar()
		print("使用了%s！生命值：%d/%d" % [item["name"], current_hp, max_hp])
		
		# Handle stacking
		if item.get("stack_count", 1) > 1:
			item["stack_count"] -= 1
		else:
			inventory.remove_at(index)
		
		if inventory_ui:
			inventory_ui.refresh(inventory, equipment)
			inventory_ui.selected_item = -1

func toggle_inventory() -> void:
	inventory_open = not inventory_open
	if inventory_ui:
		inventory_ui.visible = inventory_open
		if inventory_open:
			inventory_ui.refresh(inventory, equipment)

var footstep_timer: float = 0.0

func setup_sprite() -> void:
	var tex := load(texture_path) as Texture2D
	if tex:
		var frames := SpriteFrames.new()
		var base_name: String = texture_path.get_file().get_basename()
		
		for dir in ["down", "up", "left", "right"]:
			var idle_anim: String = "idle_" + dir
			frames.add_animation(idle_anim)
			frames.set_animation_speed(idle_anim, 5.0)
			frames.set_animation_loop(idle_anim, true)
			frames.add_frame(idle_anim, tex, 1.0)
			
			var walk_anim: String = "walk_" + dir
			frames.add_animation(walk_anim)
			frames.set_animation_speed(walk_anim, 10.0)
			frames.set_animation_loop(walk_anim, true)
			
			# 尝试加载4帧行走动画
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
		push_warning("Failed to load player texture: " + texture_path)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return
	
	if DialogueBubble and DialogueBubble.is_active:
		velocity = Vector2.ZERO
		update_animation("idle")
		return
	
	# Block movement if shop is open
	if shop_ui_open():
		velocity = Vector2.ZERO
		update_animation("idle")
		return
	
	attack_cooldown -= delta
	invincible_timer -= delta
	
	var input_direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
		facing_direction = input_direction
		velocity = input_direction * speed
		update_animation("walk")
		# 脚步声
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			footstep_timer = 0.35
			if SoundManager and SoundManager.has_method("play_sfx"):
				SoundManager.play_sfx("footstep")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * friction * delta * 10)
		update_animation("idle")
		footstep_timer = 0.0
	
	move_and_slide()
	update_weapon_position()

func update_animation(state: String) -> void:
	if not sprite.sprite_frames:
		return
	
	var anim_name := state + "_"
	
	if abs(facing_direction.x) > abs(facing_direction.y):
		anim_name += "right" if facing_direction.x > 0 else "left"
		if state == "idle" or state == "walk":
			sprite.flip_h = facing_direction.x < 0
			anim_name = state + "_right"
	else:
		anim_name += "down" if facing_direction.y > 0 else "up"
		sprite.flip_h = false
	
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)

func update_weapon_position() -> void:
	if not weapon_sprite.visible:
		return
	
	weapon_sprite.z_index = 0
	
	if facing_direction.y > 0:
		weapon_sprite.position = Vector2(10, 14)
		weapon_sprite.flip_h = false
	elif facing_direction.y < 0:
		weapon_sprite.position = Vector2(8, 0)
		weapon_sprite.z_index = -1
		weapon_sprite.flip_h = false
	elif facing_direction.x > 0:
		weapon_sprite.position = Vector2(14, 8)
		weapon_sprite.flip_h = false
	else:
		weapon_sprite.position = Vector2(-14, 8)
		weapon_sprite.flip_h = true

func weapon_swing() -> void:
	if not weapon_sprite.visible:
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	# Swing out and back to 0
	if facing_direction.y > 0:
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(45), 0.08)
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(-30), 0.08)
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(0), 0.08)
	elif facing_direction.y < 0:
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(-45), 0.08)
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(30), 0.08)
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(0), 0.08)
	elif facing_direction.x > 0:
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(-60), 0.08)
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(20), 0.08)
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(0), 0.08)
	else:
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(60), 0.08)
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(-20), 0.08)
		tween.tween_property(weapon_sprite, "rotation", deg_to_rad(0), 0.08)

func shop_ui_open() -> bool:
	var merchant = get_tree().get_first_node_in_group("merchant")
	if merchant and merchant.has_method("get_shop_ui"):
		var shop = merchant.get_shop_ui()
		if shop and shop.visible:
			return true
	return false

func _input(event: InputEvent) -> void:
	if shop_ui_open():
		# Let shop UI handle its own input
		return
	
	if event.is_action_pressed("interact"):
		if DialogueBubble and DialogueBubble.is_active:
			return
		try_interact()
	
	if event.is_action_pressed("attack"):
		try_attack()
	
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	
	if event.is_action_pressed("unequip"):
		unequip_slot("main_hand")
	
	if event.is_action_pressed("save_game"):
		if SaveUI and SaveUI.has_method("open"):
			SaveUI.open()
	
	if event.is_action_pressed("load_game"):
		if SaveUI and SaveUI.has_method("open"):
			SaveUI.open()
	
	if event.is_action_pressed("respawn") and is_dead:
		respawn()
	
	if inventory_open and event.is_action_pressed("interact"):
		if inventory_ui and inventory_ui.has_method("get_selected_index"):
			var idx: int = inventory_ui.get_selected_index()
			if idx >= 0 and idx < inventory.size():
				var item: Dictionary = inventory[idx]
				if SLOT_MAP.has(item.get("type", "")):
					equip_from_inventory(idx)
				elif item.get("type", "") == "consumable":
					use_consumable(idx)
				get_viewport().set_input_as_handled()

func try_interact() -> void:
	var space := get_world_2d().direct_space_state
	
	var area_query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 32.0
	area_query.shape = circle
	area_query.transform = Transform2D(0, global_position)
	area_query.collision_mask = 1 << 2
	area_query.collide_with_areas = true
	area_query.collide_with_bodies = false
	
	var area_results: Array = space.intersect_shape(area_query, 10)
	for result in area_results:
		var collider := result.collider as Node
		if collider and collider.has_method("interact"):
			collider.interact()
			return
	
	var body_query := PhysicsShapeQueryParameters2D.new()
	body_query.shape = circle
	body_query.transform = Transform2D(0, global_position + facing_direction * 24.0)
	body_query.collision_mask = 1 << 2
	body_query.collide_with_areas = false
	body_query.collide_with_bodies = true
	
	var body_results: Array = space.intersect_shape(body_query, 5)
	for result in body_results:
		var collider := result.collider as Node
		if collider and collider.has_method("interact"):
			collider.interact()
			break

func try_attack() -> void:
	if attack_cooldown > 0.0:
		return
	
	attack_cooldown = 0.5
	
	# 挥剑音效
	if SoundManager and SoundManager.has_method("play_sfx"):
		SoundManager.play_sfx("sword_swing")
	
	# Always play swing animation even if no target
	weapon_swing()
	
	var tween := create_tween()
	sprite.modulate = Color(1.3, 1.3, 1.3, 1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	
	# Check for hit
	var space := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = attack_range
	query.shape = circle
	query.transform = Transform2D(0, global_position + facing_direction * 20.0)
	query.collision_mask = 1 << 2
	
	var results: Array = space.intersect_shape(query, 10)
	for result in results:
		var collider := result.collider as Node
		if collider and collider != self and collider.has_method("take_damage"):
			# Crit check: 10% chance for 1.5x damage
			var is_crit := randf() < 0.1
			var final_damage := attack_damage
			if is_crit:
				final_damage = int(float(attack_damage) * 1.5)
			
			collider.take_damage(final_damage)
			
			# Show floating damage text
			var ftm = get_tree().get_first_node_in_group("floating_text_manager") as Node
			if ftm and ftm.has_method("show_damage"):
				ftm.show_damage(collider.global_position + Vector2(0, -20), final_damage, is_crit)
			
			# Knockback enemy
			if collider is CharacterBody2D:
				var knockback_dir: Vector2 = (collider.global_position - global_position).normalized()
				collider.velocity = knockback_dir * 150.0
				collider.move_and_slide()
			break

func take_damage(amount: int) -> void:
	if invincible_timer > 0.0 or current_hp <= 0:
		return
	current_hp -= amount
	invincible_timer = INVINCIBLE_DURATION
	update_hp_bar()
	
	# Trace
	if GameTrace and GameTrace.has_method("log_event"):
		GameTrace.log_event("player_take_damage", {"amount": amount, "hp": current_hp, "max_hp": max_hp})
	
	# 受伤音效
	if SoundManager and SoundManager.has_method("play_sfx"):
		SoundManager.play_sfx("player_hurt")
	
	# Show floating damage text
	var ftm = get_tree().get_first_node_in_group("floating_text_manager") as Node
	if ftm and ftm.has_method("show_text"):
		ftm.show_text(global_position + Vector2(0, -30), "-%d" % amount, Color(1, 0.3, 0.3, 1))
	
	var tween := create_tween()
	sprite.modulate = Color(1, 0.3, 0.3, 1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.2)
	
	# Flash effect for invincibility
	var flash_tween := create_tween()
	flash_tween.set_loops(3)
	flash_tween.tween_property(sprite, "modulate:a", 0.4, 0.1)
	flash_tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	
	print("受到%d点伤害！生命值：%d/%d" % [amount, current_hp, max_hp])
	
	if current_hp <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	print("玩家阵亡！")
	
	# Trace
	if GameTrace and GameTrace.has_method("log_event"):
		GameTrace.log_event("player_die", {"hp": current_hp, "level": level, "gold": gold, "pos": str(global_position)})
	
	# Show Game Over UI instead of direct respawn
	var game_over = get_tree().get_first_node_in_group("game_over_ui")
	if game_over and game_over.has_method("show_game_over"):
		game_over.show_game_over(self)
	else:
		# Fallback: show death toast
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("你阵亡了——按[R]键复活", 9999.0)
	
	# Dim the sprite
	sprite.modulate = Color(0.3, 0.3, 0.3, 1)

func respawn() -> void:
	is_dead = false
	current_hp = max_hp
	global_position = respawn_position
	velocity = Vector2.ZERO
	invincible_timer = 1.0
	
	# Trace
	if GameTrace and GameTrace.has_method("log_event"):
		GameTrace.log_event("player_respawn", {"hp": current_hp, "pos": str(global_position)})
	sprite.modulate = Color(1, 1, 1, 1)
	update_hp_bar()
	
	if ToastManager and ToastManager.has_method("hide_toast"):
		ToastManager.hide_toast()
	
	print("玩家在%s处复活" % str(respawn_position))
