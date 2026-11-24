# v0.5.0 — 2026-11-23

- Authenticated per-account localhost API using a one-use signed HMAC ticket, HttpOnly cookie and private Linux 0600 signing key.
- SQLite-backed child progress and project storage under each Unix account's private home, with API validation, quotas and synchronization from browser cache.
- New Physics Lab with LED/resistor and elastic beam educational calculation models, plus 18 original offline Field Guide lessons.
- Offline ORBIT lesson lookup with a named source; remains explicitly non-generative.
- Source launch now opens the child's Luanti world directly using `--world` and `--go` if installed.
- Firstboot image experiment changed from automatic child-account creation to application staging only.
- User service UMask tightened to 0077, installer checks symlink paths; backup checksum & archive path inspection added.
- Read-only Pi performance sampler, expanded family recovery documentation and automated tests.
- 35 automated security, integration, science and recovery tests passed on development host.
- Status remains **INSTALLABLE ENGINEERING PREVIEW, NOT A TESTED IMAGE OR HARDWARE-CERTIFIED APPLIANCE**.

---

# Changelog

## 0.4.0 — ENGINEERING EDITION (2026-11-22)

- Added real Unix-account-bound local portal service, per-UID localhost ports, fixed allowlist native application launcher and explicit confirmation.
- Added bounded, symlink-protected group-folder notebook and blueprint sharing API and verified cross-user tests.
- Added cautious Pi4/Trixie-only account provisioner with real 0700 homes for Atlas and Nova, 2770 shared group folder, and preserved user creations.
- Added optional reversible per-UID nftables network guard and independent approved-app APT installer.
- Added Luanti sky-island worldmod (six regions, quest atlas, portal nodes and original textures), awaiting physical engine test.
- Added systemd user service, desktop launcher, adult backup/audit scripts and experimental Raspberry Pi official image-gen recipe.
- Added installable opt-in Debian payload packaging with no automatic account/network changes and a GitHub Actions test workflow.
- 23 passing source/HTTP/contract tests, browser-based identity/workflow checks, exact-payload HTTP smoke, deterministic `.deb` build, independent docs and explicit hardware release gates.
- No Raspberry Pi hardware test or completed flashable image is claimed.


## 0.3.0 — REFORGED (2026-11-22)

- Full visual/art-direction overhaul, cinematic original Aether Citadel environment and responsive welcome experience.
- Replaced generic icon-only dashboard with labeled system rail and coherent story-first hierarchy.
- Rebuilt 12 connected routes across Mission Control, ForgeVerse, Pocket Builder, Robot Logic Lab, Quest Atlas, studios, ORBIT, vault, library, family, team and settings.
- Added playable offline 7×7 Robot Logic Lab with obstacle detection, energy objective, command sequences, step/reset/run controls and saved program per workspace.
- Expanded original educational quest catalog from 18 to 20, adding geology and soundscape projects.
- Retained functional 12×12×8 isometric builder with six materials, rotation, undo/redo and JSON import/export.
- Added three visual atmospheres, reduced-motion support and mobile navigation fixes.
- Redesigned ORBIT as a clearly scripted helper with persistent prototype conversation history.
- Kept data local; added explicit warnings against misrepresenting OS accounts, OS-level policy, 3D game content, installed apps or generative AI.
- Added dedicated Figma editable Reforged page with gateway and 12 destination screens, semantic color and spacing variables, and separate art imagery.
- Executed Python/HTTP/syntax and headless Chromium visual/action checks.
- Added OS rollout specification, art/design system, source transparency and QA handoff.

## 0.2.0 — previous edition

Earlier OS-shell prototype superseded by Reforged. Its CSS and layouts are not required to run version 0.3.

## 0.6.0 — 2026-11-23

- Add structured, editable, import/export Maker Journal linked to quests; private SQLite integration uses the existing v3 storage protocol.
- Add authenticated System Pulse hardware observation API and device health view with no invented readings.
- Add privacy/security docs, repository publishing hygiene, expanded unit tests, and updated Debian packaging.
