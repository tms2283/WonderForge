# WonderForge Reforged 2027 — Complete Design and Engineering Blueprint

**Prototype build 0.3 · November 22, 2026**

The combined master reference covers actual runnable code, UX design, hardware engineering, test evidence and honest limitations.


---

<!-- From README.md -->

# WONDERFORGE REFORGED — Prototype 0.3

**Make the impossible possible.**  A cinematic, offline-first, interactive maker environment designed for **one shared Raspberry Pi 4 Model B (4 GB RAM)** and two home-educated brothers (11 and 13). This is a functional **browser-based OS experience prototype**, not a bootable operating-system distribution.

![Mission Control](previews/A-01-Mission-Control.png)

## Start it

Prerequisites: **Python 3.9+**, an installed graphical browser (Chromium recommended), and a computer or Raspberry Pi with enough free space for approximately 15 MB. No Node, npm, game engine, cloud key, paid API, database, fonts, or internet connection is required to run the app.

On macOS, Linux, or Raspberry Pi OS:

```bash
cd WonderForge-OS-2027-Reforged
python3 server.py
# Open http://127.0.0.1:8765/ in the same device's browser
```

Or use `bash start.sh` to start the local server and attempt to open a browser. **On Windows**, double-click `start-windows.bat` if Python 3 is installed; close its command window to stop the server. Press `Ctrl+C` to stop it. This server listens on **127.0.0.1 only**, not the local network. It has no authenticated upload, command execution, remote-control, or write endpoints. Internet connections are not required.

If port 8765 is occupied, use `python3 server.py --port 8766` and open `http://127.0.0.1:8766/`.

An optional user-level desktop shortcut installer is provided. **The default is a dry run:**

```bash
bash installer/install.sh
# Inspect the printed source, target, and shortcut locations.
bash installer/install.sh --apply
```

It installs **only the current web prototype for the user who runs it**, not the entire Raspberry Pi OS distribution, external creative applications, or child-safe system settings. It does **not** use sudo or modify the bootloader. Make sure an adult chooses the installation location on the shared device.

## Experience map: 13 experiences (gateway + 12 destinations)

| Screen | What works in prototype | Planned OS-level integration |
| --- | --- | --- |
| Workshop Gateway | Three distinct workspaces: Atlas, Nova, Team Forge | Real OS users and a shared protected folder |
| Mission Control | Illustrated home, dynamic stats, mission and quick launches | Real app integration, content and hardware status |
| ForgeVerse | Six interactive destination markers, regional missions | Real Luanti world and collaborative builds |
| Pocket Builder | 12×12×8 canvas, 6 materials, rotation, layered voxel placement, undo/redo, example and JSON exchange | Asset pipeline into Luanti or real CAD formats |
| **Robot Logic Lab** | **Playable 7×7 robot coding puzzle with step-by-step execution, obstacles, energy pickup, debugging, and saved program** | Multiple levels, block programming curriculum, simulated robotics |
| Quest Atlas | 20 original STEM/creative quests, step lists, hints, progress | Offline content packs and performance-appropriate apps |
| Creation Studios | Nine studio directories with first-project ideas and installation disclosures | Reliable launcher integrations after Pi 4 validation |
| ORBIT | Offline scripted prompts for engineering, science, art, programming, and experimentation | Optional AI model on a different device, no background heavyweight Pi 4 LLM |
| Project Vault | Notes, create/edit/delete, JSON backup/restore | Linux home folders and secure backups |
| Discovery Library | Six research categories and guided questions | Licensing-reviewed Kiwix/Kolibri content packs |
| Team Forge | Shared browser workspace, role timer, collaborative prompts | Explicit shared file permissions and real multiplayer |
| Parent Desk | Family guidance, progress summary export and security disclosures | Adult-only enforced settings and secure parental controls |
| Settings | Themes, reduced motion, profile switching, explicit capability disclosure | Real device configuration and accessibility controls |

The current route list has **12 dock destinations plus the initial workshop gateway**, and each route is reachable in the local app. Use `Ctrl+K` (or `Cmd+K`) to jump between destinations, and `Esc` to dismiss dialogs.

## What makes this edition different

Previous editions leaned on traditional dark dashboard cards and abstract decorative planets. Reforged replaces that with a cohesive **adventure-first environmental language**. The Aether Citadel is both the login art and the concept world's hero scene, not a generic stock background. Typography, palette, iconography, controls, content hierarchy, atmosphere, and editor mechanics are aligned. The 3D-looking isometric builder and robot game are actual Canvas/DOM interactions, not static picture placeholders.

