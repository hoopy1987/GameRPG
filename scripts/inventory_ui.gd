extends Control

@onready var item_grid: GridContainer = $Panel/ScrollContainer/ItemGrid
@onready var desc_label: RichTextLabel = $Panel/DescLabel
@onready var stats_label: Label = $Panel/StatsLabel
@onready var hint_label: Label = $Panel/HintLabel
@onready var gold_label: Label = $Panel/GoldLabel

@onready var all_btn: Button = $Panel/FilterButtons/AllBtn
@onready var weapon_btn: Button = $Panel/FilterButtons/WeaponBtn
@onready var armor_btn: Button = $Panel/FilterButtons/ArmorBtn
@onready var consumable_btn: Button = $Panel/FilterButtons/ConsumableBtn

var equip_slots: Dictionary = {}
var selected_item: int = -1
var player_ref: Node = null
var current_filter: String = "all"
var item_nodes: Array = []

func _ready() -> void:
	equip_slots["main_hand"] = $Panel/EquipPanel/MainHand
	equip_slots["off_hand"] = $Panel/EquipPanel/OffHand
	equip_slots["helmet"] = $Panel/EquipPanel/Helmet
	equip_slots["armor"] = $Panel/EquipPanel/Armor
	
	for slot_name in equip_slots.keys():
		var slot_node = equip_slots[slot_name]
		slot_node.gui_input.connect(_on_slot_clicked.bind(slot_name))
	
	all_btn.pressed.connect(_on_filter_changed.bind("all"))
	weapon_btn.pressed.connect(_on_filter_changed.bind("weapon"))
	armor_btn.pressed.connect(_on_filter_changed.bind("armor"))
	consumable_btn.pressed.connect(_on_filter_changed.bind("consumable"))
	
	_update_filter_buttons()

func _on_filter_changed(filter: String) -> void:
	current_filter = filter
	selected_item = -1
	_update_filter_buttons()
	if player_ref:
		refresh(player_ref.inventory, player_ref.equipment)

func _update_filter_buttons() -> void:
	all_btn.modulate = Color(1, 1, 1, 1) if current_filter == "all" else Color(0.6, 0.6, 0.6, 1)
	weapon_btn.modulate = Color(1, 1, 1, 1) if current_filter == "weapon" else Color(0.6, 0.6, 0.6, 1)
	armor_btn.modulate = Color(1, 1, 1, 1) if current_filter == "armor" else Color(0.6, 0.6, 0.6, 1)
	consumable_btn.modulate = Color(1, 1, 1, 1) if current_filter == "consumable" else Color(0.6, 0.6, 0.6, 1)

func update_gold(amount: int) -> void:
	if gold_label:
		gold_label.text = "💰 %d" % amount

func _on_slot_clicked(event: InputEvent, slot_name: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player_ref and player_ref.has_method("unequip_slot"):
			player_ref.unequip_slot(slot_name)

func _get_filtered_items(items: Array) -> Array:
	if current_filter == "all":
		return items
	var filtered: Array = []
	for item in items:
		var item_type: String = item.get("type", "")
		match current_filter:
			"weapon":
				if item_type == "weapon":
					filtered.append(item)
			"armor":
				if item_type in ["shield", "helmet", "armor"]:
					filtered.append(item)
			"consumable":
				if item_type == "consumable":
					filtered.append(item)
	return filtered

func refresh(items: Array, equipment: Dictionary) -> void:
	# Clear grid
	for node in item_nodes:
		node.queue_free()
	item_nodes.clear()
	
	var display_items: Array = []
	var display_indices: Array = []
	
	for orig_idx in range(items.size()):
		var item: Dictionary = items[orig_idx]
		if _item_matches_filter(item):
			display_items.append(item)
			display_indices.append(orig_idx)
			var cell := _create_item_cell(item, display_items.size() - 1, orig_idx)
			item_grid.add_child(cell)
			item_nodes.append(cell)
	
	for slot_name in equip_slots.keys():
		var slot_node: TextureRect = equip_slots[slot_name]
		if equipment.has(slot_name) and equipment[slot_name].has("icon"):
			var tex = load(equipment[slot_name]["icon"]) as Texture2D
			slot_node.texture = tex
		else:
			slot_node.texture = null
	
	if display_items.size() > 0 and selected_item < 0:
		selected_item = 0
		_highlight_item(0)
	elif selected_item >= display_items.size():
		selected_item = -1
	
	if player_ref:
		update_gold(player_ref.gold)
	
	_update_display(display_items, equipment)

func _item_matches_filter(item: Dictionary) -> bool:
	if current_filter == "all":
		return true
	var item_type: String = item.get("type", "")
	match current_filter:
		"weapon":
			return item_type == "weapon"
		"armor":
			return item_type in ["shield", "helmet", "armor"]
		"consumable":
			return item_type == "consumable"
	return true

func _create_item_cell(item: Dictionary, display_index: int, original_index: int) -> Control:
	var container := Control.new()
	container.custom_minimum_size = Vector2(44, 44)
	container.size = Vector2(44, 44)
	
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.15, 1)
	bg.size = Vector2(44, 44)
	container.add_child(bg)
	
	# Border (selected highlight)
	var border := ColorRect.new()
	border.color = Color(1, 0.84, 0, 0)  # invisible by default
	border.size = Vector2(44, 44)
	border.set_meta("is_border", true)
	container.add_child(border)
	
	# Icon
	var icon := TextureRect.new()
	icon.size = Vector2(36, 36)
	icon.position = Vector2(4, 4)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex = load(item.get("icon", "res://assets/generated/item_sword.png")) as Texture2D
	if tex:
		icon.texture = tex
	container.add_child(icon)
	
	# Stack count badge
	var count: int = item.get("stack_count", 1)
	if count > 1:
		var badge := Label.new()
		badge.text = str(count)
		badge.position = Vector2(24, 24)
		badge.size = Vector2(20, 16)
		badge.add_theme_font_size_override("font_size", 10)
		badge.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		badge.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		badge.add_theme_constant_override("outline_size", 2)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		container.add_child(badge)
	
	# Click handler
	var btn := Button.new()
	btn.flat = true
	btn.size = Vector2(44, 44)
	btn.pressed.connect(_on_cell_clicked.bind(display_index))
	container.set_meta("original_index", original_index)
	container.add_child(btn)
	
	return container

