#!/usr/bin/env python3
"""
批量汉化脚本：将 Godot RPG 项目中的所有英文文本替换为中文。
"""
import json
import os
import re
from pathlib import Path

BASE = Path(r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg")

# ============================================================================
# 1. JSON 文件汉化
# ============================================================================

def localize_items():
    path = BASE / "data" / "items.json"
    with open(path, "r", encoding="utf-8") as f:
        items = json.load(f)
    mapping = {
        "Health Potion": "生命药水",
        "Restores 20 HP": "恢复20点生命值",
        "Iron Sword": "铁剑",
        "A sharp iron sword": "一把锋利的铁剑",
        "A basic iron sword. +5 damage.": "一把基础铁剑。攻击力+5。",
        "Wooden Shield": "木盾",
        "A sturdy wooden shield": "一面坚固的木盾",
        "Leather Helmet": "皮头盔",
        "Basic leather head protection": "基础皮革头部防护",
        "Chain Armor": "锁子甲",
        "Light chainmail armor": "轻型锁子甲",
        "Knight's Crest": "骑士纹章",
        "A charred knight's crest... identical to yours": "一枚烧焦的骑士纹章……和你的一模一样",
        "Spider Venom Sac": "蜘蛛毒囊",
        "A venom sac from a cave spider": "洞穴蜘蛛的毒囊",
        "Bat Wing": "蝙蝠翅膀",
        "A leathery wing from a cave bat": "洞穴蝙蝠的皮翼",
    }
    for item in items:
        if item["name"] in mapping:
            item["name"] = mapping[item["name"]]
        if item.get("desc", "") in mapping:
            item["desc"] = mapping[item["desc"]]
    with open(path, "w", encoding="utf-8") as f:
        json.dump(items, f, ensure_ascii=False, indent="\t")
    print("[汉化] data/items.json")


def localize_quests():
    path = BASE / "data" / "quests.json"
    with open(path, "r", encoding="utf-8") as f:
        quests = json.load(f)
    mapping = {
        "First Steps": "启程",
        "Talk to the Villager and defeat 3 enemies.": "与村民对话并击败3个敌人。",
        "Ashes Commission": "灰烬委托",
        "Investigate the cave north of the village and uncover the truth of the knight's remains.": "调查村庄北部的洞穴，揭开骑士遗骸的真相。",
        "talk_elder": "拜访长者",
        "Talk to Elder Alder in the village center": "在村庄中心与赤杨长者对话",
        "enter_cave": "进入洞穴",
        "Enter the cave north of the village": "进入村庄北部的洞穴",
        "kill_spiders": "消灭蜘蛛",
        "Defeat 3 cave spiders": "击败3只洞穴蜘蛛",
        "inspect_remains": "调查遗骸",
        "Inspect the knight's remains deep in the cave": "检查洞穴深处的骑士遗骸",
        "report_back": "回报任务",
        "Report back to Elder Alder": "向赤杨长者汇报调查结果",
    }
    for quest in quests:
        if quest.get("name", "") in mapping:
            quest["name"] = mapping[quest["name"]]
        if quest.get("description", "") in mapping:
            quest["description"] = mapping[quest["description"]]
        for stage in quest.get("stages", []):
            if stage.get("id", "") in mapping:
                stage["id"] = mapping[stage["id"]]
            if stage.get("description", "") in mapping:
                stage["description"] = mapping[stage["description"]]
    with open(path, "w", encoding="utf-8") as f:
        json.dump(quests, f, ensure_ascii=False, indent="\t")
    print("[汉化] data/quests.json")


def localize_enemies():
    path = BASE / "data" / "enemies.json"
    with open(path, "r", encoding="utf-8") as f:
        enemies = json.load(f)
    mapping = {
        "Slime": "史莱姆",
        "Goblin": "哥布林",
        "Wolf": "野狼",
        "Cave Spider": "洞穴蜘蛛",
        "Cave Bat": "洞穴蝙蝠",
    }
    for enemy in enemies:
        if enemy["name"] in mapping:
            enemy["name"] = mapping[enemy["name"]]
    with open(path, "w", encoding="utf-8") as f:
        json.dump(enemies, f, ensure_ascii=False, indent="\t")
    print("[汉化] data/enemies.json")


# ============================================================================
# 2. GDScript 文件汉化（精确替换用户可见字符串）
# ============================================================================

def replace_in_file(path: Path, replacements: dict):
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    orig = text
    for old, new in replacements.items():
        text = text.replace(old, new)
    if text != orig:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"[汉化] {path.relative_to(BASE)}")


def localize_player_gd():
    path = BASE / "scripts" / "player.gd"
    reps = {
        '"主手"': '"主手"',  # 已是中文
        '"副手"': '"副手"',
        '"头盔"': '"头盔"',
        '"盔甲"': '"盔甲"',
        '"Added to inventory: %s"': '"已加入背包：%s"',
        '"Equipped %s to %s"': '"已将%s装备到%s"',
        '"Unequipped %s"': '"已卸下%s"',
        '"Unequipped %s from %s"': '"已从%s卸下%s"',
        '"Cannot equip %s"': '"无法装备%s"',
        '"Used %s! HP: %d/%d"': '"使用了%s！生命值：%d/%d"',
        '"Stacked %s (x%d)"': '"%s已叠加（x%d）"',
        '"Gold: %d (+ %d)"': '"金币：%d（+%d）"',
        '"Level Up! Now Lv.%d | HP: %d | ATK: %d"': '"升级了！当前等级%d | 生命值：%d | 攻击力：%d"',
        '"Player took %d damage! HP: %d/%d"': '"受到%d点伤害！生命值：%d/%d"',
        '"Player died!"': '"玩家阵亡！"',
        '"YOU DIED - Press [R] to respawn"': '"你阵亡了——按[R]键复活"',
        '"Player respawned at %s"': '"玩家在%s处复活"',
    }
    replace_in_file(path, reps)


