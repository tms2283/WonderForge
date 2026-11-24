# WONDERFORGE: AETHERWORKS — GODOT GAME DIRECTION

A native Godot 4.7.2 project that pivots WonderForge away from its original web-dashboard approach toward a **third-person original-IP sandbox engineering adventure**: a playable world, modular machine construction, a physics rover test, racing checkpoints, exploration commissions and an offline mentor. A standalone original illustration is included for the title scene.

> **Release honesty:** This is an authored **vertical-slice foundation**, NOT a finished LEGO Worlds / Scrap Mechanic / Besiege-equivalent. The GDScript sources and scenes exist; the local environment does not have the Godot editor/runtime, so native execution and Raspberry Pi hardware performance are still pending. CI includes a Godot headless smoke test to be run after publishing.

## Start on a normal Windows, Mac, or Linux computer

1. Download the **official Godot 4.7.2 editor**: <https://godotengine.org/download/archive/4.7.2-stable/>.
2. Open Godot Project Manager → **Import** → select `game/project.godot`.
3. Run (F6 or F5). An original Aetherworks title screen appears.
4. Select **Begin Adventure**. Close the welcome folio, explore the 3D world, and experiment with fabrication and rover physics.
5. Read `docs/GAME_DESIGN_BIBLE.md`, `docs/VISUAL_ART_BIBLE.md`, and `agent/MASTER_BUILD_PROMPT.md` before continuing large-scale production.

## Demonstrated systems

| Implemented as source | Target for full production |
|---|---|
| Original cinematic title artwork and native Godot menu | Rigged hand-authored player and NPCs; dynamic cinematic presentation |
| Terrain, roads, workshop and settlement procedural 3D blockout | Premium authored world art and streamed 8+ biome zones |
| Third-person avatar and orbit camera | Expressive traversal, climbing, parkour and contextual interactions |
| Ten modular prototype parts, snap grid, layers, undo/redo, save | Full structural constraint graph, joints, wiring, stress, breakage |
| RigidBody rover with four raycast suspension points | Arbitrarily assembled wheeled, walking, flying and nautical machines |
| Track with checkpoint racing and lap clock | Race championships, AI opponents, leaderboards kept local |
| Eight original quests with progression and rewards | Narrative branching, factions, economy and community simulation |
| Diegetic native HUD, quest folio and ORBIT offline guide | Production interaction UX, voiced NPCs, localization and accessibility |
| Optional *read-only conversation* direct to local Ollama | Integrate existing permissioned WonderForge agent backend |

## Controls

`WASD` move/drive; `SHIFT` sprint; `SPACE` jump/brake; hold `right mouse` to orbit camera; `E` near an inventor to interact; `B` toggle fabricator; `V` drive/exit rover; `J` quest journal; `O` ORBIT; `F5` save; `ESC` close or return to menu. Fabricator: left click place, right click remove, `1..0` modules, `R` rotate, `[` and `]` layers, `Z/Y` undo/redo, mouse wheel select next part.

## No false promises about hardware

Godot Compatibility rendering is the *starting profile*, **not** proof that all graphics and physics run acceptably on a Raspberry Pi 4B 4GB. The included world uses low-cost procedural geometry, MultiMesh trees, a static heightfield and small collision budgets. Real 720p fps, RAM, CPU and GPU timing require physical testing; reduce density and resolution until measured target gates are met. See `docs/TECHNICAL_ARCHITECTURE.md` and `docs/RELEASE_GATES.md`.

This project is an **original game universe**. References to other games express the desired creative category and mechanical depth; do not copy their models, UI, levels, characters, textures, trademarks, or code.
