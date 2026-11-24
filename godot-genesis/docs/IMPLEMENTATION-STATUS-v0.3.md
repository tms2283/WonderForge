# WonderForge: Genesis — v0.3 implementation and test evidence

Updated: 2026-11-23. Source of truth is the `godot-genesis/` directory, not the historical browser UI in the repository root.

## Real implementation (not merely a plan)

- Original Godot 4.7-compatible 3D Founders' Valley, third-person controls, exploration, five guild beacons and construction.
- **Rover engineering garage:** press `G` for a focusable in-engine UI. The chassis, motor, tire, suspension, gearbox and battery selections are validated by `GenesisRoverBlueprint`, use consistent units and directly update four actual `VehicleWheel3D` nodes and a `VehicleBody3D`'s mass, torque, steering and energy consumption. User hypothesis input is included.
- **Six-gate proving grounds:** choosing *Run the Proving Grounds* actually teleports the configured Rover to the arena track, starts a time trial, enforces checkpoint order, samples the game's current telemetry, and records results in a private JSON journal.
- **Experiment comparison:** `J` reports differences between the two most recent runs and identifies how many design variables changed. Inferences are clearly labeled as game-model observations, **not real vehicle physics measurements**.
- **Collision-backed construction:** parts can be built and stacked, will collide with players and vehicles, and can be undone/redone with Z/X while preserving inventory costs. This is not yet a constraint-linked Besiege-style assembly solver.
- **Original preview geometry:** 4 deterministic geometry models (Founders' Workshop and Astral Observatory each in Explorer and desktop-tier variants) are built via `art_pipeline/generate_original_models.py` and included as `.glb` assets with SHA-256 verification and explicit triangle budgets.
- Single `genesis_save_v1.json` saves compatible old player/world/build data and extends it with a sanitized rover blueprint. The trial journal is a separate private local file; the same save schema works across visual quality tiers.
- Quality selection `-- --quality=explorer|creator|ultra`; graphics affect instance counts, shadows and render distance, not equipment stats, checkpoints, journal or quests.

## Test requirements

Run from the Godot project directory:

```bash
python3 -m unittest discover -s tests -v
python3 tools/validate_project.py
# Native Godot 4.7.2 installed:
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 30 -- --quality=explorer
godot --headless --path . --script res://tests/runtime_smoke.gd
```

The GitHub workflow `.github/workflows/godot-genesis.yml` executes the same Godot import, 30-frame runtime smoke and system-contract test on GitHub-hosted Linux. A headless success is **not** a graphical usability test or a Raspberry Pi benchmark.

## User test path (desktop)

1. Launch Godot main scene and press F1 to dismiss the guide.
2. Walk to the large, originally modeled workshop beside the spawn. Open engineering with `G`.
3. Set motor to `torque` and gearbox to `climb`. Write a prediction (e.g., "better climbing, faster battery depletion"). Choose **Run the Proving Grounds**.
4. Drive `WASD`; steer through every visible arch in numbered order, use SPACE to brake, R to reset and E to exit.
5. When finished, press J to read trial time, speed, charge and the comparison note. Repeat with `economy` motor only, keeping the other five settings unchanged.
6. Press B and choose parts 1–6. Aim at ground or existing parts, click to place, Z to undo, X to redo. Walk or drive against a built wall to check that it has a collider.
7. Press F5, exit, restart, press F9. Confirm the rover blueprint, built construction and previous journal records are retained.
8. Launch Explorer, Creator and Ultra and ensure results and save data are the same even where graphics differ.

## Honest limitations

- The assembled Rover is **not yet modular joint-physics assembly**. It is one rigid body whose mass and wheel physics are configured by choices. No accurate torque curve, drivetrain mesh, wheel slip ratio or tire/soil material dynamics are claimed. Godot documentation cautions that built-in VehicleBody3D is not a fully realistic vehicle simulator.
- Construction has static colliders and valid placement checks but does not yet simulate mass distribution or failure of connected machines. `data/part_catalog.json` contains 42 production specifications; only six simple world-builder materials are in-game. This distinction is intentional.
- The original `.glb` assets are original hand-procedural geometry with relatively realistic scale and material differentiation; **final high-detail environment art, character animation, UI polish, VFX, lighting and sound** remain art-team work. The asset manifest calls these work-in-progress.
- Five current guild beacons, early adventure and garage trial are a vertical slice. The authored 24 production quest briefs and empire/multiplayer/AI agent proposals are not implemented as complete gameplay.
- Pi 4B 4GB is the minimum **target**. No frame rate, memory budget, or thermal behavior has been established on a real Pi 4B.
- No model weights or generative AI are embedded in this Godot build. The separate browser-based ORBIT Ollama integration must be adapted to a properly permissioned Godot system, not copied into unsandboxed arbitrary agent actions.

## Production art rule

Professional PC graphics use high-quality authored meshes, PBR materials, decals, weathering, animation, audio and tuned lights with original style and valid asset licenses. Explorer uses generated LOD from the **same source lineage**, not a separate ugly game. Capture Godot screenshots of the actual gameplay and require design review before marking art complete.
