#!/usr/bin/env bash
# WonderForge v0.5 provisioning for a physical Raspberry Pi 4B running 64-bit Raspberry Pi OS.
# DRY RUN BY DEFAULT. No flashing, disk formatting, autologin or password storage.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET=/opt/wonderforge
APPLY=0; INSTALL_APPS=0; AUTOSTART=0; ADMIN=''
usage() {
  cat <<'HELP'
Usage: sudo bash installer/system-install.sh [--apply] [--with-apps] [--autostart] [--admin-user USER]

The default is a dry-run plan. --apply REQUIRES Raspberry Pi 4B,
64-bit arm64 Raspberry Pi OS and root. Creates locked standard users atlas/nova,
root-owned application, separate private homes, explicit group-shared project
folder, menu launcher, per-user systemd service, and two original Luanti worlds.
DOES NOT set passwords; run `sudo passwd atlas` and `sudo passwd nova` after.
DOES NOT disable existing desktop autologin; disable it using raspi-config first.
--with-apps installs optional selected apt packages (requires network and disk).
--autostart installs startup shortcuts ONLY in the two child accounts.
--admin-user names the existing adult administrator and checks its identity.
HELP
}
for arg in "$@"; do
 case "$arg" in
  --apply) APPLY=1;;
  --with-apps) INSTALL_APPS=1;;
  --autostart) AUTOSTART=1;;
  --admin-user=*) ADMIN=${arg#*=};;
  --help|-h) usage;exit 0;;
  *) echo "Unknown option $arg" >&2;usage;exit 2;;
 esac
done
printf 'WONDERFORGE / INSTALL PLAN\n'
printf 'Source: %s\nDestination: %s\nUsers: atlas, nova (no sudo, locked until adult sets passwords)\n' "$ROOT" "$TARGET"
echo 'Shared directory: /srv/wonderforge/team (root:wonderforge mode 2770)'
echo 'Installed menu item: /usr/share/applications/wonderforge.desktop'
echo 'Internet and package installation are NOT performed unless --with-apps is supplied.'
echo 'No firmware changes, partitions, auto-login, external network server, or password generation.'
if (( !APPLY )); then
 echo 'DRY RUN ONLY. Re-run with --apply on the physical Pi after backup and OS upgrade.'
 exit 0
fi
[[ $EUID -eq 0 ]] || { echo 'Use sudo for --apply' >&2;exit 1; }
[[ -r /etc/os-release ]] || { echo 'Cannot verify OS.' >&2;exit 1; }
# shellcheck disable=SC1091
source /etc/os-release
[[ ${VERSION_CODENAME:-} == trixie && ${ID:-} == raspbian || ${VERSION_CODENAME:-} == trixie && ${ID:-} == debian ]] || {
 echo 'Requires Raspberry Pi OS Debian Trixie; refusing to modify host.' >&2;exit 1; }
[[ $(dpkg --print-architecture) == arm64 ]] || { echo 'Requires arm64 Raspberry Pi OS.' >&2;exit 1; }
MODEL=$(tr -d '\000' </proc/device-tree/model 2>/dev/null || true)
[[ $MODEL == *'Raspberry Pi 4 Model B'* ]] || { echo "Requires Pi 4B. Detected: ${MODEL:-unknown}" >&2;exit 1; }
if [[ -n $ADMIN ]]; then
  [[ $ADMIN =~ ^[a-z_][a-z0-9_-]*$ ]] || { echo 'Invalid adult admin name' >&2;exit 1; }
  id "$ADMIN" >/dev/null 2>&1 || { echo 'The nominated administrator does not exist.' >&2;exit 1; }
  [[ $ADMIN != atlas && $ADMIN != nova && $ADMIN != root ]] || { echo 'Adult must be separate from both child accounts.' >&2;exit 1; }
  id -nG "$ADMIN" | tr ' ' '\n' | grep -qxE 'sudo|wheel' || { echo 'Adult must already have administrator rights.' >&2;exit 1; }
fi
if (( INSTALL_APPS )); then
  free_kb=$(df -Pk / | awk 'NR==2{print $4}')
  (( free_kb > 7000000 )) || { echo 'Need at least 7 GB free space for optional apps.' >&2;exit 1; }