There is no dependency on online UI frameworks or external font CDNs. Landscape assets are bundled in optimized WebP images. The browser only redraws the voxel canvas when a user changes it; there is no continuously running 3D engine or GPU-heavy shader. CSS motion is reduced if the device or user requests it.

## What it is *not*

This point matters because the target users are children and the device is shared.

- **Not a bootable replacement operating system.** The Python server + browser provides a concept and functional UI; it doesn't replace Raspberry Pi OS, boot from SD, configure displays, or install driver support.
- **Not secure accounts.** Atlas, Nova, and Team Forge are localStorage namespaces within one browser. Anyone who can access the same browser profile may see or change the prototype data. Do not put private information in notebooks.
- **Not an installed app launcher.** The software matrix describes applications and their likely integration paths; it does not run or confirm installation of any named program.
- **Not a 3D multiplayer game.** ForgeVerse is currently a story map and quest hub. The physical Luanti game world is a future feature.
- **Not generative AI.** ORBIT is a deterministic scripted keyword helper; it neither interprets arbitrary plans nor accesses files, devices, accounts, or APIs.
- **Not enforced parental controls.** Parent Desk is an informational design, not a filter, login gate, permission system, or browser policy manager.
- **Not a physical Pi benchmark.** All cited performance considerations are design targets; real measurements require the brothers' Pi 4B.

## Local data and controls

All profile data lives in the browser's `localStorage` under the namespace `wf-reforged:v3`. It holds each workspace's project notes, quest completion, builder blueprints, chat history, and Logic Lab programs. A single **shared browser profile can expose all those records**. Browser clearing or private mode may destroy them.

Export projects from the Vault and blueprints from Pocket Builder as JSON before moving devices or clearing browser data. Import is schema-checked, size-limited, and validates known materials and grid coordinates. A local family progress summary is also exportable.

## Project structure

```
WonderForge-OS-2027-Reforged/
  README.md
  server.py                  read-only, loopback-only static server
  start.sh                   Linux/macOS/Raspberry Pi startup
  start-windows.bat          optional Windows launch shortcut
  web/
    index.html               app shell, welcome gateway, SVG icons
    styles.css               responsive visual system, reduced-motion support
    app.js                   routes, persistence, 2 hands-on maker tools
    assets/                  original AI-generated environment art (WebP)
  data/
    quests.json              20 original mission briefs
    apps.json                9 studio directories with availability notes
  design/
    tokens.json              semantic visual design tokens
  docs/
    DESIGN-SYSTEM.md         detailed design language and interaction rules
    PI4-ROLLOUT-PLAN.md      practical future OS engineering stages
    QA-REPORT.md             verification record and limitations
    CONTENT-AND-ASSETS.md    disclosure and third-party software notes
  installer/
    install.sh               dry-run first, user-level shortcut only
  tools/
    doctor.py                read-only hardware/program diagnostic
  tests/
    test_project.py          seven unit/HTTP/contract tests
  previews/                 real Chromium captures
  MANIFEST-SHA256.txt
  LICENSE
```

## Developer checks

```bash
python3 -m unittest discover -s tests -v
node --check web/app.js                 # optional, if Node is installed
bash -n start.sh installer/install.sh   # syntax check, if Bash available
python3 tools/doctor.py                # read-only Pi reconnaissance
```

Visual browser tests were run in Chromium using the actual app DOM, CSS, JavaScript, and bundled local catalogs. Due to the testing sandbox's browser network restriction, browser screenshots were captured with local catalog reads simulated by returning the exact JSON files and local image URLs replaced with the identical asset bytes embedded as data URIs. They are **actual rendering of working UI code**, not fabricated design mockups. The real server was independently exercised using Python HTTP requests. The Pi 4B itself has not been tested.

## Next real engineering milestones

