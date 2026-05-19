from PIL import Image
import os

# Create a spritesheet from generated tiles
out = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\generated"

# Load tiles
tiles = {}
tile_names = ["tile_grass", "tile_dirt", "tile_stone", "tile_water", 
              "tile_wall", "tile_roof", "tile_wood", "tile_sand"]

for name in tile_names:
    path = f"{out}/{name}.png"
    if os.path.exists(path):
        tiles[name] = Image.open(path)

# Create a 4x2 grid spritesheet (256x128)
sheet_w = 32 * 4  # 4 columns
sheet_h = 32 * 2  # 2 rows
sheet = Image.new('RGBA', (sheet_w, sheet_h), (0, 0, 0, 0))

positions = [
    (0, 0, "tile_grass"), (1, 0, "tile_dirt"), (2, 0, "tile_stone"), (3, 0, "tile_water"),
    (0, 1, "tile_wall"), (1, 1, "tile_roof"), (2, 1, "tile_wood"), (3, 1, "tile_sand"),
]

for col, row, name in positions:
    if name in tiles:
        x = col * 32
        y = row * 32
        sheet.paste(tiles[name], (x, y))

sheet.save(f"{out}/tileset_sheet.png")
print(f"Spritesheet: {out}/tileset_sheet.png ({sheet_w}x{sheet_h})")
print("Tile layout:")
for col, row, name in positions:
    print(f"  ({col},{row}) = {name}")