fi
if [[ -L $TARGET || -L /srv/wonderforge || -L /srv/wonderforge/team ]]; then
 echo 'Refusing to provision through a symlinked application or shared-directory path.' >&2; exit 1
fi
for tool in groupadd useradd usermod passwd install cp chmod chown; do command -v "$tool" >/dev/null || { echo "Missing $tool" >&2;exit 1; }; done
if getent group wonderforge >/dev/null; then :; else groupadd --system wonderforge; fi
for u in atlas nova; do
 if id "$u" >/dev/null 2>&1; then
   [[ $(id -u "$u") -ge 1000 ]] || { echo "Refusing to reuse system user $u" >&2;exit 1; }
   groups="$(id -nG "$u")"
   if printf '%s\n' "$groups" | tr ' ' '\n' | grep -qE '^(sudo|wheel|docker|lxd|adm|systemd-journal)$'; then
      echo "User $u already has privileged group membership. Investigate manually." >&2;exit 1
   fi
   usermod -a -G wonderforge "$u"
 else
   useradd -m -U -s /bin/bash -G wonderforge "$u"
   passwd --lock "$u" >/dev/null
 fi
 [[ ! -L /home/$u ]] || { echo "Unsafe symlink /home/$u" >&2;exit 1; }
 chmod 0700 "/home/$u"
done
install -d -m 0755 -o root -g root /srv/wonderforge
install -d -m 2770 -o root -g wonderforge /srv/wonderforge/team
if [[ "$ROOT" != "$TARGET" && -d "$TARGET" ]]; then
 b="/opt/wonderforge.backup.$(date -u +%Y%m%d%H%M%S)"
 cp -a "$TARGET" "$b"
 echo "Previous installation backed up: $b"
fi
install -d -m 0755 -o root -g root "$TARGET"
if [[ "$ROOT" != "$TARGET" ]]; then
 for name in web data design docs os scripts installer tools; do cp -a "$ROOT/$name" "$TARGET/"; done
 cp -a "$ROOT/server.py" "$ROOT/portal_security.py" "$ROOT/device_health.py" "$ROOT/README.md" "$TARGET/"
else
 echo "Using preinstalled Debian package payload in $TARGET; preserving package-managed files."
fi
chown -R root:root "$TARGET"
find "$TARGET" -type d -exec chmod 0755 '{}' +
find "$TARGET" -type f -exec chmod 0644 '{}' +
install -m 0755 -o root -g root "$ROOT/scripts/wonderforge-launch" /usr/local/bin/wonderforge-launch
install -m 0644 -o root -g root "$ROOT/os/desktop/wonderforge.desktop" /usr/share/applications/wonderforge.desktop
install -d -m 0755 -o root -g root /usr/lib/systemd/user
install -m 0644 -o root -g root "$ROOT/os/systemd/wonderforge.service" /usr/lib/systemd/user/wonderforge.service
for u in atlas nova; do
  dest="/home/$u/.minetest/worlds/WonderForge"
  if [[ ! -e $dest ]]; then
    install -d -m 0750 -o "$u" -g "$u" "$(dirname "$dest")"
    cp -a "$ROOT/os/worlds/WonderForge" "$dest"
    chown -R "$u:$u" "$dest"
  else
    echo "Preserving existing $u game world: $dest"
  fi
  install -d -m 0700 -o "$u" -g "$u" "/home/$u/.config/wonderforge"
  if (( AUTOSTART )); then
    install -d -m 0700 -o "$u" -g "$u" "/home/$u/.config/autostart"
    install -m 0644 -o "$u" -g "$u" "$ROOT/os/desktop/wonderforge.desktop.template" "/home/$u/.config/autostart/wonderforge.desktop"
  fi
done
if (( INSTALL_APPS )); then bash "$ROOT/installer/install-apps.sh" --apply;fi
echo 'Provisioned WonderForge application and two locked non-admin Linux accounts.'
echo 'NEXT: sudo passwd atlas; sudo passwd nova; disable desktop auto-login; sign into each account.'
echo 'START: choose WonderForge in the Applications menu (or run wonderforge-launch).'
echo 'NETWORK: child access is NOT blocked unless adult separately installs --apply offline guard.'
