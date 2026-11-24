# WonderForge OS 2027: Physical Raspberry Pi 4B Installation

Target: **one Raspberry Pi 4 Model B, 4 GB RAM**, a normal monitor/keyboard/mouse, and two standard Unix accounts (`atlas`, `nova`) plus an adult administrator. As of November 22, 2026, a 64-bit Raspberry Pi OS Trixie Desktop installation is the supported starting point. WonderForge intentionally runs **on** Raspberry Pi OS; the word *OS* describes the child-facing desktop experience, not a custom kernel.

## Stage 0 · Protect the current Pi

The brothers already use one shared Pi. First ask what is stored on its current SD card or SSD. A fresh image **erases the selected storage device**. Use a spare, clearly identified card or SSD (prefer 64 GB+, with 128 GB or an SSD offering more room for creative assets). Leave the existing working card intact until the replacement has passed the acceptance steps.

Back up documents, existing programs, saved worlds, pictures, notebooks, browser bookmarks and any other personal work before changing the boot medium. An SD-card copy is useful, but verify it can boot or restore. Do not mistake a screenshot of a folder for a backup. Arrange a protected external backup destination. The optional script `scripts/backup-family.sh` is for a previously provisioned installation and produces an **unencrypted** tarball; keep that file on an encrypted, adult-controlled drive.

A sufficiently powerful official Pi USB-C power supply, active cooling when appropriate, and good SD/SSD storage reduce instability. Avoid new firmware tweaks, unusual overclocks, or forcing unsupported display modes just to achieve a particular design aesthetic.

## Stage 1 · Official Raspberry Pi OS

Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/) on another computer to write the official **Raspberry Pi OS (64-bit) with Desktop** to the **spare** medium. Configure hostname, Wi-Fi and a **distinct adult administrator account** (not `atlas` or `nova`) using the Imager's supported user setup. Do not use an identical password for the adult and children.

Boot the Pi once as the adult. Confirm display, Wi-Fi, keyboard and storage. Apply normal updates:

```bash
sudo apt update
sudo apt full-upgrade
sudo reboot
```

After reboot, confirm platform information:

```bash
uname -m                          # aarch64
cat /etc/os-release               # VERSION_CODENAME=trixie
tr -d '\0' </proc/device-tree/model
free -h
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS
```

Expected hardware: `Raspberry Pi 4 Model B`; system architecture: `aarch64`/Debian `arm64`. **Never paste flash or format commands using unverified `/dev/sdX` device names.** The installer does not format anything.

### A vital login policy

Open `sudo raspi-config` and ensure **Desktop Auto Login is disabled**. The actual Linux login chooser must appear so the brothers can use different Unix accounts. If the adult's account remains automatically logged in, children can inherit its privileges regardless of what the WonderForge graphic says. Check the distro's display-manager and login behavior rather than editing a guessed `lightdm.conf` file; Raspberry Pi OS releases have changed greeters.

## Stage 2 · Transfer the project

Unzip the `WonderForge-OS-2027-Engineering-v0.4.zip` project to an **adult-owned working directory** (e.g. `$HOME/Downloads/WonderForge-OS-2027-Engineering`). Before doing anything as root, inspect `installer/system-install.sh` and run the dry run:

```bash
cd ~/Downloads/WonderForge-OS-2027-Engineering
bash installer/system-install.sh
bash installer/install-apps.sh
bash installer/offline-guard.sh
```

The dry run should print the exact system paths and user accounts. It should **not** create accounts, install programs, alter networking or start a service. Verify the source directory is readable and not a symlink to an untrusted location.

If you prefer the Debian package, install it with `sudo apt install ./wonderforge-os_0.7.0_all.deb` from a directory containing the package. This provides an ordinary program payload, not user accounts. The `.deb` and source-tree methods are alternatives; using both is unnecessary.

## Stage 3 · Provision actual accounts

For the ZIP/source-tree method:

```bash
sudo bash installer/system-install.sh --apply --admin-user="$(whoami)" --autostart
```

For the `.deb` method:

```bash
sudo bash /opt/wonderforge/installer/system-install.sh --apply --admin-user="$(whoami)" --autostart
```

**What it does:** validates hardware, OS and privileged administrator, creates the unprivileged `atlas` and `nova` accounts if absent, locks their passwords initially, adds both to the `wonderforge` group, creates `0700` home directories, creates the root-owned shared directory at `/srv/wonderforge/team` with group write access and setgid, installs a root-owned local app and launcher, and copies a separate WonderForge Luanti world into each child's home **without overwriting an existing world**. It does not change the bootloader, format storage, add remote SSH logins, or activate account-level network restrictions.

Then **on the Pi's adult terminal** set two private child login passwords:

```bash
sudo passwd atlas
sudo passwd nova
```

Avoid writing passwords in files or sharing them in chat. For the children to sign in, passwords must be enabled. Verify they are not in the `sudo`, `docker` or similarly powerful groups:

```bash
id atlas
id nova
ls -ld /home/atlas /home/nova /srv/wonderforge/team
```

