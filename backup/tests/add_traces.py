import os

base = 'C:/Users/lenovo/.kimi_openclaw/workspace/godot_rpg/scripts'

# 1. player.gd - take_damage + die + respawn
path = os.path.join(base, 'player.gd')
with open(path, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Add trace to take_damage
content = content.replace(
    'func take_damage(amount: int) -> void:\n\tif invincible_timer > 0.0 or current_hp <= 0:\n\t\treturn\n\tcurrent_hp -= amount\n\tinvincible_timer = INVINCIBLE_DURATION\n\tupdate_hp_bar()',
    'func take_damage(amount: int) -> void:\n\tif invincible_timer > 0.0 or current_hp <= 0:\n\t\treturn\n\tcurrent_hp -= amount\n\tinvincible_timer = INVINCIBLE_DURATION\n\tupdate_hp_bar()\n\t\n\t# Trace\n\tif GameTrace and GameTrace.has_method("log_event"):\n\t\tGameTrace.log_event("player_take_damage", {"amount": amount, "hp": current_hp, "max_hp": max_hp})'
)

# Add trace to die
content = content.replace(
    'func die() -> void:\n\tif is_dead:\n\t\treturn\n\tis_dead = true\n\tvelocity = Vector2.ZERO\n\tprint("Player died!")',
    'func die() -> void:\n\tif is_dead:\n\t\treturn\n\tis_dead = true\n\tvelocity = Vector2.ZERO\n\tprint("Player died!")\n\t\n\t# Trace\n\tif GameTrace and GameTrace.has_method("log_event"):\n\t\tGameTrace.log_event("player_die", {"hp": current_hp, "level": level, "gold": gold, "pos": str(global_position)})'
)

# Add trace to respawn
content = content.replace(
    'func respawn() -> void:\n\tis_dead = false\n\tcurrent_hp = max_hp\n\tglobal_position = respawn_position\n\tvelocity = Vector2.ZERO\n\tinvincible_timer = 1.0',
    'func respawn() -> void:\n\tis_dead = false\n\tcurrent_hp = max_hp\n\tglobal_position = respawn_position\n\tvelocity = Vector2.ZERO\n\tinvincible_timer = 1.0\n\t\n\t# Trace\n\tif GameTrace and GameTrace.has_method("log_event"):\n\t\tGameTrace.log_event("player_respawn", {"hp": current_hp, "pos": str(global_position)})'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('FIXED: player.gd')

# 2. enemy.gd - perform_attack + die
path = os.path.join(base, 'enemy.gd')
with open(path, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

content = content.replace(
    'func perform_attack() -> void:\n\tif target and target.has_method("take_damage"):\n\t\ttarget.take_damage(attack_damage)\n\t\tif SoundManager and SoundManager.has_method("play_sfx"):\n\t\t\tSoundManager.play_sfx("hit_damage")',
    'func perform_attack() -> void:\n\tif target and target.has_method("take_damage"):\n\t\t# Trace\n\t\tif GameTrace and GameTrace.has_method("log_event"):\n\t\t\tGameTrace.log_event("enemy_attack", {"damage": attack_damage, "target_pos": str(target.global_position) if target else "none"})\n\t\ttarget.take_damage(attack_damage)\n\t\tif SoundManager and SoundManager.has_method("play_sfx"):\n\t\t\tSoundManager.play_sfx("hit_damage")'
)

content = content.replace(
    'func die() -> void:\n\tis_dying = true\n\tvelocity = Vector2.ZERO',
    'func die() -> void:\n\tis_dying = true\n\tvelocity = Vector2.ZERO\n\t\n\t# Trace\n\tif GameTrace and GameTrace.has_method("log_event"):\n\t\tGameTrace.log_event("enemy_die", {"type": get_meta("enemy_type", ""), "pos": str(global_position)})'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('FIXED: enemy.gd')

# 3. merchant.gd - interact (trade open)
path = os.path.join(base, 'merchant.gd')
with open(path, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

content = content.replace(
    'func interact() -> void:\n\tif is_merchant and shop_ui:',
    'func interact() -> void:\n\t# Trace\n\tif GameTrace and GameTrace.has_method("log_event"):\n\t\tGameTrace.log_event("merchant_interact", {"npc_name": npc_name})\n\tif is_merchant and shop_ui:'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('FIXED: merchant.gd')

# 4. quest_manager.gd - check_completion
path = os.path.join(base, 'quest_manager.gd')
with open(path, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

content = content.replace(
    'func check_completion() -> void:\n\tif completed:\n\t\treturn\n\t\n\tif kill_count >= required_kills and talked_to_npc:\n\t\tcompleted = true',
    'func check_completion() -> void:\n\tif completed:\n\t\treturn\n\t\n\t# Trace\n\tif GameTrace and GameTrace.has_method("log_event"):\n\t\tGameTrace.log_event("quest_check", {"kills": kill_count, "required": required_kills, "talked": talked_to_npc})\n\t\n\tif kill_count >= required_kills and talked_to_npc:\n\t\tcompleted = true\n\t\t# Trace\n\t\tif GameTrace and GameTrace.has_method("log_event"):\n\t\t\tGameTrace.log_event("quest_complete", {"quest_name": quest_name})'
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('FIXED: quest_manager.gd')

print('All trace logs added!')
