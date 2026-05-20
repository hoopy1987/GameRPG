from PIL import Image

img = Image.open(r'C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\tilesheet.png')
w, h = img.width, img.height
tile_w, tile_h = 32, 32
cols, rows = w // tile_w, h // tile_h

print(f"瓦片图尺寸: {w}x{h} = {cols}列 x {rows}行 = {cols*rows}个瓦片")
print(f"\n=== 第一行（y=0），{cols}个瓦片 ===\n")

for col in range(cols):
    x1, y1 = col * tile_w, 0
    x2, y2 = x1 + tile_w, tile_h
    tile = img.crop((x1, y1, x2, y2))
    
    # 取中心16x16区域避免边框干扰
    center = tile.crop((8, 8, 24, 24))
    pixels = list(center.getdata())
    
    r_sum = sum(p[0] for p in pixels)
    g_sum = sum(p[1] for p in pixels)
    b_sum = sum(p[2] for p in pixels)
    n = len(pixels)
    
    r, g, b = r_sum // n, g_sum // n, b_sum // n
    
    # 根据颜色分类
    desc = ""
    alpha_avg = sum(p[3] for p in pixels) // n if len(pixels[0]) > 3 else 255
    if alpha_avg < 30:
        desc = "透明/空"
    elif r < 80 and g < 80 and b > 120:
        desc = "蓝色/水"
    elif r < 80 and g > 100 and b < 80:
        desc = "绿色/草地"
    elif r > 120 and g < 80 and b < 80:
        desc = "红色"
    elif r > 120 and g > 100 and b < 80:
        desc = "棕色/泥土"
    elif r > 100 and g > 100 and b > 100:
        if r > 180 and g > 180 and b > 180:
            desc = "白色/浅色"
        elif abs(r-g) < 20 and abs(g-b) < 20:
            desc = "灰色/石板"
        else:
            desc = f"浅灰({r},{g},{b})"
    elif r > 80 and g > 50 and b < 50:
        desc = "橙棕/木头"
    elif r < 50 and g < 50 and b < 50:
        desc = "黑色/暗"
    else:
        desc = f"混合({r},{g},{b})"
    
    print(f"({col:2d},0): {desc}")

print("\n=== 关键颜色瓦片位置（所有行）===\n")

# 扫描所有行找草地/泥土/水/石板
for row in range(rows):
    for col in range(cols):
        x1, y1 = col * tile_w, row * tile_h
        tile = img.crop((x1, y1, x1 + tile_w, y1 + tile_h))
        center = tile.crop((8, 8, 24, 24))
        pixels = list(center.getdata())
        n = len(pixels)
        r = sum(p[0] for p in pixels) // n
        g = sum(p[1] for p in pixels) // n
        b = sum(p[2] for p in pixels) // n
        
        # 只输出显著特征的瓦片
        if r < 80 and g > 100 and b < 80:
            print(f"({col:2d},{row:2d}): 绿色/草地  RGB({r},{g},{b})")
        elif r > 120 and g > 100 and b < 80:
            print(f"({col:2d},{row:2d}): 棕色/泥土  RGB({r},{g},{b})")
        elif r < 80 and g < 80 and b > 120:
            print(f"({col:2d},{row:2d}): 蓝色/水    RGB({r},{g},{b})")
        elif r > 100 and g > 100 and b > 100 and abs(r-g) < 30 and abs(g-b) < 30:
            print(f"({col:2d},{row:2d}): 灰色/石板  RGB({r},{g},{b})")
        elif r > 120 and g < 80 and b < 80:
            print(f"({col:2d},{row:2d}): 红色       RGB({r},{g},{b})")
        elif r > 120 and g > 120 and b < 80:
            print(f"({col:2d},{row:2d}): 黄色       RGB({r},{g},{b})")
