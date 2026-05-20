from PIL import Image

# Check character spritesheet
char_sheet = Image.open(r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\kenney_chars\Spritesheet\roguelikeChar_transparent.png")
print(f"Character sheet size: {char_sheet.size}")

# RPG tilesheet
rpg_sheet = Image.open(r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\kenney_rpg\Spritesheet\roguelikeSheet_transparent.png")
print(f"RPG sheet size: {rpg_sheet.size}")

# Try to determine character tile size
# Characters are usually 16x16 or 32x32 in Kenney packs
print("\nChecking spritesheet info...")
with open(r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\kenney_chars\spritesheetInfo.txt") as f:
    print(f.read())
