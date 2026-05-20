from PIL import Image, ImageDraw
import random

OUTPUT_DIR = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\generated"

random.seed(42)

def draw_cave_floor(draw, x0, y0, color, cracks=False):
    for x in range(32):
        for y in range(32):
            c = max(0, min(255, color[0] + random.randint(-12, 12)))
            g = max(0, min(255, color[1] + random.randint(-12, 12)))
            b = max(0, min(255, color[2] + random.randint(-12, 12)))
            draw.point((x0+x, y0+y), fill=(c, g, b, 255))
    if cracks:
        for _ in range(2):
            sx = x0 + random.randint(2, 28)
            sy = y0 + random.randint(2, 28)
            for step in range(random.randint(4, 10)):
                draw.line([(sx, sy), (sx+random.randint(-2,2), sy+random.randint(-2,2))], fill=(20, 20, 25, 255), width=1)
                sx += random.randint(-2, 2)
                sy += random.randint(-2, 2)

def draw_cave_wall(draw, x0, y0):
    base = (45, 40, 55)
    for x in range(32):
        for y in range(32):
            c = max(0, min(255, base[0] + random.randint(-15, 15)))
            g = max(0, min(255, base[1] + random.randint(-15, 15)))
            b = max(0, min(255, base[2] + random.randint(-15, 15)))
            draw.point((x0+x, y0+y), fill=(c, g, b, 255))
    draw.rectangle([x0, y0, x0+31, y0+31], outline=(25, 22, 30), width=2)
    for _ in range(4):
        rx = x0 + random.randint(4, 24)
        ry = y0 + random.randint(4, 24)
        r = random.randint(2, 4)
        draw.ellipse([rx-r, ry-r, rx+r, ry+r], fill=(55, 50, 65), outline=(30, 28, 40), width=1)

def draw_cobweb(draw, x0, y0):
    base = (55, 50, 60)
    for x in range(32):
        for y in range(32):
            draw.point((x0+x, y0+y), fill=base)
    lines = [
        [(x0, y0), (x0+16, y0+16)], [(x0+32, y0), (x0+16, y0+16)],
        [(x0, y0+32), (x0+16, y0+16)], [(x0+32, y0+32), (x0+16, y0+16)],
        [(x0+16, y0), (x0+16, y0+16)], [(x0+16, y0+32), (x0+16, y0+16)],
        [(x0, y0+16), (x0+16, y0+16)], [(x0+32, y0+16), (x0+16, y0+16)],
    ]
    for line in lines:
        draw.line(line, fill=(120, 115, 130, 180), width=1)
    import math
    for angle in range(0, 360, 45):
        rad = math.radians(angle)
        ex = int(x0 + 16 + math.cos(rad) * 14)
        ey = int(y0 + 16 + math.sin(rad) * 14)
        draw.line([(x0+16, y0+16), (ex, ey)], fill=(100, 95, 110, 140), width=1)

def draw_torch(draw, x0, y0):
    base = (45, 40, 55)
    for x in range(32):
        for y in range(32):
            draw.point((x0+x, y0+y), fill=base)
    draw.rectangle([x0+12, y0+8, x0+20, y0+24], fill=(80, 60, 40), outline=(40, 30, 20), width=1)
    flame_colors = [(255, 120, 0), (255, 180, 0), (255, 220, 50)]
    for i, fc in enumerate(flame_colors):
        r = 6 - i * 2
        draw.ellipse([x0+16-r, y0+6-r, x0+16+r, y0+6+r], fill=fc)
    for r in range(10, 16):
        a = int(30 - (r-10)*5)
        draw.ellipse([x0+16-r, y0+6-r, x0+16+r, y0+6+r], outline=(255, 150, 0, a), width=1)

