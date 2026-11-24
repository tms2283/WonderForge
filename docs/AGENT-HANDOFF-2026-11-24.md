# WonderForge 2026-11-24 local agent handoff — execution-first

**Repository:** https://github.com/tms2283/WonderForge  
**Native game:** Godot 4.7.2 project in `godot-genesis/`; Raspberry Pi 4B 4GB is the minimum target, not the PC graphics ceiling.  
**Complementary OS:** Offline-first Raspberry Pi OS installable portal, learning tools, Luanti world and optional local ORBIT in repository root.  

This handoff is a **verified-alpha-to-production plan**, not a statement that the full game/OS is finished.

## Do first, before modifying code

1. Clone latest `main`; inspect `AGENTS.md`, `godot-genesis/AGENTS.md`, `godot-genesis/WONDERFORGE-ULTIMATE-AGENT-SPEC.md`, `godot-genesis/docs/IMPLEMENTATION-STATUS-v0.3.md`, `godot-genesis/docs/LOCAL-AGENT-HANDOFF-v0.3.md`, `godot-genesis/docs/ART_BIBLE.md`, `godot-genesis/docs/QA_ACCEPTANCE.md`, `godot-genesis/docs/SAVE-RECOVERY-v0.4.md`, `godot-genesis/docs/ASSEMBLY-SCAN-v0.4.md`.
2. Install the repo-pinned **Godot 4.7.2** on the desktop development machine; Python 3.11+ and Node.js are needed for tests. On Windows, use the correct executable and a Bash-capable environment for shell checks.
3. Execute this **non-destructive** local preflight from the repository root:

```bash
python3 tools/agent_preflight.py --full --strict --report .agent-reports/preflight.json
```

The tool marks unavailable hardware **NOT_RUN** and captures actual engine test output. Keep generated reports out of git; do not upload child/user private data.

4. Launch the actual Godot game in a **GUI**, play its first 15 minutes and capture reproducible video/screenshots from the running engine. Record behavior at 1280×720 and 1920×1080, with keyboard/mouse and gamepad. Headless checks cannot prove the product looks or feels finished. File concrete defects before redesigning its UI.

## Truthful current implementation

- **Code exists:** Godot 3D valley, roaming player, original WIP workshop/observatory assets, six-component configured ForgeRover, six-gate driving circuit, recorded experiment journal, six-placeable-part collidable builder, save/load, three graphics profiles, scripted ORBIT plus opt-in localhost model (model itself not bundled).
- **New verified code:** staged, schema-validated saves and last-good-backup recovery; geometry-based adjacency graph, Build-mode **I** inspection, and a measurable three-connected-part/7m introductory build challenge.
- **Specified but not implemented as finished gameplay:** 42-part runtime construction catalog, physical socket/hinge/motor graph, production art, 24 complete quest arcs, full story, high-fidelity vehicle dynamics, settlement/economy, professionally finished sound.
- **Not hardware certified:** Raspberry Pi native 3D FPS/temperature/memory, Pi power-loss storage recovery, child account login/recovery in the actual family setup, local Ollama throughput or comprehensive content filtering.

## Mandatory workstreams, in priority order

**P0 — GUI and player acceptance.** Real Windows/Linux guided/uncoached sessions. Fix confusing first interaction, focus, collision, camera, controller navigation, UI readability, accessibility, saves and trial failures. Acceptance: new player finds workshop, changes one rover part, predicts a result, completes six gates, compares two runs, builds a connected structure, saves/reloads, and uses offline ORBIT without external setup. Attach actual video and hardware/input metadata to the PR.

**P1 — art-directed opening environment.** Deliver one outstanding 60m Founders' Valley vista and traversable workshop/waterworks composition, original Blender masters, proper PBR materials, LOD0/1/2 and consistent Explorer/Creator/Ultra variants. Capture true engine imagery; no copyright-infringing meshes, unlicensed music or fake game captures.

**P2 — real LEGO-style mechanics.** Extend `scripts/world_builder.gd` and its safe `GenesisAssemblyScan` geometry fallback. Hook the 42-part JSON catalog into selectable physical runtime parts; give each socket a stable ID, orientation and compatibility class. Preview, snap, collide, serialize, undo/redo and maintain connected-component graphs. Implement constrained joints, actuators and stress/physics tests for a *working* machine. A connected surface is not a weld, and no design should be called mechanically viable until engine tests prove it. Preserve v1 save/schema migration compatibility.

**P3 — vehicle engineering truth.** Validate actual wheel/motor/gear/battery handling and recoverable traction. Create controlled A/B automated trials with an explicit seed/initial state, instrumented times, speeds, battery, slip/contact and repeatability. Add constrained test cases for rollovers and disconnected controls. Distinguish gameplay approximations from real engineering certification.

**P4 — one fully authored world-changing 15-minute quest.** Player discovers a failed crossing, assembles a legitimate structure, tests and repairs it, then visibly unlocks a new region/NPC interaction, with clear failure recovery and evidence recorded in the journal. Quest rewards must be triggered by real game events, not generic button clicking or scattered props. Finish this before scaling the entire 24-quest catalog.

**P5 — shared Pi OS + family boundaries.** Recheck the account model, per-user private homes, opt-in shared folder, localhost launch/session isolation, offline field guide, AI sandbox and explicit adult approvals. Do not run `sudo ... --apply` on a development host or tamper with the physical family's active media. Read the root Pi installation/recovery docs. ORBIT remains optional, untrusted and not a child-safety filter.

**P6 — native platform quality.** Test actual Pi 4B/4GB Compatibility renderer (ARM64, not x64), PC graphics tiers, controller disconnect, offline mode, save corruption, low disk, app kill mid-write and power interruption on sacrificial media. Log p50/p95 frame time, memory pressure, temperature, throttling and OS/Godot version. Package tested exports, integrity receipts, dependencies, original asset license inventory and rollback instructions.

## Definition of done, every PR

Each PR must include: precise feature state (IMPLEMENTED/SPECIFICATION/NOT RUN), changed source files, reproducible test commands **and actual output**, true GUI screenshot/video for visual changes, quality tier comparison, machine and Godot version, latency/performance metrics when claimed, source asset provenance, save migration analysis, rollback path and known risks. Keep green Python, Godot import and actual runtime/system/save/assembly contracts. Never misrepresent a headless test as Pi certification.

**Do not rewrite the entire spec before testing the real game.** The first coding-agent deliverable is P0 human-playtested actual executable improvements.
