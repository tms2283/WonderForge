# WonderForge 0.7.0 QA evidence report

**Development host:** Linux x86-64. **Physical target:** Raspberry Pi 4B, 4GB RAM, Raspberry Pi OS 64-bit. **Date:** 23 November 2026.

| Verification | Result | Interpretation |
|---|---|---|
| Python automated suite | PASS, 51 tests | Unit/integration behavior on development host |
| Python compile checks | PASS | Syntax is accepted by local Python (CI also checks 3.11 and 3.12) |
| Node.js syntax (`web/app.js`, `web/labs.js`, `web/journal.js`) | PASS | No syntax errors; not a browser performance benchmark |
| Shell parser on installer, image and packaging scripts | PASS | No shell parse error; privileged `--apply` was NOT run |
| Browser protocol simulation | PASS | ORBIT response, source labels, draft approval, fallback and responsive 390px view |
| Existing journal/system browser smoke | PASS | Existing screens remain usable after changes |
| Fake localhost Ollama | PASS | Actual HTTP client JSON exchange and two-turn tool path; NOT model inference speed/quality |
| Private API unauthorized/CSRF/replay tests | PASS | Portal tests reject unauthenticated requests and reused proposals |
| Source package and Debian payload | PASS | Application files present, including `local_ai.py` and adult setup utility |
| Local model, real Pi throughput | **NOT RUN** | Requires actual board, installed weights, PSU and cooling |
| True OS login / Luanti launch / unplugged operation | **NOT RUN** | Requires the family's Pi and adult consent |
| Bootable image | **NOT APPLICABLE** | User prefers installing onto existing Raspberry Pi OS |

**Security boundaries:** fixed loopback transport, no browser direct access to Ollama, model-selected calls restricted to four read-only methods, user approval before client journal write, production HttpOnly portal sessions, no model weights or credentials in source tree. These measures do not make a tiny model safe to leave with children unsupervised.

Review `docs/RELEASE-GATES-v0.7.md` for the outstanding physical gates. Do not turn this report's CI green status into a claim that ARM64 GPU/CPU graphics or local model performance has been certified.
