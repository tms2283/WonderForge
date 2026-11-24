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
