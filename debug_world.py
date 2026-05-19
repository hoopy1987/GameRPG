import re

with open(r'C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\scenes\world.tscn', 'r', encoding='utf-8') as f:
    content = f.read()

ext_count = len(re.findall(r'\[ext_resource', content))
sub_count = len(re.findall(r'\[sub_resource', content))
ids = re.findall(r'id="([^"]+)"', content)
node_refs = re.findall(r'instance=ExtResource\("([^"]+)"\)', content)

print(f'ext_count={ext_count}, sub_count={sub_count}, expected_load_steps={1+ext_count+sub_count}')
print(f'ids found ({len(ids)}): {ids}')
print(f'node_refs ({len(node_refs)}): {node_refs}')

for ref in node_refs:
    if ref not in ids:
        print(f'MISSING: {ref}')
    else:
        print(f'OK: {ref}')
