extends CanvasLayer

@onready var toast_label: Label = $ToastLabel

var toast_timer: float = 0.0

func _ready() -> void:
	toast_label.visible = false

func _process(delta: float) -> void:
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			hide_toast()

func show_toast(text: String, duration: float = 2.0) -> void:
	toast_label.text = text
	toast_label.visible = true
	toast_timer = duration
	
	# Center on screen
	var viewport_size := get_viewport().get_visible_rect().size
	toast_label.position = Vector2(
		(viewport_size.x - toast_label.size.x) / 2,
		viewport_size.y * 0.15
	)
	
	# Fade in
	toast_label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(toast_label, "modulate:a", 1.0, 0.2)

func hide_toast() -> void:
	var tween := create_tween()
	tween.tween_property(toast_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		toast_label.visible = false
	)
