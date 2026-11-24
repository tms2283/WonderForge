# Architecture — PC-led art, Pi-minimum capability

**Technical decisions:** Godot stable GDScript, separate physical simulation and render presentation, authoring master scenes and tier derivatives, deterministic quest state and bounded local AI. Build from the vertical slice outward. Target Windows, Linux and macOS desktops plus ARM64 Raspberry Pi OS where actually certified.

## Renderer abstraction and material fallback

Create `res://data/quality/presets/*.tres` for Explorer, Creator and Ultra. `QualityManager` reads command line, persisted user preference and measured capabilities, then selects visual visibility ranges, vegetation LOD, mesh/material variant and shadow/particle budgets. **Renderer itself must be chosen at process start**. PC Ultra runs Forward+ if supported and verified. Pi uses Compatibility and static/baked effects. Every PBR material should have both quality variants mapped in manifest; never require unsupported shader features to see a collision-critical socket. At runtime, failed advanced shader should switch to a validated fallback material, not invisible geometry.

## Layer rules

`GameDomain` saves only pure data (quest state, economy, graph, profile ID). `GameWorld` produces transient nodes and physics bodies. `GameView` binds geometry/animation/UI to domain events. `AIService` offers optional offline explanation via a separate supervised process. `PlatformHost` handles OS paths, display settings and approved external tool launches. Godot should **not** launch arbitrary shell commands proposed by AI, and cannot assume the previous Python portal is already running.

The **machine graph** serializes part definitions and connector edges, and is consumed by physics and rendering. No ownership cycle between scene nodes and game data. Tests should operate on domain graph without needing GPU. This allows a saved machine to be opened on Pi with lower visual LOD while retaining connectivity and material mass. Use fixed physics ticks and record solver version in experiment logs.

## Family profiles

Separate profile saves using the platform's per-user secure data directory. When using shared Pi Linux accounts, OS home permissions separate files; a deliberately shared blueprint directory is the only exchange route. Desktop family mode may offer profile selection, but that is **not** secure child account separation. Shared blueprints are copied via explicit action; always prompt before overwriting. Local AI conversation logs are private and opt-in, with clear deletion controls.

## Cross-platform build targets

| Platform | Native exports | Renderer | Status in this source bundle |
|---|---|---|---|
| Windows x86_64 | Godot Windows templates | Forward+ / Compatibility | Source target; no export binary included |
| Linux x86_64 | Godot Linux templates | Forward+ / Compatibility | Source target; no export binary included |
| macOS x86_64 / arm64 | Godot macOS templates | Metal backend / Compatibility | Planned, unverified |
| Raspberry Pi 4B arm64, 4GB | ARM64-compatible Godot build/export | Compatibility | Minimum target, unverified hardware |

**Conformance principle:** account security and graphics tiers are distinct. A high-end gaming PC can run the best renderer, highest LOD, widest physics budget and larger local AI while a Pi uses lower budgets; neither may receive different core campaign rewards, rules or save semantics.
