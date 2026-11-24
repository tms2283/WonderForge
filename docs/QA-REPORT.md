# WonderForge Reforged 0.3 — QA Record

> **Historical prototype QA only.** For the current engineering integration edition, see [QA-REPORT-v0.4.md](QA-REPORT-v0.4.md).


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
