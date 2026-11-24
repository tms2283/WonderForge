# WonderForge v0.5 · Honest Raspberry Pi 4B Performance Plan

## Hardware budget

One Raspberry Pi 4B with 4 GB RAM, shared by two brothers. No Pi 5 GPU performance, PCIe AI HAT, or large always-running language model is assumed. The desktop combines bundled compressed artwork, plain JavaScript, CSS, HTML and Python's built-in HTTP server. Luanti and actual engineering tools run as separate Linux processes when the user chooses them.

## Measurements rather than fabricated numbers

Run the **read-only resource sampler** on the actual Pi:

```bash
python3 tools/pi4-benchmark.py --duration 60 --interval 2 --label idle-desktop --json-out ~/Desktop/wonderforge-idle.json
python3 tools/pi4-benchmark.py --duration 60 --interval 2 --label wonderforge-browser --json-out ~/Desktop/wonderforge-browser.json
python3 tools/pi4-benchmark.py --duration 60 --interval 2 --label luanti-gameplay --json-out ~/Desktop/wonderforge-game.json
```

The sampler reads `/proc/stat`, `/proc/meminfo`, optional thermal sysfs and optional `vcgencmd get_throttled`. It does not monitor network activity, collect personal files, use third-party libraries or contact the cloud. You must **manually open** the relevant app or Luanti world before starting each measurement. It does **not measure actual FPS**; inspect Luanti's own statistics and record game responsiveness manually. x86 host measurements explicitly say `is_real_pi4b: false`.

### Suggested acceptance gates — targets, not measured results

- A genuine Pi desktop and WonderForge experience should remain usable with no repeated out-of-memory process kills while switching screens or editing blocks.
- Check there is reasonable `MemAvailable` headroom. If it consistently approaches zero, reduce image sizes, disable unused apps, or close Chromium while gaming. Do not mask the result with swap thrashing.
- No persistent thermal or low-voltage throttling during 15-minute real workloads; inspect the `throttled_bits` output and use correct power and ventilation.
- Verify screen readers/keyboard flow and reduced motion where needed. A beautiful image is not a proxy for accessible UX.
- Record observed app start delays, Luanti loading stability, USB storage behavior, and reboot-to-login reliability over multiple runs on the Pi.

## Performance adaptations

Prefer native 64-bit Pi OS graphics drivers, hardware-appropriate resolutions, compressed pre-rendered images, short animations and one heavy creation tool at a time. A Pi 4B's 4 GB of RAM is finite. The OS builder recipe must not run background ML inference by default; ORBIT's retrieval is intentionally lightweight. Avoid installing every suggested heavyweight creative program at once before confirming free storage and swap settings.

## Completion standard

This release provides a *measurement harness* but **zero genuine Pi 4B benchmark samples**. Passing x86 browser tests is not evidence of Pi GPU driver, gamepad, audio or heat behavior. Keep a log of both successful and failed hardware checks.
