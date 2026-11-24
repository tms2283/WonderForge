#!/usr/bin/env bash
# Creates a protected local backup archive (tar itself is NOT encrypted).
# Prefer a mounted encrypted external disk. DRY RUN is the default.
set -euo pipefail
APPLY=0; DEST=''
for a in "$@";do case "$a" in --apply)APPLY=1;; --dest=*)DEST=${a#*=};; -h|--help)echo 'Usage: sudo bash scripts/backup-family.sh --dest=/mnt/ENCRYPTEDDISK [--apply]';exit 0;; *)echo 'Unknown option:' "$a" >&2;exit 2;;esac;done
[[ -n $DEST && $DEST == /* ]] || { echo 'Provide an absolute destination directory via --dest=/path' >&2;exit 2; }
for path in /home/atlas /home/nova /srv/wonderforge/team;do
 [[ -e $path ]] || { echo "Missing $path" >&2;exit 1; }
done
echo "Backup plan: create tar.gz containing /home/atlas /home/nova /srv/wonderforge/team in $DEST"
echo 'Contains private child data; do not store in public cloud or unprotected shared folders.'
echo 'A SHA-256 receipt and an archive integrity audit will be produced.'
if (( !APPLY ));then echo 'DRY RUN ONLY.';exit 0;fi
[[ $EUID -eq 0 ]] || { echo 'Run via sudo.' >&2;exit 1; }
[[ -d $DEST && ! -L $DEST ]] || { echo 'Destination must exist and not be a symlink.' >&2;exit 1; }
[[ $DEST != /home/* && $DEST != /srv/wonderforge/* ]] || { echo 'Do not place a family archive inside the data being backed up.' >&2;exit 1; }
name="wonderforge-family-$(date -u +%Y%m%dT%H%M%SZ).tar.gz"
[[ ! -e "$DEST/$name" ]] || { echo 'An archive with this name already exists; retry later.' >&2; exit 1; }
umask 077
tmp="$(mktemp "$DEST/.wonderforge-backup.XXXXXXXX.tar.gz")"
trap 'rm -f -- "$tmp"' EXIT
# Permission-preserving archive; fails if data cannot be read. No format fallback.
tar --acls --xattrs -czpf "$tmp" -C / home/atlas home/nova srv/wonderforge/team
chmod 600 "$tmp"
INSPECT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/tools/inspect-backup.py"
python3 "$INSPECT" "$tmp"
mv -n -- "$tmp" "$DEST/$name"
trap - EXIT
sha256sum -- "$DEST/$name" > "$DEST/$name.sha256"
chmod 600 "$DEST/$name.sha256"
echo "Backup completed: $DEST/$name"
echo "Verification receipt: $DEST/$name.sha256"
echo 'Verify by listing archive entries before restoring. Tar is NOT encrypted by this script.'
