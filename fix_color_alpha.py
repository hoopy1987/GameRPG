import os, re

scenes_dir = r'C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\scenes'
scripts_dir = r'C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\scripts'
fixed = 0

# Regex: Color followed by exactly 3 comma-separated numbers, then closing paren
# We need to add a 4th argument (alpha=1)
pattern = re.compile(r'Color\(\s*([0-9.]+)\s*,\s*([0-9.]+)\s*,\s*([0-9.]+)\s*\)')

def fix_colors(content, filename):
    global fixed
    new_content = pattern.sub(r'Color(\1, \2, \3, 1)', content)
    if new_content != content:
        fixed += 1
        matches = pattern.findall(content)
        print(f'Fixed {len(matches)} Color() in {filename}')
        return new_content
    return content

# Fix all .tscn files
for fname in sorted(os.listdir(scenes_dir)):
    if not fname.endswith('.tscn'):
        continue
    path = os.path.join(scenes_dir, fname)
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content = fix_colors(content, fname)
    if new_content != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)

# Fix all .gd files too (some may have Color without alpha)
for fname in sorted(os.listdir(scripts_dir)):
    if not fname.endswith('.gd'):
        continue
    path = os.path.join(scripts_dir, fname)
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content = fix_colors(content, fname)
    if new_content != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)

print(f'\nDone! Fixed Color() alpha in {fixed} files.')
