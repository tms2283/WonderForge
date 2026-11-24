#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v godot >/dev/null 2>&1; then
    echo 'Godot 4.7.x runtime is required.' >&2
    exit 1
fi
exec godot --rendering-method forward_plus --path . -- --quality=ultra
