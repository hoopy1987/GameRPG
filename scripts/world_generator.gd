extends Node2D

@onready var tile_map: TileMapLayer = $TileMapLayer

# Atlas coordinates (matching new_tileset.tres)
const GRASS := Vector2i(0, 0)
const DIRT := Vector2i(1, 0)
const STONE := Vector2i(2, 0)
const WATER := Vector2i(3, 0)
const WALL := Vector2i(0, 1)
const ROOF := Vector2i(1, 1)
const WOOD := Vector2i(2, 1)
const SAND := Vector2i(3, 1)

# Village dimensions (tiles)
const VILLAGE_W := 80
const VILLAGE_H := 45
const TILE_SIZE := 32

# Central square (6×6, centered at 40,22)
const SQ_X1 := 37
const SQ_X2 := 42
const SQ_Y1 := 19
const SQ_Y2 := 24

func _ready() -> void:
	generate_village()
	print("炭火村生成完毕: %dx%d  tiles | 中心广场(%d,%d)-(%d,%d)"
		% [VILLAGE_W, VILLAGE_H, SQ_X1, SQ_Y1, SQ_X2, SQ_Y2])

func generate_village() -> void:
	if not tile_map:
		return

	# 1. Base ground
	_fill_ground()

	# 2. Central square
	_build_central_square()

	# 3. Radial roads
	_build_main_roads()
	_build_alleys()

	# 4. Functional buildings
	_build_blacksmith()
	_build_tavern()
	_build_houses()
	_build_church()
	_build_market()

	# 5. Perimeter fence
	_build_fence()

	# 6. Outer farmland & trees
	_build_farmland()
	_scatter_trees()

	# 7. Decorative details
	_add_details()

	# 8. Collision
	_generate_tile_collision()

# ---------------------------------------------------------------------------
# Base Ground
# ---------------------------------------------------------------------------
func _fill_ground() -> void:
	for x in range(VILLAGE_W):
		for y in range(VILLAGE_H):
			var noise := randf()
			var tile := GRASS
			if noise < 0.08:
				tile = SAND
			tile_map.set_cell(Vector2i(x, y), 0, tile)

# ---------------------------------------------------------------------------
# Central Square: 6×6 stone pavement + fountain
# ---------------------------------------------------------------------------
func _build_central_square() -> void:
	for x in range(SQ_X1, SQ_X2 + 1):
		for y in range(SQ_Y1, SQ_Y2 + 1):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)

	# Fountain at center (2×2 water surrounded by stone)
	var fx := 39
	var fy := 21
	for dx in range(2):
		for dy in range(2):
			tile_map.set_cell(Vector2i(fx + dx, fy + dy), 0, WATER)

	# Notice board at square edge (south side, center)
	# Represented as a wall tile for visual contrast
	tile_map.set_cell(Vector2i(40, SQ_Y2), 0, WOOD)

# ---------------------------------------------------------------------------
# Main Roads: 3 tiles wide, stone
# ---------------------------------------------------------------------------
func _build_main_roads() -> void:
	# North road
	for x in range(39, 42):
		for y in range(0, SQ_Y1):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)

	# South road
	for x in range(39, 42):
		for y in range(SQ_Y2 + 1, VILLAGE_H):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)

	# East road
	for x in range(SQ_X2 + 1, VILLAGE_W):
		for y in range(21, 24):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)

	# West road
	for x in range(0, SQ_X1):
		for y in range(21, 24):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)

# ---------------------------------------------------------------------------
# Alleys: 2 tiles wide, dirt, connecting buildings to roads
# ---------------------------------------------------------------------------
func _build_alleys() -> void:
	# Blacksmith alley (from E road to blacksmith, y=15-18, x=56-57)
	for x in range(56, 58):
		for y in range(15, 19):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Church alley (from W road to church, x=19-20, y=12-13)
	for x in range(19, 21):
		for y in range(12, 14):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Houses alley (vertical from S road to houses, x=55-56, y=25-39)
	for x in range(55, 57):
		for y in range(25, 40):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Market alley (horizontal from square to market, x=43-47, y=21-22)
	for x in range(43, 48):
		for y in range(21, 23):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Cross alley: connects church alley to north road (x=19-20, y=14-18)
	for x in range(19, 21):
		for y in range(14, 19):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Cross alley: connects blacksmith alley to north road (x=56-57, y=8-14)
	for x in range(56, 58):
		for y in range(8, 15):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

