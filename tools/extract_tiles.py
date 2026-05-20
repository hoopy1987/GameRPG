from PIL import Image
import os

# Load the Kenney spritesheet
sheet_path = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\kenney_rpg\Spritesheet\roguelikeSheet_transparent.png"
sheet = Image.open(sheet_path)
print(f"Spritesheet size: {sheet.size}")
print(f"Tile size: 16x16")
print(f"Grid: {sheet.size[0] // 16} x {sheet.size[1] // 16} tiles")

# Show preview of different sections
# Row 0-2: Ground tiles
# Row 3-6: Walls/buildings
# Row 7+: Items, characters

# Let's look at specific tiles for our game
# Ground tiles (row 0): grass variations
grass_tiles = [
    (0, 0),   # basic grass
    (1, 0),   # grass light
    (2, 0),   # grass dark
    (3, 0),   # dirt path
    (4, 0),   # stone floor
]

# Wall tiles (row 3-4)
wall_tiles = [
    (0, 3),   # stone wall top
    (1, 3),   # stone wall
    (2, 3),   # wood wall
    (3, 3),   # door
]

# Character tiles - let's find them
# Characters are usually in later rows
print("\nLooking for character tiles...")

# Extract some sample tiles
output_dir = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\extracted"
os.makedirs(output_dir, exist_ok=True)

def extract_tile(sheet, tx, ty, size=16):
    x = tx * size
    y = ty * size
    return sheet.crop((x, y, x + size, y + size))

# Extract ground tiles
for i, (tx, ty) in enumerate(grass_tiles):
    tile = extract_tile(sheet, tx, ty)
    tile.save(f"{output_dir}/grass_{i}.png")
    
# Extract wall tiles
for i, (tx, ty) in enumerate(wall_tiles):
    tile = extract_tile(sheet, tx, ty)
    tile.save(f"{output_dir}/wall_{i}.png")

# Extract character-looking tiles (scan rows 15+)
print("\nScanning for characters...")
char_positions = []
for row in range(15, 30):
    for col in range(0, 10):
        tile = extract_tile(sheet, col, row)
        # Check if tile is not empty (has content)
        pixels = list(tile.getdata())
        if any(p[3] > 0 for p in pixels if len(p) == 4):  # has alpha
            # Save potential character tiles
            tile.save(f"{output_dir}/tile_{col}_{row}.png")
            char_positions.append((col, row))

print(f"Found {len(char_positions)} non-empty tiles in character zone")
print("Sample positions:", char_positions[:10])

print(f"\nExtracted tiles saved to: {output_dir}")
