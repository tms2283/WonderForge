#!/usr/bin/env python3
"""Read-only benchmark of actual local model on its deployment host.

Does not claim other people's Pi performance, install packages, or upload results.
One deterministic local inference request, no account, URL or remote service.
"""
import argparse
import json
import os
from pathlib import Path
import sys
import time
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import local_ai
import device_health


def run():
    parser=argparse.ArgumentParser(description='Benchmark the installed local Ollama model on the current machine')
    parser.add_argument('--output', type=Path, help='Optional local JSON result path (keep private)')
    args=parser.parse_args()
    before=device_health.sample()
    info=local_ai.status()
    if not info['available']:
        raise SystemExit('Local model not ready: '+info.get('reason','unknown'))
    start=time.monotonic()
    # One round trip for latency; avoid ingesting a minor’s private journal data.
    text=local_ai._model_chat([{'role':'system','content':'Answer in two short sentences.'},
                               {'role':'user','content':'Explain one safe experiment using paper bridges.'}],max_tokens=90)
    elapsed=round(time.monotonic()-start,2)
    after=device_health.sample()
    result={'model':local_ai.selected_model(),'elapsed_seconds':elapsed,
            'answer_characters':len(text),'device_before':before,'device_after':after,
            'note':'One local CPU inference sample, not a gameplay FPS or scientific performance guarantee.'}
    if args.output:
        args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
        os.chmod(args.output,0o600)
        print('Private benchmark result written to '+str(args.output))
    else:
        print(json.dumps(result,indent=2))

if __name__=='__main__':run()