# ---------------------------------------------------------------------------
# Blacksmith: NE quadrant
# ---------------------------------------------------------------------------
func _build_blacksmith() -> void:
	var bx := 52
	var by := 8
	var bw := 9
	var bh := 7
	_build_building(bx, by, bw, bh, WOOD, WALL, ROOF)
	# Forge sign (wall tile on roof edge above door)
	tile_map.set_cell(Vector2i(bx + bw / 2, by - 1), 0, WALL)

# ---------------------------------------------------------------------------
# Tavern: South of center
# ---------------------------------------------------------------------------
func _build_tavern() -> void:
	var tx := 33
	var ty := 30
	var tw := 15
	var th := 9
	_build_building(tx, ty, tw, th, WOOD, WALL, ROOF)
	# Tavern sign
	tile_map.set_cell(Vector2i(tx + tw / 2, ty - 1), 0, WALL)

# ---------------------------------------------------------------------------
# Houses: Southeast, 5 small houses
# ---------------------------------------------------------------------------
func _build_houses() -> void:
	# House 1
	_build_small_house(52, 28, 7, 5)
	# House 2
	_build_small_house(60, 28, 7, 5)
	# House 3
	_build_small_house(52, 34, 7, 5)
	# House 4
	_build_small_house(60, 34, 7, 5)
	# House 5 (slightly offset)
	_build_small_house(56, 40, 7, 5)

func _build_small_house(x: int, y: int, w: int, h: int) -> void:
	_build_building(x, y, w, h, WOOD, WALL, ROOF)
	# Small garden patch in front (2×1 dirt)
	var gx := x + w / 2
	var gy := y + h
	if gy < VILLAGE_H - 1:
		tile_map.set_cell(Vector2i(gx, gy), 0, DIRT)
		if gx + 1 < VILLAGE_W:
			tile_map.set_cell(Vector2i(gx + 1, gy), 0, DIRT)

# ---------------------------------------------------------------------------
# Church: Northwest
# ---------------------------------------------------------------------------
func _build_church() -> void:
	var cx := 8
	var cy := 7
	var cw := 11
	var ch := 11
	_build_building(cx, cy, cw, ch, STONE, WALL, ROOF)
	# Bell tower (extra wall tiles on roof)
	tile_map.set_cell(Vector2i(cx + cw / 2, cy - 1), 0, WALL)
	tile_map.set_cell(Vector2i(cx + cw / 2, cy - 2), 0, WALL)

# ---------------------------------------------------------------------------
# Market: East of square, 4 stalls
# ---------------------------------------------------------------------------
func _build_market() -> void:
	# Stall 1
	_build_stall(48, 17)
	# Stall 2
	_build_stall(52, 17)
	# Stall 3
	_build_stall(48, 21)
	# Stall 4
	_build_stall(52, 21)

func _build_stall(x: int, y: int) -> void:
	# 2×2 stall: wood counter + roof overhead
	for dx in range(2):
		for dy in range(2):
			var sx := x + dx
			var sy := y + dy
			tile_map.set_cell(Vector2i(sx, sy), 0, WOOD)
	# Roof overhang
	for dx in range(2):
		tile_map.set_cell(Vector2i(x + dx, y - 1), 0, ROOF)

