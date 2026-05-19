extends "res://scripts/npc.gd"

@export var shop_items: Array = []
@export var is_merchant: bool = true

var shop_ui: Control = null

func _ready() -> void:
	# Call parent _ready first (sets up sprite, collision, etc.)
	super._ready()
	
	if is_merchant:
		setup_shop()

func setup_shop() -> void:
	shop_ui = preload("res://scenes/shop_ui.tscn").instantiate()
	add_child(shop_ui)
	
	# Default shop items if none set
	if shop_items.is_empty():
		shop_items = [
			{"name": "生命药水", "type": "consumable", "icon": "res://assets/generated/item_potion.png", "heal": 25, "price": 15, "desc": "恢复25点生命值"},
			{"name": "铁剑", "type": "weapon", "icon": "res://assets/generated/item_sword.png", "damage_bonus": 8, "price": 50, "desc": "一把锋利的铁剑。攻击力+8"},
			{"name": "木盾", "type": "shield", "icon": "res://assets/generated/item_shield.png", "price": 30, "desc": "一面坚固的木盾"},
			{"name": "魔法药水", "type": "consumable", "icon": "res://assets/generated/item_potion.png", "heal": 50, "price": 40, "desc": "恢复50点生命值"}
		]
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player:
		shop_ui.player_ref = player
	
	shop_ui.setup_shop(shop_items)

func get_shop_ui() -> Control:
	return shop_ui

func interact() -> void:
	if is_merchant and shop_ui:
		var player = get_tree().get_first_node_in_group("player") as Node2D
		if player:
			shop_ui.player_ref = player
			shop_ui.open_shop()
			
			# Face the player
			face_toward(player.global_position)
			
			# Register NPC talk for quest
			var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node
			if quest_mgr and quest_mgr.has_method("register_npc_talk"):
				quest_mgr.register_npc_talk(npc_name)
	else:
		# Use normal NPC dialogue
		super.interact()
