# WonderForge Security, Child Accounts, and Family Boundaries

This is an engineering threat model for **one shared Raspberry Pi 4B with two child standard accounts**. The system's aim is to protect personal work and avoid unsupervised network access, while supporting a curious, hands-on experience. It is not a commercial child-monitoring product and must not be represented as one.

## Trust boundary: operating system, not painted interface

The welcome portraits were initially visual profiles implemented by JavaScript/localStorage. That was fine for exploring interaction design, but not for making privacy claims. A browser-local profile selector may be manipulated by anyone using that browser profile. In v0.4 and later, `/api/session` derives the Unix username from the **process effective UID**. If `atlas` is logged in, WonderForge selects Atlas and ignores attempts to enter Nova or the pseudoprofile Team Forge. If the Unix username is `nova`, the reverse applies. The real login chooser is the Raspberry Pi OS display manager, not WonderForge.

Separate home paths `/home/atlas` and `/home/nova` are set to `0700`; each home contains its own browser profile, project localStorage, Luanti world and other files. Both non-administrator accounts belong to the supplementary group `wonderforge`; neither is granted membership in `sudo`, `docker`, `adm` or other privileged groups by the installer. The adult retains a separate normal administrator account with `sudo`. Before installation, the installer refuses to silently normalize a pre-existing `atlas` or `nova` account that has a privileged group; investigate that manually.

Passwords are created interactively by the adult on the actual Pi (`sudo passwd atlas`, `sudo passwd nova`), not passed to ChatGPT or embedded into YAML, sample scripts or images. The account creation script initially locks password logins to avoid an unintentional public/default password. Desktop auto-login must be **disabled** on the Pi. The system installer does not try to guess which Raspberry Pi greeter controls it.

## Shared folder, explicit consent

`/srv/wonderforge/team` is owned by `root:wonderforge`, mode `2770`: the setgid bit means new files inherit the group. The per-user Python API uses group-writable mode `0660` for newly created records. Nothing in `/home/atlas` or `/home/nova` is automatically shared. A deliberate **Share Copy** action creates a new JSON record in the team folder. Shared blueprints are schema checked, bounded to at most 1,152 cells, and only accept six known material identifiers. Notebook notes are size limited. IDs are 96-bit random hex, not paths supplied by the browser. Two brothers can view shared records after signing into their own accounts and refreshing Team Forge. These records can be modified or deleted by other members of the group from Linux, so the group is a **collaboration boundary**, not immutable evidence storage.

**v0.5 storage upgrade:** In an authenticated Linux account, core workspace data (projects, quest progress, blueprints, programming and experiment states) is now also stored in a SQLite file under that account's `~/.local/share/wonderforge/workshop.sqlite3` (mode 0600, directory mode 0700). Browser localStorage remains a fast UI cache. Clearing browser history or its cache should not erase database-backed records; however, deleting the Linux home, database, or an interrupted disk write may still lose work. Export JSON as an independent portable backup and use the adult backup procedure. Demo mode, launched with bare `python3 server.py`, has **no Unix user authentication and no protected cross-user storage**; do not use it to hold children's real private data on a shared account. Backups must be encrypted or placed on an encrypted adult-controlled disk; `scripts/backup-family.sh` itself uses ordinary `tar.gz` and explicitly does not provide encryption.

## Local HTTP and app launching

The server accepts connections only on `127.0.0.1`. The **production `--user-port` mode now authenticates every `/api/` read and write**. `wonderforge-launch` creates a short-lived signed single-use ticket from a secret file (mode 0600 in a mode-0700 private directory). The server exchanges the ticket for a random HttpOnly SameSite=Strict session cookie and immediately redirects to `/` to clear the ticket from browser navigation. An unauthenticated second Unix user connecting to the loopback port receives HTTP 401. The token is held in server memory and expires after 10 hours; restarting the service ends sessions. This does not protect a browser compromised under the **same Unix user**. `--user-port` also derives a distinct local port from the Unix UID. No public Wi-Fi, LAN or WAN listener is configured. The static file table enumerates bundled code, data and media and does not expose arbitrary filesystem paths. Unknown paths and attempts to POST to arbitrary routes fail. All returned content includes `nosniff`, `no-referrer`, restrictive CSP, same-origin resource and frame-deny headers. The JSON write endpoints additionally require a valid authenticated portal session in production and an exact localhost `Origin`, JSON content type, a bounded body length, and reject known cross-site fetch metadata. The server rejects spoofed Host headers to reduce DNS-rebinding exposure. No CORS wildcard is present.

A tiny allowlist maps application identifiers to approved binaries. Browser callers cannot supply a pathname, argument string, environment command, working directory or shell expression. Launch requests are bound to a user desktop, require a confirmation click in the interface, and are rate limited per application. No launch is performed while the backend has root privileges. The app subprocess is **not evidence** that a compatible GUI successfully opened or finished. Every actual launch must be tested on the target hardware.

**Residual risk:** this is a localhost service used inside a graphical session, not a fortified security daemon. A compromised extension/browser running as the same Unix user may access the same user's files and local ports. The script checks Origin and CSP but does not prove safety against all possible same-origin XSS, malicious installed software, a rogue kernel module or a person with physical/root access. The adult should review extensions and updates.

## Offline enforcement is opt-in

`installer/offline-guard.sh` installs a dedicated systemd oneshot service and an `nftables` table which rejects outbound packets whose **socket owner** UID is Atlas/Nova and whose output interface is not loopback. This blocks ordinary child-user Internet and LAN traffic, but the adult can continue installing updates and resources from a separate account. The policy can be linted with `nft -c -f` before activation and removed with the documented `--remove` operation. It intentionally does not touch default system firewall tables. Disabling the guard is necessary for child-owned LAN multiplayer, cloud tools or local network resources on another device.

This guard is **not content filtering**. It does not classify images or websites, cannot define screen-time allowances, and does not implement safe search, audit logs, AI moderation or network policy for the adult administrator. It does not automatically restrict external links in offline content that the adult has already downloaded. A resourceful attacker or malware with more privilege might bypass some restrictions. The children should not know or have the adult's administrative password. Review external media and removable devices as you normally would.

## Family-first product decisions

WonderForge deliberately avoids competitive leaderboards, public forums, influencer feeds, social notifications, anonymous chat, reward streak pressure and engagement-maximizing loops. ORBIT in the prototype is rule-based and stays on device. It does **not** connect to an external AI provider, inspect personal files or execute tools on its own. The design values curiosity, experimentation, cooperation, and service; it is compatible with a Christian household without substituting religious answers for accurate scientific explanations or presenting fictional fantasy worlds as reality.

Most importantly, do not place technical or electrical experiments beyond an eleven-year-old's experience in front of them without adult supervision. Even 3.3V Pico projects can involve hot components, batteries, fragile electronics, or tools that warrant instruction.

## Review checklist

1. The Pi boots into a real multi-user login screen; no adult auto-login.
2. The children have different passwords from the adult; their homes are mode 700.
3. Neither child can read the other's private home or use `sudo`.
4. A shared notebook appears to the other only after an explicit Share Copy.
5. Unshared localStorage notes do not cross Linux users.
6. `/api/session` reports the actual logged-in account.
7. Requests from a foreign Host/Origin are rejected by the local API.
8. Installed app launches are only for allowlisted applications and never run as root.
9. The optional network guard is tested using the child session and documented rollback.
10. The adult has working backups, a recovery account, and knows how to start the Pi desktop without WonderForge.
