#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v godot >/dev/null 2>&1; then
    echo 'Godot 4.7.x runtime is required. This is a source project, not an ARM64 binary.' >&2
    exit 1
fi
exec godot --rendering-method gl_compatibility --path . -- --quality=explorer
