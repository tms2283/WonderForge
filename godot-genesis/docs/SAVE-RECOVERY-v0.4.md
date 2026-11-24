# Genesis save-integrity and recovery contract (pre-handoff)

**Scope:** `godot-genesis/`. Implemented as `scripts/save_guard.gd`, integrated into `scripts/game.gd`. This improves resilience of the existing `wonderforge.genesis.save.v1` format; it **does not** silently migrate, encrypt, synchronize or upload any personal data.

## What the code does

- Rejects oversized (512 KiB), malformed or non-finite world saves before they enter the game.
- Checks the rover blueprint, player position, inventories, progression, visited map and maximum 300 parts.
- Writes first into `user://genesis_save_v1.json.tmp`, flushes and validates the candidate before attempting replacement.
- On subsequent saves, preserves the prior valid save as `genesis_save_v1.json.bak` before replacing the primary. The backup is not overwritten with a corrupt primary.
- If the primary cannot be read, loads the validated backup, tells the player recovery occurred and leaves the damaged primary intact.
- Preserves the existing `genesis_save_v1.json` and its schema, which avoids migration of the game world and quality tiers.

## Limits and test evidence

This is a single-process local save path. Replacement rename is designed to be atomic on supported filesystems, but **power-loss durability is not guaranteed without a disk/device validation**, and the backup protects one previous valid state, not an unlimited history. A successful headless Godot save-contract test is not evidence that low-voltage Pi SD-card writes are reliable. There is no encryption.

Automated Godot test:

```bash
cd godot-genesis
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/save_guard_smoke.gd
```

Expected marker: `WF SAVE GUARD CONTRACT PASS`. The CI workflow runs this with the actual Godot 4.7.2 engine.

## Adult recovery procedure

1. Stop the game before working with saves.
2. Back up the entire Godot user-data folder to a protected device, including `.bak` and `.tmp` files, before editing.
3. Try F9 load. If a validated backup is found, the game will report recovering from a previous save.
4. Make a new F5 save only after confirming the loaded world and inventory are correct.
5. If both copies are corrupt, **do not delete them**. File a bug report and attach sanitized validation logs (never children's personal save data in a public issue).

## Agent next actions

- On a real Pi, simulate interruption during save, full disk, write denial and reboots using a disposable test account and SD card; record pass/fail.
- Validate the same behavior on Windows exports and all Explorer/Creator/Ultra tiers.
- Preserve the save schema; add migrations only with checked compatibility tests and backup/rollback.
