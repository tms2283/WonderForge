# Engineering the Real WonderForge OS on One Raspberry Pi 4B (4 GB)

## Scope and operating assumptions

Two brothers aged 11 and 13 currently **share one Raspberry Pi 4 Model B with 4 GB RAM**. The primary plan is to make that hardware feel extraordinary without pretending it can run modern workstation graphics, a local 30B language model, or multiple heavyweight desktop sessions in parallel. Real-time child multiplayer should be treated as a possible later feature rather than a prerequisite for a joyful shared workstation.

The deliverable here is only the interactive web prototype. The steps below are an intentionally **gated engineering program** for a bootable distribution. They are *not* instructions to overwrite the family's only boot medium without backup.

### Phase zero: inventory and establish a safe baseline

Adult operator should record the actual Pi revision, SD/SSD model, current OS build, display resolution, connected controllers, audio devices and any existing family data. Run `python3 tools/doctor.py` for a read-only snapshot. The tool reports hardware/architecture, approximate free storage, OS, Python and program presence; it cannot prove package compatibility or graphics performance.

Before changing boot media: back up the complete existing data and check that the backup can be read from a different device. Keep a known-working image/card untouched. Plan experiments on a separate high-quality storage device. Verify the power adapter, active cooling (if used) and stable USB peripherals. Make sure both brothers can recover to a known-working desktop without relying on an AI tool or network connection.

### Phase one: real OS and account isolation

Start from a verified, current **64-bit Raspberry Pi OS** install for Pi 4B. Do not assume a particular release's package versions or `rpi-image-gen` YAML syntax without checking the exact upstream revision; the design research snapshot is November 2026. Update using the official OS documentation and security policy appropriate at installation time.

Design the user model as:

```text
Family Pi 4B
  adult-admin             administrative owner, password/private config
  inventor-atlas          standard user, own Home and project data
  inventor-nova           standard user, own Home and project data
  wonderforge-share       Unix group for shared projects (not a login)
  /srv/wonderforge/shared-projects/
                          group-owned, explicit allowed access
```

The account names here are **illustrative**, not fixed requirements. A child should not have automatic `sudo` or unrestricted `polkit` privileges. Configure shared directory group ownership, default ACLs if necessary, umask, directory inheritance and backup permissions deliberately. Avoid globally writable folders. Test both **positive** and **negative** permissions: Alice can create personal work, Bob cannot read it by default; both can access the intended shared folder; neither can read adult configuration; no unexpected symlink or mount bypass. Profile selection belongs to the actual desktop or login manager. Do not call the browser profiles secure once real accounts exist.

### Phase two: an integrated desktop shell, not a fragile kiosk

Install the WonderForge prototype in a system-owned, non-writable application directory after code review, for example `/opt/wonderforge` or under `/usr/share/wonderforge` with correct permissions. Run the loopback server as a dedicated non-privileged process, or place the static files behind an approved local webview. Establish a desktop launcher, menu entry and graceful stop behavior. Avoid root-owned browsing processes.

A child must always be able to minimize the WonderForge experience, change to needed native software, manage a normal file dialog and recover after browser crashes. If a dedicated launcher shell becomes desirable, make it an **opt-in layer on top of an ordinary desktop session**. Test keyboard input, screenreader/basic accessibility, file pickers, app switching, logout, low battery/peripheral disconnects and safe shutdown before trying fullscreen/kiosk mode.

The prototype's `server.py` intentionally exposes only known resources and rejects unknown URLs, POSTs and remote binding. That is a safe demonstration, but it is not a production authentication or authorization layer. The real app must use file permissions or an explicit authenticated service for any writes, with careful audit of path traversal and IPC.

### Phase three: practical, measured performance

