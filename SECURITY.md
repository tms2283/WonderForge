# Security and privacy

WonderForge is a local, offline-first maker *application* for a shared Raspberry Pi 4B. It is not a certified parental-control product or a supported distribution of Raspberry Pi OS.

## Reporting

Please avoid publishing vulnerabilities that expose child accounts or local files. Use the repository owner's private contact channel if available; if not, open a minimal issue without proof-of-concept secrets or identifying data.

## Threat boundaries

- **Real separation** is via Linux user accounts and private home permissions, not the visible Atlas/Nova selector.
- Production mode uses per-user short-lived tickets and an HttpOnly, SameSite=Strict session cookie. `python3 server.py` is a deliberately unauthenticated **demo** and must not be used for child account separation.
- The portal listens only on `127.0.0.1`; no API is designed to face a network.
- The optional nftables offline guard can limit outbound connections per child UID. It is not a substitute for supervision or a content-filter product.
- The team directory contains **explicit shared copies**, so other team group members can read them.
- Root and other privileged system processes remain in the operating system's trusted computing base.

## Privacy commitments

No account credentials, external analytics, profiling, ad SDKs, or automatic remote AI requests are bundled. Browser data and project notebooks should never be committed to this public repository. Test data uses fictional project names and no information identifying minors.

## Safe testing

Automated tests use temporary directories, port-zero localhost servers, and mocked Unix identities. Installers are dry-run-only unless supplied explicit `--apply`, which refuses a non-Raspberry Pi 4 Model B target. Physical installation requires a spare storage device and adult approval.

## Optional ORBIT generative AI

The optional model is a separate Ollama service running with `OLLAMA_HOST=127.0.0.1:11434` and `OLLAMA_NO_CLOUD=1`, configured only after adult approval. WonderForge never sends children's prompts to an external service or opens a model-provided URL. Model-selected tools are read-only and strictly allowlisted; draft approval is human-gated. Local generative models can still produce inaccurate or inappropriate text, and the model service is not a substitute for adult supervision or OS security. See `docs/LOCAL-AI.md` for setup, limitations and rollback.
