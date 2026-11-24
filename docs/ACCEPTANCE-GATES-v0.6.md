# Raspberry Pi 4B field acceptance gates

**Target:** one physical Raspberry Pi 4 Model B with 4 GB RAM, latest tested Raspberry Pi OS Desktop 64-bit Trixie, separate adult and child logins, fresh spare SD card/SSD. This document is a test plan, *not* a record of tests already performed.

| Gate | Procedure | Pass evidence |
| --- | --- | --- |
| A: Safe installation | Back up current Pi, dry-run `system-install.sh`, inspect changes, provision only on spare media | Installer logs; no change to old boot card |
| B: User separation | Create two Linux user logins, make a personal journal in each, clear browser cache/reboot, switch account | Private journal reappears only in correct login, no access from other login |
| C: Team sharing | Explicitly share blueprint and notebook; confirm both can see team copy | Both see shared copy; personal original remains private |
| D: Real app launcher | Install Luanti and Thonny with adult approval, launch from studios | Actual windows appear under child UID, not root |
| E: Luanti world | Enter all six regions, complete in-world quest, save and resume | Screenshot/recorded quest results; no mapgen errors |
| F: Memory and thermals | Sample idle, Portal+Builder, Portal+Lab, Portal+Luanti separately for 10 minutes | Actual System Pulse logs, free memory, throttle register, measured gameplay FPS if available |
| G: Offline handling | Disconnect network, use portal, journal, world, lessons; attempt optional approved app | Core experience works; any unavailable program disclosed honestly |
| H: Recovery | Export journal/project backups, restore into a clean user, reboot | Data intact; no symlink/path traversal accepted |
| I: Accessibility | Keyboard-only navigation, readable focus, reduced motion, mobile/narrow fallback | No inaccessible key control or horizontal overflow; adult can adjust text |
| J: Image recipe | Build `.img` on capable ARM64 host, boot spare medium | Actual boot and login verified; only then label image boot-tested |

**Stop immediately** on file loss, unsafe child permissions, hot hardware/throttling, failed power/voltage checks, or unexpected network access. Keep a known-good official OS card for rollback.