def draw_ore(draw, x0, y0):
    base = (50, 45, 58)
    for x in range(32):
        for y in range(32):
            draw.point((x0+x, y0+y), fill=base)
    for _ in range(3):
        ox = x0 + random.randint(4, 24)
        oy = y0 + random.randint(4, 24)
        for step in range(random.randint(3, 6)):
            draw.line([(ox, oy), (ox+random.randint(-3,3), oy+random.randint(-3,3))], fill=(180, 160, 80), width=2)
            ox += random.randint(-2, 2)
            oy += random.randint(-2, 2)
    for _ in range(6):
        sx = x0 + random.randint(4, 28)
        sy = y0 + random.randint(4, 28)
        draw.ellipse([sx-1, sy-1, sx+1, sy+1], fill=(220, 210, 150))

def draw_entrance(draw, x0, y0):
    base = (30, 28, 35)
    for x in range(32):
        for y in range(32):
            draw.point((x0+x, y0+y), fill=base)
    draw.ellipse([x0+4, y0+4, x0+28, y0+28], fill=(10, 8, 12), outline=(20, 18, 25), width=2)
    for i in range(3):
        y = y0 + 12 + i * 6
        draw.arc([x0+6, y, x0+26, y+8], start=0, end=180, fill=(40, 38, 48), width=2)

# ====== Cave Tileset (128x64) ======
tileset = Image.new("RGBA", (128, 64), (0, 0, 0, 0))
draw = ImageDraw.Draw(tileset)
draw_cave_floor(draw, 0, 0, (60, 58, 65))
draw_cave_floor(draw, 32, 0, (55, 52, 60), cracks=True)
draw_cave_wall(draw, 64, 0)
draw_cave_wall(draw, 96, 0)
draw_cobweb(draw, 0, 32)
draw_torch(draw, 32, 32)
draw_ore(draw, 64, 32)
draw_entrance(draw, 96, 32)
tileset.save(f"{OUTPUT_DIR}/cave_tileset.png")
print("Saved cave_tileset.png")

