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
	print("炭火村生成完毕: %dx%d tiles | 中心广场(%d,%d)-(%d,%d)"
		% [VILLAGE_W, VILLAGE_H, SQ_X1, SQ_Y1, SQ_X2, SQ_Y2])

func generate_village() -> void:
	if not tile_map:
		return

	# 1. Base ground with variation
	_fill_ground()

	# 2. Central square with fountain and decorations
	_build_central_square()

	# 3. Radial roads and alleys
	_build_main_roads()
	_build_alleys()

	# 4. Functional buildings with details
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

	# 7. Decorative details (signs, benches, wells, gardens)
	_add_details()

	# 8. Collision for water, walls, trees
	_generate_tile_collision()

# ---------------------------------------------------------------------------
# Base Ground — varied terrain
# ---------------------------------------------------------------------------
func _fill_ground() -> void:
	for x in range(VILLAGE_W):
		for y in range(VILLAGE_H):
			var noise := randf()
			var tile := GRASS
			if noise < 0.06:
				tile = SAND
			elif noise < 0.12:
				tile = DIRT
			tile_map.set_cell(Vector2i(x, y), 0, tile)

# ---------------------------------------------------------------------------
# Central Square: stone pavement + fountain + benches + notice board
# ---------------------------------------------------------------------------
func _build_central_square() -> void:
	# Stone pavement base
	for x in range(SQ_X1, SQ_X2 + 1):
		for y in range(SQ_Y1, SQ_Y2 + 1):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)

	# Fountain at center (2×2 water surrounded by stone rim)
	var fx := 39
	var fy := 21
	for dx in range(2):
		for dy in range(2):
			tile_map.set_cell(Vector2i(fx + dx, fy + dy), 0, WATER)

	# Stone rim around fountain
	for x in range(fx - 1, fx + 3):
		tile_map.set_cell(Vector2i(x, fy - 1), 0, STONE)
		tile_map.set_cell(Vector2i(x, fy + 2), 0, STONE)
	for y in range(fy - 1, fy + 3):
		tile_map.set_cell(Vector2i(fx - 1, y), 0, STONE)
		tile_map.set_cell(Vector2i(fx + 2, y), 0, STONE)

	# Benches near fountain (wood tile on stone, not walkable but decorative)
	tile_map.set_cell(Vector2i(37, 20), 0, WOOD)
	tile_map.set_cell(Vector2i(42, 20), 0, WOOD)
	tile_map.set_cell(Vector2i(37, 23), 0, WOOD)
	tile_map.set_cell(Vector2i(42, 23), 0, WOOD)

	# Notice board at square edge (south side)
	tile_map.set_cell(Vector2i(40, SQ_Y2), 0, WALL)

	# Flower patches at square corners
	tile_map.set_cell(Vector2i(SQ_X1, SQ_Y1), 0, DIRT)
	tile_map.set_cell(Vector2i(SQ_X2, SQ_Y1), 0, DIRT)
	tile_map.set_cell(Vector2i(SQ_X1, SQ_Y2), 0, DIRT)
	tile_map.set_cell(Vector2i(SQ_X2, SQ_Y2), 0, DIRT)

# ---------------------------------------------------------------------------
# Main Roads: 3 tiles wide, stone with dirt edges
# ---------------------------------------------------------------------------
func _build_main_roads() -> void:
	# North road
	for x in range(39, 42):
		for y in range(0, SQ_Y1):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)
	# Road edges
	for y in range(0, SQ_Y1):
		tile_map.set_cell(Vector2i(38, y), 0, DIRT)
		tile_map.set_cell(Vector2i(42, y), 0, DIRT)

	# South road
	for x in range(39, 42):
		for y in range(SQ_Y2 + 1, VILLAGE_H):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)
	for y in range(SQ_Y2 + 1, VILLAGE_H):
		tile_map.set_cell(Vector2i(38, y), 0, DIRT)
		tile_map.set_cell(Vector2i(42, y), 0, DIRT)

	# East road
	for x in range(SQ_X2 + 1, VILLAGE_W):
		for y in range(21, 24):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)
	for x in range(SQ_X2 + 1, VILLAGE_W):
		tile_map.set_cell(Vector2i(x, 20), 0, DIRT)
		tile_map.set_cell(Vector2i(x, 24), 0, DIRT)

	# West road
	for x in range(0, SQ_X1):
		for y in range(21, 24):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)
	for x in range(0, SQ_X1):
		tile_map.set_cell(Vector2i(x, 20), 0, DIRT)
		tile_map.set_cell(Vector2i(x, 24), 0, DIRT)

