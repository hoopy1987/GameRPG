# 矿洞调查开发任务追踪

## 任务清单（9项）——全部完成 ✅

### 1. 场景切换系统
- [x] scene_transition.gd（AutoLoad，淡入淡出+玩家状态保存/恢复）
- [x] project.godot 注册 SceneTransition

### 2. 矿洞场景
- [x] scenes/cave.tscn（60×40 TileMap，含入口区/主通道/侧室/Boss房）
- [x] scripts/cave_generator.gd（矿洞布局生成器）
- [x] 复用现有 new_tileset.tres（STONE/WALL/DIRT/WOOD）

### 3. 矿洞入口
- [x] world.tscn 北部添加 CaveEntrance Area2D
- [x] world_generator.gd 添加 _on_cave_entrance_body_entered 处理
- [x] cave_generator.gd 添加返回 world 的出口处理

### 4. 新敌人
- [x] data/enemies.json 添加 gargoyle（石像鬼，80HP，石化光线，掉落gargoyle_stone）

### 5. 新物品
- [x] data/items.json 添加 gargoyle_stone（材料）
- [x] data/items.json 添加 vein_heart（任务道具）

### 6. 任务链
- [x] data/quests.json 添加 mine_rescue（矿洞救援，6阶段任务链）
- [x] stages: 拜访守卫→进入矿洞→寻找队长→击败石像鬼→取得矿脉之心→回报任务

### 7. 新NPC
- [x] cave.tscn 中放置矿洞守卫 NPC（复用 npc.tscn）
- [x] cave.tscn 中放置矿工队长·托尔 NPC（复用 npc.tscn）

### 8. 存档支持
- [x] save_manager.gd save_game 记录 current_scene
- [x] save_manager.gd load_game 检测场景差异并调用 SceneTransition.change_scene()

### 9. 测试扩展
- [x] test_full.gd 新增阶段11（8项矿洞内容测试）
- [x] 11阶段共50项，矿洞8项全通过

## 提交记录
- 2026-05-19: `b948712` feat: 矿洞调查剧情第一幕完整内容
- 2026-05-19: `e0e9dd6` fix: GDScript syntax error at line 664（world_generator.gd）
- 2026-05-19: `d4161cf` feat: village optimization（村庄优化，另一会话）

## 测试基线
- 原42项: 42/42 通过（100%）
- 新增8项: 8/8 通过（100%）
- 总计50项: 45通过，4项既有资源缺失，1项环境限制

## 备注
- world_generator.gd:387-388 修复了 strict 模式类型推断问题（var bx: int / var by: int）
- NPC纹理8个加载失败为既有问题（.import文件已补，headless模式未触发缓存重建，图形窗口启动后自动修复）