1. Validate fresh 64-bit Raspberry Pi OS on the physical Pi 4B, including display, browser, GPU and memory behavior. Avoid making an untested OS image the boys' only boot medium.
2. Establish distinct **standard Linux user accounts** and an explicit group-owned shared project directory. Keep a separate administrator account and recovery/backup process. A browser's profile chooser does not substitute for OS permissions.
3. Integrate WonderForge in an ordinary desktop session first. Evaluate a kiosk-like shell *only after* usability, task switching, emergency recovery, and accessibility tests.
4. Add the Luanti game, original content, and a safe export/import bridge, with correct licenses and measured performance.
5. Integrate approved ARM64 education apps. Put installation and any online asset acquisition under adult control.
6. After repeatable functional Pi testing, build a custom image with Raspberry Pi's [rpi-image-gen](https://github.com/raspberrypi/rpi-image-gen) and add automated smoke tests. As of November 2026 the tool is under active development; pin a tested revision rather than assuming future syntax.

The extensive directions live in `docs/PI4-ROLLOUT-PLAN.md`. Figma's Reforged page carries editable layouts and separate scene artwork, while the HTML package remains the **runnable source of truth**.

## Sources and rights

Original application code and original instructional content are MIT-licensed under the included `LICENSE` to the extent authored for this project. Fantasy scenery is generated artwork provided with the project; usage remains subject to the applicable image-generation service terms. App names, third-party tools and trademarks remain their owners' property. No external games, copyrighted textbooks, music samples or proprietary font files are redistributed in this package.

**A school day should end with something made, not just another hour of scrolling.**


---

<!-- From docs/DESIGN-SYSTEM.md -->

# WonderForge Reforged — Visual Design & Interaction System

## Product thesis

The primary design problem is not getting two young people to click educational shortcuts. It is creating a **place they want to inhabit**, where every place is a doorway to genuine making and learning, and where a shared machine remains a shared asset rather than a source of friction.

The reference experience is an imaginative **invention station**: a bridge between a premium science-fiction adventure, a modern creative suite, and a practical Raspberry Pi desktop. Avoid the tropes of both conventional school portals (primary colors, worksheets, progress badges everywhere) and inaccessible productivity dashboards (tiny icons, metric cards with no clear action). Instead use *one compelling world*, clear choices and real tools.

The Aether Citadel is a fictional symbol of possibility, not a claim that an open-world game is installed. Its monumental ring gate reads as an observatory, architecture reads as structural invention, and workshops/greenhouses/solar arrays suggest sciences behind the fantasy. The artwork serves the specific conceptual hierarchy: dark negative space behind text, bright imaginative world ahead.

## Visual hierarchy

The eye should move through these steps: **identity → story → one primary action → practical next action → small progress note**. The main home screen contains a world-scale visual story, then the action `Explore ForgeVerse`, a nearby option to open a real blueprint editor, and a few meaningful quests. It should not compete with five sidebars or two dozen KPI cards.

A good home screen answers four questions in less than ten seconds: *Whose workshop is this? What can I build now? Where does a world lead? How do I find my saved work?*

## Color and meaning

**Starlight** is the canonical visual mode. Midnight blue (`#08111C`) and deep-blue panels suggest a calm workshop after dark; pale mint (`#81E3D4`) means a safe creative action; warm gold (`#FFE0A4`) means quest/world lore or a visible caution; muted blue-grey (`#A1B5C0`) supports descriptions without dominating. None of these colors alone conveys a safety state: pair them with text and shape.

**Dawn** shifts the experience toward copper and violet for creative variety. **Contrast** strengthens foreground legibility and reduces ambiguity. All themes use the same layout and data. User-selected reduced motion and OS-level prefers-reduced-motion are honored.

Use `design/tokens.json` as the portable specification and matching variables in the Figma file. Tokens are semantic; don't hardcode a new turquoise in every screen.

## Typography

The interface uses system-first sans-serif fallbacks: Avenir Next → Segoe UI → Inter → system-ui. This avoids web font downloads and gives a polished result on many platforms. A real Pi OS build should decide on the shipped, properly licensed OS system font, then recheck line wraps across 720p, 1080p, browser zoom, and display scaling.

Titles use high density, bold weight and slightly negative letter spacing. Avoid all-caps for long descriptions. Micro labels use uppercase and positive tracking only when genuinely serving a functional label. Large page headings are 43 px at desktop; the hero scales to ~72 px; cards use ~21 px. Readable secondary text should normally stay at 12–14 px or larger for children; some 9–10 px engineering chrome is decorative and must not carry essential instructions alone.

## Graphic language

