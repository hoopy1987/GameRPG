from PIL import Image, ImageDraw
import os

out = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\generated"
os.makedirs(out, exist_ok=True)

size = 32

def save(img, name):
    img.save(f"{out}/{name}.png")
    print(f"Generated: {name}.png")

# === CHARACTERS ===

# Player Knight - blue tunic, silver helmet
def draw_person(base, shirt, pants, hair=None, helmet=None):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Body/shirt
    d.rectangle([10, 14, 22, 26], fill=shirt)
    # Legs/pants
    d.rectangle([10, 26, 15, 32], fill=pants)
    d.rectangle([17, 26, 22, 32], fill=pants)
    # Head
    head_color = hair if hair else (255, 220, 180, 255)
    d.rectangle([11, 6, 21, 14], fill=head_color)
    # Helmet
    if helmet:
        d.rectangle([10, 4, 22, 10], fill=helmet)
        d.rectangle([10, 10, 22, 12], fill=helmet)
    return img

# Knight player
knight = draw_person(None, (50, 80, 150, 255), (80, 60, 40, 255), helmet=(180, 180, 200, 255))
# Add sword
knight_d = ImageDraw.Draw(knight)
knight_d.rectangle([22, 18, 24, 28], fill=(200, 200, 220, 255))  # sword blade
knight_d.rectangle([21, 26, 25, 28], fill=(139, 90, 43, 255))     # hilt
save(knight, "char_knight")

# Villager - brown clothes
villager = draw_person(None, (139, 90, 43, 255), (100, 70, 50, 255), hair=(139, 69, 19, 255))
save(villager, "char_villager")

# Shopkeeper - green clothes, apron
shop = draw_person(None, (34, 139, 34, 255), (80, 60, 40, 255), hair=(80, 60, 40, 255))
shop_d = ImageDraw.Draw(shop)
shop_d.rectangle([10, 16, 22, 24], fill=(200, 180, 160, 255))  # apron
save(shop, "char_shopkeeper")

# Enemy - red monster
enemy = Image.new('RGBA', (size, size), (0, 0, 0, 0))
e_d = ImageDraw.Draw(enemy)
e_d.rectangle([8, 12, 24, 26], fill=(180, 0, 0, 255))   # body
e_d.rectangle([10, 4, 22, 12], fill=(220, 50, 50, 255))  # head
e_d.rectangle([6, 14, 8, 22], fill=(180, 0, 0, 255))    # left arm
e_d.rectangle([24, 14, 26, 22], fill=(180, 0, 0, 255))   # right arm
e_d.rectangle([8, 8, 10, 10], fill=(255, 255, 0, 255))   # eye
e_d.rectangle([20, 8, 22, 10], fill=(255, 255, 0, 255))  # eye
save(enemy, "char_enemy")

# === ITEMS ===

# Health potion - red flask
potion = Image.new('RGBA', (size, size), (0, 0, 0, 0))
p_d = ImageDraw.Draw(potion)
p_d.ellipse([10, 14, 22, 28], fill=(220, 20, 60, 255))     # flask body
p_d.rectangle([13, 10, 19, 14], fill=(180, 180, 180, 255))  # neck
p_d.rectangle([12, 8, 20, 10], fill=(139, 90, 43, 255))     # cork
save(potion, "item_potion")

# Sword
sword = Image.new('RGBA', (size, size), (0, 0, 0, 0))
s_d = ImageDraw.Draw(sword)
s_d.rectangle([15, 4, 17, 24], fill=(200, 200, 220, 255))  # blade
s_d.rectangle([13, 24, 19, 26], fill=(139, 90, 43, 255))   # guard
s_d.rectangle([15, 26, 17, 30], fill=(139, 90, 43, 255))    # handle
save(sword, "item_sword")

# Shield
shield = Image.new('RGBA', (size, size), (0, 0, 0, 0))
sh_d = ImageDraw.Draw(shield)
sh_d.ellipse([8, 8, 24, 28], fill=(139, 69, 19, 255))       # wood
sh_d.ellipse([10, 10, 22, 26], fill=(160, 90, 30, 255))      # lighter
sh_d.rectangle([15, 14, 17, 20], fill=(200, 180, 50, 255))   # emblem
save(shield, "item_shield")

# Gold coin
coin = Image.new('RGBA', (size, size), (0, 0, 0, 0))
c_d = ImageDraw.Draw(coin)
c_d.ellipse([8, 8, 24, 24], fill=(255, 215, 0, 255))        # gold
c_d.ellipse([10, 10, 22, 22], fill=(255, 223, 50, 255))     # highlight
c_d.text((13, 12), "$", fill=(180, 150, 0, 255))              # $ symbol (small)
save(coin, "item_coin")

# === UI ELEMENTS ===

# Health bar background
hp_bg = Image.new('RGBA', (64, 8), (50, 50, 50, 255))
save(hp_bg, "ui_hp_bg")

# Health bar fill
hp_fill = Image.new('RGBA', (64, 8), (220, 50, 50, 255))
# Add gradient
for x in range(64):
    for y in range(8):
        hp_fill.putpixel((x, y), (220 - x, 50 + x // 2, 50, 255))
save(hp_fill, "ui_hp_fill")

# Inventory panel
panel = Image.new('RGBA', (200, 150), (30, 30, 30, 230))
panel_d = ImageDraw.Draw(panel)
panel_d.rectangle([0, 0, 199, 149], outline=(139, 90, 43, 255), width=2)
save(panel, "ui_panel")

print(f"\nDone! Generated characters + items + UI to {out}")
