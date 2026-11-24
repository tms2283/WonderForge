# WonderForge 2027 — Engineering v0.5 release notes

**Date:** 23 November 2026. **Hardware target:** one shared Raspberry Pi 4 Model B, 4 GB RAM. **Status:** installable engineering preview; *not* a proven bootable custom operating system.

## The improvements that materially change this release

### A credible user privacy boundary

- The previous localhost-only separate-port design was insufficient: another Unix account could reach the other account's port. Production `server.py --user-port` now requires a signed one-use 40-second ticket from the child account's private 0600 key and exchanges it for a 10-hour HttpOnly/SameSite-Strict browser session.
- Every `/api/` read and write requires that session. The entry URL immediately redirects to `/`, making the one-use token disappear from the browser address bar.
- The real Linux username determines the workshop. UI portraits do not impersonate another Unix user.
- `~/.local/share/wonderforge/workshop.sqlite3` stores projects, quest progress, block blueprints, logic programs, experiment configuration, and chat in a 0600 database beneath a 0700 directory, as a separate copy from browser localStorage.
- State keys, request size, total storage size, app commands, Team Forge shared records and HTTP origins are checked. The local service uses `UMask=0077`. Sharing always requires a deliberate copy.

**Limit:** compromised browser code or software operating as the **same Linux user** can access that user's own files; a root or physical attacker can bypass these boundaries. This isn't a professional security certification, and the optional network guard is not a complete parental-control system.

### Learning that works without a network connection

- 18 original offline science/engineering lessons across six ForgeVerse regions. Every lesson includes a concept, practical activity, evidence to record, a safety note, and suggested follow-up.
- Two local science tools: an LED resistor current/power model and a simply-supported beam deflection/stress model. Adjustable controls, visually explained outputs, and direct lab-notebook creation.
- ORBIT retrieves matching local lessons using keyword rules, identifies the source, and does not invent a generative model.
- Existing 20 quests, 12×12×8 block editor, 7×7 robot logic programming challenge, downloadable blueprints and Team Forge sharing remain.

**Limit:** these are idealized educational models. They cannot certify a physical circuit or structure. An adult supervises real tools, electronics and mechanics.

### Better deployment and recoverability

- Debian application-only package remains no-side-effect on installation. User accounts, passwords, LAN policy and autostart require a separate explicit adult operation on a Pi 4B.
- System installer now refuses symlinked install/shared paths before mutating them. Child home directories stay private; app is root-owned.
- The Luanti launcher points directly at the child's locally installed `WonderForge` world using the documented `--world ... --go` arguments, if that world exists. It cannot run arbitrary shell commands.
- Custom-image firstboot no longer **automatically creates child accounts**. It only stages app files, requiring adult initial OS login and deliberate provisioning. The image-builder recipe is still experimental, and no bootable image is supplied.
- The family backup tool can create a SHA-256 receipt and validate archive entry paths before marking the archive complete. It does **not** encrypt archives or automatically restore/overwrite the kids' home folders.
- New read-only `tools/pi4-benchmark.py` measures CPU percentage, available RAM, temperature and throttling on the actual device. It explicitly marks x86 development samples as not real Pi measurements.

## What we tested on the development host

- **34 Python unittest cases passed**, including independent math reference checks, private API security, one-use ticket replay refusal, cross-site write rejection, SQLite state, original lesson data, backup-integrity policy, installer default safety and image recipe structure.
- Chromium/Playwright browser flows passed for the Linux-session simulated desktop and mobile Team Forge experience. Separate visual checks exercised Physics Lab, Field Guide, ORBIT lesson retrieval and mobile layout.
- JavaScript syntax, shell syntax and Python compilation passed.
- The Debian package is assembled from source and can be unpacked and smoke-tested; this proves the payload layout, not native Pi graphics/gameplay.

## Must still be verified on a real Raspberry Pi

1. A real physical Pi 4B first boot with a spare 64-bit OS card/SSD; official greeter and adult admin login.
2. Running the installer, setting unique passwords for both children, logging out and into each account and checking that neither can read the other's data or `sudo`.
3. Loading original Luanti world and discovering all six islands and portals in an actual Luanti ARM64 runtime, with frame rate and memory testing.
4. Launching selected actual ARM64 creative applications and confirming app windows return to WonderForge.
5. Running `tools/pi4-benchmark.py` while idle, in browser and in Luanti; recording temperatures and throttling.
6. Exercising optional network guard installation **and rollback**, plus the family's backup-and-recovery plan.
7. Accessibility review with real users; keyboard-only and reduced-motion controls are not a substitute for full audit.
8. Building the experimental OS image on a privileged native ARM64 host with the official image-builder, flashing a spare card, and testing from cold boot. **No physical image build or boot verification has occurred.**

## Recommended first installation

1. Preserve the current working card/SSD unchanged.
2. Use a spare SD card or SSD with official Raspberry Pi OS Desktop **64-bit Trixie**, create an **adult administrator** account, update OS and verify that ordinary desktop applications run.
3. Transfer the `.deb`; run `sudo apt install ./wonderforge-os_0.5.0_all.deb`. This installs no child accounts.
4. Preview provisioning with `sudo bash /opt/wonderforge/installer/system-install.sh`. If ready, execute `sudo bash /opt/wonderforge/installer/system-install.sh --apply --admin-user=ADULT_USERNAME` and `sudo passwd atlas` / `sudo passwd nova`.
5. Disable Pi OS desktop autologin, log in separately as each child, open WonderForge from the Applications menu and complete the QA checklist. Curated apps are installed separately with an adult's consent.

For detailed instructions, see [Family quickstart](QUICKSTART-FAMILY.md), [Security](SECURITY-AND-FAMILY.md), [Deployment](PI4-INSTALLATION.md), [Recovery](RECOVERY-v0.5.md), [Pi benchmarking](PERFORMANCE-v0.5.md), and [QA report](QA-REPORT-v0.5.md).
