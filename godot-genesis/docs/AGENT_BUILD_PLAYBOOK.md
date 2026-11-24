# WONDERFORGE — AUTONOMOUS GODOT BUILD AGENT PLAYBOOK

**Role:** principal gameplay engineer + technical artist + QA lead. **Goal:** transform the Godot Genesis blockout into a premium cross-platform invention-adventure game. **Execution principle:** implement a playable verified vertical slice, not a hundred inoperable menus. Favor safe incremental commits with objective acceptance evidence. Work from Godot 4.7.x stable GDScript; do not quietly upgrade to unstable engine releases. The Pi4 4GB is the **minimum certification target**; PC Ultra is the primary visual-quality design target. Asset source and save formats are shared.

## Read these artifacts before editing code

1. `docs/MASTER_GAME_DESIGN.md` for gameplay truth, progression, architecture and scope.
2. `docs/ART_BIBLE.md` for non-negotiable visual identity, scene sheets, materials, character and machine art.
3. `docs/PI4_PERFORMANCE.md` for rendering, quality profiles and device evidence.
4. `docs/QA_ACCEPTANCE.md` for exact proof required to call a feature shipped.
5. `README.md` for controls, current running code and explicit unfinished areas.

**Start session protocol:** record `git status`, Godot version/executable path, OS and architecture, render driver, source revision, available CPU/RAM/GPU and project baseline errors. Import and run `scenes/Main.tscn`. Save 3 screenshots (opening, movement, rover) and runtime log. If Godot is unavailable, perform source checks and stop claims of runtime verification. If a screenshot could not be captured by the running engine, do not substitute concept art or screenshots from a web page. Use a second branch named `feature/<ticket>`; never overwrite a teammate's uncommitted work. Commit each verified milestone with source and test evidence.

## Skills and tools

- **Godot** editor/headless/import/export, GDScript debugger, remote scene inspector and profiler. Test both Forward+ desktop and Compatibility Pi-tier renderers before changing default project renderer.
- **Blender** for clean mesh/rig/UV/LOD geometry and glTF 2.0 export. Use authored, licensed source assets only; capture turntables.
- **ComfyUI** for original concept studies and surface moodboards, NOT final meshes without artist review and proof of texture/mesh fidelity.
- **Audio** original or properly licensed, delivered as OGG/WAV/FLAC with rights record.
- **AI coding agent** may write source, tests, docs, scripts, prompts and art conversion tooling; it must never silently install OS packages or execute unknown downloaded scripts, and may not manufacture test outputs.
- **GitHub** CI with headless import/test and export checks on supported runners; Pi smoke/performance must run on a separate actual board before labels change.

## Workstream 00 — establish an engine-qualified baseline

**Inputs:** current `scenes/Main.tscn` and scripts. **Actions:** validate scene parses under the pinned engine. Fix any GDScript class registration or inference errors. Launch for at least five minutes; walk from the workshop to the grove; ray-place three parts, save and reload; enter Rover and drive at least 100m; walk near beacon and confirm progression. Save `artifacts/baseline/<commit>/`: `engine-version.txt`, `parse.log`, `play.log`, `screenshot-opening.png`, `screenshot-builder.png`, `screenshot-rover.png`, `test-matrix.json`. **Acceptance:** zero script parse errors, zero runtime exceptions, all initial interactions physically navigable, save round-trip. **Common failures:** GDScript typed inference mismatch, invalid resource enum, material/shadow feature unsupported on GL Compatibility, top-down camera blocked by a building, overlarge HUD on 720p; these are actual bugs to correct. CI parses only; it does not prove gameplay.

## Workstream 01 — replace the opening scene with final-quality authored modular environment

**Targets:** `scenes/world/FoundersLanding.tscn`, `scenes/props/`, `art/source/founders/`, `art/export/founders/`, `scripts/world/zone_loader.gd`, `data/landmarks/*.tres`. **Deliver 3 LODs** for monumental bridge, arches, workshop roof, aqueduct, waterfall cliff, mature oak and telescope tower, with correct collision and Godot pivots. Draw initial plan with exact coordinates and grid. Use terrain heightmap + procedural roadside dressing, not thousands of manually positioned unique nodes. Include stone/wood/copper trim atlas, surface decals and wind shader variants. Set a stable golden-hour light rig and weather color grade. Create 4 hero screenshots following compositions in `ART_BIBLE.md`. **Acceptance:** aesthetics signed off side-by-side with approved concept sheet; exploration from spawn to workshop remains <=2 minutes; interactive sockets distinguishable at 720p; LODs do not pop disastrously; collision paths accessible. **De-scope:** if key art cannot be finished, keep polished placeholder only for that art, do not replace gameplay with painted picture.

## Workstream 02 — build the modular machine-part catalog

