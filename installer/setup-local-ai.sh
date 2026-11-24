#!/usr/bin/env bash
# Adult-only, dry-run-first local inference configuration for a shared Pi 4B.
# Never installs a remote runtime via curl|sh, never downloads unprompted,
# and never enables Ollama cloud models or network binding.
set -euo pipefail
MODEL=qwen3:0.6b
APPLY=0
REMOVE=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --remove) REMOVE=1 ;;
    --model=qwen3:0.6b|--model=qwen3:1.7b|--model=gemma3:1b|--model=gemma3:270m) MODEL="${arg#--model=}" ;;
    --help|-h) echo "Usage: sudo bash installer/setup-local-ai.sh [--apply] [--remove] [--model=qwen3:0.6b]"; exit 0 ;;
    *) echo "Unsupported argument: $arg" >&2; exit 2 ;;
  esac
done
CONF=/etc/systemd/system/ollama.service.d/10-wonderforge-local-only.conf
MARKER='# Managed by WonderForge local AI setup: deny remote binding and cloud features'
OS_ARCH="$(uname -m)"
RAM_KIB="$(awk '/^MemTotal:/{print $2; exit}' /proc/meminfo 2>/dev/null || printf '0')"
RAM_MIB=$(( ${RAM_KIB:-0}/1024 ))
free_kib="$(df -Pk / 2>/dev/null | awk 'NR==2{print $4}')"
free_mib=$(( ${free_kib:-0}/1024 ))
echo "WonderForge ORBIT local AI — adult setup"
echo "Hardware: ${OS_ARCH}, RAM approx ${RAM_MIB} MiB, root filesystem free approx ${free_mib} MiB"
echo "Selected local model: $MODEL"
echo "Expected Ollama registry file sizes: qwen3:0.6b ~523MB; qwen3:1.7b ~1.4GB; gemma3:1b ~806MB; gemma3:270m ~292MB."
echo "The loaded model requires additional memory. A Pi 4B's CPU may be slow; stop inference before Luanti if needed."
echo "Only official Ollama installed by an adult is supported. No cloud account or API key is needed."
echo "Will write only $CONF, restart local ollama.service, and (unless removing) pull ONE approved model."
echo "The change is reversible with --apply --remove. Existing Ollama settings may change; review first."
if [[ $APPLY -ne 1 ]]; then
  echo 'DRY RUN. No files changed, no network requests made.'
  exit 0
fi
if [[ $EUID -ne 0 ]]; then echo 'Use sudo for --apply to change the system Ollama service.' >&2; exit 1; fi
if [[ $REMOVE -eq 1 ]]; then
  if [[ -e "$CONF" ]]; then
    if ! grep -Fq "$MARKER" "$CONF"; then echo 'Refusing to remove an unfamiliar Ollama configuration.' >&2; exit 1; fi
    rm -- "$CONF"
    systemctl daemon-reload
    systemctl restart ollama.service
  fi
  echo 'WonderForge Ollama-specific service override removed. Downloaded model files were not deleted.'
  exit 0
fi
if [[ "$OS_ARCH" != aarch64 ]]; then echo 'Real deployment requires Raspberry Pi OS 64-bit (aarch64); refusing to modify this host.' >&2; exit 1; fi
if (( RAM_MIB < 2800 )); then echo 'At least 3GB physical RAM recommended for this setup.' >&2; exit 1; fi
if (( free_mib < 2100 )); then echo 'Need at least 2.1GB free disk before pulling any model.' >&2; exit 1; fi
command -v ollama >/dev/null || { echo 'Install the official Linux ARM64 Ollama runtime first. See docs/LOCAL-AI.md.' >&2; exit 1; }
command -v systemctl >/dev/null || { echo 'systemd is required for this managed installation' >&2; exit 1; }
if ! systemctl cat ollama.service >/dev/null 2>&1; then echo 'ollama.service is not installed' >&2; exit 1; fi
if [[ -e "$CONF" ]] && ! grep -Fq "$MARKER" "$CONF"; then
  echo 'Refusing to overwrite a non-WonderForge service override.' >&2; exit 1
fi
install -d -m 0755 "$(dirname "$CONF")"
tmp="$(mktemp "${CONF}.XXXXXX")"
trap 'rm -f -- "$tmp"' EXIT
cat >"$tmp" <<EOF
$MARKER
[Service]
Environment="OLLAMA_HOST=127.0.0.1:11434"
Environment="OLLAMA_NO_CLOUD=1"
Environment="OLLAMA_NUM_PARALLEL=1"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_CONTEXT_LENGTH=2048"
EOF
chmod 0644 "$tmp"
mv -- "$tmp" "$CONF"
systemctl daemon-reload
systemctl restart ollama.service
if ! systemctl is-active --quiet ollama.service; then
  echo 'Ollama did not start: inspect journalctl -u ollama and revert with --apply --remove.' >&2
  exit 1
fi
# Only this explicitly selected approved model can be fetched. No shell eval or redirects.
ollama pull "$MODEL"
echo "Configured: http://127.0.0.1:11434 only, cloud features disabled, model $MODEL."
echo "Log into Atlas/Nova and press CHECK LOCAL MODEL in ORBIT."