# ---------------------------------------------------------------------------
# Alleys: 2 tiles wide, dirt, connecting buildings to roads
# ---------------------------------------------------------------------------
func _build_alleys() -> void:
	# Blacksmith alley (from E road to blacksmith)
	for x in range(56, 58):
		for y in range(15, 19):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Church alley (from W road to church)
	for x in range(19, 21):
		for y in range(12, 14):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Houses alley (vertical from S road to houses)
	for x in range(55, 57):
		for y in range(25, 40):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Market alley (horizontal from square to market)
	for x in range(43, 48):
		for y in range(21, 23):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Cross alley: connects church alley to north road
	for x in range(19, 21):
		for y in range(14, 19):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Cross alley: connects blacksmith alley to north road
	for x in range(56, 58):
		for y in range(8, 15):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Additional: tavern alley from S road
	for x in range(34, 36):
		for y in range(28, 30):
			tile_map.set_cell(Vector2i(x, y), 0, DIRT)

# ---------------------------------------------------------------------------
# Blacksmith: NE quadrant with chimney and forge sign
# ---------------------------------------------------------------------------
func _build_blacksmith() -> void:
	var bx := 52
	var by := 8
	var bw := 9
	var bh := 7
	_build_building(bx, by, bw, bh, WOOD, WALL, ROOF)
	# Chimney on roof (wall tile extending up)
	tile_map.set_cell(Vector2i(bx + 1, by - 2), 0, WALL)
	tile_map.set_cell(Vector2i(bx + 1, by - 3), 0, WALL)
	# Forge sign (wall tile on roof edge)
	tile_map.set_cell(Vector2i(bx + bw / 2, by - 1), 0, WALL)
	# Anvil marker inside (stone tile)
	tile_map.set_cell(Vector2i(bx + 2, by + 2), 0, STONE)

# ---------------------------------------------------------------------------
# Tavern: South of center with larger footprint and sign
# ---------------------------------------------------------------------------
func _build_tavern() -> void:
	var tx := 33
	var ty := 30
	var tw := 15
	var th := 9
	_build_building(tx, ty, tw, th, WOOD, WALL, ROOF)
	# Tavern sign post
	tile_map.set_cell(Vector2i(tx + tw / 2, ty - 1), 0, WALL)
	# Chimney
	tile_map.set_cell(Vector2i(tx + tw - 2, ty - 2), 0, WALL)
	tile_map.set_cell(Vector2i(tx + tw - 2, ty - 3), 0, WALL)
	# Outdoor seating area (stone patio)
	for x in range(tx + 2, tx + tw - 2):
		for y in range(ty + th, ty + th + 2):
			if y < VILLAGE_H:
				tile_map.set_cell(Vector2i(x, y), 0, STONE)

# ---------------------------------------------------------------------------
# Houses: Southeast, 5 small houses with gardens
# ---------------------------------------------------------------------------
func _build_houses() -> void:
	_build_small_house(52, 28, 7, 5, true)   # House 1 with garden
	_build_small_house(60, 28, 7, 5, true)   # House 2 with garden
	_build_small_house(52, 34, 7, 5, false)  # House 3
	_build_small_house(60, 34, 7, 5, true)   # House 4 with garden
	_build_small_house(56, 40, 7, 5, false)  # House 5

func _build_small_house(x: int, y: int, w: int, h: int, has_garden: bool = false) -> void:
	_build_building(x, y, w, h, WOOD, WALL, ROOF)
	# Small chimney
	tile_map.set_cell(Vector2i(x + 1, y - 2), 0, WALL)
	if has_garden:
		# Garden patch in front (dirt with possible flower spots)
		var gx := x + w / 2
		var gy := y + h
		if gy < VILLAGE_H - 1:
			tile_map.set_cell(Vector2i(gx, gy), 0, DIRT)
			tile_map.set_cell(Vector2i(gx + 1, gy), 0, DIRT)
			if gy + 1 < VILLAGE_H:
				tile_map.set_cell(Vector2i(gx, gy + 1), 0, GRASS)
				tile_map.set_cell(Vector2i(gx + 1, gy + 1), 0, GRASS)

# ---------------------------------------------------------------------------
# Church: Northwest with bell tower and cemetery
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
	tile_map.set_cell(Vector2i(cx + cw / 2, cy - 3), 0, WALL)
	# Small cemetery markers (stone tiles outside)
	for i in range(3):
		var sx := cx + cw + 1 + i
		var sy := cy + 2 + i * 2
		if sx < VILLAGE_W and sy < VILLAGE_H:
			tile_map.set_cell(Vector2i(sx, sy), 0, STONE)

# ---------------------------------------------------------------------------
# Market: East of square, 4 stalls with canopy
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
	# Market ground (stone for market area)
	for x in range(47, 55):
		for y in range(16, 24):
			if _is_walkable_area(x, y):
				tile_map.set_cell(Vector2i(x, y), 0, STONE)

