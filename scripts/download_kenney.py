import urllib.request, os

url = 'https://kenney.nl/media/pages/assets/roguelike-rpg-pack/12c03cd78b-1677697420/kenney_roguelike-rpg-pack.zip'
out = r'C:\Users\lenovo\Downloads\rpg_assets\kenney_roguelike.zip'

print('Downloading Kenney Roguelike/RPG Pack...')
urllib.request.urlretrieve(url, out)
sz = os.path.getsize(out)
print(f'Downloaded: {sz} bytes ({sz/1024/1024:.2f} MB)')
