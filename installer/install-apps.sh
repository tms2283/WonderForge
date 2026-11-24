#!/usr/bin/env bash
# Install only curated package sets after adult consent; preview is default.
set -euo pipefail
CORE=(luanti luanti-game-minetest thonny gimp inkscape)
EXTRAS=(openscad kicad stellarium audacity krita)
apply=0; extras=0
usage(){ echo 'Usage: sudo bash installer/install-apps.sh [--apply] [--extras]'; }
for arg in "$@"; do case "$arg" in --apply) apply=1;; --extras) extras=1;; -h|--help) usage;exit 0;; *) usage >&2;exit 2;; esac;done
packages=("${CORE[@]}"); if (( extras )); then packages+=("${EXTRAS[@]}"); fi
printf 'WonderForge optional approved app set: %s\n' "${packages[*]}"
if (( !apply )); then echo 'DRY RUN. To install, rerun with --apply (sudo required).';exit 0;fi
[[ $EUID -eq 0 ]] || { echo 'Run as root via sudo.' >&2;exit 1; }
command -v apt-get >/dev/null || { echo 'Debian apt-get required.' >&2;exit 1; }
apt-get update
missing=()
for pkg in "${packages[@]}"; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then :; else missing+=("$pkg"); fi
done
if ((${#missing[@]}>0)); then printf 'Not found in apt sources: %s\n' "${missing[*]}" >&2;exit 1;fi
apt-get install -y --no-install-recommends "${packages[@]}"
echo 'Approved applications installed; launch from Creation Studios or Linux applications menu.'