- **Adventure artwork:** coherent original world art, not interchangeable stock photos. In a real OS use assets intentionally for each world and ensure content licensing before redistribution.
- **App icons:** simple consistent line-based 24 px SVGs with no external icon font or giant emoji library. Emoji are acceptable for quest flavor and child-friendly feedback, but not as sole navigational meaning.
- **Surfaces:** rounded only where touch targets or information grouping benefits. Cards 12–14 px; hero 16 px; controls 8–9 px. Avoid arbitrary 32 px radii on every box.
- **System bars:** minimal status, not fake CPU utilization. "PI 4B · 4GB" describes the project target—not live detection.
- **Motion:** hover movement under 3 px and short page transitions; no ambient Three.js rendering; no looping decorative canvas animation.
- **Sound:** no autoplay. Future sound effects must be optional, reduced-volume and mindful of shared spaces.

## Space planning by view

### Gateway

Hero message: **Make the impossible possible.** Three choices: Atlas, Nova, Team Forge. The account tiles are illustrations of intended identity choices; current web keys have no OS-level permissions. In future, OS session choice must be handled securely by a real display manager or equivalent, not browser-localStorage.

### Mission Control

The world is the hero. An actual builder is the adjacent call to action, and progress is subordinate. The right rail offers identity, ORBIT's scripted prototype and the Project Vault. The lower row guides users toward hands-on quests rather than passive viewing.

### ForgeVerse

Use an immersive panoramic world and six region pins with accessible button names. A region panel explains what scientific or creative skill is actually involved and launches a specific quest. A fantasy marker always maps to a genuine learning activity. Do not promise a non-existent multiplayer server.

### Pocket Builder

The work area gets the most space. The material grid and layer slider are adjacent tools, not buried settings. The viewport uses a 2D Canvas draw-on-change iso renderer rather than a heavyweight 3D scene; in the real OS the builder may export to compatible formats once validated.

### Robot Logic Lab

An actual 7×7 path planning task with a target and obstacle cells. Four arrows form a command sequence; the user can run, step, reset, remove, or clear. Instructions are visually distinguishable from results. The app keeps the program for the current workspace and stores a `logic-completed` flag on successful energy + goal completion. Extend the pedagogy with a short reflection: *Where was the first wrong command? Could you write a shorter valid program?*

### Quest Atlas

Missions expose a tangible artifact, learning domain, concrete steps, practical hint, collaboration tactic and optional stretch task. Completion is a personal record, not a coercive streak. Quest details should be printable and independently understandable.

### ORBIT

The current version is a *rule-based prototype*. Its visible label makes that limitation unmistakable. Replies ask users to observe and test rather than claim to magically solve tasks. Future model integration must be optional, explicit about remote transmission, and child-appropriate under adult settings.

### Project Vault

A plain note is still a real creative artifact. A good design makes it possible to take notes after failure. The prototype supports user-created notes, editing and JSON export. In production, a real database or file store should use separate Linux permissions and backups, not common-browser localStorage namespaces.

### Team Forge

Sharing one Pi is a feature, not a defect. Alternate **Driver** (controls the machine) and **Navigator** (checks goals, proposes tests), with a timer that can be paused. A collaborative workspace has shared projects, and individual workspaces remain separate once real Linux accounts are implemented.

### Parent Desk

Family controls must be honest: explanatory here, enforced later. Its language promotes reading, service, scientific accuracy, technical safety and curiosity. Religious and ethical reflection should be family-led, not interfere with evidence-based inquiry, and avoid turning science into slogans.

## Responsive behavior

**Desktop (1600×1000):** full labeled left sidebar, large 930 px panoramic story image, 294 px context rail. **Compact desktop (1180–1450):** narrower rail and context card, reduced hero font. **Tablet (<900):** stacked content and optional condensed navigation. **Mobile (390×844):** a slide-in sidebar with a clickable scrim underneath it, stacked calls to action, no horizontal overflow and reduced heading sizes. Pi target is generally a monitor, but mobile is useful for reviewing and sharing concepts.

Do not confuse responsive layout with Pi performance. Real UI latency must be measured on the physical device with its browser, compositor and storage. A screenshot cannot prove 60 fps or smooth scrolling.

## Interaction quality bar

Every control must do what its label says. A door that says **Enter** must open a relevant destination, not a blank screen. A launcher that isn't installed must say it is informational. A "Completed" action must persist in the correct workspace. A builder input must survive refresh. Importers must reject unexpected schema, oversized files, unknown materials and invalid positions. `Ctrl+K`/`Cmd+K` should open global navigation and `Escape` should dismiss overlays.

No dangerous actions or background installations are triggered by UI demo buttons.

## Why this should feel different

