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

	# 4. Functional buildings with interior details
	_build_blacksmith()
	_build_tavern()
	_build_houses()
	_build_church()
	_build_market()

	# 5. Stream and bridges
	_build_stream()
	_build_bridges()

	# 6. Perimeter fence
	_build_fence()

	# 7. Outer farmland & trees
	_build_farmland()
	_scatter_trees()

	# 8. Decorative details (signs, wells, lanterns, barrels, scarecrows)
	_add_details()

	# 9. Investigation points (signboards, gravestones, anvils)
	_add_investigation_points()

	# 10. Campfire rest spot
	_add_campfire()

	# 11. Destroyable barrels and crates
	_add_destroyables()

	# 12. Road edge irregularity
	_irregularize_roads()

	# 13. Collision for water, walls, trees
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
# Blacksmith: NE quadrant with chimney, forge sign, and interior details
# ---------------------------------------------------------------------------
func _build_blacksmith() -> void:
	var bx: int = 52
	var by: int = 8
	var bw := 9
	var bh := 7
	_build_building(bx, by, bw, bh, WOOD, WALL, ROOF)
	# Chimney on roof (wall tile extending up)
	tile_map.set_cell(Vector2i(bx + 1, by - 2), 0, WALL)
	tile_map.set_cell(Vector2i(bx + 1, by - 3), 0, WALL)
	# Forge sign (wall tile on roof edge)
	tile_map.set_cell(Vector2i(bx + bw / 2, by - 1), 0, WALL)
	# Anvil marker near back wall (stone tile)
	tile_map.set_cell(Vector2i(bx + 2, by + 1), 0, STONE)
	# Fuel pile corner (wood tiles)
	tile_map.set_cell(Vector2i(bx + bw - 2, by + bh - 2), 0, WOOD)
	tile_map.set_cell(Vector2i(bx + bw - 3, by + bh - 2), 0, WOOD)
	# Forge furnace (wall tile inside, near chimney)
	tile_map.set_cell(Vector2i(bx + 1, by + 1), 0, WALL)

# ---------------------------------------------------------------------------
# Tavern: South of center with bar counter, stage, beer barrels
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
	# Bar counter (stone row near north wall)
	for x in range(tx + 2, tx + tw - 2):
		tile_map.set_cell(Vector2i(x, ty + 1), 0, STONE)
	# Bar stools (wood tiles in front of bar)
	tile_map.set_cell(Vector2i(tx + 3, ty + 2), 0, WOOD)
	tile_map.set_cell(Vector2i(tx + 6, ty + 2), 0, WOOD)
	tile_map.set_cell(Vector2i(tx + 9, ty + 2), 0, WOOD)
	tile_map.set_cell(Vector2i(tx + 12, ty + 2), 0, WOOD)
	# Stage area (stone platform in SE corner)
	for x in range(tx + tw - 5, tx + tw - 1):
		for y in range(ty + th - 4, ty + th - 1):
			tile_map.set_cell(Vector2i(x, y), 0, STONE)
	# Beer barrels stacked (wood tiles near stage)
	tile_map.set_cell(Vector2i(tx + tw - 2, ty + 2), 0, WOOD)
	tile_map.set_cell(Vector2i(tx + tw - 2, ty + 3), 0, WOOD)
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
# Church: Northwest with bell tower, cemetery, altar, pews, stained glass
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
	# Altar (stone 2x2 at north interior)
	var ax := cx + cw / 2
	var ay := cy + 2
	tile_map.set_cell(Vector2i(ax, ay), 0, STONE)
	tile_map.set_cell(Vector2i(ax + 1, ay), 0, STONE)
	tile_map.set_cell(Vector2i(ax, ay + 1), 0, STONE)
	tile_map.set_cell(Vector2i(ax + 1, ay + 1), 0, STONE)
	# Pews / benches (wood rows facing altar, with aisle gap)
	for row_y in [cy + 5, cy + 7]:
		for px in range(cx + 2, cx + cw - 2):
			if px != ax and px != ax + 1:
				tile_map.set_cell(Vector2i(px, row_y), 0, WOOD)
	# Stained glass windows (wood tile replacing wall on sides)
	tile_map.set_cell(Vector2i(cx, cy + 3), 0, WOOD)
	tile_map.set_cell(Vector2i(cx + cw - 1, cy + 3), 0, WOOD)
	tile_map.set_cell(Vector2i(cx, cy + 6), 0, WOOD)
	tile_map.set_cell(Vector2i(cx + cw - 1, cy + 6), 0, WOOD)
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
# Stream: meandering from NW corner toward SE edge
# ---------------------------------------------------------------------------
func _build_stream() -> void:
	# Stream path: starts near church (x=3, y=5), meanders to south edge
	var stream_points := [
		Vector2i(3, 5), Vector2i(4, 6), Vector2i(5, 7), Vector2i(6, 8),
		Vector2i(7, 9), Vector2i(8, 10), Vector2i(9, 11), Vector2i(10, 12),
		Vector2i(11, 13), Vector2i(12, 14), Vector2i(13, 15), Vector2i(14, 16),
		Vector2i(15, 17), Vector2i(16, 18), Vector2i(17, 19), Vector2i(18, 20),
		Vector2i(19, 21), Vector2i(20, 22), Vector2i(21, 23), Vector2i(22, 24),
		Vector2i(23, 25), Vector2i(24, 26), Vector2i(25, 27), Vector2i(26, 28),
		Vector2i(27, 29), Vector2i(28, 30), Vector2i(29, 31), Vector2i(30, 32),
		Vector2i(31, 33), Vector2i(32, 34), Vector2i(33, 35), Vector2i(34, 36),
		Vector2i(35, 37), Vector2i(36, 38), Vector2i(37, 39), Vector2i(38, 40),
		Vector2i(39, 41), Vector2i(40, 42), Vector2i(41, 43), Vector2i(42, 44)
	]
	for pt in stream_points:
		if pt.x >= 0 and pt.x < VILLAGE_W and pt.y >= 0 and pt.y < VILLAGE_H:
			tile_map.set_cell(pt, 0, WATER)
	# Stream banks (stone tiles adjacent to water)
	for pt in stream_points:
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var bx: int = pt.x + dx
				var by: int = pt.y + dy
				if bx >= 0 and bx < VILLAGE_W and by >= 0 and by < VILLAGE_H:
					var cell := tile_map.get_cell_atlas_coords(Vector2i(bx, by))
					if cell == GRASS or cell == DIRT or cell == SAND:
						tile_map.set_cell(Vector2i(bx, by), 0, STONE)

