from PIL import Image, ImageDraw, ImageFont
import os

output_dir = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\chars"
preview = Image.new('RGBA', (200, 320), (30, 30, 40, 255))
draw = ImageDraw.Draw(preview)

# Place characters in a grid
positions = [
    (0,0), (1,0), (2,0), (3,0), (4,0),
    (0,1), (1,1), (2,1), (3,1), (4,1),
    (0,2), (1,2), (2,2), (3,2), (4,2),
    (0,3), (1,3), (2,3), (3,3), (4,3),
    (0,4), (1,4), (2,4), (3,4), (4,4),
]

for i, (col, row) in enumerate(positions):
    px = (i % 5) * 40 + 4
    py = (i // 5) * 40 + 4
    
    char_path = f"{output_dir}/char_r{row}_c{col}.png"
    if os.path.exists(char_path):
        char = Image.open(char_path)
        # Convert to RGBA if needed
        if char.mode != 'RGBA':
            char = char.convert('RGBA')
        # Scale up 2x for visibility
        char = char.resize((32, 32), Image.NEAREST)
        # Create a clean copy to avoid mask issues
        char_copy = Image.new('RGBA', char.size, (0,0,0,0))
        char_copy.paste(char, (0,0))
        preview.paste(char_copy, (px, py), char_copy)
        draw.rectangle([px-2, py-2, px+34, py+34], outline=(100, 100, 120), width=1)

# Add labels
try:
    font = ImageFont.truetype("arial.ttf", 10)
except:
    font = ImageFont.load_default()

draw.text((4, 300), "Kenney Medieval Characters Preview", fill=(200, 200, 200), font=font)

preview.save(r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\chars_preview.png")
print("Preview saved to: assets/chars_preview.png")
print("\nRecommended selections:")
print("  Player (Knight):      char_r0_c0 (row 0, col 0)")
print("  NPC Villager:         char_r2_c0 (row 2, col 0)")  
print("  NPC Shopkeeper:       char_r2_c3 (row 2, col 3)")
