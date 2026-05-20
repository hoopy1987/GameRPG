#!/usr/bin/env python3
"""批量替换剩余的英文文本"""
import os
from pathlib import Path

BASE = Path(r"C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\scripts")

def replace_in_file(path: Path, reps: dict):
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    orig = text
    for old, new in reps.items():
        text = text.replace(old, new)
    if text != orig:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"[汉化] {path.name}")

# save_manager.gd
replace_in_file(BASE / "save_manager.gd", {
    'push_error("Failed to save game")': 'push_error("无法保存游戏")',
    'ToastManager.show_toast("Save failed!", 2.0)': 'ToastManager.show_toast("保存失败！", 2.0)',
    'push_error("Failed to open save file")': 'push_error("无法打开存档文件")',
    'push_error("Failed to parse save file: %s" % json.get_error_message())': 'push_error("解析存档文件失败：%s" % json.get_error_message())',
    'push_error("Invalid save data")': 'push_error("无效的存档数据")',
    'print("Save slot %d deleted" % slot)': 'print("存档槽 %d 已删除" % slot)',
})

# data_loader.gd
replace_in_file(BASE / "data_loader.gd", {
    'print("DataLoader: Failed to open %s" % path)': 'print("数据加载器：无法打开 %s" % path)',
    'print("DataLoader: JSON parse error in %s: %s" % [path, json.get_error_message()])': 'print("数据加载器：JSON解析错误 %s：%s" % [path, json.get_error_message()])',
    'print("DataLoader: loaded %d enemies, %d items, %d quests" % [_enemies.size(), _items.size(), _quests.size()])': 'print("数据加载器：已加载 %d 个敌人，%d 个物品，%d 个任务" % [_enemies.size(), _items.size(), _quests.size()])',
})

# quest_manager.gd
replace_in_file(BASE / "quest_manager.gd", {
    'print("Quest: %d/%d enemies defeated" % [kill_count, required_kills])': 'print("任务：已击败 %d/%d 个敌人" % [kill_count, required_kills])',
    'print("Quest: Talked to %s" % npc_name)': 'print("任务：已与%s对话" % npc_name)',
    'print("Reward received: %s" % reward_item["name"])': 'print("获得奖励：%s" % reward_item["name"])',
    'push_warning("QuestManager: quest \'%s\' not found in JSON" % quest_id)': 'push_warning("任务管理器：未在JSON中找到任务\'%s\'" % quest_id)',
})

# enemy_spawner.gd
replace_in_file(BASE / "enemy_spawner.gd", {
    'push_warning("EnemySpawner: no enemy_scene assigned")': 'push_warning("敌人生成器：未分配敌人场景")',
    'print("Spawned %d enemies" % enemy_count)': 'print("已生成 %d 个敌人" % enemy_count)',
})

# world_generator.gd
replace_in_file(BASE / "world_generator.gd", {
    'print("Village generated: %dx%d tiles" % [village_w, village_h])': 'print("村庄生成完毕：%dx%d 格" % [village_w, village_h])',
})

print("\n剩余英文文本汉化完成！")