# ---------------------------------------------------------------------------
# Bridges: 2 wooden bridges crossing the stream
# ---------------------------------------------------------------------------
func _build_bridges() -> void:
	# Bridge 1: near church alley crossing (around x=19, y=21)
	# Bridge spans 3 tiles across stream
	for x in range(18, 21):
		tile_map.set_cell(Vector2i(x, 21), 0, WOOD)
	# Bridge 2: near south edge (around x=38, y=40)
	for x in range(37, 40):
		tile_map.set_cell(Vector2i(x, 40), 0, WOOD)

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
# Decorative details — signs, wells, lanterns, barrels, scarecrows
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

	# Scarecrows in farmland (south edge, wall tile on dirt)
	if VILLAGE_H > 42:
		tile_map.set_cell(Vector2i(35, 43), 0, WALL)
		tile_map.set_cell(Vector2i(45, 43), 0, WALL)

	# Haystacks near tavern patio (wood tiles)
	tile_map.set_cell(Vector2i(35, 32), 0, WOOD)
	tile_map.set_cell(Vector2i(48, 32), 0, WOOD)

# ---------------------------------------------------------------------------
# Investigation points: signboards, gravestones, tavern board, anvil
# ---------------------------------------------------------------------------
func _add_investigation_points() -> void:
	var ip_parent := Node2D.new()
	ip_parent.name = "InvestigationPoints"
	add_child(ip_parent)

	# 1. Square notice board — shows available quests hint
	_add_investigation_point(ip_parent, Vector2(40, 24), "公告板",
		["【村庄公告板】",
		"~ 近期委托 ~",
		"• 铁匠格雷恩：急需矿洞深处的优质矿石",
		"• 草药师莉安娜：寻找稀有的月光草",
		"• 村长埃尔温：调查矿洞深处的古老遗迹",
		"",
		"（与对应NPC对话可接取任务）"])

	# 2. Church graveyard — village history fragments
	_add_investigation_point(ip_parent, Vector2(19, 9), "墓碑",
		["【无名墓碑】",
		"这里安息着炭火村的开拓者们。",
		"百年前，一群矿工在此发现了永不熄灭的炭火，",
		"于是建立了这个村庄。",
		"",
		"—— 愿圣光守护他们的灵魂"])

	# 3. Tavern signboard — shows daily specials
	_add_investigation_point(ip_parent, Vector2(40, 29), "酒馆木牌",
		["【金麦穗酒馆 · 今日特供】",
		"• 黑麦烈酒 —— 5铜币",
		"• 烤野猪肉 —— 12铜币",
		"• 蘑菇炖菜 —— 8铜币",
		"",
		"（传闻：酒馆老板知道很多消息……）"])

	# 4. Blacksmith anvil — forging tip
	_add_investigation_point(ip_parent, Vector2(54, 9), "铁砧",
		["【铁砧旁的便条】",
		"'矿石品质决定武器上限。'",
		"",
		"优质铁矿石 + 木炭 = 精良武器",
		"普通铁矿石 + 普通木材 = 基础武器",
		"",
		"—— 格雷恩·铁锤"])

	# 5. Well near market — rumor
	_add_investigation_point(ip_parent, Vector2(46, 19), "水井",
		["【村民的低语】",
		"据说矿洞最深处有什么东西在动……",
		"别一个人去，带上火把和剑。",
		"",
		"—— 两个村民的闲聊"])

