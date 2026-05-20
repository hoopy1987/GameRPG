from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

BASE = "C:/Users/lenovo/.kimi_openclaw/workspace/godot_rpg/assets/ui"
os.makedirs(BASE, exist_ok=True)

# 色彩定义
DEEP_BROWN = (42, 31, 21)      # #2a1f15 羊皮纸底
BROWN_HOVER = (90, 69, 48)     # #5a4530 悬停底
BROWN_PRESSED = (31, 22, 13)   # #1f160d 按下底
BROWN_DISABLED = (42, 31, 21)  # 禁用底
DARK_GOLD = (139, 105, 20)     # #8b6914 暗金边框
LIGHT_GOLD = (176, 140, 40)    # #b08c28 亮金
BRIGHT_GOLD = (240, 216, 120)  # #f0d878 高亮金
HP_GREEN = (80, 180, 80)       # #50b450
HP_YELLOW = (220, 180, 50)     # #dcb432
HP_RED = (200, 60, 50)         # #c83c32
XP_BLUE = (120, 150, 220)      # #7896dc
GOLD_COIN = (255, 215, 0)      # 金币

def noise_texture(img, intensity=8):
    """添加羊皮纸纹理噪点"""
    import random
    px = img.load()
    for x in range(img.size[0]):
        for y in range(img.size[1]):
            if px[x, y][3] > 0:
                n = random.randint(-intensity, intensity)
                c = px[x, y]
                px[x, y] = (
                    max(0, min(255, c[0] + n)),
                    max(0, min(255, c[1] + n)),
                    max(0, min(255, c[2] + n)),
                    c[3]
                )
    return img

# 1. ui_panel_bg.png — 羊皮纸底色，九宫格 256×256，patch margin 24
def gen_panel_bg():
    w, h = 256, 256
    img = Image.new("RGBA", (w, h), (*DEEP_BROWN, 255))
    draw = ImageDraw.Draw(img)
    # 内发光边框
    for i in range(3):
        c = tuple(int(DEEP_BROWN[j] + (LIGHT_GOLD[j] - DEEP_BROWN[j]) * (i / 3)) for j in range(3))
        draw.rectangle([i, i, w-1-i, h-1-i], outline=c, width=1)
    # 四角装饰小方块
    corner_size = 16
    for (cx, cy) in [(0, 0), (w-corner_size, 0), (0, h-corner_size), (w-corner_size, h-corner_size)]:
        draw.rectangle([cx+4, cy+4, cx+corner_size-4, cy+corner_size-4], fill=(*DARK_GOLD, 180))
    img = noise_texture(img, 6)
    img.save(os.path.join(BASE, "ui_panel_bg.png"))
    print(" -> ui_panel_bg.png")

# 2. ui_panel_border.png — 暗金边框

def gen_panel_border():
    w, h = 256, 256
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # 3px外框
    for i in range(3):
        c = DARK_GOLD if i < 2 else LIGHT_GOLD
        draw.rectangle([i, i, w-1-i, h-1-i], outline=c, width=1)
    # 四角花纹装饰
    cs = 20
    for (cx, cy, flip_x, flip_y) in [(0, 0, 1, 1), (w-cs, 0, -1, 1), (0, h-cs, 1, -1), (w-cs, h-cs, -1, -1)]:
        for j in range(4):
            x1 = cx + (4 + j * 3) * flip_x
            y1 = cy + 4 * flip_y
            x2 = cx + 4 * flip_x
            y2 = cy + (4 + j * 3) * flip_y
            draw.line([(x1, y1), (x2, y2)], fill=BRIGHT_GOLD, width=2)
    img.save(os.path.join(BASE, "ui_panel_border.png"))
    print(" -> ui_panel_border.png")

# 3-6. 按钮四态 128×48
def gen_button(name, bg, border, highlight=None, pressed=False, disabled=False):
    w, h = 128, 48
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # 底
    draw.rounded_rectangle([0, 0, w-1, h-1], radius=6, fill=(*bg, 255))
    # 边框
    draw.rounded_rectangle([0, 0, w-1, h-1], radius=6, outline=(*border, 255), width=2)
    # 高光
    if highlight:
        draw.rounded_rectangle([2, 2, w-3, int(h*0.4)], radius=4, fill=(*highlight, 40))
    if pressed:
        # 内凹阴影
        draw.rounded_rectangle([2, 2, w-3, h-3], radius=5, outline=(0, 0, 0, 60), width=2)
    if disabled:
        # 半透明覆盖
        overlay = Image.new("RGBA", (w, h), (0, 0, 0, 100))
        img = Image.alpha_composite(img, overlay)
    img.save(os.path.join(BASE, f"ui_button_{name}.png"))
    print(f" -> ui_button_{name}.png")

