# Godot RPG 开发日志 — 2026-05-15

## 📋 项目概况

| 项目 | 详情 |
|------|------|
| **项目路径** | `C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg\` |
| **引擎** | Godot 4.6.2-stable |
| **类型** | 2D Top-Down 中世纪 RPG |
| **启动方式** | `godot --path "C:\Users\lenovo\.kimi_openclaw\workspace\godot_rpg"` |

---

## ✅ 已完成系统（全部验证通过）

| # | 系统 | 功能细节 |
|---|------|---------|
| 1 | **移动控制** | WASD 四向移动，摩擦减速，相机平滑跟随 (zoom=2) |
| 2 | **角色精灵** | 动态加载 32×32 像素角色（骑士/村民/商人/敌人），左右自动翻转 |
| 3 | **瓦片地图** | 80×45 村庄自动生成（草地/泥土/石头/水/墙/屋顶/木地/沙地） |
| 4 | **NPC 对话** | 走近显示 `!`，空格触发对话气泡 UI，底部面板逐条推进 |
| 5 | **战斗系统** | J 键攻击，武器挥动动画，敌人击退 150 速度，击杀掉落金币 |
| 6 | **敌人 AI** | 巡逻/追逐/攻击三态，3 个动态生成，死后重生场景重载 |
| 7 | **装备系统** | 4 槽位（主手/副手/头盔/盔甲），背包选中空格装备，点击槽位卸下 |
| 8 | **物品系统** | 拾取进背包，药水使用回血，剑装备+5 伤害，武器显示在手上 |
| 9 | **金币经济** | 独立计数（不进背包），击杀掉落，背包顶部 💰 显示 |
| 10 | **背包 UI** | 400×300 紧凑面板，物品列表 + 4 装备槽 + 属性 + 金币 + 描述 |
| 11 | **任务系统** | 击杀 3 敌人 + 和村民对话 = 完成任务奖励金币 |
| 12 | **存档系统** | F5 保存（位置/HP/背包/装备/任务进度），F6 加载 |
| 13 | **血条 UI** | 玩家头顶实时 HP 条 + 数字，受击同步更新 |

---

## 📂 文件结构

```
godot_rpg/
├── project.godot              # 项目配置 + 输入映射
├── icon.svg
├── assets/
│   ├── generated/             # 🎨 程序生成的像素素材
│   │   ├── tile_*.png         # 8种瓦片（草地/泥土/石头/水/墙/屋顶/木/沙）
│   │   ├── char_*.png         # 4种角色（骑士/村民/商人/敌人）
│   │   ├── item_*.png         # 4种物品（药水/剑/盾/金币）
│   │   ├── ui_*.png           # UI素材（血条背景/填充/面板）
│   │   └── tileset_sheet.png  # 瓦片合集
│   ├── kenney_rpg/            # 下载的 Kenney Roguelike RPG Pack
│   ├── kenney_chars/          # 下载的 Kenney Characters
│   └── chars/                 # 提取的单独角色预览
├── scenes/
│   ├── world.tscn             # 主场景（地图+玩家+NPC+敌人+物品）
│   ├── player.tscn            # 玩家角色
│   ├── npc.tscn               # NPC模板
│   ├── enemy.tscn             # 敌人模板
│   ├── enemy_spawner.tscn     # 动态生成敌人
│   ├── item_pickup.tscn       # 地面可拾取物品
│   ├── dialogue_bubble.tscn   # 对话气泡 UI
│   ├── inventory_ui.tscn      # 背包 UI（最新版 400×300）
│   ├── quest_manager.tscn     # 任务管理器
│   └── save_manager.tscn      # 存档管理器
└── scripts/
	├── player.gd              # 玩家：移动/攻击/装备/背包/血条/存档
	├── npc.gd                 # NPC：对话/面向玩家
	├── enemy.gd               # 敌人：AI/受击/击退/死亡掉落
	├── enemy_spawner.gd       # 动态生成敌人
	├── world_generator.gd     # 村庄地图生成
	├── dialogue_bubble.gd     # 对话气泡逻辑
	├── inventory_ui.gd        # 背包 UI 逻辑
	├── quest_manager.gd       # 任务追踪
	├── save_manager.gd          # 存档读写
	└── item_pickup.gd         # 物品拾取逻辑
