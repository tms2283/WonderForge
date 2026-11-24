# WONDERFORGE: GENESIS
## A real 3D game project — not a browser dashboard

**Godot 4.7.x | MIT source code | Windows / Linux / macOS targets, Pi 4B 4GB minimum | Developer vertical slice v0.2**

This project is the **new game-engine foundation** for WonderForge. It is deliberately not presented as finished art or finished gameplay. The shipped Godot scene provides the systems and navigable map; the ambitious end-to-end professional game design, detailed visual specifications, engineering simulations, RPG mechanics, empire progression, physics construction, art production, and AI-agent implementation contracts live in `docs/`.

### How to run

1. Download stable Godot 4.7.2 from the [official download page](https://godotengine.org/download/). On desktop, use the standard full editor (not the .NET edition); the code is pure GDScript. Windows, Linux and macOS are **development targets**; the Pi 4B is the **minimum certification target**, not the graphics-quality ceiling.
2. Extract this project archive.
3. Open Godot → **Import** → select `project.godot` inside this folder → **Import & Edit**.
4. Press **F6** with `scenes/Main.tscn` selected or **F5** to run the project.
5. Read the start screen's controls; press **F1** to hide it.
6. For an explicit visual tier launch with `godot --path . -- --quality=explorer`, `--quality=creator` or `--quality=ultra`. See `launchers/`. Desktop Ultra can request `--rendering-method forward_plus` if your GPU supports it; this is a renderer startup setting, not automatic magic graphics.
7. Run `python3 tools/validate_project.py` and `python3 -m unittest discover -s tests -v` for **static source/data** checks. Godot parsing/gameplay is a distinct validation gate.

### Cross-platform product vision and baseline

**The same game with three visual modes:** Explorer for Pi 4B 4GB, Creator for standard PCs/laptops, Ultra for gaming PCs. The playable source keeps a single quest and save schema across profiles; profile switching changes world tessellation, tree instances, camera far range, shadow use, fog and frame cap. Modern PC graphics in the production art bible require **high-quality 3D models, materials, animation and authored lighting not included in this source blockout**. The Pi is minimum support rather than a limit on game design.

The project also contains **42 detailed, validated static part specifications and 24 authored quest briefs**, explicitly marked **production design data, not implemented in gameplay**. Complete detailed implementation contracts are under `docs/`, including the 15-minute first chapter, multi-biome world art, construction physics, vehicle racing, RPG and empire economy systems, AI and acceptance tests.

### What exists in the initial vertical-slice source

- Third-person CharacterBody3D adventurer, camera orbit, sprint, jump.
- Procedural 3D valley with terrain collision, five quest guilds, roads, workshop, observatory, foundry, engineering arena, groves, vegetation using MultiMesh, skies and cloud islands.
- Six-material build mode with perspective ray placement, rotation, part costs, inventory, world-save/load and basic objective integration.
- Driveable four-wheeled prototype rover using Godot VehicleBody3D, with enter/exit interaction.
- Four-stage tutorial quest and guild discovery rewards, HUD, compass-like coordinates and session saves.
- No external model, texture, font, or paid asset dependency. Everything visible is authored as editable engine geometry **and is not the final art**. There is currently no Godot editor/runtime binary in the authoring environment, so this source snapshot has passed static checks but not an engine-level playtest. The GitHub CI workflow is intended to run headless Godot import after publication.

### What is **not yet done** (read this before promising a finished game)

- Production-quality art, smooth animation, interiors, cinematic sound, materials, shaders, atmospheric effects and polished UX. **The visuals are blockout/previsualization only.**
- Real snap graph, hinge physics, dynamic joint assembly, stress testing, aerodynamic simulation, structural failure, drag-and-drop machine design, full driving feel, combat/RPG progression, mission campaign, multiplayer, world streaming, procedural economy or intelligent NPCs. Each has explicit acceptance criteria in the design specification.
- Full game build or measured performance on Raspberry Pi 4B 4 GB. Desktop performance is not proof of Raspberry Pi compatibility.

### Code paths

| Directory | Purpose |
| --- | --- |
| `scenes/Main.tscn` | Godot boot scene |
| `scripts/game.gd` | Game state, mission stages, input, save/load |
| `scripts/world_gen.gd` | Procedural landscape and landmarks |
| `scripts/player.gd` | Third-person CharacterBody3D movement |
| `scripts/camera_rig.gd` | Orbiting playable camera |
| `scripts/world_builder.gd` | Local construction previsualization |
| `scripts/vehicle.gd` | Four-wheel driveable testbed |
| `scripts/hud.gd` | Responsive-ish in-engine HUD and controls |
| `WONDERFORGE-ULTIMATE-AGENT-SPEC.md` | **Combined 13k+ word agent-ready production and art specification** |
| `docs/MASTER_GAME_DESIGN.md` | Gameplay, progression, simulation, quests, economy, architecture |
| `docs/ART_BIBLE.md` | Art direction and scene-by-scene visual specifications |
| `docs/AGENT_BUILD_PLAYBOOK.md` | Step-by-step agent tasks, files, acceptance gates |
| `docs/PI4_PERFORMANCE.md` | Profiling and Pi-specific graphics plan |
| `docs/QA_ACCEPTANCE.md` | Manual and automated testing matrix |

### Source and quality verification

The Python static validator checks scene links, script preloads, the 42-part metadata catalog, 24 quest specs and the three quality modes. Four Python contract tests pass, but **no Godot runtime has been launched by this authoring environment**. Every imported scene, vehicle physics interaction and actual platform support must be tested in Godot. See `docs/QA_ACCEPTANCE.md` for manual runtime acceptance and the GitHub Actions workflow in the parent repository for a true engine-parser test.

### Build philosophy

**Premium-world look first in art direction, verified engineering first in release claims.** Build a desktop-quality master art set with tiered texture/mesh/LOD assets. Generate Pi-optimized variants from the same asset lineage. This avoids turning the primary art vision into an ugly low-end UI. Treat educational calculations as validated models with transparent assumptions and real-world experiments rather than pretending visual tricks are engineering simulations.

### Licensing note

Code produced for this project may be shared under the MIT license in `LICENSE`. All final art and music require original creation or valid, documented third-party licenses. The games named as inspirations are **reference points for game mechanics and quality**, not assets or designs to copy.
