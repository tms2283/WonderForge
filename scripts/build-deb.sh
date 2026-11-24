#!/usr/bin/env bash
# Reproducible architecture-independent application payload. Safe as non-root.
# Does not create users, install dependencies or modify the operating system.
set -euo pipefail
# Normalize archive timestamps across repeated builds of the same source snapshot.
export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-1795305600}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/dist}"
command -v dpkg-deb >/dev/null || { echo 'dpkg-deb is required' >&2; exit 1; }
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/DEBIAN" "$STAGE/opt/wonderforge" "$STAGE/usr/local/bin" \
    "$STAGE/usr/share/applications" "$STAGE/usr/lib/systemd/user"
cat > "$STAGE/DEBIAN/control" <<'CONTROL'
Package: wonderforge-os
Version: 0.6.0
Section: education
Priority: optional
Architecture: all
Maintainer: WonderForge Prototype Project <maintainers@wonderforge.invalid>
Depends: python3 (>= 3.11)
Suggests: chromium, luanti, luanti-game-minetest, thonny
Description: Offline-first family maker desktop for Raspberry Pi 4B
 WonderForge is an optional educational browser desktop and launcher.
 Linux user accounts and team permissions require a separate opt-in
 provisioning command. No users, passwords, firewall rules, autologin
 settings or privileged services are created at install time.
CONTROL
for item in web data design docs os installer scripts tools;do cp -a "$ROOT/$item" "$STAGE/opt/wonderforge/";done
for item in server.py portal_security.py device_health.py README.md CHANGELOG.md LICENSE;do cp -a "$ROOT/$item" "$STAGE/opt/wonderforge/";done
# Remove host Python cache artifacts: these are machine/version dependent and
# must not appear in a reproducible cross-architecture source-only package.
find "$STAGE/opt/wonderforge" -type d -name '__pycache__' -prune -exec rm -rf '{}' +
find "$STAGE/opt/wonderforge" -type f -name '*.pyc' -delete
install -m 0755 "$ROOT/scripts/wonderforge-launch" "$STAGE/usr/local/bin/wonderforge-launch"
install -m 0644 "$ROOT/os/desktop/wonderforge.desktop" "$STAGE/usr/share/applications/wonderforge.desktop"
install -m 0644 "$ROOT/os/systemd/wonderforge.service" "$STAGE/usr/lib/systemd/user/wonderforge.service"
find "$STAGE/opt/wonderforge" -type d -exec chmod 0755 '{}' +
find "$STAGE/opt/wonderforge" -type f -exec chmod 0644 '{}' +
dpkg-deb --build --root-owner-group "$STAGE" "$OUT/wonderforge-os_0.6.0_all.deb"
dpkg-deb --info "$OUT/wonderforge-os_0.6.0_all.deb"
echo "Built: $OUT/wonderforge-os_0.6.0_all.deb"
