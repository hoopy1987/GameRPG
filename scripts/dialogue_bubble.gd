extends CanvasLayer

@onready var container: Control = $DialogueContainer
@onready var name_label: Label = $DialogueContainer/NameLabel
@onready var text_label: RichTextLabel = $DialogueContainer/TextLabel
@onready var continue_hint: Label = $DialogueContainer/ContinueHint

var current_npc: Node = null
var dialogue_lines: Array[String] = []
var current_index: int = 0
var is_active: bool = false
var is_typing: bool = false
var type_tween: Tween = null

func _ready() -> void:
	container.visible = false

func start_dialogue(npc: Node, lines: Array[String]) -> void:
	if lines.is_empty():
		return
	
	current_npc = npc
	dialogue_lines = lines.duplicate()
	current_index = 0
	is_active = true
	container.visible = true
	
	show_line()

func show_line() -> void:
	if current_index < dialogue_lines.size():
		var line = dialogue_lines[current_index]
		# Parse "Name: Content" format
		if line.find(":") != -1:
			var parts = line.split(":", true, 1)
			name_label.text = parts[0].strip_edges()
			_set_text(parts[1].strip_edges())
		else:
			# Speaker name compatibility: NPC has npc_name, investigation point has point_name
			var speaker_name := "???"
			if current_npc:
				if "npc_name" in current_npc:
					speaker_name = current_npc.npc_name
				elif "point_name" in current_npc:
					speaker_name = current_npc.point_name
				elif current_npc.has_meta("point_name"):
					speaker_name = current_npc.get_meta("point_name")
			name_label.text = speaker_name
			_set_text(line)
		
		continue_hint.visible = false
		_start_typewriter()

func _set_text(text: String) -> void:
	text_label.text = text
	text_label.visible_ratio = 0.0

func _start_typewriter() -> void:
	is_typing = true
	continue_hint.visible = false
	
	if type_tween and type_tween.is_valid():
		type_tween.kill()
	
	type_tween = create_tween()
	var duration: float = clamp(float(text_label.text.length()) * 0.03, 0.3, 2.0)
	type_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	type_tween.tween_callback(func():
		is_typing = false
		continue_hint.visible = current_index < dialogue_lines.size() - 1
	)

func _finish_typing() -> void:
	if type_tween and type_tween.is_valid():
		type_tween.kill()
	text_label.visible_ratio = 1.0
	is_typing = false
	continue_hint.visible = current_index < dialogue_lines.size() - 1

func advance() -> bool:
	if not is_active:
		return false
	
	# If still typing, finish it instantly
	if is_typing:
		_finish_typing()
		return true
	
	current_index += 1
	if current_index >= dialogue_lines.size():
		close_dialogue()
		return true
	
	show_line()
	return true

func close_dialogue() -> void:
	if type_tween and type_tween.is_valid():
		type_tween.kill()
	is_active = false
	is_typing = false
	container.visible = false
	current_npc = null
	dialogue_lines.clear()
	current_index = 0

func _input(event: InputEvent) -> void:
	if is_active and event.is_action_pressed("interact"):
		advance()
		get_viewport().set_input_as_handled()
