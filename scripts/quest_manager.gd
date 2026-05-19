extends Node

@export var quest_id: String = "first_steps"

var quest_name: String = ""
var quest_description: String = ""
var required_kills: int = 0
var required_npc_talk: String = ""
var reward_item: Dictionary = {}

var kill_count: int = 0
var talked_to_npc: bool = false
var completed: bool = false

func _ready() -> void:
	_load_quest_data()

func _load_quest_data() -> void:
	var data: Dictionary = DataLoader.get_quest(quest_id)
	if data.is_empty():
		push_warning("任务管理器：未在JSON中找到任务'%s'" % quest_id)
		return
	
	quest_name = data.get("name", quest_name)
	quest_description = data.get("description", quest_description)
	required_kills = data.get("required_kills", required_kills)
	required_npc_talk = data.get("required_npc_talk", required_npc_talk)
	
	var reward_item_id: String = data.get("reward_item_id", "")
	if reward_item_id != "":
		var item_data: Dictionary = DataLoader.get_item(reward_item_id)
		if not item_data.is_empty():
			reward_item = item_data

func register_kill() -> void:
	kill_count += 1
	check_completion()
	print("任务：已击败 %d/%d 个敌人" % [kill_count, required_kills])
	_refresh_ui()

func register_npc_talk(npc_name: String) -> void:
	if npc_name == required_npc_talk:
		talked_to_npc = true
		check_completion()
		print("任务：已与%s对话" % npc_name)
		_refresh_ui()

func _refresh_ui() -> void:
	var qt = get_tree().get_first_node_in_group("quest_tracker_ui") as Node
	if qt and qt.has_method("refresh"):
		qt.refresh()

func check_completion() -> void:
	if completed:
		return
	
	# Trace
	if GameTrace and GameTrace.has_method("log_event"):
		GameTrace.log_event("quest_check", {"kills": kill_count, "required": required_kills, "talked": talked_to_npc})
	
	if kill_count >= required_kills and talked_to_npc:
		completed = true
		# Trace
		if GameTrace and GameTrace.has_method("log_event"):
			GameTrace.log_event("quest_complete", {"quest_name": quest_name})
		print("任务完成：%s！" % quest_name)
		
		if ToastManager and ToastManager.has_method("show_toast"):
			ToastManager.show_toast("任务完成！", 2.0)
		
		var ftm = get_tree().get_first_node_in_group("floating_text_manager") as Node
		if ftm and ftm.has_method("show_text"):
			var player = get_tree().get_first_node_in_group("player") as Node2D
			if player:
				ftm.show_text(player.global_position + Vector2(0, -50), "任务完成！", Color(0.3, 1, 0.3, 1), 2.0)
		
		_refresh_ui()
		give_reward()

func give_reward() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player and player.has_method("add_item"):
		player.add_item(reward_item)
		print("获得奖励：%s" % reward_item["name"])
