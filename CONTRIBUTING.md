# Contributing to WonderForge

WonderForge is a maker environment for one shared Raspberry Pi 4B with 4 GB of RAM. Optimizing for its real constraints matters more than adding a speculative feature checklist.

## Contribution rules

- Keep a usable offline path: no forced network services, remote fonts, analytics, external JavaScript frameworks, or automatic cloud AI calls.
- Every educational feature must have a concrete learning outcome, a way to test an idea, and a way to keep evidence; do not gamify performance anxiety or equate quest completion with mastery.
- Keep local privilege boundaries: children have standard accounts, the parent retains system administration, explicit sharing crosses accounts via Team Forge. Never use loopback ports or cosmetic profiles as security.
- A hardware claim needs a real Pi 4B test. State hardware-untested status if no physical device is available.
- Own and license your assets or provide the full compatible source/license attribution. Do not commit children's photos, names, school details, credentials, real experiment journal data, or package caches.

## Local validation

```bash
python3 -m unittest discover -s tests -v
node --check web/app.js && node --check web/labs.js && node --check web/journal.js
for s in installer/*.sh scripts/*.sh image/*.sh; do bash -n "$s"; done
bash scripts/build-deb.sh /tmp/wonderforge-artifacts
```

## Before opening a pull request

Explain *what actually works*, what still needs physical Raspberry Pi validation, risk to existing user state, the manual test performed, and how to roll back. Avoid pushing untested image builders or internet restrictions as defaults.