# ====== Cave Spider Sprite (128x32, 4 frames) ======
spider = Image.new("RGBA", (128, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(spider)
for f in range(4):
    x0 = f * 32
    body_color = (40, 35, 50)
    leg_color = (60, 55, 70)
    draw.ellipse([x0+10, 10, x0+22, 22], fill=body_color, outline=(30, 25, 40), width=1)
    draw.ellipse([x0+12, 8, x0+20, 14], fill=(50, 45, 60), outline=(30, 25, 40), width=1)
    offsets = [[-2, 0, 2, 0], [0, 2, 0, -2], [2, 0, -2, 0], [0, -2, 0, 2]]
    for i in range(4):
        lx = x0 + 8 + i * 4
        ly = 14 + offsets[f][i]
        draw.line([(x0+16, 16), (lx, ly)], fill=leg_color, width=2)
    draw.ellipse([x0+14, 12, x0+15, 13], fill=(200, 50, 50))
    draw.ellipse([x0+17, 12, x0+18, 13], fill=(200, 50, 50))
spider.save(f"{OUTPUT_DIR}/cave_spider.png")
print("Saved cave_spider.png")

# ====== Cave Bat Sprite (128x32, 4 frames) ======
bat = Image.new("RGBA", (128, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(bat)
for f in range(4):
    x0 = f * 32
    body_color = (50, 45, 60)
    wing_colors = [(60, 55, 75), (70, 65, 85), (60, 55, 75), (50, 45, 65)]
    wy = 8 + (f % 2) * 4
    draw.polygon([(x0+4, wy), (x0+16, 14), (x0+8, 18)], fill=wing_colors[f], outline=(40, 35, 50), width=1)
    draw.polygon([(x0+28, wy), (x0+16, 14), (x0+24, 18)], fill=wing_colors[f], outline=(40, 35, 50), width=1)
    draw.ellipse([x0+12, 12, x0+20, 20], fill=body_color, outline=(35, 30, 45), width=1)
    draw.polygon([(x0+13, 12), (x0+11, 8), (x0+15, 12)], fill=(45, 40, 55))
    draw.polygon([(x0+19, 12), (x0+21, 8), (x0+17, 12)], fill=(45, 40, 55))
    draw.ellipse([x0+14, 14, x0+15, 15], fill=(180, 50, 50))
    draw.ellipse([x0+17, 14, x0+18, 15], fill=(180, 50, 50))
bat.save(f"{OUTPUT_DIR}/cave_bat.png")
print("Saved cave_bat.png")

# ====== NPC Elder Portrait (64x64) ======
elder = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
draw = ImageDraw.Draw(elder)
border_color = (210, 195, 160)
draw.rectangle([0, 0, 63, 63], fill=(245, 235, 210), outline=border_color, width=3)
draw.rectangle([4, 4, 59, 59], outline=(220, 205, 175), width=1)
skin = (220, 200, 175)
draw.ellipse([16, 10, 48, 42], fill=skin, outline=(180, 160, 140), width=1)
for i in range(12):
    hx = 16 + random.randint(-4, 32)
    hy = 8 + random.randint(0, 8)
    draw.ellipse([hx, hy, hx+4, hy+6], fill=(230, 230, 230))
draw.ellipse([22, 22, 26, 24], fill=(100, 90, 80))
draw.ellipse([36, 22, 40, 24], fill=(100, 90, 80))
draw.line([(30, 24), (30, 30)], fill=(180, 160, 140), width=2)
draw.arc([24, 30, 38, 38], start=0, end=180, fill=(140, 120, 110), width=2)
beard_color = (210, 210, 210)
for i in range(20):
    bx = 20 + random.randint(0, 24)
    by = 32 + random.randint(0, 12)
    draw.ellipse([bx, by, bx+3, by+4], fill=beard_color)
draw.rectangle([8, 46, 56, 56], fill=(230, 220, 195), outline=border_color, width=1)
try:
    draw.text((12, 48), "Elder", fill=(80, 60, 40))
except:
    pass
elder.save(f"{OUTPUT_DIR}/npc_elder_portrait.png")
print("Saved npc_elder_portrait.png")

# ====== Knight's Crest (32x32) ======
crest = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(crest)
shield_points = [(16, 2), (28, 8), (26, 20), (16, 30), (6, 20), (4, 8)]
draw.polygon(shield_points, fill=(160, 140, 80), outline=(100, 80, 40), width=2)
draw.polygon([(16, 10), (12, 16), (20, 16)], fill=(200, 180, 100), outline=(120, 100, 50), width=1)
draw.ellipse([14, 12, 18, 16], fill=(220, 50, 50))
for y in range(24, 32):
    for x in range(32):
        if random.random() < 0.3:
            draw.point((x, y), fill=(80, 75, 70, 150))
crest.save(f"{OUTPUT_DIR}/item_crest.png")
print("Saved item_crest.png")

# ====== Spider Venom Sac (32x32) ======
venom = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(venom)
draw.ellipse([6, 8, 26, 26], fill=(80, 120, 60), outline=(50, 80, 40), width=2)
for r in range(6, 2, -1):
    draw.ellipse([16-r, 16-r, 16+r, 16+r], fill=(120, 200, 80, 40))
draw.line([(16, 8), (16, 4)], fill=(60, 90, 50), width=2)
draw.ellipse([12, 2, 20, 8], fill=(70, 100, 55), outline=(50, 80, 40), width=1)
venom.save(f"{OUTPUT_DIR}/item_spider_venom.png")
print("Saved item_spider_venom.png")

# ====== Bat Wing (32x32) ======
wing = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(wing)
draw.polygon([(4, 8), (28, 4), (20, 24), (8, 20)], fill=(60, 55, 75, 200), outline=(40, 35, 55), width=1)
draw.line([(4, 8), (28, 4)], fill=(80, 75, 95), width=2)
draw.line([(4, 8), (8, 20)], fill=(70, 65, 85), width=1)
draw.line([(12, 7), (14, 18)], fill=(70, 65, 85), width=1)
draw.line([(20, 6), (20, 22)], fill=(70, 65, 85), width=1)
draw.line([(28, 4), (20, 24)], fill=(70, 65, 85), width=1)
wing.save(f"{OUTPUT_DIR}/item_bat_wing.png")
print("Saved item_bat_wing.png")

print("\nAll Act 1 placeholder assets generated successfully!")
