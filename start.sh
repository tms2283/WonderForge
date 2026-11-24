#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${WONDERFORGE_PORT:-8765}"
python3 "$DIR/server.py" --port "$PORT" &
PID=$!
cleanup() { kill "$PID" 2>/dev/null || true; }
trap cleanup EXIT INT TERM
sleep 0.5
if command -v xdg-open >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
  xdg-open "http://127.0.0.1:$PORT/" >/dev/null 2>&1 || true
else
  echo "Open http://127.0.0.1:$PORT/ in your web browser."
fi
wait "$PID"
