# WonderForge Genesis — structural contact scanner

A new **I** shortcut in build mode reports geometric face contacts, connected groups, and horizontal span. The introductory construction milestone now requires at least **three face-contacting parts in the same group, across 7 m**, instead of arbitrary pieces scattered in the world.

The scanner uses the six existing runtime part dimensions; no change to `wonderforge.genesis.assembly.v1` or `genesis_save_v1.json`. Previous completed milestones are preserved.

**Engineering limitations:** Face adjacency with 0.26 m placement-grid tolerance is only a gameplay learning approximation. This is not joint physics, stress/load distribution, ground anchoring, collision-proof stability or bridge-repair machinery. It does not yet integrate the 42-part production catalog. Never call it a mechanically sound structure.

## Tests

```bash
cd godot-genesis
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/assembly_scan_smoke.gd
```

The GitHub engine CI tests real Godot GDScript and geometry results. Actual GUI placement legibility, performance on Raspberry Pi 4B, and live joint constraints require local follow-up and must remain **NOT RUN** until observed.
