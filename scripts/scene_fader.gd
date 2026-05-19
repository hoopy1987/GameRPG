extends CanvasLayer

@onready var fader: ColorRect = $ColorRect

func _ready() -> void:
	fader.color = Color(0, 0, 0, 0)
	fader.visible = true
	fader.z_index = 100
	fader.set_deferred("size", Vector2(1920, 1080))

func fade_out(duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(fader, "color:a", 1.0, duration)
	await tween.finished

func fade_in(duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(fader, "color:a", 0.0, duration)
	await tween.finished

func transition(callback: Callable, out_duration: float = 0.5, in_duration: float = 0.5) -> void:
	await fade_out(out_duration)
	callback.call()
	await fade_in(in_duration)