**Files:** `data/parts/catalog.json`, `scripts/assembly/part_definition.gd`, `scripts/assembly/part_registry.gd`, `scripts/assembly/machine_graph.gd`, `scripts/assembly/graph_serializer.gd`, `scripts/assembly/connectors.gd`, `scripts/assembly/snap_solver.gd`, `scenes/parts/*.tscn`. **Minimum first delivery:** 30 visual+functional parts: structural beam (wood/steel), chassis frame, panel, strut, cross brace, axle shaft, bearing, wheel-small, wheel-large, tire-road, tire-offroad, caster, motor-electric, battery, gearbox, clutch, gear-8t, gear-16t, gear-32t, pulley, belt, spring, hydraulic piston, hinge, universal joint, steering rack, switch, lever, sensor-proximity, sensor-speed, lamp, cargo container, chain segment, rotor, float, propeller, solar panel, water turbine, seat, steering wheel, brake, connector, bridge anchor. Deliver named metadata for each including ID, unit scale, mass, material, center of mass, allowed connections, physics collider, tier-visual asset, texture license.

**Implement canonical graph:** stable part ID, connector ID, rigid groups and dynamic joint edges. Serialize numerical units and immutable schema version. Prohibit duplicate UUIDs, dangling edges, impossible connection classes, NaN, infinity, recursive asset paths and oversized graphs before spawning anything. **Acceptance:** machine saved in one operating system loads in another with identical graph and collision topology; 100 undo/redo operations restore original hash; invalid connector produces explanatory UI; no node names embedded as persistent IDs.

## Workstream 03 — create an intuitive spatial construction editor

**Files:** `scenes/ui/BuildHUD.tscn`, `scripts/build/build_controller.gd`, `scripts/build/tool_palette.gd`, `scripts/build/ghost_material.gd`, `scripts/build/command_stack.gd`, `scripts/build/workbench_camera.gd`. Implement enter/exit interpolation, object picking, outline, hover, snapping, intelligent part rotation, joint previews, symmetry/mirror, free placement, group move/duplicate and paint. Add 0.25m grid toggle, 15° rotation preset and precision mode. Device controls: keyboard/mouse, controller radial menu and gamepad bumper rotate. Add visible “WHY NOT?” connector error message. Include a “Quick Build” preset wizard for new players and advanced mode with joint/force visuals. **Acceptance:** novice attaches wheel to socket with <=3 clicks; two-minute benchmark to build a basic car without prior reading; undo restores cost and inventory; controls can be rebound; no impassable modal; game sim pauses while dragging unstable assemblies only when explicitly indicated.

## Workstream 04 — physical sandbox and testing simulator

**Files:** `scripts/physics/assembly_compiler.gd`, `scripts/physics/joint_factory.gd`, `scripts/physics/collision_groups.gd`, `scripts/physics/force_probes.gd`, `scripts/tests/arena_controller.gd`, `scripts/tests/measurement_logger.gd`. Compile part graph into rigid clusters and constraints; support fixed/weld, hinge, slider, rope, spring, rotational drive, damping and steering. Tune contacts, mass, restitution and friction by material with named units. Add deterministic offline test course with start/stop, reset, record and replay; summaries include velocity trace, time, distance, energy use, tire slip and contact violations. Validate conservation sanity: freefall acceleration, inclined plane, torque on a rotating flywheel, unloaded spring oscillation, bridge beam sag in a validated simplified model. Show a disclaimer where physics is approximated. **Acceptance:** machine falls when unsupported, bridge sags under added load, hinge rotates within bounds, wheels can lose traction and have visibly consistent motion, no ghost impulses or persistent creeping after reset. Record max contact/joint count and processing time by tier.

## Workstream 05 — “good driving” before advanced realism

**Files:** `scripts/vehicles/vehicle_controller.gd`, `scripts/vehicles/rig_suspension.gd`, `scripts/vehicles/steering_model.gd`, `scripts/vehicles/vehicle_camera.gd`, `data/vehicle_presets/*.tres`. Replace VehicleBody3D proof of concept with deterministic raycast/rigidbody suspension if it performs better and supports modular wheels. Give vehicle a controllable acceleration, predictable stopping distance, speed-dependent camera and shock-absorber visualization. Include tire friction variations and terrain-dependent rolling resistance; allow safe assists, handbrake, reverse, respawn. Build proper slalom, gradient hill, rocky lane and small jump. **Acceptance:** each control feels responsive at 30 FPS, no uncontrollable wobble, distinct tires change outcomes demonstrably, position reset is safe, a saved rover enters the world with the same appearance and physics on PC and Pi within declared approximation tolerances.

## Workstream 06 — write the game's first playable adventure chapter

