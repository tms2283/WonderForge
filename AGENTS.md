# Agent instructions — WonderForge

Implement features against the **real system** described here, not a visually convincing placeholder. This is an open-source, offline-first maker interface intended for one **Raspberry Pi 4 Model B with 4 GB RAM**, shared sequentially by two brothers with **different Linux user accounts**.

## Absolute invariants

1. **No fabricated capabilities.** A functional web UI does not prove a bootable OS image; a Luanti worldmod has no certified performance without actual Luanti/Pi testing; a scripted ORBIT answer is not a local generative model. Every UI capability note must say what actually runs.
2. **Offline and low-footprint first.** Do not add remote fonts, CDNs, analytics, tracking, account signups, intrusive gamification, or always-running 3D canvases. Every network requirement is opt-in and adult-approved.
3. **No unsafe privileged automation.** System installer dry-run by default, `--apply` gated to verified Raspberry Pi OS Trixie arm64 on Pi 4B; do not change partitions, passwords, autologin, boot configuration, or nftables without a user-controlled opt-in. No child membership in sudo/wheel/dockerd groups.
4. **User privacy.** `atlas` and `nova` Linux homes mode 0700. The visible demo profile selector is not authentication. Each production portal authenticates browser API requests using a one-time ticket and session. Keep the browser localhost-only.
5. **Personal state stays personal.** SQLite lives under the Linux user's private home; Team Forge receives explicit copies in a group-owned directory. Do not leak state between users or commit user data.
6. **Educational quality.** A quest needs a genuine outcome, a testable experiment, and a meaningful artifact. Maker Journal evidence means a child *documented* a test, not that the system certified its scientific correctness.

## Test and build contract

```bash
python3 -m unittest discover -s tests -v
node --check web/app.js && node --check web/labs.js && node --check web/journal.js
for s in installer/*.sh scripts/*.sh image/*.sh start.sh; do bash -n "$s"; done
bash scripts/build-deb.sh /tmp/wonderforge-build
```

The optional `python3 tools/browser-smoke-v06.py` uses development dependencies and a mocked API for browser UI checks. A passing mocked browser test is not a Pi 4 hardware certification.

## Next implementation priorities

- Add the real Pi acceptance harness: first boot on spare media, pre/post install diagnostics, rollback and SD-card corruption recovery.
- Validate Luanti assets, portal interactions, memory limits, save/resume behavior, and controls on a physical Pi 4B.
- Improve evidence linking, parent-visible opt-in portfolios, offline lesson index/search and accessibility for keyboard/controller navigation.
- Expand safe, opt-in creative software integrations based on ARM64 availability, not guesswork.
- Allow optional stronger AI through a separately connected machine or explicit adult-approved service; retain scripted offline guidance on the Pi.

## Documentation

Read `SECURITY.md`, `docs/RELEASE-NOTES-v0.6.md`, `docs/QUICKSTART-FAMILY.md`, `docs/IMAGE-BUILD.md`, and `docs/PI4-ROLLOUT-PLAN.md` before changing installation or security. Update tests and docs with every behavior change. Never write success claims without a corresponding test or observed output.
