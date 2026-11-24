# Codex / Copilot / local agent operating instructions — WonderForge Genesis

**Task:** build a premium cross-platform physics-based exploration, invention, racing, settlement and learning game in Godot 4.7.x. The Raspberry Pi 4B 4GB is the *minimum* supported device, not the PC graphics ceiling. Use three quality levels Explorer, Creator and Ultra; save/quest/assembly semantics identical. The current source is a working-intent 3D **blockout vertical slice** with source checks and Godot headless CI; its placeholder primitive art is NOT acceptable for production art gates.

## Before editing

1. Read `WONDERFORGE-ULTIMATE-AGENT-SPEC.md` in full, particularly the art bible, baseline QA and sequential workstreams.
2. Run `python3 tools/validate_project.py` and `python3 -m unittest discover -s tests -v`.
3. If a Godot binary is available, run `godot --headless --path . --editor --quit` and a 30-frame scene smoke check; record CLI output and exact Godot version. If not available, mark engine-level validation NOT RUN.
4. Choose one workstream, implement, test, capture evidence and commit. Do not pretend a planning document is finished gameplay.

## Never break these invariants

- No copyrighted meshes/UI/characters copied from inspiration games. Original designs and licensed assets only.
- No silent changes to per-profile quest rewards, save schema, machine masses or physical units.
- No arbitrary local AI-generated shell commands, remote requests, unsafe GPIO actions, hidden file reads or autonomous game-control actions.
- No false claims of actual Pi performance from desktop checks; no claiming measured structural accuracy without model validation.
- No manufactured screenshots, logs or test results; distinguish concept-art renders from real Godot captures.
- Use tested graphics fallback assets and content budget on Pi while preserving high-quality PC master assets.
- Don't put child or user personal data into version control.

## Definition of done for any feature

A feature is done only when its implementation (not merely its design) is navigable, persistent as appropriate, clear to uncoached users, functional with keyboard/controller where promised, verified by reproducible logs/tests, visually compared with approved art direction and performance-measured on relevant supported platforms. Separate PASS / FAIL / NOT RUN for each release gate. Report newly discovered problems instead of hiding them.

## Priority

Workstream 00 parse/run, 01 hero art, 02 graph/parts, 03 builder UX, 04 simulation, 05 handling, 06 authored 15-minute adventure, then racing/settlements/ORBIT/optimization. Prioritize one exceptional full playable vertical slice over dozens of hollow map markers.

## Current working baseline (v0.3)

Before modifying game systems, run `godot --headless --path godot-genesis --script res://tests/runtime_smoke.gd` **after** normal Godot import and inspect `docs/IMPLEMENTATION-STATUS-v0.3.md`. Preserve the `GenesisRoverBlueprint` schema and `genesis_save_v1.json`, test independent workshop selections, checkpoint order, journal persistence, builder collision/undo/redo and all three quality profiles. Keep original model provenance and generated asset integrity checks in CI. The required manual gameplay gate is in `docs/LOCAL-AGENT-HANDOFF-v0.3.md`; automated headless success does not replace first-person playtesting and art review.

## Save-integrity regression gate (2026-11-24)

The game now has `scripts/save_guard.gd` and `tests/save_guard_smoke.gd`. Run the save-contract test in actual Godot after import; preserve the current v1 save schema and recovery semantics. Read `docs/SAVE-RECOVERY-v0.4.md` before altering disk I/O. Desktop test success does not certify power-loss resilience of a Pi SD card.

## Assembly contact scanner gate (2026-11-24)

The builder now exposes `structure_report()` from `GenesisAssemblyScan`. Press **I** in Build mode. This is a geometric contact estimator for an introductory connected-build quest, **not** an actual fixed/hinge joint solver or strength certification. Read `docs/ASSEMBLY-SCAN-v0.4.md` and execute `tests/assembly_scan_smoke.gd` in Godot 4.7.2 before any physics or catalogue integration.
