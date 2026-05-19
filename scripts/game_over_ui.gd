extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/TitleLabel
@onready var info_label: Label = $Panel/InfoLabel
@onready var load_btn: Button = $Panel/LoadBtn
@onready var respawn_btn: Button = $Panel/RespawnBtn
@onready var overlay: ColorRect = $Overlay

func _ready() -> void:
	panel.visible = false
	overlay.visible = false
	load_btn.pressed.connect(_on_load)
	respawn_btn.pressed.connect(_on_respawn)

func show_game_over(player: Node) -> void:
	if not player:
		return
	
	var level: int = player.level if "level" in player else 1
	var gold: int = player.gold if "gold" in player else 0
	
	title_label.text = "你阵亡了"
	info_label.text = "等级 %d · 持有金币 %d" % [level, gold]
	
	# 检查是否有存档
	var has_save: bool = SaveManager.has_any_save() if SaveManager and SaveManager.has_method("has_any_save") else false
	load_btn.disabled = not has_save
	if not has_save:
		load_btn.text = "无存档"
	else:
		load_btn.text = "读取存档"
	
	overlay.visible = true
	panel.visible = true

func _on_load() -> void:
	panel.visible = false
	var fader = get_tree().get_first_node_in_group("scene_fader")
	if fader and fader.has_method("fade_out"):
		await fader.fade_out(0.5)
	
	# 回到主菜单读取存档
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	await get_tree().process_frame
	var save_ui = get_tree().get_first_node_in_group("save_ui")
	if save_ui and save_ui.has_method("open"):
		save_ui.open()

func _on_respawn() -> void:
	panel.visible = false
	var fader = get_tree().get_first_node_in_group("scene_fader")
	if fader and fader.has_method("fade_out"):
		await fader.fade_out(0.5)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# 原地复活：HP恢复50%
		player.is_dead = false
		player.current_hp = int(player.max_hp * 0.5)
		player.velocity = Vector2.ZERO
		player.sprite.modulate = Color(1, 1, 1, 1)
		player.update_hp_bar()
		
		# 3秒无敌帧
		player.invincible_timer = 3.0
		var flash_tween := create_tween()
		flash_tween.set_loops(15)
		flash_tween.tween_property(player.sprite, "modulate:a", 0.4, 0.1)
		flash_tween.tween_property(player.sprite, "modulate:a", 1.0, 0.1)
	
	if ToastManager and ToastManager.has_method("show_toast"):
		ToastManager.show_toast("原地复活！HP恢复50%", 2.0)
	
	if fader and fader.has_method("fade_in"):
		await fader.fade_in(0.5)

func _hide_ui() -> void:
	panel.visible = false
	overlay.visible = false
