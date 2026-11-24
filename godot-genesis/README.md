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
- No external paid model, font, or texture-pack dependency. The source includes original in-progress glTF workshop and observatory geometry in Explorer and desktop variants. **None of this is the final art.** GitHub Actions has successfully imported and run the Godot 4.7.2 scene and checked the actual rover, garage, construction, course and journal system contracts; a human visual playtest remains essential.

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

The Python static validator checks scene links, script preloads, the 42-part metadata catalog, 24 quest specs, four deterministic model assets and three quality modes. **Five Python contract tests pass.** GitHub Actions runs actual Godot 4.7.2 import, headless scene execution, an independent engine-level system-contract test, desktop exports and a headless smoke check of the exported Linux executable. These are real automated engine checks, **not GUI usability, artistic-quality or Pi-hardware verification**. See `docs/RELEASE-EVIDENCE-v0.3.md` and `docs/QA_ACCEPTANCE.md`.

### Build philosophy

**Premium-world look first in art direction, verified engineering first in release claims.** Build a desktop-quality master art set with tiered texture/mesh/LOD assets. Generate Pi-optimized variants from the same asset lineage. This avoids turning the primary art vision into an ugly low-end UI. Treat educational calculations as validated models with transparent assumptions and real-world experiments rather than pretending visual tricks are engineering simulations.

### Licensing note

Code produced for this project may be shared under the MIT license in `LICENSE`. All final art and music require original creation or valid, documented third-party licenses. The games named as inspirations are **reference points for game mechanics and quality**, not assets or designs to copy.

## v0.3 — substantive engineering-gameplay release

The new work focuses on a **playable build → hypothesize → drive → measure → compare** loop, instead of more dashboard widgets. Press **G** in the Godot adventure to open a six-component rover engineering garage, tune actual Godot wheel and body properties, write a prediction, and run a six-checkpoint driving trial. The game records actual in-engine trial telemetry to a local journal. Press **J** to compare the two most recent experiments. The terrain builder now creates collision-backed structures and supports **Z undo / X redo**. Four original authored 3D GLBs replace the generic workshop/observatory blockouts, with separate Explorer and desktop mesh variants; they remain WIP assets, not final art.

See [Implementation & test status](docs/IMPLEMENTATION-STATUS-v0.3.md), [Detailed local-agent handoff](docs/LOCAL-AGENT-HANDOFF-v0.3.md), [GLB generator](art_pipeline/generate_original_models.py), and [Godot runtime system test](tests/runtime_smoke.gd). Hardware frame rates, production asset quality and advanced Besiege-grade mechanical simulation are not yet certified.

### Controls added in this development increment

- **F2**: in-engine ORBIT Mentor, scripted offline by default; optional explicitly enabled local-only Ollama mode.
- **Standard gamepad**: left stick move/drive, right stick orbit, A jump/confirm/place, B brake/build toggle, X interact, Y garage, shoulders change construction part, START guide and BACK trial comparison. Keyboard/mouse equivalents continue to work.
- **Player model**: a more legible, animated original procedural silhouette is in the scene, but is not release-quality rigged character art.

### Portable PC builds (experimental CI)

The repository contains Godot export presets and `.github/workflows/genesis-export.yml`. A [completed successful export run](https://github.com/tms2283/WonderForge/actions/runs/45330259622) produced standalone **Windows x86-64 and Linux x86-64** preview artifacts with matching official Godot 4.7.2 templates and successfully ran the exported Linux executable headlessly. Open that run, scroll to **Artifacts**, download your operating-system package, extract it and keep the `.pck` beside the executable. Subsequent game-source changes automatically trigger the export workflow. Manual Windows GUI and Pi ARM64 testing remain separate release gates; see `docs/RELEASE-EVIDENCE-v0.3.md`.
