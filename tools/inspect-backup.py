#!/usr/bin/env python3
"""Read-only safety audit of WonderForge family backup archives.

This does NOT decrypt, extract, overwrite, or recover files. The family archive
is NOT encrypted by the backup script. Inspect prior to any manual restore.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import stat
import tarfile

ALLOWED = ('home/atlas', 'home/nova', 'srv/wonderforge/team')
MAX_MEMBERS = 500_000
MAX_LOGICAL_BYTES = 250 * 1024**3


def audit(path: Path, expected_sha256: str | None = None) -> dict:
    report = {'archive': str(path), 'ok': False, 'members': 0, 'regular_files': 0,
              'logical_bytes': 0, 'issues': [], 'sha256': ''}
    if not path.is_file() or path.is_symlink():
        report['issues'].append('Archive missing, symlinked, or not a regular file')
        return report
    actual = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            actual.update(chunk)
    report['sha256'] = actual.hexdigest()
    if expected_sha256 and expected_sha256.lower() != report['sha256']:
        report['issues'].append('SHA-256 checksum does not match')
    try:
        with tarfile.open(path, 'r:gz') as archive:
            for member in archive:
                report['members'] += 1
                if report['members'] > MAX_MEMBERS:
                    report['issues'].append('Unusually large number of archive entries')
                    break
                parts = PurePosixPath(member.name).parts
                path_str = '/'.join(parts)
                if member.name.startswith('/') or not parts or '..' in parts or '.' in parts:
                    report['issues'].append('Unsafe archive path')
                    break
                if not any(path_str == p or path_str.startswith(p + '/') for p in ALLOWED):
                    report['issues'].append('Unexpected archive path: ' + path_str[:110])
                    break
                if member.issym() or member.islnk() or member.isdev() or member.isfifo():
                    report['issues'].append('Unsafe archive entry type at: ' + path_str[:110])
                    break
                if not (member.isfile() or member.isdir()):
                    report['issues'].append('Unsupported archive entry type: ' + path_str[:110])
                    break
                if member.isfile():
                    report['regular_files'] += 1
                    report['logical_bytes'] += member.size
                    if report['logical_bytes'] > MAX_LOGICAL_BYTES:
                        report['issues'].append('Backup exceeds audit maximum logical size')
                        break
    except (OSError, tarfile.TarError, EOFError) as exc:
        report['issues'].append('Cannot read archive: ' + str(exc)[:200])
    report['ok'] = not report['issues']
    return report


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('archive', type=Path)
    p.add_argument('--sha256', help='expected lowercase hexadecimal SHA-256')
    p.add_argument('--json', action='store_true')
    args = p.parse_args()
    result = audit(args.archive, args.sha256)
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print('WONDERFORGE / READ-ONLY FAMILY BACKUP AUDIT')
        for k, v in result.items():
            print(f'{k}: {v}')
        print('Inspect files with an adult before manual restoration. Backup is UNENCRYPTED.')
    raise SystemExit(0 if result['ok'] else 2)