```

---

## 🎮 完整控制键位

| 按键 | 功能 |
|------|------|
| `W A S D` | 移动 |
| `空格` | 交互 / 拾取 / NPC 对话 / 背包内使用 |
| `J` | 攻击（必定挥剑，命中敌人+击退+击杀掉金币）|
| `I` | 打开/关闭背包 |
| `U` | 快捷卸下主手武器 |
| `F5` | 保存游戏 |
| `F6` | 加载游戏 |

---

## ⚠️ 已知问题 & 待办

| 优先级 | 问题 | 说明 |
|--------|------|------|
| 🔴 高 | 敌人太强 | 3个围攻掉血极快，需减数量/削伤害/加防御 |
| 🟡 中 | UID 警告 | `quest123` / `save123` UID 无效，但不影响运行 |
| 🟡 中 | 房屋碰撞缺失 | 墙壁瓦片无碰撞体，玩家可穿墙 |
| 🟢 低 | 金币无用途 | 有计数但无商店/消耗渠道 |
| 🟢 低 | 角色无行走动画 | 单帧精灵，只有翻转 |
| 🟢 低 | 无音效/BGM | 全程静音 |
| 🟢 低 | 存档无 UI 提示 | F5/F6 只在控制台 print，无屏幕反馈 |

---

## 🔧 技术栈

- **引擎**：Godot 4.6.2-stable (OpenGL 兼容模式)
- **语言**：GDScript
- **素材**：Pillow 生成的像素艺术 + Kenney CC0 素材包
- **版本控制**：待初始化 git

---

## 📝 开发时间线

| 时间 | 里程碑 |
|------|--------|
| 09:42 | 开始项目，收集电脑配置 |
| 10:00 | 完成无锡统计局数据抓取（36指标，Python+WebBridge）|
| 10:47 | Godot 项目创建，基础移动+相机 |
| 11:05 | NPC 对话系统完成 |
| 11:30 | 下载 Kenney 素材，角色替换占位图 |
| 12:00 | 瓦片地图+敌人AI+战斗系统完成 |
| 14:00 | 背包系统+物品拾取+装备系统完成 |
| 15:00 | 任务系统+存档系统完成 |
| 16:00 | 装备系统重做（4槽位+属性查看+脱下）|
| 17:00 | 战斗体验优化（武器挥动+击退+击杀掉落）|
| 17:30 | 空挥武器+金币独立+背包UI缩小 |

---

## 2026-05-18 策划+开发更新

### 策划文档产出
- `策划文档 — RPG基础功能与UI体系.md` — 完整策划文档（缺口清单/设计规格/UI规范/开发任务清单）

### Phase 0 — 阻塞修复（全部完成）

| # | 任务 | 完成内容 |
|---|------|---------|
| P0-T1 | 敌人平衡 | enemy_count=2, max_hp=20, attack_damage=3 |
| P0-T2 | 攻击预警 | 0.3s蓄力红圈脉冲闪烁 |
| P0-T3 | 玩家无敌帧 | 0.6s受击无敌 + sprite半透明闪烁 |
| P0-T4 | 房屋碰撞 | world_generator动态生成StaticBody2D墙 |
| P0-T5 | 死亡重生 | die()保留进度 + R键respawn() + 1s无敌 |
| P0-T6 | 存档补全 | 存gold/equipment/xp/level/max_hp/respawn_pos |
| P0-T7 | 存档恢复 | load_game()完整恢复 + recalc_stats + update_visuals |

### Phase 1 — 核心功能（全部完成）

| # | 任务 | 完成内容 |
|---|------|---------|
| P1-T1 | Toast提示 | toast_manager + autoload，存档/购买/任务均有反馈 |
| P1-T2 | 浮动文字 | floating_text_manager，伤害/XP/金币飘字 |
| P1-T3 | 经验等级 | add_xp(25)/level_up()，+10HP/+2ATK，头顶Lv.+XP条 |
| P1-T4 | 属性面板 | 背包内显示ATK(含装备加成)，头顶LV/HP/XP实时可见 |
| P1-T5 | 任务追踪UI | 右上角常驻面板，击杀/对话进度实时更新，L键切换 |
| P1-T6 | 商店/商人 | merchant.gd继承npc.gd，shop_ui支持买/卖/关闭，默认4商品 |
| P1-T7 | 主菜单 | main_menu.tscn，启动先进菜单，开始/读档/设置/退出 |
| P1-T8 | 暂停菜单 | pause_menu.tscn，ESC触发，继续/保存/读取/设置/返回菜单 |
| P1-T9 | 设置面板 | settings_ui，主音量/BGM/音效/全屏，持久化到settings.json |
| P1-T10 | 场景过渡Fade | scene_fader.tscn，黑屏淡入淡出，菜单/死亡/加载均触发 |

### Phase 2 — 体验打磨（部分完成）

| # | 任务 | 完成内容 |
|---|------|---------|
| P2-T3 | 敌人血条统一 | ProgressBar始终可见，绿(>50%)/黄(30-50%)/红(<30%) |
| P2-T6 | 对话打字机 | RichTextLabel + visible_ratio Tween，0.03s/字，空格加速 |
| P2-T9 | 暴击机制 | 10%概率×1.5倍伤害，金色飘字 |

### 新增/修改文件

**新建脚本：**
- `scripts/floating_text_manager.gd`
- `scripts/quest_tracker_ui.gd`
- `scripts/scene_fader.gd`
- `scripts/main_menu.gd`
- `scripts/pause_menu.gd`
- `scripts/settings_ui.gd`

**新建场景：**
- `scenes/floating_text.tscn`
- `scenes/floating_text_manager.tscn`
- `scenes/quest_tracker_ui.tscn`
- `scenes/scene_fader.tscn`
- `scenes/main_menu.tscn`
- `scenes/pause_menu.tscn`
- `scenes/settings_ui.tscn`

**修改脚本：**
- `scripts/player.gd` — 无敌帧/死亡重生/XP等级/暴击/浮动文字联动/quest_tracker输入
- `scripts/enemy.gd` — 数值平衡/攻击预警/XP浮动文字/血条三色
- `scripts/dialogue_bubble.gd` — 打字机效果
- `scripts/quest_manager.gd` — 任务完成Toast+飘字
- `scripts/save_manager.gd` — 完整存档数据结构
- `scripts/settings_ui.gd` — 自动创建BGM/SFX音频Bus

**修改场景：**
- `scenes/enemy.tscn` — max_hp=20, attack_damage=4, ProgressBar_value=20
- `scenes/dialogue_bubble.tscn` — TextLabel改为RichTextLabel
- `scenes/world.tscn` — 接入所有新UI节点 + 商人实例化 + 边界墙
- `project.godot` — 启动场景改为main_menu.tscn，新增pause/quest_tracker输入

### 完整键位表

| 按键 | 功能 |
|------|------|
| `W A S D` | 移动 |
| `空格` | 交互/拾取/NPC对话/背包内使用/对话加速 |
| `J` | 攻击（10%暴击×1.5倍）|
| `I` | 打开/关闭背包 |
| `U` | 快捷卸下主手武器 |
| `L` | 切换任务追踪面板显示 |
| `ESC` | 暂停菜单 |
| `R` | 死亡后重生 |
| `F5` | 保存游戏 |
| `F6` | 加载游戏 |

### 已知问题

| 优先级 | 问题 | 说明 |
|--------|------|------|
| 🟡 中 | UID占位符 | 新增.tscn文件用了占位uid，需Godot打开一次自动修正 |
| 🟢 低 | 行走动画 | 单帧滑步，Pillow自动生成4帧方案待执行 |
| 🟢 低 | 音效/BGM | AudioBus已创建，但无实际音频文件 |
| 🟢 低 | 背包网格布局 | 仍为ItemList，未改为GridContainer+图标 |
| ⚪ 延 | 多存档槽位 | 当前单档覆盖 |
| ⚪ 延 | 数据配置表化 | 敌人/物品/任务仍硬编码 |

---

*记录时间：2026-05-18 (Asia/Shanghai)*
*记录者：OpenClaw Agent (k2p5)*

---

## 2026-05-16 开发更新

### 新增系统

| # | 系统 | 功能细节 |
|---|------|---------|
| 14 | **商店系统** | 商人NPC出售药水/剑/盾，金币终于有了用途 |
| 15 | **XP/升级系统** | 击杀敌人获得25XP，升级+10HP/+2攻击，等级显示在头顶 |
| 16 | **死亡/重生系统** | 死亡后按[R]重生（不再强制重载场景），重生后1秒无敌 |
| 17 | **Toast通知** | 存档/读档/购买/金币不足均有屏幕提示 |
| 18 | **物品堆叠** | 药水类道具自动堆叠，显示数量(xN) |
| 19 | **房屋碰撞** | 墙壁瓦片生成StaticBody2D碰撞体，无法穿墙 |

### 优化修复

| 优先级 | 问题 | 修复方式 |
|--------|------|---------|
| 敌人太强 | 敌人数量 3→2，攻击 5→3，玩家新增0.6秒受伤无敌帧 |
| UID警告 | 所有场景文件替换为合法Godot UID |
| 存档无UI | F5存档/F6读档触发Toast提示 |
| 金币无用途 | 商人出售4种商品（药水15G/剑50G/盾30G/高级药水40G） |

### 新增文件

- `scripts/merchant.gd` — 商人NPC逻辑
- `scripts/shop_ui.gd` — 商店UI面板
- `scripts/toast_manager.gd` — 屏幕通知系统
- `scenes/merchant.tscn` — 商人场景
- `scenes/shop_ui.tscn` — 商店UI场景
- `scenes/toast_manager.tscn` — Toast通知场景

### 修改文件

- `scripts/player.gd` — 新增XP/等级/死亡/重生/无敌/堆叠
- `scripts/enemy.gd` — 伤害降低(5→3)，死亡掉落5金币，给予25XP
- `scripts/enemy_spawner.gd` — 敌人数 3→2
- `scripts/world_generator.gd` — 房屋墙壁自动生成碰撞体
- `scripts/save_manager.gd` — 保存/读取XP/等级/装备/重生点，Toast反馈
- `scripts/inventory_ui.gd` — 显示堆叠数量
- `project.godot` — 新增[R]重生键位，ToastManager自动加载
- 所有.tscn场景文件 — 替换为合法UID

### 键位更新

| 按键 | 功能 |
|------|------|
| `R` | 死亡后重生（新增）|
| `I` | 背包 |
| `J` | 攻击 |
| `空格` | 交互/拾取/对话 |
| `U` | 快捷卸下主手 |
| `F5` | 存档 |
| `F6` | 读档 |
