extends Node2D

@onready var tile_map: TileMapLayer = $TileMapLayer

# Atlas coordinates (reuse existing tileset)
const DIRT := Vector2i(1, 0)
const STONE := Vector2i(2, 0)
const WALL := Vector2i(0, 1)
const WOOD := Vector2i(2, 1)

# Cave dimensions (tiles)
const CAVE_W := 60
const CAVE_H := 40
const TILE_SIZE := 32

func _ready() -> void:
	generate_cave()
	print("矿洞生成完毕: %dx%d tiles" % [CAVE_W, CAVE_H])

func generate_cave() -> void:
	if not tile_map:
		return

	# 1. Base floor - stone ground
	for x in range(CAVE_W):
		for y in range(CAVE_H):
			# Add variation to floor
			if randf() < 0.1:
				tile_map.set_cell(Vector2i(x, y), 0, DIRT)
			else:
				tile_map.set_cell(Vector2i(x, y), 0, STONE)

	# 2. Outer walls
	for x in range(CAVE_W):
		tile_map.set_cell(Vector2i(x, 0), 0, WALL)
		tile_map.set_cell(Vector2i(x, CAVE_H - 1), 0, WALL)
	for y in range(CAVE_H):
		tile_map.set_cell(Vector2i(0, y), 0, WALL)
		tile_map.set_cell(Vector2i(CAVE_W - 1, y), 0, WALL)

	# 3. Main passage from entrance to boss room
	_build_main_passage()

	# 4. Side chambers
	_build_side_chambers()

	# 5. Boss room (large chamber at the end)
	_build_boss_room()

	# 6. Entrance area (connects back to world)
	_build_entrance_area()

	# 7. Decorative elements
	_build_decorations()

func _build_main_passage() -> void:
	# Central corridor: x=28-32, y=5 to y=30
	for y in range(5, 30):
		for x in range(26, 34):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)

	# Clear walls in passage
	for y in range(5, 30):
		for x in range(26, 34):
			var existing = tile_map.get_cell_atlas_coords(Vector2i(x, y))
			if existing == WALL:
				tile_map.set_cell(Vector2i(x, y), 0, STONE)

func _build_side_chambers() -> void:
	# Left chamber 1 (x=8-20, y=10-18)
	_build_chamber(8, 10, 20, 18, 14, 14)
	
	# Right chamber 1 (x=40-52, y=12-20)
	_build_chamber(40, 12, 52, 20, 46, 16)
	
	# Left chamber 2 (x=10-22, y=24-32)
	_build_chamber(10, 24, 22, 32, 16, 28)

func _build_chamber(x1: int, y1: int, x2: int, y2: int, door_x: int, door_y: int) -> void:
	# Room interior
	for x in range(x1, x2):
		for y in range(y1, y2):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)
	
	# Room walls
	for x in range(x1, x2):
		tile_map.set_cell(Vector2i(x, y1), 0, WALL)
		tile_map.set_cell(Vector2i(x, y2 - 1), 0, WALL)
	for y in range(y1, y2):
		tile_map.set_cell(Vector2i(x1, y), 0, WALL)
		tile_map.set_cell(Vector2i(x2 - 1, y), 0, WALL)
	
	# Doorway connecting to main passage
	if door_x >= x1 and door_x < x2 and door_y >= y1 and door_y < y2:
		tile_map.set_cell(Vector2i(door_x, door_y), 0, STONE)
		if door_y == y1 or door_y == y2 - 1:
			# Horizontal wall door
			tile_map.set_cell(Vector2i(door_x, door_y), 0, STONE)
			tile_map.set_cell(Vector2i(door_x - 1, door_y), 0, WALL)
			tile_map.set_cell(Vector2i(door_x + 1, door_y), 0, WALL)
		else:
			# Vertical wall door
			tile_map.set_cell(Vector2i(door_x, door_y), 0, STONE)
			tile_map.set_cell(Vector2i(door_x, y1), 0, WALL)
			tile_map.set_cell(Vector2i(door_x, y2 - 1), 0, WALL)

func _build_boss_room() -> void:
	# Large chamber at bottom: x=20-40, y=30-38
	for x in range(18, 42):
		for y in range(30, 38):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)
	
	# Boss room walls
	for x in range(18, 42):
		tile_map.set_cell(Vector2i(x, 30), 0, WALL)
		tile_map.set_cell(Vector2i(x, 37), 0, WALL)
	for y in range(30, 38):
		tile_map.set_cell(Vector2i(18, y), 0, WALL)
		tile_map.set_cell(Vector2i(41, y), 0, WALL)
	
	# Doorway from main passage
	tile_map.set_cell(Vector2i(30, 30), 0, STONE)
	tile_map.set_cell(Vector2i(29, 30), 0, WALL)
	tile_map.set_cell(Vector2i(31, 30), 0, WALL)

func _build_entrance_area() -> void:
	# Entrance at top center (y=1-4, x=26-34)
	for x in range(24, 36):
		for y in range(1, 5):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)
	
	# Wide entrance opening
	for x in range(26, 34):
		tile_map.set_cell(Vector2i(x, 0), 0, STONE)

func _build_decorations() -> void:
	# Random rock piles (using WOOD as debris/timber)
	var rock_positions = [
		Vector2i(15, 15), Vector2i(45, 15), Vector2i(12, 28),
		Vector2i(48, 25), Vector2i(25, 22), Vector2i(35, 22),
		Vector2i(20, 34), Vector2i(38, 34)
	]
	for pos in rock_positions:
		if randf() < 0.7:
			tile_map.set_cell(pos, 0, WOOD)
	
	# Crystal formations (using DIRT with specific pattern)
	var crystal_positions = [
		Vector2i(10, 12), Vector2i(50, 14), Vector2i(14, 26),
		Vector2i(46, 28), Vector2i(22, 33), Vector2i(36, 33)
	]
	for pos in crystal_positions:
		if randf() < 0.5:
			tile_map.set_cell(pos, 0, DIRT)

func _on_cave_entrance_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if SceneTransition and SceneTransition.has_method("change_scene"):
			SceneTransition.change_scene("res://scenes/world.tscn", Vector2(640, 100))
