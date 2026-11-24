# ORBIT Local AI — Raspberry Pi 4B / 4 GB installation and operating guide

**Status:** The software integration, localhost-only transport, bounded read-only agent tools, proposal approval, tests, and fallback are implemented in WonderForge v0.7. **No actual model has been executed on the family's Pi**. Expect slow CPU-only replies; do not equate an integration-test pass with demonstrated inference performance or child-safe AI.

## 1. What is included

ORBIT v0.7 can query an **optional, separately installed** Ollama instance over a fixed `127.0.0.1:11434` address. No provider URL, credentials, API keys, or model downloads are included in the repository. It uses `POST /api/chat` with `stream:false`, `think:false`, `num_ctx:2048`, `num_thread:2`, a short response cap, and a 45-second model keep-alive. At most **one** inference request is active per WonderForge server. Each question can involve at most **two read-only tool calls** and at most two local model turns. Each turn has a 75-second timeout, so long pauses are normal on a Pi 4.

The small model can select only these app-defined tools:

| Tool | Effect | Read / write? |
|---|---|---|
| `search_lessons` | Search the reviewed, original offline Field Guide | Read only |
| `search_quests` | Search the local curated quest catalog | Read only |
| `estimate_led` | Compute bounded idealized LED/resistor current and power | Read only |
| `estimate_beam` | Compute bounded idealized elastic beam deflection | Read only |

There is **no** web browsing, shell or arbitrary Python execution, filesystem reading, access to other children's journals, GPIO control, software installation, Internet access, or operating-system administration. The Python backend checks every tool name and argument independently. Model requests cannot choose an HTTP endpoint; the server only connects to the literal loopback address.

The model can suggest a **Maker Journal draft**. A draft is an unverified idea, not proof an experiment happened. The model cannot fill in observed measurements or conclusions. The user must press **APPROVE & SAVE DRAFT**, after which the usual private journal storage path saves the record. Proposals expire in 180 seconds, are single-use, and in the installed portal are bound to the authenticated browser session.

If Ollama or the selected model is unavailable, ORBIT intentionally uses the existing **scripted** offline Field Guide. The UI labels the mode; it does not present canned text as a model answer.

## 2. Model choices and the Pi 4 reality

The default is **`qwen3:0.6b`**, approximately **523 MB to download**, per the official Ollama model directory. The larger model file sizes are not RAM consumption figures; Ollama, context/cache, Chromium and the Linux desktop require additional memory. The board has **4 GB shared CPU/GPU RAM**, and model generation is CPU-bound. Start here; do not presume an instruction-following model under 1B parameters is reliably agentic. Our application validates its output and makes tools safe even when its planning is poor.

| Ollama name | Registry download size (approx.) | Use |
|---|---:|---|
| `qwen3:0.6b` | 523 MB | Default trial for Pi 4B 4 GB |
| `gemma3:270m` | 292 MB | Smaller fallback, weaker understanding; review model license |
| `gemma3:1b` | 806 MB | Optional comparison; review model license |
| `qwen3:1.7b` | 1.4 GB | Advanced experiment only; may be impractical with Chromium |

Model names are fixed in the code allowlist. Model tags with `:cloud`, arbitrary namespaces, URLs and unreviewed sizes are rejected. Qwen3-0.6B upstream model card currently says Apache-2.0; **the model weights are downloaded separately and retain their own licenses and attribution**.

Official sources consulted (23 Nov 2026):

- https://ollama.com/library/qwen3
- https://ollama.com/library/gemma3
- https://docs.ollama.com/api/chat
- https://docs.ollama.com/faq
- https://ollama.com/download/linux
- https://huggingface.co/Qwen/Qwen3-0.6B

## 3. Adult-only installation on *existing* Raspberry Pi OS

This requires Raspberry Pi OS **64-bit** (ideally current Trixie), a Pi 4B, suitable free disk space, an adult with sudo access, working time and a *temporary* approved network connection for downloading software/model weights. Keep a backup of personal projects and their current working SD card before system changes.

Verify first:

```bash
uname -m                    # Must say aarch64 for this path
free -h
df -h /
python3 --version
```

**First, install official Ollama ARM64 yourself as the adult**, following the verified Linux instructions. WonderForge intentionally does not silently pipe an Internet script into a root shell. If following Ollama's install script, first download it from its official URL, inspect the actual file and make an informed decision before executing it. Ollama's documentation also provides manual ARM64 installation instructions. Confirm the installed service exists:

```bash
command -v ollama
systemctl status ollama.service --no-pager
```

**Next, preview WonderForge's exact local-only configuration.** If the application was installed with the `.deb`, use `/opt/wonderforge/installer/setup-local-ai.sh`. If working from the cloned repo, use `installer/setup-local-ai.sh`:

```bash
sudo bash /opt/wonderforge/installer/setup-local-ai.sh
```