def localize_npc_gd():
    path = BASE / "scripts" / "npc.gd"
    reps = {
        'npc_name = "NPC"': 'npc_name = "村民"',
        '"Hello!"': '"你好！"',
        '"Welcome to our village."': '"欢迎来到我们的村庄。"',
    }
    replace_in_file(path, reps)


def localize_merchant_gd():
    path = BASE / "scripts" / "merchant.gd"
    reps = {
        '"Health Potion"': '"生命药水"',
        '"Iron Sword"': '"铁剑"',
        '"Wooden Shield"': '"木盾"',
        '"Magic Potion"': '"魔法药水"',
        '"Restores 25 HP"': '"恢复25点生命值"',
        '"A sharp iron sword. +8 ATK"': '"一把锋利的铁剑。攻击力+8"',
        '"A sturdy wooden shield"': '"一面坚固的木盾"',
        '"Restores 50 HP"': '"恢复50点生命值"',
    }
    replace_in_file(path, reps)


def localize_shop_ui_gd():
    path = BASE / "scripts" / "shop_ui.gd"
    reps = {
        '"Buy"': '"购买"',
        '"Sell"': '"出售"',
        '"Not enough gold!"': '"金币不足！"',
        '"Bought %s!"': '"已购买%s！"',
        '"Sold %s for %dG!"': '"已出售%s，获得%d金币！"',
        '"ATK"': '"攻击力"',
        '"HP"': '"生命值"',
        '"Price: %dG"': '"价格：%d金币"',
        '"Sell: %dG (x%d = %dG total)"': '"出售：%d金币（x%d = 共%d金币）"',
    }
    replace_in_file(path, reps)


def localize_floating_text_gd():
    path = BASE / "scripts" / "floating_text_manager.gd"
    reps = {
        '"CRIT %s"': '"暴击 %s"',
        '"LEVEL UP! Lv.%d"': '"升级！等级%d"',
        '"Got %s!"': '"获得%s！"',
    }
    replace_in_file(path, reps)


def localize_quest_tracker_gd():
    path = BASE / "scripts" / "quest_tracker_ui.gd"
    reps = {
        '"COMPLETE"': '"已完成"',
        '"Defeat enemies %d/%d"': '"击败敌人 %d/%d"',
        '"Talk to %s %s"': '"与%s对话 %s"',
    }
    replace_in_file(path, reps)


def localize_item_pickup_gd():
    path = BASE / "scripts" / "item_pickup.gd"
    reps = {
        'item_name = "Health Potion"': 'item_name = "生命药水"',
        '"Restores 20 HP"': '"恢复20点生命值"',
        '"[SPACE] Pick up"': '"[空格] 拾取"',
        '"Picked up: %s x%d"': '"拾取了：%s x%d"',
        '"Picked up: %s"': '"拾取了：%s"',
    }
    replace_in_file(path, reps)


def localize_enemy_gd():
    path = BASE / "scripts" / "enemy.gd"
    reps = {
        '"Gold Coin"': '"金币"',
        '"A shiny gold coin"': '"一枚闪亮的金币"',
    }
    replace_in_file(path, reps)


# ============================================================================
# 3. TSCN 场景文件汉化
# ============================================================================

def localize_world_tscn():
    path = BASE / "scenes" / "world.tscn"
    reps = {
        'npc_name = "Villager"': 'npc_name = "村民"',
        'dialogue_lines = ["Hello traveler!", "Welcome to our village.", "The forest to the north is dangerous..."]'
        : 'dialogue_lines = ["你好，旅人！", "欢迎来到炭火村。", "北边的森林很危险，千万小心……"]',
        'npc_name = "Shopkeeper"': 'npc_name = "商人"',
        'dialogue_lines = ["I\'ve got the best prices in town!", "Sword? Shield? Potion? You name it!"]'
        : 'dialogue_lines = ["我这儿是全城最实惠的！", "剑？盾？药水？应有尽有！"]',
        'item_name = "Health Potion"': 'item_name = "生命药水"',
        'description = "Restores 20 HP"': 'description = "恢复20点生命值"',
        'item_name = "Iron Sword"': 'item_name = "铁剑"',
        'description = "A basic iron sword. +5 damage."': 'description = "一把基础铁剑。攻击力+5。"',
    }
    replace_in_file(path, reps)


def localize_main_menu_tscn():
    path = BASE / "scenes" / "main_menu.tscn"
    reps = {
        'text = "⚔️ MEDIEVAL RPG"': 'text = "⚔️ 中世纪 RPG"',
    }
    replace_in_file(path, reps)


# ============================================================================
# 主流程
# ============================================================================

if __name__ == "__main__":
    localize_items()
    localize_quests()
    localize_enemies()
    localize_player_gd()
    localize_npc_gd()
    localize_merchant_gd()
    localize_shop_ui_gd()
    localize_floating_text_gd()
    localize_quest_tracker_gd()
    localize_item_pickup_gd()
    localize_enemy_gd()
    localize_world_tscn()
    localize_main_menu_tscn()
    print("\n✅ 汉化完成！")
