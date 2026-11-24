# Family installation quickstart · WonderForge Engineering 0.5

**Computer:** one Raspberry Pi 4 Model B (4 GB RAM). **Operating system:** official Raspberry Pi OS Desktop 64-bit, Debian Trixie. **Goal:** install an optional creative desktop for two separate, non-admin Linux users. **Status:** engineering preview, not a boot-tested appliance.

## Before anything else

1. **Back up the existing Pi.** Do not overwrite the only working SD card or SSD. Use a spare storage device, preferably at least 64 GB, with enough free space for art tools and game worlds.
2. Create the **adult administrator account** using Raspberry Pi Imager / the official OS first-run process. Verify the normal graphical desktop, network, keyboard, audio and OS updates. Keep that adult account separate from the two children.
3. From a terminal in the adult account, copy `wonderforge-os_0.6.0_all.deb` onto the Pi. This file only contains the WonderForge app payload; third-party apps are not included.

## Install without immediately changing accounts or network

```bash
sudo apt install ./wonderforge-os_0.6.0_all.deb
sudo bash /opt/wonderforge/installer/system-install.sh
```

The second command is **only a preview**. Read it. If the displayed paths and proposed accounts are what you want, apply it explicitly (replace `YOUR_ADMIN_LOGIN` with your existing adult Linux username):

```bash
sudo bash /opt/wonderforge/installer/system-install.sh --apply --admin-user=YOUR_ADMIN_LOGIN
sudo passwd atlas
sudo passwd nova
```

Select distinct, strong passwords known to the adult and the appropriate child. This intentionally creates no default passwords and no autologin. **Disable existing desktop autologin with `sudo raspi-config`** so the brothers get real account separation rather than fake browser profiles.

## Install tools and launch

First preview the curated packages. On the adult account, run:

```bash
sudo bash /opt/wonderforge/installer/install-apps.sh
```

Then, if the tool selection and storage space are appropriate, install the core applications:

```bash
sudo bash /opt/wonderforge/installer/install-apps.sh --apply
```

Log out. Log in as **Atlas** or **Nova** at the real Linux greeter. Use **Applications → WonderForge — Invention Station**, or run `wonderforge-launch`. The desktop UI uses a local loopback service, separate Chromium profile, and each account's own private file storage.

## Brother-to-brother sharing

The brothers work in separate Linux accounts. In the WonderForge **Project Vault** or **Pocket Builder**, use **Share Copy**. In **Team Forge**, the other brother can discover and import the shared copy from `/srv/wonderforge/team`. This is deliberately one-way copying, not magic shared editing or simultaneous game multiplayer.

## Optional controls and audit

To preview child-account **outbound offline mode** (blocks Internet **and LAN** for both child users), run:

```bash
sudo bash /opt/wonderforge/installer/offline-guard.sh
```

Read `docs/SECURITY-AND-FAMILY.md` before enabling it. Reversible actions are `--apply` and `--apply --remove`. It is **not comprehensive internet filtering or screen-time supervision**.

After copying and extracting the full engineering ZIP onto the Pi, run its read-only hardware check from the extracted project directory:

```bash
python3 tools/pi4-audit.py
```

**Note:** The `.deb` contains the core app but does not install all optional development/test tools. This command is provided by the full source ZIP and prints expected warnings for uninstalled optional software.

## If something doesn't work

- **Portal doesn't start:** open a terminal as Atlas/Nova, run `systemctl --user status wonderforge.service`, and try `wonderforge-launch` again. Verify Chromium exists with `command -v chromium`.
- **Luanti world missing:** the installer should copy `~/.minetest/worlds/WonderForge` for each user. Launch Luanti, select **WonderForge**, and verify the six regions. No claim is made of hardware-verified gameplay yet.
- **Accounts can't sign in:** from the adult account, run `sudo passwd atlas` or `sudo passwd nova`. Check that auto-login is disabled.
- **Network is unexpectedly unavailable:** adult can use `sudo bash /opt/wonderforge/installer/offline-guard.sh --apply --remove` if the optional guard was previously enabled.
- **Restore previous experience:** shut down and boot from the untouched original storage medium. The prototype installer does not erase the existing Linux OS or flash storage.

## Exit strategy

`sudo apt remove wonderforge-os` removes the Debian application payload. It deliberately **does not delete** the children's accounts, home folders, or shared records. These remain until an adult chooses what to archive. The optional network guard must be removed separately before uninstalling its script.

**Never use the experimental image-build recipe or a newly created `.img` as the only boot medium until a complete real-Pi acceptance run has passed.**


## New in v0.5 — science and guided discovery

From the sidebar, open **Physics Lab** for two idealized models: an LED/resistor current model and a simple loaded-beam deflection model. These are teaching calculators, **not approval to build circuits or safe structures**; the current and material assumptions are shown. Open **Offline Field Guide** for 18 original short lessons with a question, hands-on activity, observation prompt and safety caution. ORBIT can retrieve a relevant guide entry and cite its title, but does not access the cloud or run a local generative AI.

**Project persistence:** The authenticated production portal saves projects, lab settings, quest completion, and logic programs to each child's private SQLite file. Use the Project Vault export regularly anyway. Never confuse the ordinary uncredentialed developer server (`python3 server.py`) with the signed-in Linux desktop launcher (`wonderforge-launch`).

**Backups:** Run the dry-run-first `scripts/backup-family.sh --dest=/mounted/ENCRYPTED_BACKUP` as an adult. It writes a standard **unencrypted** tar.gz and a `.sha256` receipt, and audits archive paths before marking it complete. The destination disk should itself be encrypted and restricted. Run `python3 tools/inspect-backup.py /path/to/archive.tar.gz --sha256 EXPECTED_HASH` to verify without extracting. Restoration is intentionally not automated because blindly overwriting the only children's homes could destroy newer projects.