**Scenes:** `scenes/missions/OpeningLanding.tscn`, `RepairCart.tscn`, `FirstRoverTrial.tscn`, `BrokenBridge.tscn`, `JournalReview.tscn`. **Quest spec:** cutscene skip, arrival, interaction indicator, first snap, rover test, scenic ride, broken bridge problem, create second revision, measured before/after, restore village route. Implement state machine and alternate solutions (detour is valid). **World consequences:** NPC cart route changes on bridge success; distant settlement smoke/street activity changes; quest steward moves from gate to market. **Acceptance:** fresh player follows flow without external guide, at least 2 valid solutions to bridge obstacle, every step can be resumed from save, objective texts have semantic tags, there is no softlock after leaving a mission zone.

## Workstream 07 — institute a real expedition & campaign map

**Files:** `data/zones/`, `scenes/ui/WorldAtlas.tscn`, `scripts/world/world_state.gd`, `scripts/world/zone_transition.gd`, `scripts/world/quest_director.gd`. Complete six zones in art bible, starting with Founders and Copperwild. Each zone needs 8–12 discoveries, 2 major missions, 4 optional experiments, 1 race/vehicle challenge and 1 visible settlement upgrade. Implement budgeted loaded-zone streaming and distant impostors. Travel options: on foot, physical rover and fast travel unlocked by repairing infrastructure. Preserve state across zone transitions. **Acceptance:** quest state serialization, isolated streaming tests, several-hour travel reliability and Pi memory stability, no long blocking stutter on zone enter.

## Workstream 08 — engineering RPG, local economy & meaningful empire

**Modules:** `scripts/economy/inventory_ledger.gd`, `production_graph.gd`, `settlement_state.gd`, `trade_route.gd`, `scripts/rpg/skill_mastery.gd`. Add eight skill ranks but never gate basic physical problem solving. Use event-driven producers and consumers: water mill -> mechanical power -> bakery; orchard -> food -> market; salvage -> metal -> foundry; stone quarry -> bridge. Route goods using logistics cost, capacity and travel delay; use aggregated calculations for offscreen settlements. Visualize infrastructure state in-world (machines moving, workers arriving, stores filled) and overlay only when requested. Build a first settlement district with at least 6 unique functional structures and 3 community improvement projects. **Acceptance:** each upgrade visibly changes world and simulation, economy never produces items from nothing without labelled fantasy source, save/load consistent over 1000 ticks, Pi only simulates local active actors physically.

## Workstream 09 — racing / challenges / replay

**Tracks:** Valley Sprint, Stonehill Climb, Ember Spiral, Cargo Relay, Water Crossing and Player Designed Circuit. Checkpoint graph prevents cutting course. A ghost recording stores input/position samples plus version and machine hash; if engine version causes nondeterminism, label ghost as approximate rather than deterministic. Race screen shows time, smooth split delta and physical tradeoffs. Build race editor using spline/control-point assets with bank/rise/guard-rail, and protect against self-intersection. **Acceptance:** 3 validated tracks by gameplay alpha, vehicle classes meaningfully differ, trial times stable within tolerance, no online leaderboard, optional shared-device local records.

## Workstream 10 — learning systems, ORBIT and journal

**Modules:** `data/lessons/*.json`, `scripts/education/concept_registry.gd`, `scripts/education/simulation_assumptions.gd`, `scripts/education/journal.gd`, `scripts/ai/orbit_bridge.gd`, `scenes/ui/FieldJournal.tscn`. Build lesson-linked interactions that support predict -> simulate -> revise. Bind event telemetry to transparent measurements, store units and solver version. Journal entries have hypothesis, procedure, observation, comparison, conclusion, model assumptions, screenshot and optional actual-world result; never auto-fill experimental result. Local AI integration should be **optional**; use the existing verified localhost-only ORBIT service via an explicit permissioned protocol with no arbitrary filesystem/shell/tool actions. On Pi AI might pause while 3D world is active, queue one operation and restore frame responsiveness; use fixed small models and a staged benchmark to determine feasibility. Model acts as guide, not game director. **Acceptance:** full playability without AI; replay the lesson with recorded telemetry, no fabricated measurements and per-user privacy intact.

## Workstream 11 — AAA-quality interaction polishing

**Deliverables:** polished player model and complete animation tree, contextual hand/tool IK, tactile part audio, foliage movement, responsive world map, color-safe status icons, help overlay and settings. Add photo mode with collision-free camera and quality selection. Instrument time-to-first-build, navigation error counts and key prompt impressions locally, without telemetry transmission. Achieve stable UI at 720p and 1080p, full controller path, remappable controls, readable quest text at TV distance. **Acceptance:** usability sessions by at least 5 testers with no author coaching, no critical navigation errors, all essential feedback multimodal.

## Workstream 12 — cross-platform export and optimization

