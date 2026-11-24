# WonderForge 0.6 quality verification

This report records development-host verification as of 23 November 2026. It is **not** physical Raspberry Pi performance or custom OS certification.

## Automated checks

- **42 Python tests passed**, including API isolation and CSRF, private SQLite state, team sharing, bounded app launches, Luanti launcher arguments, image/installer dry runs, circuit/beam math, original lesson catalogs, Maker Journal validation and backup rejection, System Pulse parsing and authenticated read-only API.
- `node --check` passed for `web/app.js`, `web/journal.js` and `web/labs.js`.
- Shell scripts pass syntax checks; native `dpkg-deb` package build completes with version 0.6.0.
- The user-scope installer has been dry-run/safe-applied with an isolated temporary HOME, and includes the two Python runtime modules required by the server.
- **Browser smoke test passed on development Chromium** using a mocked API: logged into demo Atlas, created a journal entry linked to the Sky Fortress quest, observed evidence metrics, opened System Pulse with explicit development-host label, checked mobile 390px overflow, and recorded no browser JavaScript errors. The browser's sandbox does not allow direct network navigation to local development ports; test fixtures are deliberately isolated and make no claims about Pi hardware.

## Still unverified

- Raspberry Pi 4B 4 GB native boot, runtime RAM and thermal targets, GPU video performance and Luanti world generation.
- Actual separate user-login provisioning and nftables child UID restrictions after reboot.
- SD card/SSD cold-start recovery and custom image-builder output/boot.

## Physical acceptance plan

Run `docs/ACCEPTANCE-GATES-v0.6.md` on the actual device with a spare SD card/SSD and adult supervision. Keep the working OS storage untouched until gates A–J are logged. **Never promote a mock-browser check to a hardware validation claim.**
