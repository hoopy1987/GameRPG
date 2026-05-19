from PIL import Image
import os

out = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\generated"
os.makedirs(out, exist_ok=True)

def save(img, name):
    img.save(f"{out}/{name}.png")
    print(f"Generated: {name}.png")

# === TILES (32x32 for better visibility) ===
size = 32

# Grass tile - various greens with random pixel noise
grass = Image.new('RGBA', (size, size), (34, 139, 34, 255))
for x in range(size):
    for y in range(size):
        if (x + y) % 7 == 0:
            grass.putpixel((x, y), (50, 160, 50, 255))
        elif (x * 3 + y) % 11 == 0:
            grass.putpixel((x, y), (28, 120, 28, 255))
save(grass, "tile_grass")

# Dirt path - browns
path = Image.new('RGBA', (size, size), (139, 90, 43, 255))
for x in range(size):
    for y in range(size):
        if (x + y) % 5 == 0:
            path.putpixel((x, y), (160, 110, 60, 255))
        elif (x * 2 + y) % 9 == 0:
            path.putpixel((x, y), (120, 80, 35, 255))
save(path, "tile_dirt")

# Stone floor - grays
stone = Image.new('RGBA', (size, size), (128, 128, 128, 255))
for x in range(size):
    for y in range(size):
        if (x + y) % 4 == 0:
            stone.putpixel((x, y), (140, 140, 140, 255))
        elif (x * 3 + y * 2) % 8 == 0:
            stone.putpixel((x, y), (110, 110, 110, 255))
# Add stone brick lines
for x in range(0, size, 16):
    for y in range(size):
        stone.putpixel((x, y), (90, 90, 90, 255))
for y in range(0, size, 16):
    for x in range(size):
        stone.putpixel((x, y), (90, 90, 90, 255))
save(stone, "tile_stone")

# Water - blues
water = Image.new('RGBA', (size, size), (30, 144, 255, 255))
for x in range(size):
    for y in range(size):
        if (x + y) % 6 == 0:
            water.putpixel((x, y), (50, 160, 255, 255))
        elif (x * 2 + y) % 10 == 0:
            water.putpixel((x, y), (20, 130, 230, 255))
save(water, "tile_water")

# Wall - dark stone with moss
wall = Image.new('RGBA', (size, size), (80, 80, 80, 255))
for x in range(size):
    for y in range(size):
        if (x + y) % 3 == 0:
            wall.putpixel((x, y), (90, 90, 90, 255))
        elif (x * 2 + y) % 7 == 0:
            wall.putpixel((x, y), (70, 70, 70, 255))
# Moss spots
for x in range(size):
    for y in range(size):
        if (x * 5 + y * 3) % 17 == 0:
            wall.putpixel((x, y), (34, 139, 34, 255))
save(wall, "tile_wall")

# Roof - reddish tiles
roof = Image.new('RGBA', (size, size), (139, 0, 0, 255))
for x in range(size):
    for y in range(size):
        if (x + y) % 5 == 0:
            roof.putpixel((x, y), (160, 20, 20, 255))
        elif (x * 3 + y) % 8 == 0:
            roof.putpixel((x, y), (120, 0, 0, 255))
save(roof, "tile_roof")

# Wood floor
wood = Image.new('RGBA', (size, size), (139, 90, 43, 255))
for x in range(size):
    for y in range(size):
        if y % 8 == 0:
            wood.putpixel((x, y), (110, 70, 30, 255))
        elif (x + y) % 4 == 0:
            wood.putpixel((x, y), (150, 100, 50, 255))
save(wood, "tile_wood")

# Sand
tile = Image.new('RGBA', (size, size), (194, 178, 128, 255))
for x in range(size):
    for y in range(size):
        if (x + y) % 7 == 0:
            tile.putpixel((x, y), (210, 190, 140, 255))
        elif (x * 3 + y) % 11 == 0:
            tile.putpixel((x, y), (180, 165, 110, 255))
save(tile, "tile_sand")

print(f"\n✅ Generated {len(os.listdir(out))} tiles to {out}")