The important shift is from **an education dashboard wearing game colors** to **a game world that leads into real invention**. A polished story makes exploration attractive; the functional tools ensure the educational benefit continues after the spectacle. The quality measure is whether the brothers can finish a session with a saved blueprint, successful logic program, scientific observation, or team artifact—not whether a screenshot looks expensive.


---

<!-- From docs/PI4-ROLLOUT-PLAN.md -->

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


---

<!-- From docs/QA-REPORT.md -->

# WonderForge Reforged 0.3 — QA Record

**Build context:** November 22, 2026. Primary device target: one shared Raspberry Pi 4B with 4 GB RAM. Test environment was desktop Linux container Chromium in headless mode, not the family's physical Raspberry Pi. No real-device frame-rate, memory-usage, thermals or boot-time measurements are claimed.

## Evidence available in this archive

- `previews/A-00-Workshop-Gateway.png` through `A-12-Settings.png`: real Chromium screenshots of every named view, including the welcome screen.
- `previews/A-03b-Builder-With-Model.png`: actual computed Canvas isometric drawing after adding the example model.
- `previews/A-04b-Robot-Logic-Lab-Solved.png`: actual command sequence and solved robot puzzle.
- `previews/B-*`: responsive Chromium screenshots at 390×844. The mobile navigation overlay was tested after correcting a layer-interception issue.
- `tools/capture_previews.py`: reproducible screenshot capture harness. Because this sandbox blocks browser access to localhost despite successful Python HTTP access, it injects the **exact source HTML/CSS/JS/JSON** into a Chromium page and embeds the **exact bundled WebP art bytes** in CSS data URLs. Storage is modeled as a browser-local in-memory `localStorage` object. This tests behavior and rendering but is not a substitute for a packaged OS end-to-end test.

## Executed automated tests

`python3 -m unittest discover -s tests -v`: **7 passed.**

1. Exactly 20 distinct, structured quests with tangible artifacts and collaboration prompts.
2. Exactly 9 studio entries with software lists and availability disclosures.
3. No external page scripts, external font service, or missing image bundle. Total WebP assets below 2 MB.
4. Distinguishable browser-prototype/OS limitation in JavaScript plus a real logic puzzle and persistence.
5. Local static site serves HTML with Content Security Policy and nosniff headers.
6. Local server serves bundled image and JavaScript.
7. Unknown paths return 404 and POST requests return 405.

`node --check web/app.js`: **passed.**

`bash -n start.sh installer/install.sh`: **passed.**

## Visual and interaction regression runs

A headless Chromium script exercised the actual app DOM and JavaScript. These events were observed to work:

- Workshop gateway presents Atlas, Nova and Team Forge; entering one opens the UI.
- Mission Control features navigation and real quest counts.
- ForgeVerse interactive regions select updated detail information.
- Pocket Builder example loads 76 blocks; rotation, undo, redo and material controls render.
- Quest Atlas shows 20 missions, opens full step-by-step details, and marks completion.
- Studios opens context-specific program disclosures.
- ORBIT accepts a query and visibly returns a corresponding *scripted* response.
- Project Vault creates/saves a genuine note and displays the card.
- Theme switches between modes.
- Ctrl+K opens search and filters destinations; Escape closes it.
- A 12-command Robot Logic Lab solution `RRRUUURRRUUU` navigates (0,6) → (3,3) → (6,0), collects the energy token and achieves status **SOLVED!**.
- Browser console reported **no unhandled page JavaScript errors** in the full-desktop and tested mobile scenarios.
- At 390 px width, `document.documentElement.scrollWidth <= 390`; no horizontal page overflow.
- The mobile scrim is below the slide-in navigation, so it no longer intercepts intended menu clicks.

## Known constraints requiring further validation

- **Physical Pi performance:** unknown until testing on the Pi 4B, especially under CPU throttling, slow SD cards, current Raspberry Pi OS compositor and Chromium package.
- **Canvas pointing:** rotation and example/undo/redo were exercised. Additional hit-test and property-based tests for all cell/layer combinations should be added before production.
- **Browser persistence:** `localStorage` is convenient but not encrypted or protected across OS users sharing a browser profile.
- **Accessibility:** semantic buttons and many accessible labels exist; full screenreader, contrast ratios at all zooms, localization and keyboard-only game tests are not yet completed.
- **Real installs:** native app matrix is a directory and must not be mistaken for installed or Pi-tested launchers.
- **ForgeVerse:** map and missions are working, but Luanti/game integration remains unbuilt.
- **Figma:** editable 1600×1000 design frames are source references. They are not application code, and they may not match real browser layout pixel-for-pixel. The Figma-generated illustrative world image differs from the separately bundled local image.
- **AI and parent controls:** both are clearly presented as demos/intent, not privileged capabilities or safety guarantees.
- **Bootable image:** no `.img` was generated; hardware recovery and image creation remain deliberate future milestones.

