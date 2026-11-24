#!/usr/bin/env bash
# Build a truly bootable Raspberry Pi image with the official builder ON A CAPABLE ARM64 HOST.
# This script prepares a custom overlay and runs the official rpi-image-gen workflow.
# Development recipe: not a verified boot image, never overwrite the kids' only SD.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RECIPE="$ROOT/image"
CACHE="${WONDERFORGE_IMAGE_WORK:-$ROOT/../wonderforge-image-work}"
REPO="$CACHE/rpi-image-gen"
STAGE=""
PIN='56ce7c6180fc2e6ac143f6b43ae978949fe22fe7'
BUILD=0
for arg in "$@"; do case "$arg" in --build) BUILD=1;; --help|-h) echo 'Usage: bash image/build-image.sh [--build]';exit 0;; *) echo "Unknown: $arg" >&2;exit 2;; esac;done
printf 'Experimental WonderForge IMAGE build plan:\n'
printf 'Host requirement: Raspberry Pi OS 64-bit Trixie on ARM64, 12 GB+ free disk, builder dependencies\n'
printf 'Recipe: %s\nBuilder: %s at %s\nWork: %s\n' "$RECIPE/wonderforge-pi4.yaml" 'raspberrypi/rpi-image-gen' "$PIN" "$CACHE"
echo 'This build does not generate passwords or establish an adult login automatically.'
echo 'It stages payload only at first boot. Adult must finish official OS login and explicitly provision accounts.'
if (( !BUILD )); then echo 'DRY RUN ONLY. Add --build on an arm64 development host.';exit 0;fi
[[ $(uname -m) == aarch64 ]] || { echo 'Native AArch64 Raspberry Pi OS build host required for this supported path.' >&2;exit 1; }
[[ -f /etc/os-release ]] || { echo 'Cannot verify host OS.' >&2;exit 1; }
# shellcheck disable=SC1091
source /etc/os-release
[[ ${VERSION_CODENAME:-} == trixie ]] || { echo 'Use a Debian Trixie ARM64 host.' >&2;exit 1; }
command -v git >/dev/null || { echo 'git is required.' >&2;exit 1; }
(( $(df -Pk "$(dirname "$CACHE")" | awk 'NR==2{print $4}') > 12000000 )) || {
 echo 'At least 12GB free disk is required.' >&2;exit 1; }
mkdir -p "$CACHE"
if [[ ! -d "$REPO/.git" ]]; then git clone https://github.com/raspberrypi/rpi-image-gen.git "$REPO";fi
(cd "$REPO" && git fetch --tags origin && git checkout --detach "$PIN")
# Build each attempt in its own unique staging directory. Never recursively
# remove a user-specified path from WONDERFORGE_IMAGE_WORK.
STAGE="$(mktemp -d "$CACHE/source.XXXXXXXX")"
mkdir -p "$STAGE/layer/wonderforge-maker.d/customize.overlay/opt/wonderforge-preinstall" \
         "$STAGE/layer/wonderforge-maker.d/customize.overlay/usr/local/sbin" \
         "$STAGE/layer/wonderforge-maker.d/customize.overlay/etc/systemd/system/multi-user.target.wants" \
         "$STAGE/layer/wonderforge-maker.d/customize.overlay/etc/systemd/system"
cp "$RECIPE/wonderforge-pi4.yaml" "$STAGE/config.yaml"
cp "$RECIPE/layer/wonderforge-maker.yaml" "$STAGE/layer/wonderforge-maker.yaml"
# Only source/material needed at first boot; 3D/game content is original and local.
for part in web data docs design installer scripts os tools server.py portal_security.py README.md; do cp -a "$ROOT/$part" "$STAGE/layer/wonderforge-maker.d/customize.overlay/opt/wonderforge-preinstall/";done
install -m 0755 "$RECIPE/firstboot.sh" "$STAGE/layer/wonderforge-maker.d/customize.overlay/usr/local/sbin/wonderforge-firstboot"
install -m 0644 "$RECIPE/wonderforge-firstboot.service" "$STAGE/layer/wonderforge-maker.d/customize.overlay/etc/systemd/system/wonderforge-firstboot.service"
ln -s ../wonderforge-firstboot.service "$STAGE/layer/wonderforge-maker.d/customize.overlay/etc/systemd/system/multi-user.target.wants/wonderforge-firstboot.service"
# A customized image must still be provisioned with an adult account via a
# separately validated first-user/OS-image flow. Never ship factory passwords.
if [[ ! -x "$REPO/rpi-image-gen" ]]; then echo 'Official builder entrypoint not executable.' >&2;exit 1;fi
(cd "$REPO" && ./rpi-image-gen metadata --lint "$STAGE/layer/wonderforge-maker.yaml")
(cd "$REPO" && ./rpi-image-gen config "$STAGE/config.yaml")
(cd "$REPO" && ./rpi-image-gen build -S "$STAGE" -c "$STAGE/config.yaml")
echo "Build command finished. Search output under $REPO/work/. Do not flash onto the only SD card."
