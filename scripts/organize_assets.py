#!/usr/bin/env python3
"""
Asset organizer for Godot RPG project.
Copies existing extracted/generated assets into a clean directory structure:
  assets/tilesets/      - terrain, walls, floors
  assets/sprites/chars/ - player, NPC, enemy character sprites
  assets/items/         - weapon, armor, consumable icons
  assets/ui/            - UI elements (kept as-is, supplemented)
"""

import os
import shutil
from pathlib import Path

BASE = Path(r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\assets")

# ---------------------------------------------------------------------------
def ensure_dir(p: Path):
    p.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# 1. TILESETS
# ---------------------------------------------------------------------------
tilesets_dir = BASE / "tilesets"
ensure_dir(tilesets_dir)

# Generated terrain tiles
generated = BASE / "generated"
terrain_map = {
    "tile_grass.png": "ground_grass.png",
    "tile_dirt.png": "ground_dirt.png",
    "tile_stone.png": "ground_stone.png",
    "tile_water.png": "ground_water.png",
    "tile_sand.png": "ground_sand.png",
    "tile_wood.png": "floor_wood.png",
    "tile_wall.png": "wall_stone.png",
    "tile_roof.png": "roof_tile.png",
}
for src_name, dst_name in terrain_map.items():
    src = generated / src_name
    dst = tilesets_dir / dst_name
    if src.exists():
        shutil.copy2(src, dst)
        print(f"[tilesets] {dst_name}")

# Extracted Dungeon Crawl tiles – copy variety tiles with descriptive names
extracted = BASE / "extracted"
dc_map = {
    # Grass variations
    "grass_0.png": "ground_grass_0.png",
    "grass_1.png": "ground_grass_1.png",
    "grass_2.png": "ground_grass_2.png",
    "grass_3.png": "ground_grass_3.png",
    "grass_4.png": "ground_grass_4.png",
    # Wall variations
    "wall_0.png": "wall_brick_0.png",
    "wall_1.png": "wall_brick_1.png",
    "wall_2.png": "wall_brick_2.png",
    "wall_3.png": "wall_brick_3.png",
    # Stone / pavement variations (from tile rows 0-1)
    "tile_0_15.png": "pavement_0.png",
    "tile_0_16.png": "pavement_1.png",
    "tile_0_17.png": "pavement_2.png",
    "tile_1_15.png": "pavement_cracked_0.png",
    "tile_1_16.png": "pavement_cracked_1.png",
    "tile_1_17.png": "pavement_cracked_2.png",
    # Dirt / earth
    "tile_2_15.png": "ground_mud_0.png",
    "tile_2_16.png": "ground_mud_1.png",
    "tile_2_17.png": "ground_mud_2.png",
    # Water / fountain
    "tile_0_19.png": "water_pool_0.png",
    "tile_0_20.png": "water_pool_1.png",
    "tile_1_19.png": "water_pool_2.png",
    "tile_1_20.png": "water_pool_3.png",
    # Wood / construction
    "tile_0_21.png": "wood_plank_0.png",
    "tile_0_22.png": "wood_plank_1.png",
    "tile_1_21.png": "wood_plank_2.png",
    "tile_1_22.png": "wood_plank_3.png",
    # Doors / gates
    "tile_0_23.png": "door_wood_closed.png",
    "tile_0_24.png": "door_wood_open.png",
    "tile_1_23.png": "door_iron_closed.png",
    "tile_1_24.png": "door_iron_open.png",
    # Fence / bars
    "tile_0_26.png": "fence_wood_0.png",
    "tile_0_27.png": "fence_wood_1.png",
    "tile_0_28.png": "fence_wood_2.png",
    "tile_0_29.png": "fence_wood_3.png",
    # Trees / nature
    "tile_2_18.png": "tree_oak.png",
    "tile_2_19.png": "tree_pine.png",
    "tile_2_20.png": "tree_dead.png",
    "tile_2_21.png": "tree_apple.png",
    "tile_3_18.png": "bush_small.png",
    "tile_3_19.png": "bush_flowers.png",
    "tile_3_20.png": "flowers_red.png",
    "tile_3_21.png": "flowers_white.png",
    # Crops / farm
    "tile_2_22.png": "wheat_field_0.png",
    "tile_2_23.png": "wheat_field_1.png",
    "tile_2_24.png": "wheat_field_2.png",
    "tile_2_25.png": "carrot_patch.png",
    "tile_2_26.png": "cabbage_patch.png",
    # Rocks / details
    "tile_2_27.png": "rock_small.png",
    "tile_2_28.png": "rock_large.png",
    "tile_2_29.png": "rock_mossy.png",
    # Signs / notice boards
    "tile_3_22.png": "sign_wood.png",
    "tile_3_23.png": "sign_direction.png",
    "tile_3_24.png": "notice_board.png",
    # Bench / well / fountain pieces
    "tile_3_25.png": "well.png",
    "tile_3_26.png": "fountain_base.png",
    "tile_3_27.png": "fountain_water.png",
    "tile_3_28.png": "bench_wood.png",
    "tile_3_29.png": "lantern_post.png",
    # Roof / building details
    "tile_4_15.png": "roof_thatch_0.png",
    "tile_4_16.png": "roof_thatch_1.png",
    "tile_4_17.png": "roof_tile_0.png",
    "tile_4_18.png": "roof_tile_1.png",
    "tile_4_19.png": "roof_slate_0.png",
    "tile_4_20.png": "roof_slate_1.png",
    # Windows / building features
    "tile_4_21.png": "window_shutter.png",
    "tile_4_22.png": "window_glass.png",
    "tile_4_23.png": "chimney.png",
    "tile_4_24.png": "ladder.png",
    # Forge / smithy details
    "tile_4_25.png": "anvil.png",
    "tile_4_26.png": "forge.png",
    "tile_4_27.png": "hammer.png",
    "tile_4_28.png": "tongs.png",
    "tile_4_29.png": "barrel.png",
    # Tavern / market
    "tile_5_15.png": "barrel_stacked.png",
    "tile_5_16.png": "crate.png",
    "tile_5_17.png": "sack.png",
    "tile_5_18.png": "table_wood.png",
    "tile_5_19.png": "stool.png",
    "tile_5_20.png": "mug.png",
    "tile_5_21.png": "bottle.png",
    "tile_5_22.png": "loaf_bread.png",
    "tile_5_23.png": "meat_haunch.png",
    "tile_5_24.png": "cheese_wheel.png",
    # Market stalls / goods
    "tile_5_25.png": "stall_fabric.png",
    "tile_5_26.png": "stall_wood.png",
    "tile_5_27.png": "basket.png",
    "tile_5_28.png": "scroll.png",
    "tile_5_29.png": "book.png",
    # Church / sacred
    "tile_6_15.png": "altar.png",
    "tile_6_16.png": "candle.png",
    "tile_6_17.png": "candelabra.png",
    "tile_6_18.png": "cross.png",
    "tile_6_19.png": "pew.png",
    "tile_6_20.png": "bell.png",
    "tile_6_21.png": "holy_water.png",
    "tile_6_22.png": "incense.png",
    "tile_6_23.png": "tombstone.png",
    "tile_6_24.png": "tombstone_old.png",
}
for src_name, dst_name in dc_map.items():
    src = extracted / src_name
    dst = tilesets_dir / dst_name
    if src.exists():
        shutil.copy2(src, dst)
        print(f"[tilesets] {dst_name}")

# ---------------------------------------------------------------------------
# 2. SPRITES / CHARACTERS
# ---------------------------------------------------------------------------
chars_dir = BASE / "sprites" / "characters"
ensure_dir(chars_dir)

# Player character (knight)
char_map = {
    # Player
    "char_knight.png": "player_knight.png",
    "char_enemy.png": "enemy_goblin.png",
    "char_villager.png": "npc_villager.png",
    "char_shopkeeper.png": "npc_merchant.png",
}
for src_name, dst_name in char_map.items():
    src = generated / src_name
    dst = chars_dir / dst_name
    if src.exists():
        shutil.copy2(src, dst)
        print(f"[sprites/chars] {dst_name}")

# Walk animation frames
animations = BASE / "animations"
anim_map = {
    # Player walk
    "player_walk_f0.png": "player_knight_walk_0.png",
    "player_walk_f1.png": "player_knight_walk_1.png",
    "player_walk_f2.png": "player_knight_walk_2.png",
    "player_walk_f3.png": "player_knight_walk_3.png",
    # Enemy walk
    "char_enemy_walk_f0.png": "enemy_goblin_walk_0.png",
    "char_enemy_walk_f1.png": "enemy_goblin_walk_1.png",
    "char_enemy_walk_f2.png": "enemy_goblin_walk_2.png",
    "char_enemy_walk_f3.png": "enemy_goblin_walk_3.png",
    # Villager walk
    "char_villager_walk_f0.png": "npc_villager_walk_0.png",
    "char_villager_walk_f1.png": "npc_villager_walk_1.png",
    "char_villager_walk_f2.png": "npc_villager_walk_2.png",
    "char_villager_walk_f3.png": "npc_villager_walk_3.png",
    # Shopkeeper walk
    "char_shopkeeper_walk_f0.png": "npc_merchant_walk_0.png",
    "char_shopkeeper_walk_f1.png": "npc_merchant_walk_1.png",
    "char_shopkeeper_walk_f2.png": "npc_merchant_walk_2.png",
    "char_shopkeeper_walk_f3.png": "npc_merchant_walk_3.png",
    # NPC variants (using existing npc_ prefixed frames)
    "npc_villager_walk_f0.png": "npc_villager_alt_walk_0.png",
    "npc_villager_walk_f1.png": "npc_villager_alt_walk_1.png",
    "npc_villager_walk_f2.png": "npc_villager_alt_walk_2.png",
    "npc_villager_walk_f3.png": "npc_villager_alt_walk_3.png",
    "npc_shopkeeper_walk_f0.png": "npc_merchant_alt_walk_0.png",
    "npc_shopkeeper_walk_f1.png": "npc_merchant_alt_walk_1.png",
    "npc_shopkeeper_walk_f2.png": "npc_merchant_alt_walk_2.png",
    "npc_shopkeeper_walk_f3.png": "npc_merchant_alt_walk_3.png",
}
for src_name, dst_name in anim_map.items():
    src = animations / src_name
    dst = chars_dir / dst_name
    if src.exists():
        shutil.copy2(src, dst)
        print(f"[sprites/chars] {dst_name}")

# ---------------------------------------------------------------------------
# 3. ITEMS
# ---------------------------------------------------------------------------
items_dir = BASE / "items"
ensure_dir(items_dir)

item_map = {
    "item_sword.png": "weapon_sword.png",
    "item_shield.png": "armor_shield.png",
    "item_potion.png": "consumable_potion.png",
    "item_coin.png": "misc_coin.png",
    "item_crest.png": "misc_crest.png",
    "item_bat_wing.png": "material_bat_wing.png",
    "item_spider_venom.png": "material_spider_venom.png",
}
for src_name, dst_name in item_map.items():
    src = generated / src_name
    dst = items_dir / dst_name
    if src.exists():
        shutil.copy2(src, dst)
        print(f"[items] {dst_name}")

# ---------------------------------------------------------------------------
# 4. UI (supplement existing with Kenney elements if available)
# ---------------------------------------------------------------------------
ui_dir = BASE / "ui"
ensure_dir(ui_dir / "kenney")

# The Kenney RPG spritesheet has UI-like elements but no dedicated UI pack.
# We note this and keep the existing generated UI assets which work fine.
# If Kenney UI Pack is downloaded later, it goes here.
print("\n[ui] Existing UI assets kept. Kenney UI Pack not found in downloads.")

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print("\n--- Asset Organization Complete ---")
for d in [tilesets_dir, chars_dir, items_dir]:
    count = len(list(d.glob("*.png")))
    print(f"  {d.relative_to(BASE)}: {count} PNG files")
