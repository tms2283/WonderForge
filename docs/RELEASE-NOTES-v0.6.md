# WonderForge 0.6 — a learning platform that keeps evidence

23 November 2026. Source-first release for one shared Raspberry Pi 4B (4 GB RAM).

## What changed from 0.5

1. **Maker Journal**: hypotheses, methods, observations, conclusions, linked quest IDs, draft/evidence distinction, per-Linux-user persistence via existing private SQLite, schema-validated backups. This is a record of inquiry, not an automatic assessment, badge farm, or substitute for a teacher.
2. **System Pulse**: authenticated read-only device telemetry for RAM, 1/5/15-minute load, optional thermal reading, free storage, and optional Raspberry Pi throttle register. All readings come from the *actual machine running the server*. Unknown values remain unknown; dev-host readings are explicitly labeled as such. No FPS claims.
3. **Quality gates**: new unit tests for structured evidence, malformed/duplicate backups, storage keys, telemetry math, route authentication, and package contents. Stronger CI with no external runtime dependencies.
4. **Repository hygiene**: source only, assets licensed to this project, reproducible `.deb` built by CI rather than committed, private data ignored, no personal account credentials or children's data.

## What is real

- Read/write local experiments and notebooks; export/import; original quests and project vault; Pocket Builder and Robot Logic Lab; two physics teaching models; offline field-guide lessons; local rules-based ORBIT; optional native app launcher; separate Unix accounts when explicitly provisioned.
- These parts have been verified in automated tests. Some visual/browser integration tests run on a development browser with mocked local APIs.

## What is NOT certified

- A bootable, reproducibly flashed custom Pi OS image, Raspberry Pi 4B FPS or thermal behavior, real Luanti world gameplay and multiplayer, an advanced offline LLM, or unbypassable child safety controls.
- Do not install over the only working SD card. First use the tested Debian payload on a spare Raspberry Pi OS installation; record hardware evidence before treating the project as production-ready.

## Upgrade notes

- Existing v3 state keys are unchanged; `wf-reforged:v3:journal:{atlas|nova|team}` is additive.
- The public GitHub repository contains source but **must never** contain user data, `~/.local/share/wonderforge` SQLite, keys or real child information.
- The `.deb` is built from current source with `bash scripts/build-deb.sh`. The first installation is not automatic account provisioning.
