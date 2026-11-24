# WonderForge 0.7.0 — ORBIT Local AI / installable Raspberry Pi OS enhancement

Date: 23 November 2026. Target: **one already-working Raspberry Pi 4 Model B, 4 GB, Raspberry Pi OS Desktop 64-bit**. No replacement OS image is required.

## What is now implemented

1. **Small local generative model:** Python-only Ollama client with a fixed `127.0.0.1:11434` endpoint, selected model allowlist, bounded request/response sizes, 2048 context, two CPU threads, one active inference, and finite timeouts. The default `qwen3:0.6b` is an *unbenchmarked* choice for a Pi 4B. No weights, cloud account, or third-party proxy are included.
2. **Agentic learning with no arbitrary system access:** A two-turn local planner can select up to two tools from a strict read-only list: Field Guide search, quest search, simulated LED/resistor arithmetic, and simulated beam deflection. Invalid calls are rejected at the Python boundary. No shell, generic code execution, file browsing, hardware I/O, application launching, network search, or cross-user database access.
3. **Human-in-the-loop creation:** The model may propose an experiment draft; a separate approval button and single-use, 180-second, cookie-bound token are required. Real journal observations and conclusions remain blank. Production saving waits for private SQLite acknowledgement before reporting success.
4. **Transparent fallback:** The UI identifies when a model is actually installed. If unavailable or failing, it uses the older scripted guide and reports that fallback honestly. Local source titles and tool names appear in model-assisted responses; all model text is escaped in the browser.
5. **Adult-only setup:** New dry-run-first `installer/setup-local-ai.sh` enforces localhost Ollama binding, disables Ollama cloud features, and downloads only one explicitly selected allowed model after a privileged `--apply`. It refuses non-ARM64 deployment, missing Ollama service, low disk, and unfamiliar pre-existing settings. The override has a documented rollback path.
6. **Actual hardware observability:** New read-only `tools/benchmark-local-ai.py` measures one local inference with before/after hardware samples; it does not invent Pi 4 speed. The existing System Pulse reports actual memory, CPU and thermal values where supported.
7. **Engineering quality:** Existing tests remain. New localhost-protocol and security tests validate model selection, tool gating, request caps, cookie authentication, CSRF checks, one-time draft consent, and browser behavior. Reproducible `.deb`, updated CI and user documentation are bundled.

## Source and installation

- Source: https://github.com/tms2283/WonderForge
- Adult guide: `docs/LOCAL-AI.md`
- Installation: `docs/QUICKSTART-FAMILY.md` and `docs/PI4-INSTALLATION.md`
- Hardware gates: `docs/RELEASE-GATES-v0.7.md`
- Tests: `python3 -m unittest discover -s tests -v`
- Browser: `python3 tools/browser-smoke-ai.py` (development Chromium and Playwright required)
- Debian build: `bash scripts/build-deb.sh dist`

## Limits and unresolved physical acceptance

This is a feature-complete *engineering release candidate*, not a certified, finished physical appliance. A real Ollama model has **not** been downloaded or benchmarked in the development environment; development-host tests use a simulated local Ollama protocol. Initial Pi deployment and thermal throttling, local model latency, actual Luanti gameplay, end-to-end dual-account login, power-loss recovery, and family content-review practices still need an adult to validate on their physical board. A tiny model does not guarantee safe or correct advice. The project remains usable without Ollama.

## Upgrade notes from 0.6

On an existing Pi with the 0.6 `.deb`, upgrade the app using `sudo apt install ./wonderforge-os_0.7.0_all.deb` from an adult login. User data is preserved in the Linux home directories, not inside the application package. Back up those private homes before upgrading. No child account, firewall rule, automatic autologin, or Ollama service is changed by the `.deb`. The optional AI service setup is a separate, explicit adult operation. If model performance is poor, disable ORBIT local inference or stop Ollama; the scripted offline guide continues functioning.
