# 🎮 Top-Down RPG Starter (Godot 4.6)

A 2D top-down RPG starter project with player movement, camera follow, NPCs, and dialogue.

## 📂 Project Structure

```
godot_rpg/
├── project.godot          # Project settings & input map
├── icon.svg               # Project icon
├── assets/                # Art assets (sprites, tilesets, etc.)
├── scenes/
│   ├── world.tscn         # Main game scene
│   ├── player.tscn        # Player character
│   └── npc.tscn           # NPC template
└── scripts/
    ├── player.gd          # Player movement & interaction
    ├── npc.gd             # NPC dialogue system
    └── editor_setup.gd    # Editor tool to generate placeholder sprites
```

## 🚀 Quick Start

### Step 1: Open in Godot
1. Launch Godot 4.6.2
2. Click **Import** → Browse to this folder → Select `project.godot`
3. Click **Import & Edit**

### Step 2: Generate Placeholder Sprites
1. In Godot, go to **Project → Tools → Run Editor Script**
2. Select `scripts/editor_setup.gd`
3. Click **Run** — this creates placeholder sprite frame resources

### Step 3: Assign Sprites to Characters
1. Open `scenes/player.tscn`
2. Click the `AnimatedSprite2D` node
3. In Inspector, assign **Sprite Frames** → `assets/player_frames.tres`
4. Do the same for `scenes/npc.tscn` with `assets/npc_frames.tres`

### Step 4: Run the Game
Press **F5** or click the play button ▶️

## 🎮 Controls

| Key | Action |
|-----|--------|
| `W` `A` `S` `D` | Move |
| `Space` | Interact with NPCs |

## 🏗️ What's Included

- ✅ **Player** — WASD movement with 4-direction facing + friction
- ✅ **Camera** — Smooth follow with drag margins
- ✅ **NPCs** — 2 example NPCs with dialogue cycling
- ✅ **Collision** — World boundaries + player-NPC interaction raycast
- ✅ **TileMap** — Ready for tile-based level design
- ✅ **Input Map** — Pre-configured in `project.godot`

## 🔧 Next Steps

Replace the placeholder `icon.svg` sprites with your own:
1. Import your character sprites into `assets/`
2. Open the `.tres` files in the SpriteFrames editor
3. Swap in your walk/idle animations for each direction

---

*Created with Godot 4.6.2*
