# WonderForge Genesis — verification and release gates

**This document is a rigorous contract, not a retrospective claim that the game has already passed these checks.** Execute every test against an actual Godot binary. When a criterion is untested, record **NOT RUN**, never PASS. For Pi hardware, collect real-device logs, not PC estimates.

## 1. Baseline testing matrix

| Code | Action | Expected result | Failure definition |
|---|---|---|---|
| B01 | Import `project.godot` with Godot 4.7.x stable | No missing resources or class failures | Any script parser/import error |
| B02 | Run `scenes/Main.tscn` 5 minutes | Valley visible, camera follows player, no exceptions | Crash, black screen, missing input |
| B03 | WASD, Shift, Space, orbit RMB+mouse | Responsive relative to camera; jump lands on world | Stuck controls, camera clipping, falling through |
| B04 | Press F1 then interact | Help screen hides without gameplay freeze | Tooltip/UI blocks intended controls |
| B05 | Approach workshop beacon, press E | Discovery reward and quest progress | No response, repeated reward exploit |
| B06 | Press B, select parts 1–6, press Q | Ghost part/rotation changes, no jitter | Wrong part/axis, invisible ghost |
| B07 | Place three parts, check resource cost | Cost exactly once and progress milestone | Inventory becomes negative or duplicates |
| B08 | Press E near rover, drive, brake, exit | Can enter, drive and safely leave | Player stuck, rover explosive force |
| B09 | F5 save, restart F9 load | Same progress, parts, player coordinate | Invalid data or silent overwrite |
| B10 | Corrupt save JSON, attempt F9 | Helpful error and no destructive state change | Crash, partial import, arbitrary file access |
| B11 | Launch with `--quality=explorer` | Explorer visual budget selected | Different quest/save results |
| B12 | Launch with `--quality=ultra` on capable PC | Ultra budget selected | Missing scenes, crash due to unsupported renderer |
| B13 | Resize window 1280x720 ↔ 1920x1080 | UI usable; no obscured critical inputs | HUD offscreen, unreadable text |
| B14 | Complete Act I | Clear chapter completion message, next options | Unclear goals, softlock |

**The current project does not yet implement all production flows.** Basic interaction code exists; Godot runtime confirmation is pending in this environment. Baseline test entries must be filled by a person or local coding agent who actually launches the engine.

## 2. Machine graph / construction system contracts

- Snapshot serializer: round-trip 10,000 randomly generated valid graphs up to tier part cap and compare stable graph ID, part transforms, connection topology and material settings.
- Reject: missing schema, malformed UUID, duplicate part ID, NaN/Infinity, oversized numbers, unknown connector class, references to unapproved external file paths, cyclic ownership pointers, count > limit, resource underflow.
- Snap geometry: socket A coincides with socket B within 1mm after transform; inconsistent orientation triggers user-facing explanation.
- Undo: 100-part placement/rotation/delete sequence, undo all, redo all, verify inventory and serialized hash identical.
- Physics: test supported vs unsupported beam, hinge limits, compound mass center, wheel slip changing with friction, collision contact and fixed timestep sensitivity.
- Performance: record max joints, contact pairs, solver milliseconds and average FPS under three tiers; fail Pi profile on actual frame-time evidence, not presumed ability.

## 3. World/quest/economy contracts

- Fresh save start, follow complete 15-minute chapter without external knowledge; five distinct novice users and median time to first working machine recorded.
- Complete bridge via physical span; then complete same quest through alternate service road; both should unlock narrative without contradictory flags.
- Leave zone in middle of mission; return via fast travel; resume without re-awarding resources.
- Settlement production ledger: no negative stock, mass/unit conservation where relevant; simulate 1000 offscreen ticks then reenter visually updated settlement.
- Save game from Windows Creator profile, load on Linux Explorer and PC Ultra; same quest/machine hash and economy state, allowing only documented numerical physics approximations.
- Damaged file: restore most recent valid backup; no silent overwrite of a newer valid save.

## 4. Educational integrity and safety

- Every numerical model has reference values and explicit units, assumptions and solver version. Reject outputs with nonsensical physical domain (negative mass, infinity, friction coefficient outside configured range).
- The game never calls a simulation result a guaranteed real-world outcome. Children must still perform observation and interpretation; ORBIT cannot write fictional observations into journal.
- An incorrect prediction yields a useful explanatory comparison; avoid generic "wrong" / grade-shame messages.
- Adult guidance appears with real tools/electricity/heat projects; no unsafe live-mains experiments in the built-in curriculum.
- Offline play succeeds with network disabled and no model. Internet connectivity is opt-in and irrelevant to core narrative.

## 5. Accessibility and UX acceptance

- Keyboard and mouse can complete every mandatory mission. Controller can select/menu/build/race with no pointer requirement. Rebinding and sensitivity controls persist.
- Use UI scale at 100%, 125%, 150%; essential text remains readable on 720p and standard TV viewing distance. Colorblind mode uses shape/icon and label.
- Reduced motion removes camera shake, head bob, repetitive flashing and heavy motion blur. Autopilot or simpler steering is labelled as assist and never changes scientific truth.
- Test at least 5 uncoached users: record first successful snap, number of invalid placements, time to navigate to Journal, success entering/exiting rover, success identifying current mission objective. Iterate on observed errors.
- No opt-out dark patterns, streak losses or pressure prompts. All save/export data can be deleted locally by the adult.

## 6. Pi4 minimum acceptance protocol

**Pi minimum hardware:** Raspberry Pi 4B 4GB (not a Pi5, no experimental overclock required). Document exact revision, OS release, driver, engine and compatible renderer. **Test all of:** boot/launch, 720p 30 FPS design goal, camera feel, construction with active physics, rover trial, at least one biome transition, save and restore, two separate user accounts, graceful exit, safe disk writes under low-storage, long warm run and temperature/throttling metrics. A Pi test cannot be simulated by constraining a gaming PC's resolution. Include screenshots and raw profiler logs of actual device. **Not-run is acceptable; invented success is not.**

## 7. Desktop high quality validation

**Windows** supported when native export runs on reference 1080p/1440p hardware. **Linux** when native export runs without editor and physics/audio work. **macOS** after signed/notarized release and tested Apple GPU paths. **Ultra** when final PBR hero scenes, advanced light settings, LOD transitions and stable 60+ FPS are measured on a documented reference gaming PC. A PC render screenshot is part of evidence, not proof of playability by itself.

## 8. Automated smoke commands and evidence

```bash
# From Godot game project root; requires official Godot executable installed.
godot --headless --path . --editor --quit
# Opens game on desktop (human interaction required for gameplay verification).
godot --path . -- --quality=creator
# Optional system smoke checks for JSON/art pack and source contracts.
python3 tools/validate_project.py
```

Continuous integration can run headless import and `tools/validate_project.py` even without a GPU. Do not call a headless smoke test a full runthrough of vehicle physics or UI. Publish `qa/<date>/` with engine version, CLI, log excerpts, full test matrix, captures and blockers. Until engine binary is available and scenes parse successfully, current runtime gate is `NOT RUN`.