# ---------------------------------------------------------------------------
# Generic building builder
# ---------------------------------------------------------------------------
func _build_building(x: int, y: int, w: int, h: int,
					 floor: Vector2i, wall: Vector2i, roof: Vector2i) -> void:
	# Floor
	for hx in range(x, x + w):
		for hy in range(y, y + h):
			tile_map.set_cell(Vector2i(hx, hy), 0, floor)

	# Walls (perimeter)
	for hx in range(x, x + w):
		tile_map.set_cell(Vector2i(hx, y), 0, wall)
		tile_map.set_cell(Vector2i(hx, y + h - 1), 0, wall)
	for hy in range(y, y + h):
		tile_map.set_cell(Vector2i(x, hy), 0, wall)
		tile_map.set_cell(Vector2i(x + w - 1, hy), 0, wall)

	# Door (stone tile in bottom wall, center)
	var door_x := x + w / 2
	tile_map.set_cell(Vector2i(door_x, y + h - 1), 0, STONE)

	# Roof overhang
	for hx in range(x - 1, x + w + 1):
		tile_map.set_cell(Vector2i(hx, y - 1), 0, roof)
	for hy in range(y - 1, y + h):
		tile_map.set_cell(Vector2i(x - 1, hy), 0, roof)
		tile_map.set_cell(Vector2i(x + w, hy), 0, roof)

	# Add collision for walls
	var walls := Node2D.new()
	walls.name = "BuildingWalls_%d_%d" % [x, y]
	add_child(walls)
	# Top wall
	_add_wall_collision(walls, Vector2((x + w / 2.0) * TILE_SIZE, y * TILE_SIZE), Vector2(w * TILE_SIZE, 8))
	# Bottom wall (split at door)
	var door_tile_x := door_x
	if door_tile_x > x:
		var left_width := (door_tile_x - x) * TILE_SIZE
		_add_wall_collision(walls, Vector2((x + (door_tile_x - x) / 2.0) * TILE_SIZE, (y + h - 1) * TILE_SIZE), Vector2(left_width, 8))
	if door_tile_x < x + w - 1:
		var right_start := door_tile_x + 1
		var right_width := (x + w - right_start) * TILE_SIZE
		_add_wall_collision(walls, Vector2((right_start + (x + w - right_start) / 2.0) * TILE_SIZE, (y + h - 1) * TILE_SIZE), Vector2(right_width, 8))
	# Left wall
	_add_wall_collision(walls, Vector2(x * TILE_SIZE, (y + h / 2.0) * TILE_SIZE), Vector2(8, h * TILE_SIZE))
	# Right wall
	_add_wall_collision(walls, Vector2((x + w - 1) * TILE_SIZE, (y + h / 2.0) * TILE_SIZE), Vector2(8, h * TILE_SIZE))

# ---------------------------------------------------------------------------
# Fence around perimeter (1 tile inside boundary)
# ---------------------------------------------------------------------------
func _build_fence() -> void:
	var fx1 := 1
	var fx2 := VILLAGE_W - 2
	var fy1 := 1
	var fy2 := VILLAGE_H - 2

	# Top fence (gap at north road)
	for x in range(fx1, fx2 + 1):
		if x < 39 or x > 41:
			tile_map.set_cell(Vector2i(x, fy1), 0, WALL)

	# Bottom fence (gap at south road)
	for x in range(fx1, fx2 + 1):
		if x < 39 or x > 41:
			tile_map.set_cell(Vector2i(x, fy2), 0, WALL)

	# Left fence (gap at west road)
	for y in range(fy1, fy2 + 1):
		if y < 21 or y > 23:
			tile_map.set_cell(Vector2i(fx1, y), 0, WALL)

	# Right fence (gap at east road)
	for y in range(fy1, fy2 + 1):
		if y < 21 or y > 23:
			tile_map.set_cell(Vector2i(fx2, y), 0, WALL)

# ---------------------------------------------------------------------------
# Farmland outside fence
# ---------------------------------------------------------------------------
func _build_farmland() -> void:
	# South farmland
	for x in range(10, 70):
		for y in range(44, 45):
			if randf() < 0.6:
				tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# East farmland
	for x in range(78, 80):
		for y in range(10, 35):
			if randf() < 0.4:
				tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# West farmland (small patch)
	for x in range(0, 1):
		for y in range(15, 30):
			if randf() < 0.3:
				tile_map.set_cell(Vector2i(x, y), 0, DIRT)

