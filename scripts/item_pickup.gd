extends Area2D

@export var item_name: String = "Health Potion"
@export var item_type: String = "consumable"  # consumable, weapon, armor, key
@export var item_icon: String = "res://assets/chars/char_r2_c5.png"
@export var heal_amount: int = 20
@export var damage_bonus: int = 0
@export var description: String = "恢复20点生命值"

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	# Load icon
	var tex := load(item_icon) as Texture2D
	if tex:
		sprite.texture = tex
	
	# Floating label
	label.text = "[空格] 拾取"
	label.visible = false
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		label.visible = false

func interact() -> void:
	# Pickup sound
	if SoundManager and SoundManager.has_method("play_sfx"):
		SoundManager.play_sfx("pickup")
	
	# Called when player presses space near this item
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	if item_type == "gold":
		var amount: int = get_meta("gold_amount", 1)
		if player.has_method("add_gold"):
			player.add_gold(amount)
		print("拾取了：%s x%d" % [item_name, amount])
		queue_free()
		return
	
	if player.has_method("add_item"):
		player.add_item({
			"name": item_name,
			"type": item_type,
			"icon": item_icon,
			"heal": heal_amount,
			"damage_bonus": damage_bonus,
			"desc": description
		})
		print("拾取了：%s" % item_name)
		queue_free()
