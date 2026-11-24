#!/usr/bin/env bash
# Experimental image: stage root-owned files only. NEVER create users/passwords at boot.
# Adult account setup MUST first be completed via Raspberry Pi Imager / Pi OS onboarding.
set -euo pipefail
MARKER=/var/lib/wonderforge/staged
[[ ! -f "$MARKER" ]] || exit 0
SOURCE=/opt/wonderforge-preinstall
TARGET=/opt/wonderforge
[[ -f "$SOURCE/server.py" && -f "$SOURCE/portal_security.py" ]] || {
 echo 'WonderForge image preinstall payload missing' >&2; exit 1; }
[[ ! -L "$SOURCE" && ! -L "$TARGET" ]] || { echo 'Unexpected symlink in image staging.' >&2; exit 1; }
install -d -m 0755 -o root -g root "$TARGET" /var/lib/wonderforge
cp -a "$SOURCE"/. "$TARGET"/
chown -R root:root "$TARGET"
find "$TARGET" -type d -exec chmod 0755 '{}' +
find "$TARGET" -type f -exec chmod 0644 '{}' +
printf 'Staged %s — adult account setup still required\n' "$(date -u +%FT%TZ)" > "$MARKER"
systemctl disable wonderforge-firstboot.service || true
logger -t wonderforge 'Payload staged. Adult must finish official OS login and then run the opt-in provisioner.'
