from PIL import Image
import urllib.request
import os

output_dir = r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets\downloads"
os.makedirs(output_dir, exist_ok=True)

urls = [
    # Big Brother Sprite Assets - Medieval Town (free)
    ("https://img.itch.zone/aW1hZ2UvMzY4Mzg0NS8yMTk1MjQ0NS5wbmc=/original/hq8dJt.png", "medieval_town_preview.png"),
]

for url, filename in urls:
    try:
        filepath = os.path.join(output_dir, filename)
        urllib.request.urlretrieve(url, filepath)
        print(f"Downloaded: {filename}")
    except Exception as e:
        print(f"Failed {filename}: {e}")
