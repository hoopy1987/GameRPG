extends Node

var _enemies: Array = []
var _items: Array = []
var _quests: Array = []

func _init() -> void:
	_load_all()

func _load_json(path: String) -> Array:
	var json := JSON.new()
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		print("数据加载器：无法打开 %s" % path)
		return []
	var text := file.get_as_text()
	file.close()
	var err := json.parse(text)
	if err != OK:
		print("数据加载器：JSON解析错误 %s：%s" % [path, json.get_error_message()])
		return []
	var data = json.data
	if data is Array:
		return data
	return []

func _load_all() -> void:
	_enemies = _load_json("res://data/enemies.json")
	_items = _load_json("res://data/items.json")
	_quests = _load_json("res://data/quests.json")
	print("数据加载器：已加载 %d 个敌人，%d 个物品，%d 个任务" % [_enemies.size(), _items.size(), _quests.size()])

func get_enemies() -> Array:
	return _enemies.duplicate()

func get_enemy(id: String) -> Dictionary:
	for e in _enemies:
		if e.get("id", "") == id:
			return e.duplicate()
	return {}

func get_items() -> Array:
	return _items.duplicate()

func get_item(id: String) -> Dictionary:
	for item in _items:
		if item.get("id", "") == id:
			return item.duplicate()
	return {}

func get_quests() -> Array:
	return _quests.duplicate()

func get_quest(id: String) -> Dictionary:
	for q in _quests:
		if q.get("id", "") == id:
			return q.duplicate()
	return {}