**Primary development:** Windows/Linux/macOS desktop, quality Creator/Ultra. **Minimum:** Pi 4B 4GB quality Explorer. Use separate `export_presets.cfg` with real Godot-export template matches, not unverified placeholder export bundles. Windows needs signed or unsigned executable with SmartScreen disclosure; macOS requires code-signing/notarization before claiming frictionless distribution; Linux includes tested dependencies and glibc baseline. ARM64 Pi may use compatible Godot export templates or a custom export build; verify rather than guess. Run Explorer/Creator/Ultra in CI where possible, then actual board in lab. See `PI4_PERFORMANCE.md` for budget proposals and model tiers.

## Workstream 13 — publish and maintain

Create GitHub `release/*` branch only when tests pass; label `v0.2-alpha`, `v0.3-beta`, etc., not “final” while missing mechanics. Deliver asset provenance, credits, performance tables, user instructions, developer quickstart, schema migration and reversal guides. Include screenshots captured by actual Godot binary with renderer metadata. Do not put copyrighted third-party textures or model weights into Git unless rights and distribution terms are explicit. Always preserve user projects across updates.

---

## Coding agent execution prompts (copy individually)

### Prompt A — verify the baseline

> Open the current WonderForge Godot repository. Read all docs listed in `AGENT_BUILD_PLAYBOOK.md`. Determine the exact installed Godot stable version and runnable export templates. Import scenes headlessly, fix any parse or runtime failures without changing intended behavior. Run the scene interactively and capture a verified screenshot. Write `artifacts/baseline/report.md` with commands, logs, limitations and next blocking issues. Run checks, commit, and continue only when every baseline acceptance criterion is met. Never claim Pi verification from desktop tests.

### Prompt B — finish the first real machine editor

> Implement Workstreams 02 and 03 in small commits. Make `MachineGraph` the persistent canonical model, with stable IDs, typed connectors and tested serialization. Build a production-ready spatial snap editor including ghost previews, rotation, 100-step undo/redo and controller menu. Keep existing saves migratable. Add at least 30 manually inspected editable part assets with provenance. Demonstrate a user snapping a wheel to a chassis and solving an invalid connector error. Capture frame and input traces; use the QA matrix before marking complete.

### Prompt C — add fully functional engineering physics

> Implement Workstreams 04 and 05. Use documented physics engine APIs, test known reference problems, and expose measurement assumptions. Make a rover assemble from `MachineGraph`, drive a slalom and hill, show tire slip, and save the assembly. Ensure physics collision and visible assembly use identical transforms. Benchmark at Explorer, Creator and Ultra tier. Do not replace physics with animation or claim engineering accuracy beyond validated constraints.

### Prompt D — build the cinematic hero region

> Following the Art Bible scene descriptions and palette, replace the blockout Founders' Valley with polished original PBR art, correct pivots and LODs. Source or create assets with reproducible licenses; preserve exact collision, player movement and part snap transforms. Capture 16:9 in-engine screenshots at consistent camera locations for PC and Pi quality levels, and compare against approved concept images. Use a deliberately excellent, authored composition rather than a generic asset dump.

### Prompt E — build a shippable end-to-end chapter

> Implement the 15-minute playable opening sequence from the Master Game Design: workshop intro, connect a vehicle, run a test, reach a broken bridge, revise a machine, record evidence, and restore settlement traffic. Both alternate solutions work. No hard-coded cutscene is mandatory. Tie state to schema-versioned saves with recovery. Conduct five-person usability testing and document observed confusion; iterate until novice success criteria pass.

### Prompt F — cross-platform release verification

> Prepare separate Explorer/Creator/Ultra builds from the same gameplay sources. Test on Windows/Linux/macOS where supported; run an actual Pi 4B 4GB with Compatibility renderer and two Linux accounts. Capture sustained render/physics CPU, memory and thermal readings, save/load integrity and graphics screenshots. Record exact hardware/software versions. If any Pi gate fails, simplify cosmetic LOD, optimize materials and cap local assemblies; do not remove basic workshop gameplay. Declare only verified platforms supported.

## Quality-of-implementation template for EVERY ticket

- **Ticket and player promise:** exactly what user can now do that they could not do before.
- **Files touched:** scenes, scripts, data, tests, assets; include authored asset licenses.
- **Functional acceptance:** objective inputs, expected outcomes, failure paths, persistence and unit constraints.
- **Aesthetic acceptance:** reference render, palette, material detail, camera framing, feedback animation, text readability.
- **Performance:** machines/parts/instances under test, renderer, resolution, p50/p95 frame time and memory snapshots.
- **Compatibility:** Windows Creator, Linux Creator, Windows Ultra, Pi Explorer; unsupported states explicit.
- **Security/privacy:** profile access, user input validation, local-only network, save serialization, AI boundaries.
- **Evidence:** reproducible commands, logs, in-engine screenshots/video, test results; explicitly mark missing evidence.
- **Rollback:** how to restore previously saved worlds, config and release assets.

Any agent claiming a milestone complete without this report has not fulfilled the contract.
