# 矿洞调查开发任务追踪

## 任务清单（9项）

### ✅ 已完成
- [x] 角色初始化
- [x] 代码基线验证（42/42通过）
- [x] Godot 4.6.2安装

### 🔄 开发中

#### 1. 场景切换系统
- [ ] scene_transition.gd（AutoLoad）
- [ ] project.godot注册

#### 2. 矿洞场景
- [ ] cave.tscn（简化版，复用现有TileSet）
- [ ] 矿洞布局（入口区→主通道→Boss房间）

#### 3. 矿洞入口
- [ ] world.tscn添加矿洞入口（Area2D触发）

#### 4. 新敌人
- [ ] enemies.json添加gargoyle
- [ ] 敌人纹理占位图

#### 5. 新物品
- [ ] items.json添加矿洞相关道具

#### 6. 任务链
- [ ] quests.json更新为多阶段任务链
- [ ] quest_manager.gd扩展支持stages

#### 7. 新NPC
- [ ] cave_guard.tscn
- [ ] miner_captain.tscn
- [ ] cave.tscn中放置

#### 8. 存档支持
- [ ] save_manager.gd支持cave场景
- [ ] save数据记录当前场景名

#### 9. 测试扩展
- [ ] test_full.gd添加矿洞相关测试

## 当前commit: 017c2b4