func _build_stall(x: int, y: int) -> void:
	# 2×2 stall: wood counter + roof overhead
	for dx in range(2):
		for dy in range(2):
			var sx := x + dx
			var sy := y + dy
			tile_map.set_cell(Vector2i(sx, sy), 0, WOOD)
	# Roof canopy overhang
	for dx in range(-1, 3):
		tile_map.set_cell(Vector2i(x + dx, y - 1), 0, ROOF)
	for dy in range(-1, 2):
		tile_map.set_cell(Vector2i(x - 1, y + dy), 0, ROOF)
		tile_map.set_cell(Vector2i(x + 2, y + dy), 0, ROOF)

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

	# Windows (wall tiles replaced with wood on side walls)
	if h > 4:
		var win_y1 := y + 2
		var win_y2 := y + h - 3
		if win_y1 < win_y2:
			tile_map.set_cell(Vector2i(x, win_y1), 0, WOOD)
			tile_map.set_cell(Vector2i(x + w - 1, win_y1), 0, WOOD)
		if win_y2 > win_y1:
			tile_map.set_cell(Vector2i(x, win_y2), 0, WOOD)
			tile_map.set_cell(Vector2i(x + w - 1, win_y2), 0, WOOD)

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
	# South farmland (wider)
	for x in range(5, 75):
		for y in range(44, 45):
			if randf() < 0.7:
				tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# East farmland
	for x in range(78, 80):
		for y in range(5, 40):
			if randf() < 0.5:
				tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# West farmland
	for x in range(0, 2):
		for y in range(10, 35):
			if randf() < 0.4:
				tile_map.set_cell(Vector2i(x, y), 0, DIRT)

	# Scattered crop patches inside (near houses)
	for i in range(10):
		var cx := 50 + randi() % 15
		var cy := 25 + randi() % 15
		if cy < VILLAGE_H - 1 and _is_walkable_area(cx, cy):
			tile_map.set_cell(Vector2i(cx, cy), 0, DIRT)

# ---------------------------------------------------------------------------
# Trees: outside fence and scattered inside
# ---------------------------------------------------------------------------
func _scatter_trees() -> void:
	# Dense forest outside
	for i in range(80):
		var tx := randi() % VILLAGE_W
		var ty := randi() % VILLAGE_H
		var outside := (tx < 2 or tx > 76 or ty < 2 or ty > 42)
		var corner := ((tx < 8 and ty < 12) or (tx > 68 and ty > 33))
		if outside or corner:
			var cell := tile_map.get_cell_atlas_coords(Vector2i(tx, ty))
			if cell == GRASS or cell == SAND or cell == DIRT:
				tile_map.set_cell(Vector2i(tx, ty), 0, WALL)

	# A few trees inside for shade / decoration (avoid roads and buildings)
	for i in range(12):
		var tx := randi() % VILLAGE_W
		var ty := randi() % VILLAGE_H
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
# Decorative details — signs, wells, lanterns, barrels
# ---------------------------------------------------------------------------
func _add_details() -> void:
	# Lantern posts along roads near square (wall tiles, but on road edges)
	tile_map.set_cell(Vector2i(38, 18), 0, WALL)
	tile_map.set_cell(Vector2i(42, 18), 0, WALL)
	tile_map.set_cell(Vector2i(38, 25), 0, WALL)
	tile_map.set_cell(Vector2i(42, 25), 0, WALL)

	# Village entrance signs (south road)
	tile_map.set_cell(Vector2i(38, 40), 0, WALL)
	tile_map.set_cell(Vector2i(42, 40), 0, WALL)

	# Well near market
	tile_map.set_cell(Vector2i(46, 19), 0, WATER)
	tile_map.set_cell(Vector2i(46, 20), 0, STONE)

	# Barrels and crates near tavern
	for i in range(8):
		var rx := 48 + randi() % 10
		var ry := 32 + randi() % 6
		var cell := tile_map.get_cell_atlas_coords(Vector2i(rx, ry))
		if cell == GRASS or cell == DIRT:
			tile_map.set_cell(Vector2i(rx, ry), 0, WOOD)

	# Random flower patches near houses
	for i in range(6):
		var fx := 50 + randi() % 16
		var fy := 26 + randi() % 18
		var cell := tile_map.get_cell_atlas_coords(Vector2i(fx, fy))
		if cell == GRASS:
			tile_map.set_cell(Vector2i(fx, fy), 0, DIRT)

	# Signpost at crossroads (center of square)
	tile_map.set_cell(Vector2i(40, 18), 0, WALL)

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
