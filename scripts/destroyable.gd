extends Area2D

@onready var sprite: Sprite2D

var current_hp: int = 1
var max_hp: int = 1

func _ready() -> void:
	current_hp = get_meta("max_hp", 1)
	max_hp = get_meta("max_hp", 1)
	sprite = $Sprite2D

func take_damage(amount: int) -> void:
	current_hp -= amount
	if current_hp <= 0:
		_destroy()

func _destroy() -> void:
	if SoundManager and SoundManager.has_method("play_sfx"):
		SoundManager.play_sfx("barrel_break")
	
	var ftm = get_tree().get_first_node_in_group("floating_text_manager") as Node
	if ftm and ftm.has_method("show_text"):
		ftm.show_text(global_position + Vector2(0, -20), "破坏！", Color(0.8, 0.3, 0.1, 1), 1.0)
	
	_spawn_drops()
	
	visible = false
	queue_free()

func _spawn_drops() -> void:
	var drop_chance := randf()
	if drop_chance < 0.5:
		var gold_amount := 1 + randi() % 5
		_spawn_item("金币", "gold", "res://assets/generated/item_coin.png", gold_amount, 0)
	elif drop_chance < 0.8:
		_spawn_item("生命药水", "consumable", "res://assets/generated/item_potion.png", 0, 15)
	# 20% chance: nothing

func _spawn_item(name: String, type: String, icon: String, gold_amount: int = 0, heal: int = 0) -> void:
	var item_scene = load("res://scenes/item_pickup.tscn")
	if item_scene:
		var item = item_scene.instantiate()
		item.item_name = name
		item.item_type = type
		item.item_icon = icon
		if type == "gold":
			item.set_meta("gold_amount", gold_amount)
		if heal > 0:
			item.heal_amount = heal
		item.position = global_position + Vector2(randi() % 20 - 10, randi() % 20 - 10)
		# Safe add_child: current_scene may be null in test environments
		var target_parent = get_tree().current_scene
		if not target_parent:
			target_parent = get_tree().root
		if target_parent and is_instance_valid(target_parent):
			target_parent.add_child(item)
		else:
			push_warning("Destroyable: no valid parent to add dropped item")
