# ForgeVerse: The Original Luanti Sky Archipelago

The packaged world is a functional **Luanti worldmod implementation**, not just a fantasy illustration. Its art direction comes from the WonderForge prototype; game rendering uses simple original low-resolution block textures to stay appropriate for the Raspberry Pi 4B. The world is not equivalent to the spectacular pre-rendered concept-art landscape. Actual node generation and playability still need testing with Luanti on a Pi.

## Installed structure

```text
~/.minetest/worlds/WonderForge/
  world.mt
  worldmods/wonderforge/
    mod.conf
    init.lua
    textures/wonderforge_*.png
```

The installer copies this separately into each child's Unix home and preserves an existing world rather than overwriting it. The `world.mt` uses Minetest Game (`gameid = minetest`) and the `singlenode` map generator. Debian Trixie packages `luanti` and `luanti-game-minetest` are prerequisites. [Debian Luanti package](https://packages.debian.org/stable/luanti), [Debian Luanti wiki](https://wiki.debian.org/Games/Luanti), [Official mod installation](https://docs.luanti.org/for-players/installing-mods/).

## What the world contains

All seven islands are deterministic functions of 3D coordinates. The center hub is at approximately `(0,12,0)` with a safe arrival point above at `(0,15,0)`. Floating islands ring the center at coordinates `(46,0)`, `(23,40)`, `(-23,40)`, `(-46,0)`, `(-23,-40)`, `(23,-40)`. Three-block-wide bridges lead toward each region. Small glowing portal nodes teleport players to the destination island; return portals lead home. Regions are generated when Luanti requests their mapchunks; the world is not installed as a giant pre-created map database.

| Region | Educational emphasis | In-world challenge |
| --- | --- | --- |
| Sky Citadel | Engineering, materials, structural loads | Construct and compare two bridge types |
| Robot Wilds | Electronics, sensors, input-output logic | Plan a rescue rover with a measurable behavior |
| Crystal Deep | Rocks, minerals, observations | Sort and describe samples by physical evidence |
| Red Frontier | Astronomy, habitats, systems | Design a resource-aware planetary shelter |
| Echo Isles | Sound, storytelling, creativity | Record an original sound sequence |
| Code Garden | Programming, algorithms, debugging | Write a short sequence around obstacles |

The central Atlas block is interactive; Luanti formspecs list the six missions, offer descriptions and toggle a per-player completed flag. Typing `/forge` opens the board from anywhere; `/forgehome` teleports the player to the central hub. The children are explicitly encouraged to complete the **real-world task**, document evidence in Project Vault and discuss changes. An in-game completion is a self-report, not proof an experiment occurred.

## Internal implementation notes

The mod registers its own terrain nodes and does not use proprietary or licensed game textures. It places geometry via `register_on_generated` with a `VoxelManip` buffer and cached content IDs, rather than thousands of `set_node` calls on join. Generated chunks outside a bounded radius/height return immediately. The loop samples exact relative island geometry so different mapchunks will agree on overlapping structures.

Textures are 16×16 PNG originals created for this project. A missing texture or unknown node should fail visibly (and be investigated) rather than silently download content. The package installs no server world, Internet service, external mobs or multi-world network bridge. A child may still need to adjust the game's video settings and hardware-accelerated rendering to make it comfortable on the Pi 4B.

## Testing it on the physical Pi

1. Install `luanti` and `luanti-game-minetest` from approved apt sources.
2. Log in as `atlas`, open Luanti, select `WonderForge` in Singleplayer, verify the base game is `Minetest Game` and start.
3. Look for floating ground immediately after map generation. If the player falls into the void, use `/forgehome`; check the log for mod loading errors.
4. Right-click the Atlas board near the hub. Verify quest names and completion toggles, leave and re-enter the world, and confirm completion is retained.
5. Walk to at least one bridge and right-click a glowing portal. Verify teleportation and return.
6. Test all six islands with mapgen, confirm no 3D world crash or 4GB out-of-memory event, and inspect the logs for Lua warnings.
7. Sign out; log in as Nova; confirm Nova has an independent world and player progress. They can collaborate side-by-side using the same Pi with role rotation, not simultaneous split-screen play.
8. Benchmark at an initial 720p resolution with modest view distance; change one setting at a time and record FPS, input latency and RAM usage.

**Known integration risk:** the Lua code was authored and source-checked in this build environment but the Luanti binary/engine was not available for an end-to-end game launch. It therefore requires real runtime validation. The code should be treated as a substantial first implementation, not a QA-certified game. If an engine API behaves differently under the installed 5.10 package, make a targeted fix and add a game-engine acceptance test rather than accepting a screenshot.

## Future bridge to Pocket Builder

The browser blueprint editor exports a bounded 12×12×8 coordinate-to-material mapping. The Luanti mod currently does **not** import that blueprint into the world. A safe next adapter would validate the same six materials and coordinates on the game side, place nodes only inside a controlled construction zone, respect game/player permissions, enforce a maximum node budget per import, and write to a persistent worldmod storage key. Directly exposing an unrestricted HTTP endpoint from the game engine or allowing players to write arbitrary world paths would be unsafe. Until that bridge is developed and tested, the experience is two complementary tools: original game world and local blueprint editor.
