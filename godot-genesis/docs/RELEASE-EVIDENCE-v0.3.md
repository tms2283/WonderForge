# WonderForge: Genesis — v0.3 release evidence and remaining gates

**Date:** November 23–24, 2026 (UTC). **Target engine:** Godot 4.7.2. **Repository:** `tms2283/WonderForge`. **Authoritative game folder:** `godot-genesis/`. This is an **interactive 3D alpha/vertical-slice development build**, not an art-complete game or Pi-validated production product.

## What was actually run

- 5 Python source/asset/document integrity tests passed in the authoring container (`python3 -m unittest discover -s tests -v`).
- `tools/validate_project.py` passed: main scene scripts, 42 catalog part specifications, 24 authored quest designs, Explorer/Creator/Ultra profile contracts, original `.glb` files and SHA-256 checksums.
- The original asset generator was executed twice; **all four GLB SHA-256 digests matched**. Both quality tiers of the workshop and observatory are real geometry, not screenshots.
- GitHub Actions **WonderForge Genesis · Godot Game Engine** succeeded for commit `0f61eab2800516624d2b4212f9540c2117632d72`, running Godot 4.7.2 headless import, 30-frame main scene and a separate native engine system-contract test that covers gamepad input maps, wheel parameter changes, construction with undo/redo, garage open/close, mentor offline fallback, ordered six-gate course, and persisted journal records. Source: https://github.com/tms2283/WonderForge/actions/runs/45329932308
- GitHub Actions **WonderForge Genesis — Export Desktop Build** succeeded for commit `36bc60d88b1613d19a476a41e13bdbbf2cdee556`: it obtained official matching export templates, reimported the Godot project, ran the engine contract, produced x86-64 Windows `.exe` + PCK and Linux executable + PCK, and launched the **exported** Linux binary headlessly for 30 frames. Source: https://github.com/tms2283/WonderForge/actions/runs/45330259622
- Artifact names from that run: `WonderForge-Genesis-Windows-x64` (~38 MB) and `WonderForge-Genesis-Linux-x64` (~29 MB). Download from GitHub Actions; unzip; run the platform executable from beside the `.pck`.

## Evidence deliberately NOT claimed

- No actual Windows GUI screenshots/playtesting or verified controller behavior in the hands of new players.
- No Pi 4B native 3D launch or measured FPS, CPU temperature, memory pressure, graphic artifacts or network connectivity.
- No measured physics validity vs a real vehicle. The VehicleBody3D power/traction values and simulation output are gameplay approximations.
- No premium AAA or AA release-ready art; the GLB models and animated avatar are authored work-in-progress, not the finished Art Bible designs.
- No complete 24-quest campaign, multiplayer, empire sim, accurate joint-constrained Besiege builder, authoritative collision network or finished audio.
- No bundled Ollama model in Godot. The optional localhost interface is consent-based and the model can be fallible.

## Manual first 30-minute playtest (owner and local agent)

Start with the Windows or Linux GitHub Action artifact or import `project.godot` in the matching Godot 4.7.2 editor. Press F1 to close help. Walk with WASD; use right mouse drag to orbit and scroll to zoom. Observe whether you can find the Founders' Workshop from the spawn without reading instructions. Press G; compare tire choices and notice the instrumented blueprint changes. Predict the effect of one modification, launch a six-checkpoint trial and drive with WASD and SPACE. Press J after finishing, then change **only one** parameter and rerun. Confirm the time and battery comparison is interpretable. Press B to build collision-backed platforms with Z/X undo/redo. F5 save, restart, F9 load. Press F2: ask offline ORBIT about the motor, optionally try a trusted separately installed Ollama after review. Record any clipping, confusing icons, camera behavior, AI hallucinations or unexpected collision.

Capture reproducible screenshots at 1280×720 and 1920×1080 for each graphics tier. Test genuine gamepads with different controllers and layouts. Record F1 and UI focus issues, body/wheel clipping, scale problems, time to first garage run, vehicle rollover recovery, action mapping ambiguity and notebook clarity. File GitHub issues with screenshots and exact Godot version. The release is **not final** until those issues are resolved and the production art gate passes.

## Publication priorities

1. First full human playtest and camera, UI, trial and save bugfixes.
2. Physically connected machine construction with sockets, joints and validation instead of static colliders.
3. High-quality original art and animation, cinematography, effects and sound for the opening valley, with Pi derived LODs.
4. Truly satisfying vehicle handling and structural load tests verified against assumptions.
5. A cohesive 15-minute quest with discovery, construction, measurable result and world-changing consequence.
6. Settlement loop, authored campaign, optional local AI, multiplayer after core quality works.
7. Final signed/versioned release and Pi 4B device certification.
