from PIL import Image
import urllib.request
import os

output_dir = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\downloads"
os.makedirs(output_dir, exist_ok=True)

# Try to download free tileset images from direct links
urls = [
    # Free grass tile from known sources
    ("https://raw.githubusercontent.com/ezimba/img/master/grass_tile_16.png", "grass.png"),
]

for url, filename in urls:
    try:
        filepath = os.path.join(output_dir, filename)
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=15) as response:
            with open(filepath, 'wb') as f:
                f.write(response.read())
        print(f"Downloaded: {filename}")
    except Exception as e:
        print(f"Failed {filename}: {e}")
