extends Area2D

@export var point_name: String = "调查点"
@export var dialogue_text: String = ""

func interact() -> void:
	var lines: Array = get_meta("investigation_lines", [])
	var meta_point_name: String = get_meta("point_name", point_name)
	if lines.is_empty():
		return
	
	if DialogueBubble and DialogueBubble.has_method("start_dialogue"):
		var formatted: Array[String] = []
		for line in lines:
			formatted.append(line)
		DialogueBubble.start_dialogue(self, formatted)
	else:
		for line in lines:
			print("[%s] %s" % [meta_point_name, line])
