extends Node

const TRACE_PATH := "user://game_trace.log"
var trace_file: FileAccess = null

func _init() -> void:
	# Open trace log in append mode (or create new)
	trace_file = FileAccess.open(TRACE_PATH, FileAccess.WRITE)
	if trace_file:
		trace_file.store_line("=== Game Trace Log ===")
		trace_file.store_line("Time: %s" % Time.get_datetime_string_from_system(false, true))
		trace_file.store_line("")

func _exit_tree() -> void:
	if trace_file:
		trace_file.close()

func log_trace(category: String, message: String) -> void:
	var line := "[%s] %s: %s" % [Time.get_time_string_from_system(), category, message]
	print(line)
	if trace_file:
		trace_file.store_line(line)
		trace_file.flush()

func log_event(event_name: String, details: Dictionary = {}) -> void:
	var detail_str := ""
	for key in details.keys():
		detail_str += "%s=%s " % [key, str(details[key])]
	log_trace("EVENT", "%s | %s" % [event_name, detail_str.strip_edges()])
