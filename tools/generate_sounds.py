import wave, struct, math, random, os

SAMPLE_RATE = 44100
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def save_wav(filename, data):
    path = os.path.join(BASE_DIR, filename)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    frames = []
    for v in data:
        v = max(-1.0, min(1.0, v))
        frames.append(struct.pack('<h', int(v * 32767)))
    with wave.open(path, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        f.writeframes(b''.join(frames))
    print(f"Saved {path}")

def noise(duration, amp=0.3):
    n = int(SAMPLE_RATE * duration)
    return [random.uniform(-1, 1) * amp * max(0, 1 - i / n * 3) for i in range(n)]

def sine(freq, duration, amp=0.3):
    n = int(SAMPLE_RATE * duration)
    return [math.sin(2 * math.pi * freq * i / SAMPLE_RATE) * amp * (1 - i / n) for i in range(n)]

def square(freq, duration, amp=0.3):
    n = int(SAMPLE_RATE * duration)
    return [(1 if math.sin(2 * math.pi * freq * i / SAMPLE_RATE) > 0 else -1) * amp * (1 - i / n) for i in range(n)]

def sweep(start_f, end_f, duration, amp=0.3):
    n = int(SAMPLE_RATE * duration)
    return [math.sin(2 * math.pi * (start_f + (end_f - start_f) * i / n) * i / SAMPLE_RATE) * amp for i in range(n)]

# 1. sword_swing: 短促高频噪声（80ms）
ss = noise(0.08, 0.3)
for i in range(len(ss) - 1):
    ss[i] = (ss[i] - ss[i + 1]) * 0.6
save_wav("assets/sounds/sword_swing.wav", ss)

# 2. hit_damage: 低频方波+噪声混合（120ms）
hit = square(100, 0.12, 0.35)
for i in range(len(hit)):
    hit[i] += random.uniform(-0.08, 0.08) * (1 - i / len(hit))
save_wav("assets/sounds/hit_damage.wav", hit)

# 3. pickup: 上升音（180ms）
pk = sweep(600, 1200, 0.18, 0.3)
save_wav("assets/sounds/pickup.wav", pk)

# 4. level_up: 三个上升音符 C-E-G-C（500ms）
lu = []
lu.extend(sine(523.25, 0.10, 0.25))
lu.extend(sine(659.25, 0.10, 0.25))
lu.extend(sine(1046.50, 0.15, 0.25))
lu.extend(sine(523.25, 0.15, 0.20))
save_wav("assets/sounds/level_up.wav", lu)

# 5. enemy_die: 下降音（250ms）
ed = sweep(500, 80, 0.25, 0.25)
save_wav("assets/sounds/enemy_die.wav", ed)

# 6. player_hurt: 噪声+低频（150ms）
hurt = noise(0.15, 0.2)
for i in range(len(hurt)):
    hurt[i] += math.sin(2 * math.pi * 80 * i / SAMPLE_RATE) * 0.12 * (1 - i / len(hurt))
save_wav("assets/sounds/player_hurt.wav", hurt)

# 7. footsteps: 极短低频敲击（60ms）
foot = []
n = int(SAMPLE_RATE * 0.06)
for i in range(n):
    v = random.uniform(-0.3, 0.3) * (1 - i / n * 5)
    v += math.sin(2 * math.pi * 200 * i / SAMPLE_RATE) * 0.1 * (1 - i / n * 3)
    foot.append(v)
save_wav("assets/sounds/footstep.wav", foot)

# 8. bgm_loop: 简单8bit风格循环（8秒）
bgm = []
for i in range(int(SAMPLE_RATE * 8)):
    t = i / SAMPLE_RATE
    # C大调琶音节奏
    arp_notes = [261.63, 329.63, 392.00, 523.25, 392.00, 329.63]
    note_idx = int(t * 3) % len(arp_notes)
    freq = arp_notes[note_idx]
    v = math.sin(2 * math.pi * freq * i / SAMPLE_RATE) * 0.06
    # 和弦垫音
    v += math.sin(2 * math.pi * 261.63 * i / SAMPLE_RATE) * 0.03
    v += math.sin(2 * math.pi * 392.00 * i / SAMPLE_RATE) * 0.03
    # 节拍包络
    beat = (t * 2) % 1.0
    env = 1.0 if beat < 0.25 else 0.5
    bgm.append(v * env)
save_wav("assets/sounds/bgm_loop.wav", bgm)

print("All sounds generated!")
