from PIL import Image, ImageDraw
import os

out = "/root/.openclaw/workspace/godot_rpg/assets/generated"
os.makedirs(out, exist_ok=True)

size = 32

def save(img, name):
    img.save(f"{out}/{name}.png")
    print(f"Generated: {name}.png")

def draw_person(shirt, pants, hair, helmet=None, accessory=None):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Body/shirt
    d.rectangle([10, 14, 22, 26], fill=shirt)
    # Legs/pants
    d.rectangle([10, 26, 15, 32], fill=pants)
    d.rectangle([17, 26, 22, 32], fill=pants)
    # Head
    d.rectangle([11, 6, 21, 14], fill=hair)
    # Helmet
    if helmet:
        d.rectangle([10, 4, 22, 10], fill=helmet)
        d.rectangle([10, 10, 22, 12], fill=helmet)
    # Accessory
    if accessory:
        accessory(img, d)
    return img

# 1. Blacksmith - dark apron, muscular, hammer
blacksmith = draw_person((80, 60, 40, 255), (60, 50, 35, 255), (120, 80, 50, 255))
bs_d = ImageDraw.Draw(blacksmith)
bs_d.rectangle([10, 14, 22, 26], fill=(60, 40, 25, 255))  # dark leather apron
bs_d.rectangle([12, 16, 20, 24], fill=(50, 35, 20, 255))  # apron body
bs_d.rectangle([22, 16, 26, 22], fill=(180, 180, 200, 255))  # hammer head
bs_d.rectangle([24, 18, 26, 28], fill=(139, 90, 43, 255))   # hammer handle
save(blacksmith, "char_blacksmith")

# 2. Priest - blue robe, white hair, staff
priest = draw_person((50, 60, 120, 255), (40, 50, 100, 255), (240, 240, 240, 255))
p_d = ImageDraw.Draw(priest)
p_d.rectangle([10, 14, 22, 30], fill=(50, 60, 120, 255))  # long robe
p_d.rectangle([23, 10, 25, 28], fill=(200, 180, 100, 255))  # staff
p_d.rectangle([22, 8, 26, 12], fill=(255, 255, 200, 255))   # staff crystal
save(priest, "char_priest")

# 3. Mayor - formal clothes, grey hair, cane
mayor = draw_person((100, 80, 60, 255), (80, 70, 55, 255), (200, 200, 200, 255))
m_d = ImageDraw.Draw(mayor)
m_d.rectangle([12, 14, 20, 18], fill=(150, 120, 80, 255))  # vest
m_d.rectangle([23, 20, 25, 30], fill=(139, 90, 43, 255))   # cane
save(mayor, "char_mayor")

# 4. Herbalist - dark cloak, green accents
herbalist = draw_person((40, 60, 40, 255), (35, 50, 35, 255), (80, 60, 80, 255))
h_d = ImageDraw.Draw(herbalist)
h_d.rectangle([10, 14, 22, 28], fill=(40, 60, 40, 255))  # cloak
h_d.rectangle([8, 20, 10, 24], fill=(50, 150, 50, 255))   # herb pouch
h_d.rectangle([20, 18, 24, 22], fill=(50, 150, 50, 255))   # herb in hand
save(herbalist, "char_herbalist")

# 5. Hunter - leather armor, bow, scar
hunter = draw_person((139, 90, 43, 255), (100, 70, 50, 255), (80, 60, 40, 255))
hu_d = ImageDraw.Draw(hunter)
hu_d.rectangle([8, 14, 24, 26], fill=(139, 90, 43, 255))  # leather armor
hu_d.rectangle([6, 16, 10, 24], fill=(100, 70, 50, 255))   # bow arm
hu_d.rectangle([4, 14, 8, 26], fill=(80, 50, 30, 255))     # bow
hu_d.line([(16, 8), (18, 10)], fill=(255, 0, 0, 255), width=1)  # scar
save(hunter, "char_hunter")

# 6. Farmer - straw hat, simple clothes
farmer = draw_person((150, 120, 80, 255), (100, 80, 60, 255), (180, 140, 100, 255))
f_d = ImageDraw.Draw(farmer)
f_d.rectangle([8, 4, 24, 8], fill=(200, 180, 100, 255))   # straw hat brim
f_d.rectangle([10, 2, 22, 6], fill=(220, 200, 120, 255))   # straw hat top
f_d.rectangle([20, 20, 24, 26], fill=(50, 150, 50, 255))    # vegetable
save(farmer, "char_farmer")

# 7. Guard - armor, helmet, spear
guard = draw_person((100, 100, 110, 255), (80, 80, 90, 255), (150, 150, 160, 255), helmet=(120, 120, 130, 255))
g_d = ImageDraw.Draw(guard)
g_d.rectangle([8, 14, 24, 26], fill=(100, 100, 110, 255))  # armor
#g_d.rectangle([22, 12, 26, 28], fill=(150, 150, 160, 255))  # spear
save(guard, "char_guard")

# 8. Scholar - glasses, robe, book
scholar = draw_person((80, 60, 100, 255), (70, 50, 90, 255), (200, 180, 150, 255))
s_d = ImageDraw.Draw(scholar)
s_d.rectangle([10, 14, 22, 28], fill=(80, 60, 100, 255))  # robe
s_d.rectangle([12, 10, 14, 12], fill=(200, 200, 220, 255))  # glasses left
s_d.rectangle([18, 10, 20, 12], fill=(200, 200, 220, 255))  # glasses right
s_d.rectangle([14, 10, 18, 11], fill=(200, 200, 220, 255))  # glasses bridge
s_d.rectangle([8, 20, 12, 26], fill=(139, 90, 43, 255))     # book
save(scholar, "char_scholar")

print(f"\nDone! Generated 8 new character sprites to {out}")