func _add_investigation_point(parent: Node, tile_pos: Vector2, label_name: String, lines: Array[String]) -> void:
	var area := Area2D.new()
	area.name = "IP_" + label_name
	area.collision_layer = 1 << 2  # NPC layer, detectable by player queries
	area.collision_mask = 2
	area.position = Vector2(tile_pos.x * TILE_SIZE + TILE_SIZE / 2, tile_pos.y * TILE_SIZE + TILE_SIZE / 2)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 24.0
	shape.shape = circle
	area.add_child(shape)

	var label := Label.new()
	label.name = "Label"
	label.offset_left = -60.0
	label.offset_top = -40.0
	label.offset_right = 60.0
	label.offset_bottom = -20.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.theme_override_font_sizes.font_size = 10
	label.theme_override_colors.font_color = Color(1, 1, 0.8, 1)
	label.text = "[空格] 调查"
	label.visible = false
	area.add_child(label)

	# Store lines as metadata for interaction
	area.set_meta("investigation_lines", lines)
	area.set_meta("point_name", label_name)

	# Attach investigation script
	area.set_script(preload("res://scripts/investigation_point.gd"))

	# Connect signals for label visibility
	area.body_entered.connect(func(body: Node2D):
		if body.is_in_group("player"):
			label.visible = true
	)
	area.body_exited.connect(func(body: Node2D):
		if body.is_in_group("player"):
			label.visible = false
	)

	parent.add_child(area)

# ---------------------------------------------------------------------------
# Campfire rest spot: near tavern patio, heals player when standing nearby
# ---------------------------------------------------------------------------
func _add_campfire() -> void:
	var campfire := Node2D.new()
	campfire.name = "Campfire"
	campfire.position = Vector2(38 * TILE_SIZE + TILE_SIZE / 2, 33 * TILE_SIZE + TILE_SIZE / 2)
	add_child(campfire)

	# Fire particles
	var particles := CPUParticles2D.new()
	particles.name = "FireParticles"
	particles.amount = 30
	particles.lifetime = 0.8
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	particles.direction = Vector2(0, -1)
	particles.spread = 20.0
	particles.gravity = Vector2(0, -30)
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 25.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 5.0
	particles.color = Color(1.0, 0.4, 0.1, 0.9)
	particles.color_ramp = _create_fire_gradient()
	campfire.add_child(particles)

	# Interaction area
	var area := Area2D.new()
	area.name = "RestArea"
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 40.0
	shape.shape = circle
	area.add_child(shape)
	campfire.add_child(area)

	# Rest label
	var label := Label.new()
	label.name = "RestLabel"
	label.offset_left = -50.0
	label.offset_top = -50.0
	label.offset_right = 50.0
	label.offset_bottom = -30.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.theme_override_font_sizes.font_size = 10
	label.theme_override_colors.font_color = Color(1, 0.7, 0.3, 1)
	label.text = "[停留] 休息恢复"
	label.visible = false
	campfire.add_child(label)

	# Repeating timer for healing check (every 3 seconds)
	var timer := Timer.new()
	timer.name = "HealTimer"
	timer.wait_time = 3.0
	timer.one_shot = false
	campfire.add_child(timer)

	# Track player presence via meta (safe across lambda captures)
	campfire.set_meta("player_inside", false)

	timer.timeout.connect(func():
		if campfire.get_meta("player_inside", false):
			var player = get_tree().get_first_node_in_group("player") as Node2D
			if player and player.has_method("heal"):
				player.heal(10)
				if FloatingTextManager and FloatingTextManager.has_method("show_text"):
					FloatingTextManager.show_text(campfire.global_position + Vector2(0, -30), "+10 HP", Color(0.3, 1.0, 0.3, 1.0), 1.5)
				if SoundManager and SoundManager.has_method("play_sfx"):
					SoundManager.play_sfx("heal")
	)

	area.body_entered.connect(func(body: Node2D):
		if body.is_in_group("player"):
			campfire.set_meta("player_inside", true)
			label.visible = true
			if timer.is_stopped():
				timer.start()
	)

	area.body_exited.connect(func(body: Node2D):
		if body.is_in_group("player"):
			campfire.set_meta("player_inside", false)
			label.visible = false
			timer.stop()
	)

