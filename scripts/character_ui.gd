extends Control

@onready var portrait: TextureRect = $Panel/Portrait
@onready var name_label: Label = $Panel/NameLabel
@onready var level_label: Label = $Panel/LevelLabel
@onready var hp_bar: ProgressBar = $Panel/HPBar
@onready var hp_label: Label = $Panel/HPLabel
@onready var xp_bar: ProgressBar = $Panel/XPBar
@onready var xp_label: Label = $Panel/XPLabel
@onready var atk_label: Label = $Panel/StatsGrid/ATKLabel
@onready var def_label: Label = $Panel/StatsGrid/DEFLabel
@onready var equip_grid: GridContainer = $Panel/EquipGrid

var player_ref: Node = null

func _ready() -> void:
	hide()
	_update_equipment_slots()

func set_player(player: Node) -> void:
	player_ref = player
	_refresh()

func _refresh() -> void:
	if not player_ref:
		return
	
	# Name and level
	name_label.text = "骑士"
	level_label.text = "Lv.%d" % player_ref.level
	
	# HP bar
	var max_hp: int = player_ref.max_hp
	var current_hp: int = player_ref.hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_label.text = "%d / %d" % [current_hp, max_hp]
	
	# XP bar
	var xp_needed: int = player_ref.xp_to_next
	var current_xp: int = player_ref.xp
	xp_bar.max_value = xp_needed
	xp_bar.value = current_xp
	xp_label.text = "%d / %d" % [current_xp, xp_needed]
	
	# Stats
	var bonus_atk: int = 0
	var bonus_def: int = 0
	for slot in player_ref.equipment.keys():
		var item: Dictionary = player_ref.equipment[slot]
		if item.has("damage_bonus"):
			bonus_atk += item["damage_bonus"]
		if item.has("defense_bonus"):
			bonus_def += item["defense_bonus"]
	
	var total_atk: int = player_ref.base_attack_damage + bonus_atk
	atk_label.text = "⚔️ 攻击: %d (+%d)" % [total_atk, bonus_atk]
	def_label.text = "🛡️ 防御: %d (+%d)" % [player_ref.base_defense + bonus_def, bonus_def]
	
	# Portrait
	if portrait.texture == null:
		var tex = load("res://assets/generated/char_knight.png") as Texture2D
		if tex:
			portrait.texture = tex
	
	_update_equipment_slots()

func _update_equipment_slots() -> void:
	if not player_ref:
		return
	
	var slot_names := ["main_hand", "off_hand", "helmet", "armor"]
	var slot_labels := ["主手", "副手", "头盔", "盔甲"]
	
	for i in range(slot_names.size()):
		var slot_name: String = slot_names[i]
		var slot_label: String = slot_labels[i]
		
		var cell: Control
		if i < equip_grid.get_child_count():
			cell = equip_grid.get_child(i)
		else:
			cell = _create_equip_cell()
			equip_grid.add_child(cell)
		
		var icon: TextureRect = cell.get_child(1)
		var label: Label = cell.get_child(2)
		
		if player_ref.equipment.has(slot_name) and player_ref.equipment[slot_name].has("icon"):
			var tex = load(player_ref.equipment[slot_name]["icon"]) as Texture2D
			icon.texture = tex
			label.text = player_ref.equipment[slot_name].get("name", slot_label)
		else:
			icon.texture = null
			label.text = slot_label

func _create_equip_cell() -> Control:
	var cell := Control.new()
	cell.custom_minimum_size = Vector2(60, 60)
	
	var bg := ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2, 1)
	bg.size = Vector2(60, 60)
	cell.add_child(bg)
	
	var icon := TextureRect.new()
	icon.position = Vector2(6, 6)
	icon.size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cell.add_child(icon)
	
	var label := Label.new()
	label.position = Vector2(0, 48)
	label.size = Vector2(60, 12)
	label.add_theme_font_size_override("font_size", 9)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cell.add_child(label)
	
	return cell

func toggle() -> void:
	visible = not visible
	if visible:
		_refresh()

func _process(_delta: float) -> void:
	if visible and player_ref:
		_refresh()