func _on_cell_clicked(index: int) -> void:
	selected_item = index
	_highlight_item(index)
	if player_ref:
		var filtered := _get_filtered_items(player_ref.inventory)
		_update_display(filtered, player_ref.equipment)

func _highlight_item(index: int) -> void:
	for i in range(item_nodes.size()):
		var border = item_nodes[i].get_child(1)  # border is 2nd child
		if border.has_meta("is_border"):
			border.color = Color(1, 0.84, 0, 1) if i == index else Color(1, 0.84, 0, 0)

func get_selected_index() -> int:
	if selected_item >= 0 and selected_item < item_nodes.size():
		return item_nodes[selected_item].get_meta("original_index", -1)
	return -1

func _update_display(items: Array, equipment: Dictionary) -> void:
	var bonus: int = 0
	for slot in equipment.keys():
		if equipment[slot].has("damage_bonus"):
			bonus += equipment[slot]["damage_bonus"]
	var total_damage: int = 10 + bonus
	stats_label.text = "⚔️ %d (+%d)" % [total_damage, bonus]
	
	if selected_item >= 0 and selected_item < items.size():
		var item: Dictionary = items[selected_item]
		var desc: String = "【%s】  %s" % [item["name"], item.get("type", "")]
		
		if item.has("damage_bonus"):
			desc += "  +%d攻" % item["damage_bonus"]
		if item.has("heal"):
			desc += "  +%d血" % item["heal"]
		if item.has("desc"):
			desc += "\n%s" % item["desc"]
		
		# Equipment comparison
		var item_type: String = item.get("type", "")
		var slot_map: Dictionary = {"weapon": "main_hand", "shield": "off_hand", "helmet": "helmet", "armor": "armor"}
		var slot: String = slot_map.get(item_type, "")
		if slot != "" and item.has("damage_bonus") and player_ref:
			var current_bonus: int = 0
			var current_item_name: String = ""
			if equipment.has(slot) and equipment[slot].has("damage_bonus"):
				current_bonus = equipment[slot]["damage_bonus"]
				current_item_name = equipment[slot].get("name", "")
			var new_bonus: int = item["damage_bonus"]
			var base_atk: int = player_ref.base_attack_damage
			var old_atk: int = base_atk + current_bonus
			var new_atk: int = base_atk + new_bonus
			var diff: int = new_atk - old_atk
			
			if current_item_name == "":
				desc += "\n[新装备] 装备后 ATK: %d → %d" % [old_atk, new_atk]
			elif diff > 0:
				desc += "\n[对比] 替换 %s 后 ATK: %d → %d (+[color=#4ade80]%d[/color])" % [current_item_name, old_atk, new_atk, diff]
			elif diff < 0:
				desc += "\n[对比] 替换 %s 后 ATK: %d → %d ([color=#f87171]%d[/color])" % [current_item_name, old_atk, new_atk, diff]
			else:
				desc += "\n[对比] 替换 %s 后 ATK 无变化 (%d)" % [current_item_name, old_atk]
		
		if item.get("type", "") == "consumable":
			hint_label.text = "[空格] 使用"
		else:
			hint_label.text = "[空格] 装备 | 点击槽位卸下"
		
		desc_label.text = desc
	else:
		desc_label.text = ""
		hint_label.text = ""
