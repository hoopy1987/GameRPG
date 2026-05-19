import os, re, sys

def check_tscn(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    errors = []
    fname = os.path.basename(path)
    
    # Check load_steps
    match = re.search(r'\[gd_scene load_steps=(\d+)', content)
    if match:
        load_steps = int(match.group(1))
        ext_count = len(re.findall(r'\[ext_resource', content))
        sub_count = len(re.findall(r'\[sub_resource', content))
        expected = 1 + ext_count + sub_count
        if load_steps != expected:
            errors.append(f'load_steps={load_steps}, expected={expected} (ext={ext_count}, sub={sub_count})')
    
    # Check for duplicate ext_resource ids
    ids = re.findall(r'id="([^"]+)"', content)
    seen = set()
    for id_val in ids:
        if id_val in seen:
            errors.append(f'duplicate ext_resource id: {id_val}')
        seen.add(id_val)
    
    # Check for groups format issue
    if 'groups = [' in content and 'PackedStringArray' not in content:
        errors.append('groups uses array format instead of PackedStringArray')
    
    # Check for missing script reference
    ext_scripts = re.findall(r'\[ext_resource type="Script".*?id="([^"]+)"', content)
    for script_id in ext_scripts:
        if f'ExtResource("{script_id}")' not in content:
            errors.append(f'Script ext_resource "{script_id}" not referenced by any node')
    
    # Check for nodes referencing non-existent ext_resource ids
    node_refs = re.findall(r'instance=ExtResource\("([^"]+)"\)', content)
    ext_ids = re.findall(r'\[ext_resource .*?id="([^"]+)"', content)
    for ref in node_refs:
        if ref not in ext_ids:
            errors.append(f'Node references missing ext_resource id: "{ref}"')
    
    return errors

scenes_dir = r'C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\scenes'
all_ok = True
for fname in sorted(os.listdir(scenes_dir)):
    if fname.endswith('.tscn'):
        path = os.path.join(scenes_dir, fname)
        errs = check_tscn(path)
        if errs:
            all_ok = False
            print(f'[FAIL] {fname}:')
            for e in errs:
                print(f'  - {e}')
        else:
            print(f'[OK] {fname}')

if all_ok:
    print('\nAll .tscn files passed validation!')
else:
    print('\nSome files have issues that need fixing.')
