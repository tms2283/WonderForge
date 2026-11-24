# WonderForge 0.7 release acceptance gates — evidence, not aspiration

**Release type:** feature-complete AI integration *candidate*, not an OS/hardware certification. Existing Raspberry Pi OS is the target; no custom `.img` is required. The Pi has one screen and 4 GB RAM.

## Automated acceptance gates (run on a development host)

- [x] Existing desktop, field guide, project vault, team sharing, journals and physics/logic tests pass.
- [x] AI API remains bound to per-user WonderForge portal, with authenticated production access.
- [x] Ollama client uses only `127.0.0.1:11434` (not a model-selected host or proxy).
- [x] Model IDs are allowlisted; cloud tags and arbitrary namespaces rejected.
- [x] Concurrency, output size, number of turns, token budget and history are capped.
- [x] Model planner cannot use shell, network, filesystem, app-launch or arbitrary Python tools.
- [x] Unsafe/invalid tool arguments are rejected; large requests rejected before inference.
- [x] Single-use consent token; authenticated cookie-bound proposal and CSRF protection.
- [x] User-confirmed draft leaves observations and conclusions blank.
- [x] Browser tests of AI success and no-model fallback on desktop and mobile.
- [x] A reproducible Debian payload includes `local_ai.py`, test data and adult-only AI setup.
- [x] CI executes tests and package integrity checks on supported Python versions.

## Physical Pi 4B acceptance gates (**not verified in this environment**)

- [ ] Adult inspects current Raspberry Pi OS installation and backs up user data.
- [ ] Normal Linux administrator, Atlas and Nova can log in and out separately.
- [ ] Portal cookie isolation across two Unix identities re-tested locally on the Pi.
- [ ] Official Ollama ARM64 service installed and configured local-only with cloud disabled.
- [ ] Selected Qwen3 0.6B model downloaded; successful `ollama list` and `/api/tags`.
- [ ] ORBIT responds to an ordinary STEM query; first/second-turn latency measured and recorded.
- [ ] Observe CPU temperature, throttle state, available memory, UI responsiveness and swap activity during model use.
- [ ] Confirm slowdown/fallback if model is stopped, restarted or unavailable.
- [ ] Check child cannot make an arbitrary model tool read files, launch programs, download software or run commands.
- [ ] Maker Journal draft approval survives portal restart and remains private to its Linux account.
- [ ] Real Luanti Sky-world loads and is playable, and does not degrade critically after a recent inference.
- [ ] Offline Field Guide and Physics Lab work when the network is disconnected.
- [ ] Restore a backup of each child's vault/journal and a shared Team Forge record.
- [ ] Recovery from a corrupted account profile, disk-full condition, power interruption and model failure is rehearsed.
- [ ] Family adult reviews all content-safety expectations: the model is fallible, not a child-content filter.

The project cannot accurately be called *hardware-finalized* until the second section has documented evidence. Do not retroactively mark unexecuted tests as passed.
