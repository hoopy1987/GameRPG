from PIL import Image
import os

char_sheet = Image.open(r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\characters.png")
tile_w, tile_h = 17, 17  # 16px + 1px margin
sheet_w, sheet_h = char_sheet.size

cols = sheet_w // tile_w
rows = sheet_h // tile_h
print(f"Character sheet: {sheet_w}x{sheet_h}, tiles: {cols}x{rows}")

output_dir = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\chars"
os.makedirs(output_dir, exist_ok=True)

def extract_char(col, row, name):
    x = col * tile_w
    y = row * tile_h
    char = char_sheet.crop((x, y, x + 16, y + 16))
    char.save(f"{output_dir}/{name}.png")
    print(f"  Extracted {name} at ({col},{row})")

# Preview first few rows to identify good characters
for row in range(min(6, rows)):
    for col in range(min(10, cols)):
        extract_char(col, row, f"char_r{row}_c{col}")

print(f"\nPreview images saved to: {output_dir}")
print("Check them and pick your favorites for player/npc!")
