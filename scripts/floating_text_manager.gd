extends CanvasLayer

@onready var container: Control = $FloatingTextContainer

const FLOAT_SPEED: float = 60.0
const FADE_DURATION: float = 1.0
const LIFE_TIME: float = 1.2

func show_text(pos: Vector2, text: String, color: Color = Color.WHITE, scale: float = 1.0) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", int(14 * scale))
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Outline for readability
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	
	container.add_child(label)
	
	# Position in viewport space
	label.position = pos - Vector2(label.size.x / 2, 0)
	
	# Animate: float up + fade out
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(label, "position:y", label.position.y - 40, LIFE_TIME)
	tween.tween_property(label, "modulate:a", 0.0, FADE_DURATION).set_delay(LIFE_TIME - FADE_DURATION)
	tween.chain().tween_callback(func():
		label.queue_free()
	)

func show_damage(pos: Vector2, amount: int, is_critical: bool = false) -> void:
	var text := "-%d" % amount
	var color := Color.WHITE
	var scale := 1.0
	
	if is_critical:
		text = "暴击 %s" % text
		color = Color(1.0, 0.84, 0.0, 1)
		scale = 1.3
	elif amount >= 10:
		color = Color(1.0, 0.5, 0.5, 1)
	
	show_text(pos, text, color, scale)

func show_heal(pos: Vector2, amount: int) -> void:
	show_text(pos, "+%d HP" % amount, Color(0.4, 1.0, 0.4, 1), 1.0)

func show_xp(pos: Vector2, amount: int) -> void:
	show_text(pos, "+%d XP" % amount, Color(0.5, 0.6, 1.0, 1), 0.9)

func show_gold(pos: Vector2, amount: int) -> void:
	show_text(pos, "+%dG" % amount, Color(1.0, 0.84, 0.0, 1), 1.0)

func show_pickup(pos: Vector2, item_name: String) -> void:
	show_text(pos, "获得%s！" % item_name, Color(0.8, 1.0, 0.8, 1), 1.0)

func show_level_up(pos: Vector2, level: int) -> void:
	show_text(pos, "升级！等级%d" % level, Color(1.0, 0.84, 0.0, 1), 1.5)
