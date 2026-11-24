#!/usr/bin/env bash
# Optional outbound internet/LAN blocking for only two Unix accounts.
# Adult confirmation and Pi-local test required; preview is the default.
set -euo pipefail
APPLY=0; REMOVE=0
for arg in "$@"; do case "$arg" in --apply) APPLY=1;; --remove) REMOVE=1;; -h|--help) echo 'Usage: sudo bash installer/offline-guard.sh [--apply] [--remove]';exit 0;; *) echo "Invalid option $arg" >&2;exit 2;; esac;done
printf 'WonderForge optional OFFLINE GUARD plan: %s\n' "$([[ $REMOVE == 1 ]] && echo REMOVE || echo INSTALL)"
echo 'Blocks outgoing non-loopback traffic owned by UNIX users atlas/nova, including LAN and Internet.'
echo 'Loopback local WonderForge will still work; adult admin networking remains unchanged.'
echo 'WARNING: This is only one technical safeguard. It is not comprehensive parental control.'
if (( !APPLY )); then echo 'DRY RUN ONLY. Re-run with --apply after the adult has reviewed the policy.';exit 0;fi
[[ $EUID == 0 ]] || { echo 'Run with sudo' >&2;exit 1; }
command -v nft >/dev/null || { echo 'nftables package is required. Install with: sudo apt install nftables' >&2;exit 1; }
command -v systemctl >/dev/null || { echo 'systemd is required.' >&2;exit 1; }
if (( REMOVE )); then
  systemctl disable --now wonderforge-offline-guard.service || true
  nft delete table inet wonderforge_family 2>/dev/null || true
  rm -f /etc/wonderforge-family.nft /etc/systemd/system/wonderforge-offline-guard.service
  systemctl daemon-reload
  echo 'Removed child-account offline guard.'
  exit 0
fi
for u in atlas nova; do id "$u" >/dev/null 2>&1 || { echo "Missing Linux user $u" >&2;exit 1;};done
A=$(id -u atlas);B=$(id -u nova)
[[ $A != $B ]] || { echo 'Users must be distinct' >&2;exit 1; }
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
cat > "$TMP" <<EOF
table inet wonderforge_family {
  chain output_guard {
    type filter hook output priority -10; policy accept;
    meta skuid { $A, $B } oifname != "lo" reject
  }
}
EOF
nft -c -f "$TMP" || { echo 'Firewall validation failed; nothing installed.' >&2;exit 1; }
install -m 0600 -o root -g root "$TMP" /etc/wonderforge-family.nft
install -m 0644 -o root -g root "$(dirname "$0")/../os/systemd/wonderforge-offline-guard.service" /etc/systemd/system/wonderforge-offline-guard.service
systemctl daemon-reload
systemctl enable --now wonderforge-offline-guard.service
nft list table inet wonderforge_family
echo 'Child outgoing non-loopback network guard enabled.'
echo 'After testing, adult can remove with: sudo bash installer/offline-guard.sh --apply --remove'