The two `/home` directories should show only owner access (`drwx------`). The team folder should be root-owned with group `wonderforge`, group writable and setgid (`drwxrws---`). A member of either child account can only access the sibling's work after it has been **deliberately copied** to Team Forge.

## Stage 4 · Install approved applications

Run the package set **only while adult-admin networking is available**:

```bash
sudo bash installer/install-apps.sh --apply
```

This installs the default core set: Luanti, Minetest Game for Luanti, Thonny, GIMP and Inkscape. Its script checks availability in the configured apt repositories. These binaries are **not redistributed** with WonderForge; apt downloads the correct versions for the Pi. For heavier optional makerspace programs:

```bash
sudo bash installer/install-apps.sh --apply --extras
```

Extras add OpenSCAD, KiCad, Stellarium, Audacity and Krita. The Pi 4B 4 GB can struggle if large 3D/CAD/audio projects run alongside Chromium. Close applications between labs, keep a low view distance in Luanti, and do not claim every application will perform well before physical benchmarks.

## Stage 5 · First child login and actual usage

Sign out completely from the adult account and select `atlas` at the Linux login screen. The `--autostart` flag should launch WonderForge automatically; otherwise open Applications → Education → WonderForge, or run `wonderforge-launch` in a terminal. The launcher starts a separate localhost-only Python process for this **UID** and opens sandboxed Chromium in app mode. It uses a private Chromium data directory for this Unix account. There is no remote network listener.

Repeat as `nova` **after signing out** of Atlas. Browser data should not transfer automatically. A visit to `http://127.0.0.1:<user-port>/api/session` from that account should identify the matching Unix user; port is `20000 + (UID % 25000)`. Never treat manually typed profile names as identity proof.

Create a notebook in Atlas → Project Vault and use **Share Copy**. Sign in as Nova → Team Forge and refresh. Open Atlas's notebook from the shared collection. Repeat with a blueprint from Pocket Builder. Then create a private Nova notebook and verify it does not appear in Atlas's personal vault. The shared copy is separate from the original private browser notebook.

## Stage 6 · Luanti game

Once installed through apt, open Luanti from Creation Studios or the Applications menu, select the local single-player `WonderForge` world associated with the **Minetest Game** base content, and enter the world. Its mod is installed in:

```text
/home/atlas/.minetest/worlds/WonderForge/worldmods/wonderforge/
/home/nova/.minetest/worlds/WonderForge/worldmods/wonderforge/
```

Generation is incremental. After initial mapchunks load, the floating hub and neighboring regions should appear. Right-click the central Atlas board or type `/forge` in Luanti chat; `/forgehome` returns you to the Invention Station. Walk/teleport among the six themed islands. If no island or texture loads, stop and check Luanti logs before encouraging the brothers to invest time in a broken world. Keep the graphics resolution modest (e.g. 1280×720), disable expensive shaders and reduce view distance. See [Luanti world details](LUANTI-WORLD.md).

## Stage 7 · Optional offline policy

Only after apps/content and the adult's maintenance connectivity are working, review:

```bash
sudo bash installer/offline-guard.sh
sudo apt install nftables
sudo bash installer/offline-guard.sh --apply
```

The account-bound nftables rule blocks outbound non-loopback traffic from Atlas and Nova. It will prevent child-owned Internet and LAN connections and can interfere with any child-owned multiplayer or networked learning tool. It does **not** block the adult's updates. After enabling it, recheck WonderForge and the Team Forge local API. Disable it for a planned supervised LAN network session using `sudo bash installer/offline-guard.sh --apply --remove` and reinstate afterward if desired.

This is not a comprehensive Internet content filter or automated screen-time system. A technically skilled child with physical possession of the machine might seek other pathways; use normal family practices and adult credentials.

## Stage 8 · Physical acceptance and recovery

Run the read-only audit from the extracted project:

```bash
python3 tools/pi4-audit.py
python3 -m unittest discover -s tests -v
```

Manually verify: display/login, root/admin separation, app launch, Luanti world generation and movement, saving/editing/exporting projects, Atlas→Nova shared notebook, Pi memory use, no crashes, reboot persistence, secure child home directories, no silent cloud contacts, adult login and update access, and working restoration from backup.

If a child account cannot log in, return to the **adult** account and verify its password is set and its account is not disabled. If WonderForge fails, Linux desktop and standard applications should remain accessible. Never hide the standard login/terminal recovery route. For uninstalling the program, use `installer/uninstall.sh` only with the source-tree install, or `sudo apt remove wonderforge-os` for Debian package deployments. Both preserve the children's homes and world saves. A factory reset is not an acceptable troubleshooting shortcut.


### Optional local AI path (v0.7)

The custom image builder is not required. On existing Raspberry Pi OS, an adult may install Ollama ARM64 and configure the local-only service using [`LOCAL-AI.md`](LOCAL-AI.md). First use the dry-run of `installer/setup-local-ai.sh`; `--apply` enforces local-only/cloud-disabled settings and downloads one allowlisted model. Do not expect multi-billion-parameter model throughput from a 4 GB Pi 4B. System Pulse and the on-device AI benchmark provide observations instead of invented performance data.
