extends Node

@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

const SOUNDS := {
	"sword_swing": "res://assets/sounds/sword_swing.wav",
	"hit_damage": "res://assets/sounds/hit_damage.wav",
	"pickup": "res://assets/sounds/pickup.wav",
	"level_up": "res://assets/sounds/level_up.wav",
	"enemy_die": "res://assets/sounds/enemy_die.wav",
	"player_hurt": "res://assets/sounds/player_hurt.wav",
	"footstep": "res://assets/sounds/footstep.wav",
}

func _ready() -> void:
	add_child(bgm_player)
	add_child(sfx_player)
	bgm_player.bus = "BGM"
	sfx_player.bus = "SFX"
	play_bgm()

func play_sfx(name: String) -> void:
	if not SOUNDS.has(name):
		return
	var stream = load(SOUNDS[name])
	if stream == null:
		return
	# 复用同一个 player，如果正在播放会打断，但对于短时间SFX可以接受
	# 如果需要叠加，后续可以换成 Pool 模式
	sfx_player.stream = stream
	sfx_player.play()

func play_sfx_at(name: String, pos: Vector2) -> void:
	# 2D空间音效版本（可选扩展）
	play_sfx(name)

func play_bgm() -> void:
	var stream = load("res://assets/sounds/bgm_loop.wav")
	if stream == null:
		return
	bgm_player.stream = stream
	bgm_player.play()
	# BGM循环：用finished信号重播
	if not bgm_player.finished.is_connected(_on_bgm_finished):
		bgm_player.finished.connect(_on_bgm_finished)

func _on_bgm_finished() -> void:
	bgm_player.play()

func stop_bgm() -> void:
	bgm_player.stop()

func set_bgm_volume_db(db: float) -> void:
	bgm_player.volume_db = db

func set_sfx_volume_db(db: float) -> void:
	sfx_player.volume_db = db
