import os, re

base = 'C:/Users/lenovo/.kimi_openclaw/workspace/godot_rpg/scripts'

# For each file, replace risky := patterns
replacements = {
    'enemy.gd': [
        ('var player := get_tree().get_first_node_in_group("player")', 'var player = get_tree().get_first_node_in_group("player") as Node2D'),
        ('var ftm := get_tree().get_first_node_in_group("floating_text_manager")', 'var ftm = get_tree().get_first_node_in_group("floating_text_manager") as Node'),
        ('var quest_mgr := get_tree().get_first_node_in_group("quest_manager")', 'var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node'),
    ],
    'item_pickup.gd': [
        ('var player := get_tree().get_first_node_in_group("player")', 'var player = get_tree().get_first_node_in_group("player") as Node2D'),
    ],
    'main_menu.gd': [
        ('var save_mgr := get_tree().get_first_node_in_group("save_manager")', 'var save_mgr = get_tree().get_first_node_in_group("save_manager") as Node'),
    ],
    'merchant.gd': [
        ('var player := get_tree().get_first_node_in_group("player")', 'var player = get_tree().get_first_node_in_group("player") as Node2D'),
        ('var quest_mgr := get_tree().get_first_node_in_group("quest_manager")', 'var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node'),
    ],
    'npc.gd': [
        ('var quest_mgr := get_tree().get_first_node_in_group("quest_manager")', 'var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node'),
    ],
    'pause_menu.gd': [
        ('var save_mgr := get_tree().get_first_node_in_group("save_manager")', 'var save_mgr = get_tree().get_first_node_in_group("save_manager") as Node'),
    ],
    'player.gd': [
        ('var ftm := get_tree().get_first_node_in_group("floating_text_manager")', 'var ftm = get_tree().get_first_node_in_group("floating_text_manager") as Node'),
        ('var area_results := space.intersect_shape(area_query, 10)', 'var area_results: Array = space.intersect_shape(area_query, 10)'),
        ('var body_results := space.intersect_shape(body_query, 5)', 'var body_results: Array = space.intersect_shape(body_query, 5)'),
        ('var results := space.intersect_shape(query, 10)', 'var results: Array = space.intersect_shape(query, 10)'),
    ],
    'quest_manager.gd': [
        ('var qt := get_tree().get_first_node_in_group("quest_tracker_ui")', 'var qt = get_tree().get_first_node_in_group("quest_tracker_ui") as Node'),
        ('var ftm := get_tree().get_first_node_in_group("floating_text_manager")', 'var ftm = get_tree().get_first_node_in_group("floating_text_manager") as Node'),
        ('var player := get_tree().get_first_node_in_group("player")', 'var player = get_tree().get_first_node_in_group("player") as Node2D'),
    ],
    'quest_tracker_ui.gd': [
        ('var quest_mgr := get_tree().get_first_node_in_group("quest_manager")', 'var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node'),
    ],
    'save_manager.gd': [
        ('var player := get_tree().get_first_node_in_group("player")', 'var player = get_tree().get_first_node_in_group("player") as Node2D'),
        ('var quest_mgr := get_tree().get_first_node_in_group("quest_manager")', 'var quest_mgr = get_tree().get_first_node_in_group("quest_manager") as Node'),
    ],
}

for fname, patterns in replacements.items():
    path = os.path.join(base, fname)
    if not os.path.exists(path):
        print('SKIP: ' + fname)
        continue
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    original = content
    for old, new in patterns:
        content = content.replace(old, new)
    if content != original:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print('FIXED: ' + fname)
    else:
        print('UNCHANGED: ' + fname)

print('Done')
