extends Control

@onready var item_list: ItemList = $Panel/ItemList
@onready var desc_label: Label = $Panel/DescLabel
@onready var gold_label: Label = $Panel/GoldLabel
@onready var action_button: Button = $Panel/ActionButton
@onready var close_button: Button = $Panel/CloseButton
@onready var buy_tab: Button = $Panel/TabContainer/BuyTab
@onready var sell_tab: Button = $Panel/TabContainer/SellTab

var shop_items: Array = []
var selected_item: int = -1
var player_ref: Node = null
var current_mode: String = "buy"  # "buy" or "sell"

func _ready() -> void:
	if not item_list.item_selected.is_connected(_on_item_selected):
		item_list.item_selected.connect(_on_item_selected)
	if not action_button.pressed.is_connected(_on_action):
		action_button.pressed.connect(_on_action)
	if not close_button.pressed.is_connected(_on_close):
		close_button.pressed.connect(_on_close)
	visible = false

func setup_shop(items: Array) -> void:
	shop_items = items

func refresh() -> void:
	item_list.clear()
	selected_item = -1
	
	if current_mode == "buy":
		action_button.text = "购买"
		for item in shop_items:
			var price: int = item.get("price", 10)
			item_list.add_item("%s - %dG" % [item["name"], price])
	else:
		action_button.text = "出售"
		if player_ref:
			for item in player_ref.inventory:
				var sell_price: int = _calc_sell_price(item)
				var stack: int = item.get("stack_count", 1)
				if stack > 1:
					item_list.add_item("%s x%d - %dG" % [item["name"], stack, sell_price])
				else:
					item_list.add_item("%s - %dG" % [item["name"], sell_price])
	
	if player_ref:
		gold_label.text = "💰 %d" % player_ref.gold
	
	_update_display()
	_update_tab_highlight()

func _calc_sell_price(item: Dictionary) -> int:
	var base: int = 5
	if item.has("damage_bonus"):
		base += item["damage_bonus"] * 3
	if item.has("heal"):
		base += int(item["heal"] / 5)
	return max(1, int(base * 0.5))

func _on_buy_tab() -> void:
	current_mode = "buy"
	refresh()

func _on_sell_tab() -> void:
	current_mode = "sell"
	refresh()

func _update_tab_highlight() -> void:
	buy_tab.modulate = Color(1, 1, 1, 1) if current_mode == "buy" else Color(0.6, 0.6, 0.6, 1)
	sell_tab.modulate = Color(1, 1, 1, 1) if current_mode == "sell" else Color(0.6, 0.6, 0.6, 1)

func _on_item_selected(index: int) -> void:
	selected_item = index
	_update_display()

func _on_action() -> void:
	if current_mode == "buy":
		_buy_item()
	else:
		_sell_item()

func _buy_item() -> void:
	if selected_item < 0 or selected_item >= shop_items.size():
		return
	if not player_ref:
		return
	
	var item: Dictionary = shop_items[selected_item]
	var price: int = item.get("price", 10)
	
	if player_ref.gold < price:
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("金币不足！", 1.5)
		return
	
	player_ref.gold -= price
	player_ref.add_item({
		"name": item["name"],
		"type": item.get("type", "consumable"),
		"icon": item.get("icon", "res://assets/generated/item_potion.png"),
		"heal": item.get("heal", 0),
		"damage_bonus": item.get("damage_bonus", 0),
		"desc": item.get("desc", "")
	})
	
	if ToastManager and ToastManager.has_method("show_toast"):
		ToastManager.show_toast("已购买%s！" % item["name"], 1.5)
	
	refresh()

func _sell_item() -> void:
	if selected_item < 0:
		return
	if not player_ref:
		return
	if selected_item >= player_ref.inventory.size():
		return
	
	var item: Dictionary = player_ref.inventory[selected_item]
	var sell_price: int = _calc_sell_price(item)
	var stack: int = item.get("stack_count", 1)
	var total_price: int = sell_price * stack
	
	player_ref.gold += total_price
	player_ref.inventory.remove_at(selected_item)
	
	if ToastManager and ToastManager.has_method("show_toast"):
		ToastManager.show_toast("已出售%s，获得%d金币！" % [item["name"], total_price], 1.5)
	
	if player_ref.inventory_ui:
		player_ref.inventory_ui.refresh(player_ref.inventory, player_ref.equipment)
	
	refresh()

func _on_close() -> void:
	visible = false
	selected_item = -1

func _update_display() -> void:
	if selected_item < 0:
		desc_label.text = ""
		action_button.disabled = true
		return
	
	if current_mode == "buy":
		if selected_item >= shop_items.size():
			return
		var item: Dictionary = shop_items[selected_item]
		var desc: String = "【%s】  %s\n" % [item["name"], item.get("type", "")]
		if item.has("damage_bonus"):
			desc += "+%d 攻击力\n" % item["damage_bonus"]
		if item.has("heal"):
			desc += "+%d 生命值\n" % item["heal"]
		if item.has("desc"):
			desc += "%s\n" % item["desc"]
		desc += "价格：%d金币" % item.get("price", 10)
		desc_label.text = desc
		
		var can_afford: bool = player_ref != null and player_ref.gold >= item.get("price", 10)
		action_button.disabled = not can_afford
	else:
		if not player_ref or selected_item >= player_ref.inventory.size():
			return
		var item: Dictionary = player_ref.inventory[selected_item]
		var sell_price: int = _calc_sell_price(item)
		var stack: int = item.get("stack_count", 1)
		var total: int = sell_price * stack
		var desc: String = "【%s】  %s\n" % [item["name"], item.get("type", "")]
		if item.has("damage_bonus"):
			desc += "+%d 攻击力\n" % item["damage_bonus"]
		if item.has("heal"):
			desc += "+%d 生命值\n" % item["heal"]
		if item.has("desc"):
			desc += "%s\n" % item["desc"]
		desc += "出售：%d金币（x%d = 共%d金币）" % [sell_price, stack, total]
		desc_label.text = desc
		action_button.disabled = false

func open_shop() -> void:
	visible = true
	current_mode = "buy"
	selected_item = -1
	refresh()
