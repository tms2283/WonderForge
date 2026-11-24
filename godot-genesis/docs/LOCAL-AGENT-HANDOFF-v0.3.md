# WonderForge: Genesis — exact local coding-agent handoff

**Your task is to turn the existing actual Godot project into a polished cross-platform engineering-adventure game; do not generate a new mockup or web app.** The minimum target remains Raspberry Pi 4B with 4GB, while desktop gaming PCs define the premium art ceiling. The project currently has a playable engineering lab, a six-gate trial and a few original WIP models. They are real engine systems, not finished art.

## Mandatory repository intake

1. Read `AGENTS.md`, `WONDERFORGE-ULTIMATE-AGENT-SPEC.md`, `docs/ART_BIBLE.md`, `docs/MASTER_GAME_DESIGN.md`, `docs/QA_ACCEPTANCE.md`, and `docs/IMPLEMENTATION-STATUS-v0.3.md` in full. The combined agent spec includes the detailed world, quest, UI, physics, art, audio, economy and platform contracts.
2. Inspect **actual** script classes: `scripts/game.gd` (orchestrator and saves), `scripts/rover_blueprint.gd` (deterministic physical configuration), `scripts/vehicle.gd` (`VehicleBody3D` adapter), `scripts/rover_garage.gd` (selectable UI), `scripts/trial_course.gd` (six checkpoint route), `scripts/engineering_journal.gd` (evidence), `scripts/world_builder.gd` (collision-backed construction), `scripts/world_gen.gd` (scene), `scripts/quality_profiles.gd` (visual budgets), `scripts/hud.gd` (presentation).
3. Run all static checks and actual Godot import, 30-frame runtime, and engine-system contract test. Fix failures before writing content. Work from feature branches and publish small, independently testable changes.
4. Inspect `assets/models/asset_manifest.json`; its original GLB sources are generated from `art_pipeline/generate_original_models.py`. No model in this first set qualifies as approved release art. Replace selectively while retaining human-scale physical plausibility, collision and LOD lineage.

## Work packages — prioritized to maximize playable quality

### Gate P0 — prove the engineering loop works with user input

Record a real **GUI** playthrough on Windows/Linux using Godot 4.7.2, not a headless render. Verify opening the garage, selecting each option, prediction entry, driving the six gates, journal saving and a deliberate experiment with only one variable changed. Confirm controls at 720p and 1080p, readable button focus and mouse/gamepad interaction; capture actual screenshots and a short 60-second gameplay video. Add reproducible automated tests for save compatibility, checkpoint order, wheel parameter changes and corrupt journal resilience. Resolve any stability and collision bugs. Reject model hallucinations as test evidence.

### Gate P1 — visual hero-scene production

Turn Founders' Valley into a coherent AA-quality scene with physical stone, copper, wood, glass and machinery. Start with one 60m vista framing the workshop, waterworks and distant sky citadel; obey the Art Bible's human-scale layout. Replace the four WIP GLB previews with source-controlled Blender or equivalent master files and final licensed textures. Deliver roughness/normal/ambient occlusion maps, collision proxies, full material variants, LOD0/LOD1/LOD2, consistent names and editorial art review. Preserve an Explorer profile that reduces geometry, lights and materials while keeping architectural silhouette and legibility.

### Gate P2 — snap graph and machine bodies

`world_builder.gd` currently places static pieces with colliders and undo/redo. Replace the basic placement with runtime part definitions from `part_catalog.json`, socket visualization, orientation alignment, compatibility checks, collision clearance, connector IDs, undo/redo serialization, and connected-component graph analysis. Add fixed joints, hinges, motors, bearings, springs, ropes and their **working constraints**. Each functional assembly must have a measured simulation budget and stable collision grouping, and fail gracefully rather than exploding when joints are disconnected. User can see *why* a connection is invalid.

### Gate P3 — vehicle handling and engineering truth

Keep `GenesisRoverBlueprint` and the independent trial telemetry contract. Implement a deterministic-enough custom raycast suspension/traction solver or a carefully validated equivalent instead of leaning on Godot's limited VehicleBody3D. Demonstrate variation of center-of-mass, weight, torque, grip, wheel radius and steering in repeatable controlled tests. Add force arrows, torque-curve visualization, replays and a brake/traction trainer. A performance change needs actual measured in-engine evidence, not just labels. Require finite velocities, recoverable rollovers, checkpoint order protection and a benchmark set of example builds.

### Gate P4 — first fully authored fifteen-minute adventure

Build the art-directed opening, playable protagonist with real animation, environmental characters, integrated tutorial, first machine assembly, test course, bridge repair and real world consequence. The first quest must teach through *physical manipulation*, not static reading. Attach rewards to verified game events, not simply placing three unrelated parts. Art, quest sequencing, sound and UX must be completed together. Capture a first-time player usability test including failed attempts and time to first construction success.

### Gate P5 — economy, racing, RPG and AI

Once P0–P4 are evidence-based and stable, build the settlement resource loop, building growth, timed racing, vehicle challenges, dynamic NPC problems and further realm unlocks from the 24 production quest briefs. Integrate local ORBIT as an OPTIONAL guidance layer that works offline, with transparent source attribution and strict non-executing tool scopes. Never permit model-generated shell commands, automatic installs, private file reads or game-state changes without explicit approval. Scripted fallback remains available when no model is installed or hardware cannot run one.

### Gate P6 — platform release

Export for Windows and Linux and measure real 3D frame times. Run an Explorer build on a Raspberry Pi 4B 4GB using Compatibility rendering, reduced mesh/texture/shader budgets, no mandatory AI model, and deterministic physics budget. Keep the save schema, hardware-independent quests and assembly semantics consistent with desktop. Test recovery from corrupt saves, app kill mid-write, drive mounts, low RAM, no network and controller disconnects. Do not certify Pi until actual Pi observations exist.

## Engineering acceptance contract for each PR

Supply source diffs; actual game screenshot or video; current Godot version and platform; test commands with complete output; performance capture where relevant; feature-state map (`IMPLEMENTED`, `SPECIFICATION`, `NOT RUN`); artifact/license inventory; and a rollback path. A green headless CI pass is mandatory but not sufficient to claim quality. No fabricated performance numbers or screenshots.

## Ready-to-run agent launch prompt

> Work in `godot-genesis/` on the existing WonderForge repository. Treat `WONDERFORGE-ULTIMATE-AGENT-SPEC.md` as the product contract and `docs/IMPLEMENTATION-STATUS-v0.3.md` as the current verified boundary. Perform Work Package P0 end-to-end, then proceed to P1–P6 only when each acceptance gate is met. Build a playable professional Godot game, not another UI prototype. Preserve stable save schema and quality invariants. Execute real Godot tests for every code change and capture evidence from the running game. Mark any unavailable hardware/art/manual test `NOT RUN` and never conceal failures. Commit working increments with reproducible tests; prioritize the actual user's first fifteen minutes over breadth.

## Desktop export handoff

`export_presets.cfg` includes portable Windows x86-64 and Linux x86-64 configurations. The GitHub workflow `.github/workflows/genesis-export.yml` downloads **official matching Godot 4.7.2 export templates**, imports the project, runs the actual engine contract, exports binary packages and attempts to run the Linux release headlessly before uploading separate application ZIPs. The exported executables are suitable only as prototype builds until a user playtests their graphics, behavior and input on both platforms. The Pi 4B requires a separate ARM64 Compatibility export and hardware validation; desktop export does not prove it.
