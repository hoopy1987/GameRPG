from PIL import Image
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def generate_walk_frames(input_path, output_dir):
    img = Image.open(input_path).convert("RGBA")
    w, h = img.size
    name = os.path.splitext(os.path.basename(input_path))[0]
    out_dir = os.path.join(BASE_DIR, output_dir)
    os.makedirs(out_dir, exist_ok=True)
    
    # 根据尺寸决定偏移量（32x32的角色蹦跳2px，16x16的蹦跳1px）
    shift_y = 2 if h >= 32 else 1
    shift_x = 1 if w >= 32 else 0
    
    frames = []
    for i in range(4):
        f = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        if i == 1:
            # 帧1: 上移，模拟右腿迈步
            f.paste(img, (0, -shift_y), img)
        elif i == 3:
            # 帧3: 上移+轻微水平偏移，模拟左腿迈步
            f.paste(img, (shift_x, -shift_y), img)
        else:
            # 帧0、帧2: 中立
            f.paste(img, (0, 0), img)
        frames.append(f)
    
    for i, frame in enumerate(frames):
        out_path = os.path.join(out_dir, f"{name}_walk_f{i}.png")
        frame.save(out_path)
        print(f"  -> {out_path}")

# 处理项目中所有实际使用的角色图
targets = [
    "assets/generated/char_knight.png",
    "assets/generated/char_enemy.png",
    "assets/generated/char_villager.png",
    "assets/generated/char_shopkeeper.png",
    "assets/npc_villager.png",
    "assets/npc_shopkeeper.png",
    "assets/player.png",
]

for t in targets:
    p = os.path.join(BASE_DIR, t)
    if os.path.exists(p):
        print(f"Processing {t}...")
        generate_walk_frames(p, "assets/animations")
    else:
        print(f"Missing: {t}")

print("Done!")