# 7-10. 血条 200×24

def gen_hp_bar():
    w, h = 200, 24
    # 底框
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, w-1, h-1], radius=4, outline=(*DARK_GOLD, 255), width=2)
    draw.rounded_rectangle([2, 2, w-3, h-3], radius=3, fill=(*DEEP_BROWN, 255))
    img.save(os.path.join(BASE, "ui_hp_bar_bg.png"))
    print(" -> ui_hp_bar_bg.png")
    
    # 三色填充条（纯色，Godot里modulate调颜色）
    for name, color in [("green", HP_GREEN), ("yellow", HP_YELLOW), ("red", HP_RED)]:
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        draw.rounded_rectangle([2, 2, w-3, h-3], radius=3, fill=(*color, 255))
        img.save(os.path.join(BASE, f"ui_hp_bar_{name}.png"))
        print(f" -> ui_hp_bar_{name}.png")

# 11-12. 经验条 200×16

def gen_xp_bar():
    w, h = 200, 16
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, w-1, h-1], radius=3, outline=(*DARK_GOLD, 255), width=2)
    draw.rounded_rectangle([2, 2, w-3, h-3], radius=2, fill=(*DEEP_BROWN, 255))
    img.save(os.path.join(BASE, "ui_xp_bar_bg.png"))
    print(" -> ui_xp_bar_bg.png")
    
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([2, 2, w-3, h-3], radius=2, fill=(*XP_BLUE, 255))
    img.save(os.path.join(BASE, "ui_xp_bar_fill.png"))
    print(" -> ui_xp_bar_fill.png")

# 13. 空槽位 64×64

def gen_slot():
    w, h = 64, 64
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, w-1, h-1], radius=4, fill=(*DEEP_BROWN, 255))
    draw.rounded_rectangle([0, 0, w-1, h-1], radius=4, outline=(*DARK_GOLD, 255), width=2)
    # 中心十字线
    cx, cy = w//2, h//2
    draw.line([(cx-8, cy), (cx+8, cy)], fill=(*DARK_GOLD, 120), width=1)
    draw.line([(cx, cy-8), (cx, cy+8)], fill=(*DARK_GOLD, 120), width=1)
    img.save(os.path.join(BASE, "ui_slot_empty.png"))
    print(" -> ui_slot_empty.png")

# 14. 金币图标 16×16

def gen_gold():
    w, h = 16, 16
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse([1, 1, w-2, h-2], fill=(*GOLD_COIN, 255), outline=(180, 140, 0, 255), width=1)
    # $ 符号简化版
    draw.line([(w//2, 4), (w//2, 12)], fill=(80, 60, 0, 255), width=1)
    draw.line([(w//2-2, 6), (w//2+2, 6)], fill=(80, 60, 0, 255), width=1)
    draw.line([(w//2-2, 10), (w//2+2, 10)], fill=(80, 60, 0, 255), width=1)
    img.save(os.path.join(BASE, "ui_gold_icon.png"))
    print(" -> ui_gold_icon.png")

# 15. Toast背景 300×48

def gen_toast():
    w, h = 300, 48
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    # 半透明底
    draw.rounded_rectangle([0, 0, w-1, h-1], radius=6, fill=(*DEEP_BROWN, 200))
    draw.rounded_rectangle([0, 0, w-1, h-1], radius=6, outline=(*DARK_GOLD, 180), width=1)
    # 左侧彩色竖条（默认绿色，Godot里可换）
    draw.rounded_rectangle([4, 4, 8, h-5], radius=2, fill=(*HP_GREEN, 255))
    img.save(os.path.join(BASE, "ui_toast_bg.png"))
    print(" -> ui_toast_bg.png")

# 生成全部
print("Generating UI assets...")
gen_panel_bg()
gen_panel_border()
gen_button("normal", DEEP_BROWN, DARK_GOLD, highlight=BROWN_HOVER)
gen_button("hover", BROWN_HOVER, LIGHT_GOLD, highlight=BRIGHT_GOLD)
gen_button("pressed", BROWN_PRESSED, DARK_GOLD, pressed=True)
gen_button("disabled", BROWN_DISABLED, (80, 80, 80), disabled=True)
gen_hp_bar()
gen_xp_bar()
gen_slot()
gen_gold()
gen_toast()
print("All UI assets generated!")
