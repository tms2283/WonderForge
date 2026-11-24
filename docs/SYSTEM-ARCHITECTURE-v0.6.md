# WonderForge architecture and trust boundaries

## Deployment scope

A Debian package of Python standard-library backend, browser UI, JSON catalogs, artwork and Luanti world. It is **not** the operating system kernel or a custom distribution. The optional image-builder path is exploratory and requires a real ARM64 build machine with mount namespace capabilities.

## Components

```text
Raspberry Pi OS 64-bit (adult administrator)
  ├─ Linux account atlas (private home 0700)
  │   ├─ Browser running WonderForge (static app + cookie)
  │   ├─ wonderforge-launch (single-use ticket)
  │   ├─ Per-UID localhost HTTP service (Python standard library)
  │   ├─ ~/.local/share/wonderforge/workshop.sqlite3 (0600)
  │   └─ ~/.minetest/worlds/WonderForge (local world)
  ├─ Linux account nova (equivalent, independent)
  ├─ /srv/wonderforge/team (group-writable explicit shared copies)
  └─ /opt/wonderforge (root-owned, no writable children)
```

`server.py` serves an exact static route allowlist. Production API endpoints require a short-lived single-use ticket exchanged for an HttpOnly SameSite cookie. A different localhost port is **not** the security boundary. Cross-site POST attempts and oversized JSON are rejected. The server may launch only fixed, root-owned, non-group-writable system binaries, using fixed argv and no shell. The child account is not an administrator.

## State model

Legacy prefixes are preserved for compatibility: `wf-reforged:v3:`; future data migrations must be additive or versioned. SQLite `state` table holds JSON-encoded private keys (quests, projects, blocks, logic, labs, chat, journal, prefs). Team Forge JSON objects are written with exclusive creation and no symlink following. A copy shared by one user is intentionally visible to both team-group members.

The Maker Journal records a hypothesis, fair-test method, observation and conclusion. The browser sanitizes records and imports; the backend constrains valid state keys and storage limits. This is **not** grading and does not validate measurements or physics claims.

## Diagnostics

`device_health.py` reads the local machine's `/proc/meminfo`, load averages, optional thermal zone and `vcgencmd get_throttled` where available. GET `/api/health` is authenticated in production. A requested reading is an observation, not a benchmark. Temperature and throttle values can be null; missing values remain absent. The UI must display a clearly labeled development host when it is not running on the Pi 4B.

## Attack surface and remaining risks

- A compromised adult/root account can access child files. This model does not protect against malicious root.
- The demo server is intentionally unauthenticated and must not be used for child accounts or a shared browser with sensitive data.
- The local browser session holds a cookie; lock the desktop when switching users. The current app does not enforce desktop auto-lock, bedtime limits or web filtering.
- Restricted offline nftables rules may not capture every privileged-process side effect. The adult must verify the firewall on the actual Pi.
- Software installed by apt has its own risks and licensing. WonderForge does not replace package maintenance.

## Architecture success criteria

- Real Linux logins keep private data isolated across reboots and during browser cache deletion.
- Explicit team sharing works but cannot disclose private non-shared notebooks.
- No executable launches from arbitrary user-supplied identifiers or shell commands.
- All personal state has a backup and documented restore path; install/upgrade cannot wipe a world.
- Pi 4B idle/interactivity/resource measurements meet targets defined in the acceptance plan on real hardware.