Use the physical Pi 4B as a performance gate. Record **idle memory**, browser memory, app-launch latency, UI frame latency, CPU temperature and memory pressure after realistic 30–60 minute sessions. Compare the display at 720p and 1080p (or the family's current display resolution), and confirm thermals remain safe under the actual case and cooling.

An initial observational matrix:

| Scenario | What to measure | Failure that blocks release |
| --- | --- | --- |
| Startup into normal desktop | time to usable desktop, CPU, RAM | login loop, black screen, runaway background service |
| Opening WonderForge | first usable interaction, art decode, browser memory | long freezes, crashes, missing fonts/assets |
| World map → Quest Atlas → Builder | navigation responsiveness, input latency | unresponsive clicks, lost saves, frame stalls |
| Build 100–200 voxels | input-to-render time and correctness | frequent misses, sustained high CPU, corrupted blueprint |
| Running Logic Lab | correct ordered commands and visible status | skipped commands, impossible goals, broken undo/reset |
| Opening native apps | launch latency, multi-app memory pressure | unusable swap thrash, browser crash, data loss |
| Luanti + WonderForge | FPS, memory and recoverability | freezes, unsaved progress, frequent thermal throttling |
| Offline with network disconnected | startup, quest/library data and saves | blank app or required cloud sign-in |

Do not cite invented FPS, memory figures, battery capacity or boot-time claims. The prototype is designed to be light, but *not yet benchmarked on their Pi*.

### Phase four: connect actual tools and honest launchers

Prioritize tools that work well with a Pi 4B and real curricular tasks. Core candidates: Luanti, Thonny/Python, Scratch where available, Inkscape, GIMP, Stellarium, Audacity, OpenSCAD and selected hardware-appropriate engineering apps. Treat heavier options such as complex Blender scenes, some Godot renderers and large CAD assemblies as **conditional** until profiled.

Each application integration should have a record of the official source, ARM64 build availability, license, package version pin, download size, memory usage, content requirements, entrypoint/desktop file, offline operation, first-launch behavior and a practical example project. The Creation Studios page currently offers an **accurately labeled directory**, not running launchers.

Add a launcher manifest with a safe allowlist. Launch only known installed programs, never arbitrary shell strings from web UI or AI text. Commands requiring an adult or network access should remain outside the child interface. For native tools, direct file opening should occur through explicit format validation and OS associations.

### Phase five: the ForgeVerse Luanti world

Luanti is the open-source voxel-engine successor to the former Minetest brand. Build a small, original creative world with one starting island and a visible **Invention Station**, then add biomes in slices. An epic six-world map should not become a sprawling, unfinished game that performs poorly on 4 GB hardware.

Suggested milestones:

1. **Slice A — World portal:** install a compatible Luanti release and a license-reviewed game content base. Boot into a flat creative map with the project branding. Confirm rendering on the actual Pi.
2. **Slice B — First quest:** a skybridge challenge with manually testable structures. Add a readable questboard interface that tracks a local progress flag without a persistent online server requirement.
3. **Slice C — Export connection:** import a sanitized portion of a Pocket Builder JSON blueprint into a controlled Luanti creative region. Coordinate axes, palette mapping, maximum volume and collision behavior need a formal schema. Do not allow arbitrary filesystem paths or command execution.
4. **Slice D — Cooperative mode:** shared-machine input modes, switching users between sessions or supported local co-op controls must be measured. A second controller does not automatically make any Luanti game split-screen; do not promise this without specific implementation.
5. **Slice E — Realm expansion:** Robot Wilds, Crystal Deep, Red Frontier, Echo Isles and Code Garden, with scientifically meaningful quest activity in each and measured draw distance/texture bounds.

Store original custom textures and media with clear provenance and license. The visual dream must survive the gap between static environment art and actual game geometry.

### Phase six: ORBIT as an honest helper

The current ORBIT is intentionally a predictable scripted hint system. It is safe to demonstrate entirely offline with negligible model memory usage. A future generative assistant is optional—not a condition of the OS being useful.

On a Pi 4B with 4 GB RAM, prioritize a **non-generative** base experience and optionally integrate:

- an approved remote or household-LAN inference service with explicit adult opt-in and disclosure of what text leaves the device;
- a strictly memory-bounded, Pi-compatible local tiny model only after real latency and thermals are measured;
- no autonomous shell access, unrestricted network crawling, package installations, or exfiltration of project notes;
- a visible "scripted vs. AI" state, clear uncertainty handling and limits on prompts about safety-critical projects.

A child-safe AI experience should ask encouraging experimental questions and encourage primary sources; it should not replace the brothers' actual thinking or claim authority.

### Phase seven: the family content archive

For offline education, investigate official/licensed packs for Kiwix and Kolibri, plus astronomy datasets, public-domain literature, PhET exercises where redistribution is permitted, project templates and open educational resources. **A link in a catalogue is not a bundled offline resource.** Store licenses and per-asset attribution and document update/refresh workflows.

Content curation should be broad enough to support creative, scientific, historical, civic and ethical inquiry without turning the environment into a narrow ideological filter. Christian family practices can inform reflection and service projects while keeping scientific sources accurate and testable.

### Phase eight: integrate parental controls properly

The intended parent desk needs real enforcement by the operating system:

- adult-only administration and protected passwords;
- child standard-user accounts, a tested permission model and backup strategy;
- clear network permissions and content filtering only with a fully specified family policy;
- auditability without invasive secret surveillance;
- graceful failure when network services are unavailable;
- user-facing reminders about data safety, electronics and physical experiments;
- ability to stop or recover the app normally.

Do not present UI mock switches or browser localStorage flags as security boundaries. Test with a separate low-privilege account and deliberate negative tests.

### Phase nine: build and ship a testable image

Raspberry Pi publishes [`rpi-image-gen`](https://github.com/raspberrypi/rpi-image-gen), an actively developed image-generation project. Pin a known tested upstream git revision and reference configuration as part of reproducible CI. Do not guess YAML schemas or image names from a different release. Build on a supported Linux host or CI environment, install dependencies according to the pinned upstream documentation, and create a **staging image** rather than flashing the production card.

Supply an explicit manifest covering OS base, package versions, application assets, launcher entries, user provisioning (avoid shipping default passwords), policy files, preloaded licensed content and image checksum. Automate offline rootfs tests and, if possible, boot tests under a suitable target device or emulator. Final acceptance requires real Raspberry Pi 4B boot tests, graphics/peripheral validation and a rollback image. Publish the installation route as a versioned artifact with release notes and verification checksums.

### Phase ten: ship safely and improve through evidence

A "WonderForge 1.0" release is not the moment everything imagined is built. It is a version that meets explicit acceptance gates: repeatable boot, retained data, responsive navigation, real accounts, genuine software launches, at least one playable Luanti quest, functional offline experience, no background model-induced slowdown, and a tested recovery path. Each additional world should be added behind quality gates, not as an unchecked promise.

This plan deliberately privileges *truthful behavior on modest hardware* over an impressive but fragile checklist.
