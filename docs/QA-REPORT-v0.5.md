# WonderForge 2027 · v0.5 Engineering QA & Release Gates

**Execution date:** November 23, 2026. **Target hardware:** Raspberry Pi 4 Model B / 4GB / Raspberry Pi OS Desktop 64-bit Trixie. **Test host:** x86_64 Linux development container, not a Raspberry Pi. **Status:** 35 passing automated tests; separate frontend flows and Debian artifacts validated.

## Tests actually executed in the development environment

1. `python3 -m unittest discover -s tests -v`: **35/35 pass** (3.2 sec on development host). Coverage includes static HTTP content and security headers, authorized/unauthorized local API requests, one-use HMAC signed portal tickets, expiration and replay refusal, session-cookie attributes, foreign origin rejection, private 0600 SQLite state and quotas, safe cross-account team records, Luanti launcher arguments, original learning catalog structure, idealized LED and beam equation reference values, malicious backup archive entries, service/installer/image source contracts and dry-run behavior.
2. `node --check web/app.js` and `node --check web/labs.js`: pass.
3. `python3 -m py_compile server.py portal_security.py tools/*.py`: pass.
4. `bash -n installer/*.sh scripts/*.sh image/*.sh`: pass.
5. `python3 tools/verify_linux_ui.py`: browser simulated Linux identity behavior, Team Forge notebook, blueprint exchange, approved app launch click, Atlas/Nova session selection, mobile viewport and JavaScript errors all pass. Uses *actual bundled HTML, CSS and JS*, but mocks the external API and runs Chromium headless in the development container.
6. `python3 /tmp/wf_browser_check.py` (in QA environment, not included in release): browser-driven Physics Lab circuit and bridge slider controls, exact idealized outputs, guide filtering, modal lesson, ORBIT source-identified reply, mobile viewport <= 390 px and no JS errors all pass. Screenshots saved to `engineering-previews/03-*`, `04-*`, `05-*`.
7. The package build `bash scripts/build-deb.sh dist` succeeds with `dpkg-deb`; the installed archive includes portal security, offline lessons, STEM calculation script, Pi diagnostics, backup inspector and Luanti world assets. Native Python bytecode caches are excluded for a portable source-only package. Package layout is verified separately with `dpkg-deb --contents`.
8. The dry-run installer and experimental image command do not create accounts or flash disks on the development host. The custom-image build **was not attempted**, since the official builder needs a suitable native ARM64 host with mount capabilities.

## Critical trust boundary fixed since v0.4

The local address `127.0.0.1` can be reached by **other Unix users on the same Pi**. Different ports do not constitute isolation. In production `--user-port` mode, all `/api/` endpoints now require a valid ticket-derived authenticated cookie; the ticket itself derives from each signed-in Unix user's mode-0600 secret and is usable once within 40 seconds. Static assets are not private, but personal data APIs are gated. The test suite proves the unauthorized rejection and positive authenticated workflow **in a development simulation**. Real account separation still requires Pi hardware execution.

`sqlite3` state persistence prevents browser-cache clearing from automatically erasing completed projects, but the SQLite file requires backups. No journaling/durability promise is made against sudden power loss, damaged SD cards or compromise by the same logged-in user.

## Original educational content

- 18 original offline Field Guide lessons, six regions, keyword retrieval, activity and evidence questions, safety cautions.
- Two original simple science models: LED current `I=max(0,V-Vf)/R`, and simply-supported beam midspan `δ=FL³/(48EI)` with rectangular section `I=bh³/12`, single central static load and example elastic modulus. Test anchor values: 5V/330Ω/2V => ~9.09mA; 100N,1m,30×40mm,wood(10GPa) => ~1.302mm. Neither is safe-for-construction or GPIO electrical wiring guidance.
- ORBIT is a scripted resource finder, not a local or remote large language model.

## Packaging and image safety

The `.deb` is a non-mutating app-only payload: it does not create accounts, install all optional creative apps, enable autostart, change network policies or set passwords. The separate installer checks target Pi hardware, OS version and root permissions and is dry-run first. First-boot image staging no longer automatically creates children. The `image/` YAML and scripts are **experimental**, with bootloader/first-user/graphics validation still required on a capable physical image builder and spare media.

`tools/inspect-backup.py` is a read-only archive integrity/path audit, not a restoration test. It rejects symlinks and unusual archive members on purpose; if it rejects a legitimate backup, the backup is **not accepted**. The backup tar.gz is NOT encrypted; only a separately encrypted destination provides confidentiality.

## Unverified conditions — must remain open

- No physical Pi 4B was accessible. **No native Pi install, Linux login, real Chromium kiosk, world load, network guard enforcement, gamepad support or graphics/audio performance measurement was performed.**
- **No flashable `.img` was built, flashed or boot tested**. A source recipe is not proof of an installable OS.
- A launched `luanti --world PATH --go` process was mocked in tests. Luanti mod/mapgen and actual FPS still need real engine testing.
- No professional vulnerability assessment, content-safety certification, or independent accessibility review has been performed. The Parent Desk is not enforceable family-policy UI.
- App dependencies and game mods must be verified against the actual Pi's available Debian package versions and display drivers; installing recommended packages may require substantial storage.
- Family recovery is not fully proven until an adult has tested archive integrity **and recovered selected files to a safe staging computer**, not over the children's active homes.

## Physical acceptance procedure

1. Spare media, adult Pi OS login, updates and recovery card; retain original boot storage untouched.
2. `sudo apt install ./wonderforge-os_0.5.0_all.deb`, preview `/opt/wonderforge/installer/system-install.sh`, approve `--apply --admin-user=ADULT`; set child passwords and disable desktop autologin.
3. Verify `atlas` cannot read `nova`'s home and vice versa; neither is in `sudo`; production `/api/session` is 401 without portal cookie, 200 after `wonderforge-launch`.
4. Test each child's private SQLite persistence across closing/reopening Chromium, and explicit Team Forge sharing between real accounts.
5. Run one real Luanti world for 15+ minutes, each region, portals and saved progress; record FPS, RAM/temperature, and throttling. Use `tools/pi4-benchmark.py` on the Pi for measurement.
6. Test real app launcher through one small app (Thonny) before installing extras.
7. Validate safe backup/checksum/inspector on an encrypted external volume and rehearse selective recovery in staging.
8. Only after passing those gates, consider using the image recipe on a native ARM64 build host. Never overwrite the sole working SD card.

**Classification:** `INSTALLABLE DEVELOPMENT PREVIEW / HARDWARE CERTIFICATION OPEN`. It is not advertised as a completed custom OS distribution.
