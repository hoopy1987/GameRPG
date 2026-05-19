extends Area2D

func interact() -> void:
	var lines: Array = get_meta("investigation_lines", [])
	var point_name: String = get_meta("point_name", "???")
	if lines.is_empty():
		return
	
	if DialogueBubble and DialogueBubble.has_method("start_dialogue"):
		var formatted: Array[String] = []
		for line in lines:
			formatted.append(line)
		DialogueBubble.start_dialogue(self, formatted)
	else:
		for line in lines:
			print("[%s] %s" % [point_name, line])