func _create_fire_gradient() -> Gradient:
	var grad := Gradient.new()
	grad.colors = [Color(1.0, 0.9, 0.2, 1.0), Color(1.0, 0.4, 0.1, 0.8), Color(0.6, 0.1, 0.05, 0.0)]
	grad.offsets = [0.0, 0.5, 1.0]
	return grad

# ---------------------------------------------------------------------------
# Destroyable barrels and crates: attack to break, drop items
# ---------------------------------------------------------------------------
func _add_destroyables() -> void:
	var dp := Node2D.new()
	dp.name = "Destroyables"
	add_child(dp)

	# Positions: near tavern, market, and houses
	var positions := [
		Vector2i(49, 33), Vector2i(51, 34), Vector2i(34, 33),
		Vector2i(50, 19), Vector2i(53, 22),
		Vector2i(55, 30), Vector2i(62, 30)
	]
	for pos in positions:
		_add_destroyable(dp, pos)

func _add_destroyable(parent: Node, tile_pos: Vector2i) -> void:
	var d := Area2D.new()
	d.name = "Destroyable_%d_%d" % [tile_pos.x, tile_pos.y]
	d.collision_layer = 4
	d.collision_mask = 2
	d.position = Vector2(tile_pos.x * TILE_SIZE + TILE_SIZE / 2, tile_pos.y * TILE_SIZE + TILE_SIZE / 2)

	# Sprite
	var sprite := Sprite2D.new()
	var tex := load("res://assets/generated/tile_wood.png") as Texture2D
	if not tex:
		# Fallback: try to find any wood-looking texture
		tex = load("res://assets/generated/tile_roof.png") as Texture2D
	if tex:
		sprite.texture = tex
		sprite.scale = Vector2(0.8, 0.8)
	d.add_child(sprite)

	# Collision
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(20, 20)
	shape.shape = rect
	d.add_child(shape)

	# Health / state
	d.set_meta("max_hp", 1)
	d.set_meta("current_hp", 1)

	# Interaction label
	var label := Label.new()
	label.name = "Label"
	label.offset_left = -30.0
	label.offset_top = -30.0
	label.offset_right = 30.0
	label.offset_bottom = -10.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.theme_override_font_sizes.font_size = 10
	label.theme_override_colors.font_color = Color(0.9, 0.3, 0.3, 1)
	label.text = "[攻击] 破坏"
	label.visible = false
	d.add_child(label)

	d.body_entered.connect(func(body: Node2D):
		if body.is_in_group("player"):
			label.visible = true
	)
	d.body_exited.connect(func(body: Node2D):
		if body.is_in_group("player"):
			label.visible = false
	)

	# Expose destroy method for player attack to call
	d.set_meta("can_interact", true)
	d.set_script(preload("res://scripts/destroyable.gd"))

	parent.add_child(d)

# ---------------------------------------------------------------------------
# Road edge irregularity: random patches of dirt/sand along road edges
# ---------------------------------------------------------------------------
func _irregularize_roads() -> void:
	for i in range(20):
		# Random patches along road edges
		var rx := 38 + randi() % 5
		var ry := randi() % VILLAGE_H
		if ry >= 0 and ry < VILLAGE_H and (ry < 19 or ry > 24):
			var cell := tile_map.get_cell_atlas_coords(Vector2i(rx, ry))
			if cell == GRASS or cell == DIRT:
				tile_map.set_cell(Vector2i(rx, ry), 0, SAND if randf() < 0.5 else DIRT)

# ---------------------------------------------------------------------------
# Collision generation for water, walls, trees
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