## Release status

**Prototype accepted for design evaluation and local browser demonstration. Not accepted for direct bootable-OS deployment or child-account security.**


---

<!-- From docs/CONTENT-AND-ASSETS.md -->

# Content, third-party software and asset provenance

**Original art bundled in this prototype:** `aether-citadel.webp` and derived crops `citadel-focus.webp`, `sky-archipelago.webp`, `ancient-observatory.webp`, `landscape-river.webp`. They come from one generated cinematic environment asset made expressly for this edition. The same generated scene is used across related screens for visual continuity. There is no external image CDN, hidden remote asset fetch, or embedded stock watermark.

Generated art usage is subject to the terms of the service that generated it; this project does not assert exclusive copyright or a guarantee of similarity clearance. Only share or redistribute it after reviewing applicable terms and the target user's rights.

**Figma design:** The connected Figma project has a separate generated scene because the available environment could not POST local image bytes to the Figma upload endpoint. That additional Figma generation consumed Figma AI credits. The editable Figma layers are illustrative of the runnable app, while the locally bundled asset is the app's actual visual source. Do not call the Figma background the exact original image.

**Icons and typography:** The app's app/navigation artwork uses inline SVG paths and standard Unicode symbols. No external fonts or proprietary font files are included. Rendering of emoji varies with the system, so icons and text labels carry core meaning. All interface source code is packaged as text.

**Third-party apps:** Luanti, Thonny, Python, Scratch, Krita, GIMP, Inkscape, OpenSCAD, KiCad, Stellarium, Audacity, Godot, Blockbench, Kiwix, Kolibri, etc. are represented in the application directory only. Their names do **not** mean that they are installed, approved for a particular Pi OS version, or bundled in this archive. Respect licenses, trademarks and update channels of each publisher before inclusion in an actual image.

**Missions:** The 20 quest briefs are original educational prompts. Hardware experiments require suitable components and adult oversight. Third-party reference books, courses and media are not shipped. Do not download a random third-party content pack into a child-visible image without licensing and safety review.

**Generated project code:** Original prototype code and educational content are distributed with MIT license text, to the extent authored as part of the project. That does not relicense third-party apps, trademarks, scientific references, image service outputs, or any user's later saved content.

**Sources consulted for implementation planning:**
- https://www.raspberrypi.com/documentation/computers/
- https://github.com/raspberrypi/rpi-image-gen
- https://www.luanti.org/
- https://www.raspberrypi.com/software/
- https://thonny.org/
- https://www.kiwix.org/
- https://learningequality.org/kolibri/
- https://refero.design/
- https://recent.design/

Research sources are informational; no third-party site's content was downloaded into the executable prototype.


---

<!-- From docs/FIGMA.md -->

# Editable Figma system

The connected Figma document is:

https://www.figma.com/design/jKaRG95zeSfYndzreJxPGU

Open the page **REFORGED 0.3 · CINEMATIC SYSTEM**. It contains 13 full desktop frames: gateway plus 12 destinations including the Robot Logic Lab. The main layouts, labels, controls, icons, game grid, material tiles, and scenery overlays are made of editable text, rectangles, vector/polygon shapes and reusable instances; the world art is a **discrete image layer**, not a flattened raster of an entire interface.

Design variables: **Reforged / Semantic** has Starlight, Dawn and Contrast modes. **Reforged / Spacing** contains the consistent spacing scale. This is a starting design system, not a complete production-ready component library.

To make the art accessible in Figma, a separate scene was created with Figma's image generation feature; **this consumed Figma AI credits**. The local browser project contains its own original bundled environment image because this runtime could not reach Figma's asset-upload endpoint from the container. Expect artistic differences across the two sources. Use the browser prototype for behavioral truth and the Figma pages for editable visual exploration.

Import existing app changes back to Figma by updating the text and layout layers, not by covering the frames with screenshot images. For real native OS work, first resolve the Pi 4 test benchmarks and the user account model.
