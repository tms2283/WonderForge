# Cross-platform renderer and simulation strategy

**Priority:** PC-quality art authoring with measurable scalability. **Certified minimum (future gate):** Raspberry Pi 4B 4GB. Raspberry Pi viability is **not** established until tested on physical hardware. Compatibility mode should be the Pi default; modern PCs may use Mobile or Forward+ where export/render requirements permit. See official Godot 3D performance, renderer and resolution-scaling documentation linked below.

## Three quality profiles: what changes and what never changes

| Feature | Explorer / Pi minimum | Creator / midrange | Ultra / gaming PC |
|---|---|---|---|
| Renderer | GL Compatibility | GL Compatibility or Mobile after testing | Forward+ if supported |
| Render target | 1280×720, adjustable scale | 1920×1080 | 2560×1440 / 3840×2160 optional |
| Trial frame goal | 30FPS sustained, 33.3ms frame | 60FPS, 16.7ms | 60+FPS, measured |
| Scene terrain subdivisions | 56 in demo | 82 in demo | 116 in demo |
| Visible tree instance sample | 110 in demo | 300 in demo | 600 in demo |
| Camera far limit | 165m | 320m | 450m |
| Shadows | Off/limited in demo | On | On, improved quality later |
| AI | Disabled during critical physics; optional tiny local model | Model optional via local CPU/GPU | Optional larger private model |
| Audio channels | budgeted | standard | high |
| Part count / active joints | budgeted after measurement | moderate | extended |
| Quest flags, saves, economy | **identical** | **identical** | **identical** |
| Part rules and physical units | **identical** | **identical** | **identical** |

**Critical:** current vertical slice chooses an aesthetic profile using `scripts/quality_profiles.gd`; future production should distinguish `VisualProfile`, `SimulationBudget` and `AccessibilityProfile`. The numeric demo presets are not proof of the FPS targets. Do **not** save quality profile into persistent world save. Graphics quality cannot silently change the blueprint's physical meaning; only number of simultaneously active rigid bodies and update frequency of distant actors may change, with documented simulation approximation.

## Recommended memory budgets (targets, not measurements)

For Explorer Pi4, aim for **peak resident game memory under 1.5GB**, leaving substantial system memory for Raspberry Pi OS and background services; initial engineering target 0.8–1.2GB. Allow world chunk meshes ~250MB, texture uploads ~300MB, engine/physics ~350MB, UI/audio/logic ~150MB, streaming buffer ~200MB—these are engineering hypotheses, not OS-provided caps. Chrome/desktop/optional local AI must be profiled separately. Disable local model while heavy physics trials run unless actual stress data justifies concurrent execution.

**GPU strategies:** MultiMesh vegetation, atlas textures, shared shader materials, baked static lighting, limited transparency, distance impostors, visibility range and occlusion culling where supported; avoid excessive shadow maps and dynamic reflections. Draw calls alone don't guarantee performance; measure GPU frame time, overdraw and shader cost. Use texture mipmaps and GLES/GL-friendly compressed formats; avoid 4K textures on Pi. Keep collision meshes simpler than visible meshes and use convex shapes for dynamics. Partition physics by local interest; never allow 500 unconstrained active parts by default on Pi.

**CPU strategies:** run world economy in coarse event ticks; procedural terrain generation off critical frame with precomputed caches; reduce NPC animation frequency by distance; throttle pathfinding and raycasts; use spatial hash for build snaps; never rebuild all instances on each mouse move. Run Godot profiler over multiple minutes with same scene and exact test inputs. Record p50 and p95 frame times, worst-stall durations and thermal throttling.

**Scaling rule:** if Explorer tier cannot sustain measured performance, reduce visual draw distance, effect counts, vegetation density, LoD triangle density and render resolution before changing gameplay. Keep target FPS and frame-time labels honest. Cross-platform save and machine graph hash must remain invariant. If physics machine complexity exceeds tier budget, warn with exact count and offer a “test in smaller groups” or batch-simulation mode; don't silently remove joints or fake results.

## Platform matrix

- **Windows 10/11 x64:** Creator and Ultra, native Godot export, keyboard/mouse and controllers. Run Direct3D/Vulkan renderer checks as applicable.
- **Linux x86_64:** Creator and Ultra, native export, validate supported GL/Vulkan drivers. Steam Deck can be benchmarked later.
- **macOS Intel/Apple Silicon:** supported after export templates, code-signing/notarization and Apple GPU/API checks pass, not by assumption.
- **Raspberry Pi OS 64-bit aarch64 / Pi4B 4GB:** Explorer target. Needs ARM64 export template/runtime compatible with OS, OpenGL ES/driver version, audio/controller testing, memory/thermal data and safe installation. May require an ARM64 build of Godot rather than the desktop editor.

## Suggested launch/runtime commands

At project root: `godot --path . --editor` (desktop development), `godot --headless --path . --editor --quit` (parse/import smoke), `godot --path . -- --quality=explorer` (runtime quality test). On compatible gaming PC, use `godot --rendering-method forward_plus --path . -- --quality=ultra` after renderer support is verified. On Pi: use the Compatibility renderer and `--quality=explorer`. The renderer is an **engine startup choice**; switch requires restart. The scripts under `launchers/` provide editable helpers. The project defaults to Compatibility so it opens on lower-end hardware, not because PC Ultra graphics should remain restricted to Compatibility forever.

## Acceptance test track

1. Record exact Pi hardware revision, RAM, OS codename/kernel, graphics driver, Godot commit/version, renderer, memory swap and power supply.
2. Create `Pi4-30min-route` deterministic run: boot, load game, open workshop, place 20 parts, test rover, drive 2km, transition zones, save, reload, quit.
3. Capture frame timings, CPU, RAM, swap, GPU memory/driver indicators, temperature, throttling flag, loader stalls and disk writes. Repeat after a fresh boot and after 30 minutes warm runtime.
4. Compare on reference PC with same save and settings except tier; confirm quests, materials, part IDs and machine topology are unchanged. Verify screenshot visual readability, even when distant detail is reduced.
5. Test thermal and low-voltage behavior without using aggressive overclocking. Fail if data corrupts or input becomes unusable. Tune graphics/physics until measured stable experience, and publish actual percentile figures.

## Official references

- Godot renderers: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Performance: https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html
- Resolution scaling: https://docs.godotengine.org/en/stable/tutorials/3d/resolution_scaling.html
- Hardware/system requirements: https://docs.godotengine.org/en/stable/about/system_requirements.html
- Multi-resolution: https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