# ---------------------------------------------------------------------------
# Trees: outside fence and scattered inside
# ---------------------------------------------------------------------------
func _scatter_trees() -> void:
	# Dense forest outside
	for i in range(60):
		var tx := randi() % VILLAGE_W
		var ty := randi() % VILLAGE_H
		# Outside fence or in corners
		var outside := (tx < 1 or tx > 77 or ty < 1 or ty > 43)
		var corner := ((tx < 5 and ty < 10) or (tx > 70 and ty > 35))
		if outside or corner:
			var cell := tile_map.get_cell_atlas_coords(Vector2i(tx, ty))
			if cell == GRASS or cell == SAND or cell == DIRT:
				tile_map.set_cell(Vector2i(tx, ty), 0, WALL)

	# A few trees inside for shade / decoration
	for i in range(8):
		var tx := randi() % VILLAGE_W
		var ty := randi() % VILLAGE_H
		# Avoid roads, square, buildings
		if _is_walkable_area(tx, ty):
			continue
		var cell := tile_map.get_cell_atlas_coords(Vector2i(tx, ty))
		if cell == GRASS:
			tile_map.set_cell(Vector2i(tx, ty), 0, WALL)

func _is_walkable_area(x: int, y: int) -> bool:
	# Central square
	if x >= SQ_X1 and x <= SQ_X2 and y >= SQ_Y1 and y <= SQ_Y2:
		return true
	# Main roads (3-wide)
	if (x >= 39 and x <= 41) or (y >= 21 and y <= 23):
		return true
	# Building zones (rough)
	if (x >= 8 and x <= 18 and y >= 7 and y <= 17):   # church
		return true
	if (x >= 52 and x <= 60 and y >= 8 and y <= 14):  # blacksmith
		return true
	if (x >= 33 and x <= 47 and y >= 30 and y <= 38): # tavern
		return true
	if (x >= 48 and x <= 58 and y >= 16 and y <= 26): # market
		return true
	if (x >= 52 and x <= 66 and y >= 28 and y <= 44): # houses
		return true
	return false

# ---------------------------------------------------------------------------
# Decorative details
# ---------------------------------------------------------------------------
func _add_details() -> void:
	# Lanterns along main roads near square
	tile_map.set_cell(Vector2i(38, 20), 0, WALL)
	tile_map.set_cell(Vector2i(43, 20), 0, WALL)
	tile_map.set_cell(Vector2i(38, 23), 0, WALL)
	tile_map.set_cell(Vector2i(43, 23), 0, WALL)

	# Benches near fountain
	tile_map.set_cell(Vector2i(37, 20), 0, WOOD)
	tile_map.set_cell(Vector2i(42, 20), 0, WOOD)

	# Wells at road intersections
	tile_map.set_cell(Vector2i(39, 18), 0, WATER)
	tile_map.set_cell(Vector2i(41, 18), 0, WATER)

	# Random barrels / crates near tavern and blacksmith
	for i in range(6):
		var rx := 50 + randi() % 15
		var ry := 30 + randi() % 10
		var cell := tile_map.get_cell_atlas_coords(Vector2i(rx, ry))
		if cell == GRASS or cell == DIRT:
			tile_map.set_cell(Vector2i(rx, ry), 0, WOOD)

	# Signs at village entrance (south road)
	tile_map.set_cell(Vector2i(38, 40), 0, WALL)
	tile_map.set_cell(Vector2i(42, 40), 0, WALL)

# ---------------------------------------------------------------------------
# Collision generation for water, trees, walls
# ---------------------------------------------------------------------------
func _generate_tile_collision() -> void:
	var obstacles := Node2D.new()
	obstacles.name = "ObstacleCollisions"
	add_child(obstacles)

	var used_cells := tile_map.get_used_cells()
	for cell_pos in used_cells:
		var atlas := tile_map.get_cell_atlas_coords(cell_pos)
		if atlas == WATER or atlas == WALL:
			var body := StaticBody2D.new()
			body.collision_layer = 1
			body.collision_mask = 0
			var shape := CollisionShape2D.new()
			var rect := RectangleShape2D.new()
			rect.size = Vector2(TILE_SIZE, TILE_SIZE)
			shape.shape = rect
			shape.position = Vector2(cell_pos.x * TILE_SIZE + TILE_SIZE / 2, cell_pos.y * TILE_SIZE + TILE_SIZE / 2)
			body.add_child(shape)
			obstacles.add_child(body)

func _add_wall_collision(parent: Node, pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = pos
	body.add_child(shape)
	parent.add_child(body)
