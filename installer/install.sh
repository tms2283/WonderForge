#!/usr/bin/env bash
# User-scoped installation. No sudo, no package installs, no file deletion without --apply.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${HOME}/.local/share/wonderforge"
DESKTOP="${HOME}/.local/share/applications/wonderforge.desktop"
if [[ "${1:-}" != "--apply" ]]; then
  echo "DRY RUN. To install this user-scoped portal, rerun with --apply."
  echo "Source: $SRC"
  echo "Target: $DEST"
  echo "Menu shortcut: $DESKTOP"
  echo "No system packages or external game content will be installed by this script."
  exit 0
fi
if [[ "$SRC" == "$DEST" ]]; then
  echo "Run installer from outside the destination directory." >&2
  exit 1
fi
mkdir -p "$DEST" "$(dirname "$DESKTOP")"
# Copy only the known assets required to run locally; preserve any existing user data.
cp -r "$SRC/web" "$SRC/data" "$DEST/"
cp "$SRC/server.py" "$SRC/portal_security.py" "$SRC/device_health.py" "$SRC/start.sh" "$DEST/"
chmod 755 "$DEST/start.sh"
cat > "$DESKTOP" <<DESKTOP
[Desktop Entry]
Type=Application
Version=1.0
Name=WonderForge Makerverse
Comment=Offline-first maker missions and blueprint studio
Exec=$DEST/start.sh
Terminal=false
Icon=$DEST/web/assets/wonderforge-icon.svg
Categories=Education;Game;
StartupNotify=true
DESKTOP
chmod 644 "$DESKTOP"
printf 'Installed launcher into %s\n' "$DEST"
printf 'Run: %s\n' "$DEST/start.sh"
printf 'Note: full Luanti universe, AI engine, and parental controls are NOT installed by this script.\n'
