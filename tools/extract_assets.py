import zipfile, os, shutil

src = r'C:\Users\lenovo\Downloads\rpg_assets\dungeon_crawl.zip'
dst = r'C:\Users\lenovo\Downloads\rpg_assets\dungeon_crawl'

# Clean extract
if os.path.exists(dst):
    shutil.rmtree(dst)
os.makedirs(dst, exist_ok=True)

with zipfile.ZipFile(src, 'r') as z:
    z.extractall(dst)
    print(f'Extracted {len(z.namelist())} files')

# Show structure
for root, dirs, files in os.walk(dst):
    level = root.replace(dst, '').count(os.sep)
    indent = ' ' * 2 * level
    print(f'{indent}{os.path.basename(root)}/')
    subindent = ' ' * 2 * (level + 1)
    for f in files[:10]:
        print(f'{subindent}{f}')
    if len(files) > 10:
        print(f'{subindent}... and {len(files)-10} more files')
