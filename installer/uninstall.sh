#!/usr/bin/env bash
# Removing the program does not remove child accounts, creations or game worlds.
set -euo pipefail
APPLY=0
if [[ ${1:-} == --apply ]]; then APPLY=1; elif [[ $# -gt 0 ]]; then echo 'Usage: sudo bash installer/uninstall.sh [--apply]' >&2;exit 2; fi
echo 'WonderForge program removal plan: remove /opt/wonderforge, installed launcher and per-user service.'
echo 'Preserved: Linux users atlas/nova, /home/*, /srv/wonderforge/team, Luanti worlds, backups.'
echo 'Optional network guard is NOT changed; remove it separately with offline-guard.sh --apply --remove.'
if (( !APPLY )); then echo 'DRY RUN ONLY.';exit 0;fi
[[ $EUID -eq 0 ]] || { echo 'Run as sudo.' >&2;exit 1; }
if command -v dpkg-query >/dev/null && dpkg-query -W -f='${Status}' wonderforge-os 2>/dev/null | grep -q 'install ok installed';then
 echo 'This was installed as a Debian package. Use: sudo apt remove wonderforge-os' >&2; exit 1
fi
for u in atlas nova; do
 f="/home/$u/.config/autostart/wonderforge.desktop"
 if [[ -f $f ]] && grep -q '^Exec=/usr/local/bin/wonderforge-launch$' "$f"; then rm -f -- "$f";fi
done
rm -f /usr/share/applications/wonderforge.desktop /usr/lib/systemd/user/wonderforge.service /usr/local/bin/wonderforge-launch
if [[ -d /opt/wonderforge && ! -L /opt/wonderforge ]];then rm -rf -- /opt/wonderforge;fi
if command -v systemctl >/dev/null;then systemctl daemon-reload || true;fi
echo 'Application removed. Child accounts, projects, and game worlds remain intact.'
