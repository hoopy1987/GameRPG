extends CanvasLayer

@onready var panel: Panel = $QuestPanel
@onready var title_label: Label = $QuestPanel/TitleLabel
@onready var content_label: Label = $QuestPanel/ContentLabel
@onready var toggle_button: Button = $QuestPanel/ToggleButton

var is_collapsed: bool = false

func _ready() -> void:
	update_display()
	visible = true

func update_display() -> void:
	var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node
	if not quest_mgr:
		return
	
	var title: String = "📜 %s" % quest_mgr.quest_name
	var status := ""
	
	if quest_mgr.completed:
		status = "✅ 已完成"
		content_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5, 1))
	else:
		var kills_text: String = "⚔️ 击败敌人 %d/%d" % [quest_mgr.kill_count, quest_mgr.required_kills]
		var talk_text: String = "💬 与%s对话 %s" % [quest_mgr.required_npc_talk, "✅" if quest_mgr.talked_to_npc else "❌"]
		status = kills_text + "\n" + talk_text
		content_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
	
	title_label.text = title
	content_label.text = status

func toggle_visibility() -> void:
	is_collapsed = not is_collapsed
	if is_collapsed:
		panel.size.y = 30
		content_label.visible = false
	else:
		panel.size.y = 80
		content_label.visible = true

func _on_toggle_button_pressed() -> void:
	toggle_visibility()

func refresh() -> void:
	update_display()
