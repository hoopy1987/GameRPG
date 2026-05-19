extends Control

@onready var map_canvas: TextureRect = $Panel/MapCanvas
@onready var player_marker: ColorRect = $Panel/PlayerMarker
@onready var title_label: Label = $Panel/TitleLabel
@onready var legend_label: Label = $Panel/LegendLabel

var player_ref: Node = null
var npc_refs: Array = []

# Map scale: village is 80x45 tiles = 2560x1440 pixels
# Minimap size: 200x120 (scaled down)
const MAP_W := 200
const MAP_H := 120
const VILLAGE_W := 2560.0
const VILLAGE_H := 1440.0

const COLORS := {
	"grass": Color(0.2, 0.5, 0.2, 1),
	"water": Color(0.2, 0.4, 0.8, 1),
	"wall": Color(0.4, 0.4, 0.4, 1),
	"road": Color(0.5, 0.45, 0.35, 1),
	"building": Color(0.6, 0.3, 0.15, 1),
	"square": Color(0.6, 0.6, 0.55, 1),
	"tree": Color(0.1, 0.35, 0.1, 1),
}

func _ready() -> void:
	hide()
	_generate_minimap_texture()
	_update_legend()

func _generate_minimap_texture() -> void:
	var img := Image.create(MAP_W, MAP_H, false, Image.FORMAT_RGBA8)
	
	# Fill background (grass)
	for x in range(MAP_W):
		for y in range(MAP_H):
			img.set_pixel(x, y, COLORS["grass"])
	
	# Draw roads (based on world_generator layout)
	# Main roads: center cross
	var cx := MAP_W / 2
	var cy := MAP_H / 2
	var road_w := 3 * MAP_W / 80  # scale from tiles
	
	# North-South road
	for x in range(int(cx - road_w), int(cx + road_w)):
		for y in range(MAP_H):
			if x >= 0 and x < MAP_W:
				img.set_pixel(x, y, COLORS["road"])
	
	# East-West road
	for x in range(MAP_W):
		for y in range(int(cy - road_w), int(cy + road_w)):
			if y >= 0 and y < MAP_H:
				img.set_pixel(x, y, COLORS["road"])
	
	# Central square
	var sq_w := 6 * MAP_W / 80
	for x in range(int(cx - sq_w/2), int(cx + sq_w/2)):
		for y in range(int(cy - sq_w/2), int(cy + sq_w/2)):
			if x >= 0 and x < MAP_W and y >= 0 and y < MAP_H:
				img.set_pixel(x, y, COLORS["square"])
	
	# Buildings (simplified rectangles)
	var buildings := [
		{"x": 52, "y": 8, "w": 9, "h": 7},    # Blacksmith
		{"x": 33, "y": 30, "w": 15, "h": 9},  # Tavern
		{"x": 8, "y": 7, "w": 11, "h": 11},   # Church
		{"x": 52, "y": 28, "w": 7, "h": 5},   # House 1
		{"x": 60, "y": 28, "w": 7, "h": 5},   # House 2
		{"x": 52, "y": 34, "w": 7, "h": 5},   # House 3
		{"x": 60, "y": 34, "w": 7, "h": 5},   # House 4
		{"x": 56, "y": 40, "w": 7, "h": 5},   # House 5
		{"x": 48, "y": 17, "w": 2, "h": 2},   # Stall 1
		{"x": 52, "y": 17, "w": 2, "h": 2},   # Stall 2
		{"x": 48, "y": 21, "w": 2, "h": 2},   # Stall 3
		{"x": 52, "y": 21, "w": 2, "h": 2},   # Stall 4
	]
	
	for b in buildings:
		var bx := int(b["x"] * MAP_W / 80)
		var by := int(b["y"] * MAP_H / 45)
		var bw := int(b["w"] * MAP_W / 80)
		var bh := int(b["h"] * MAP_H / 45)
		for x in range(bx, bx + bw):
			for y in range(by, by + bh):
				if x >= 0 and x < MAP_W and y >= 0 and y < MAP_H:
					img.set_pixel(x, y, COLORS["building"])
	
	# Trees (scattered green dots)
	var tree_positions := [
		{"x": 5, "y": 5}, {"x": 70, "y": 5}, {"x": 75, "y": 10},
		{"x": 5, "y": 40}, {"x": 75, "y": 35}, {"x": 70, "y": 40},
		{"x": 20, "y": 35}, {"x": 60, "y": 5}, {"x": 35, "y": 38},
	]
	for t in tree_positions:
		var tx := int(t["x"] * MAP_W / 80)
		var ty := int(t["y"] * MAP_H / 45)
		if tx >= 0 and tx < MAP_W and ty >= 0 and ty < MAP_H:
			img.set_pixel(tx, ty, COLORS["tree"])
			if tx + 1 < MAP_W:
				img.set_pixel(tx + 1, ty, COLORS["tree"])
			if ty + 1 < MAP_H:
				img.set_pixel(tx, ty + 1, COLORS["tree"])
	
	var tex := ImageTexture.create_from_image(img)
	map_canvas.texture = tex

func _update_legend() -> void:
	legend_label.text = "● 玩家  ■ 建筑  — 道路  ◆ 广场"

func update_player_position(player_pos: Vector2) -> void:
	var mx := player_pos.x / VILLAGE_W * MAP_W
	var my := player_pos.y / VILLAGE_H * MAP_H
	player_marker.position = Vector2(mx, my)

func toggle() -> void:
	visible = not visible
	if visible and player_ref:
		update_player_position(player_ref.position)

func _process(_delta: float) -> void:
	if visible and player_ref:
		update_player_position(player_ref.position)