Dry run changes nothing. Review the output and the source before proceeding. When ready, the adult explicitly applies it:

```bash
sudo bash /opt/wonderforge/installer/setup-local-ai.sh --apply
```

This changes only its own `/etc/systemd/system/ollama.service.d/10-wonderforge-local-only.conf` drop-in, reloads and restarts the Ollama service, then explicitly pulls `qwen3:0.6b`. The setup script refuses a non-ARM64 host, very limited disk space, a missing Ollama service, and overwriting an unfamiliar drop-in. It can affect other applications using that Ollama service, so the adult should review first.

The drop-in sets:

```ini
[Service]
Environment="OLLAMA_HOST=127.0.0.1:11434"
Environment="OLLAMA_NO_CLOUD=1"
Environment="OLLAMA_NUM_PARALLEL=1"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_CONTEXT_LENGTH=2048"
```

Official Ollama documentation confirms `OLLAMA_NO_CLOUD=1` disables Ollama cloud features and default local binding is `127.0.0.1`. **This controls the Ollama service, not every other program on the Pi.** Do not expose the API on `0.0.0.0`, use reverse proxies, or add external browser origins.

Finally, log in to the real `atlas` or `nova` Linux account, launch WonderForge and press **ORBIT → CHECK LOCAL MODEL**. The badge should read `LOCAL AI · QWEN3:0.6B`. Ask "Find a lesson on resistors" or "Plan a simple experiment". Record the actual time to respond and observe System Pulse. Any request failure must visibly return to the scripted offline guide. It is okay to decide the local model is too slow and stay with the scripted mode.

## 4. Measure hardware instead of guessing

Run from the repository, or `/opt/wonderforge/tools` on an installed system:

```bash
python3 /opt/wonderforge/tools/benchmark-local-ai.py \
  --output "$HOME/wonderforge-ai-benchmark.json"
```

This makes **one local inference**, records the observed wall time and two read-only hardware snapshots, and writes its private report to the chosen location with mode `0600`. It is not a standardized tokens/second benchmark and does not measure Luanti FPS. Run the test when the Pi is cool and idle, then compare against browsing and game use separately. If temperature or throttling becomes problematic, reduce concurrent workloads and review cooling/PSU.

### Memory and concurrency decisions

- One model, one local generation at a time.
- Two CPU threads and only 2048 context tokens. Long histories are trimmed; don't request giant files.
- Agent mode has at most two short generation turns and two validated read-only tool invocations; the second turn consumes the tool's data.
- Model stays loaded 45 seconds after use. An adult can run `ollama stop qwen3:0.6b` or stop Ollama before demanding Luanti sessions.
- Prefer a decent SSD and adequate power/cooling. **No benchmark has been run on the family's Pi yet.**
- An optional model service does not make Raspberry Pi OS itself an AI operating system or create a general privileged coding agent.

## 5. Troubleshooting and explicit rollback

```bash
systemctl is-active ollama.service
ollama list
ollama ps
curl --noproxy '*' http://127.0.0.1:11434/api/tags
journalctl -u ollama.service --no-pager -n 50
```

Do not paste model conversations, the contents of children's journals, cookies, private tickets or passwords into public bug reports. For the browser portal, inspect `systemctl --user status wonderforge.service` while signed in as that child. A missing model is a normal, harmless fallback. **No model is automatically downloaded by the `.deb` installer.**

To switch models, the adult can re-run `setup-local-ai.sh --apply --model=gemma3:270m`, then set `WONDERFORGE_AI_MODEL=gemma3:270m` in the relevant nonprivileged user service environment and restart it; the selected model must match the backend's allowlist. Model selection is a system configuration change, not an arbitrary value from browser chat.

To remove just WonderForge's Ollama service override (it will *not* delete downloaded weights):

```bash
sudo bash /opt/wonderforge/installer/setup-local-ai.sh --apply --remove
```

To disable WonderForge generative inference immediately, set `WONDERFORGE_AI_ENABLED=0` for the user service and restart WonderForge. ORBIT then uses its scripted guide. For a shared Pi, the adult can alternatively stop `ollama.service` until model use is wanted.

## 6. Responsible use by children

A 0.6B model is *not* a guaranteed age-appropriate content filter, trusted safety advisor, qualified engineer, or infallible teacher. The model can hallucinate. The read-only tool allowlist mitigates system-action risk, **not every harmful or inaccurate sentence it might produce**. Adults should supervise exploration and especially real circuits, heat sources, chemicals, tools and potentially dangerous projects. Use the source-identified offline lessons as the starting point, but independently confirm important claims. Any proposed experiment still requires the human to measure and write observations. Respect the brothers' separate Linux accounts; a shared model service is not a substitute for account security.

A source update, a unit test, a mocked Ollama conversation, or a good UI screenshot **does not** establish that local inference works satisfactorily on a real 4 GB Pi. The acceptance gate is a measured Pi 4B test with an adult present.
