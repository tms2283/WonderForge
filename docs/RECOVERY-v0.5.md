# WonderForge v0.5 · Adult-led Backup, Recovery & Safe Update Plan

**First rule:** Preserve the family's currently working boot storage until a newly installed spare card has successfully rebooted multiple times. No file here erases or partitions a boot card.

## What is saved where

- Atlas private files and SQLite data: `/home/atlas/`, including `.local/share/wonderforge/workshop.sqlite3`, Chromium profile, Luanti world, and individual working files.
- Nova: `/home/nova/`, structurally independent.
- Explicitly shared notebooks/blueprints: `/srv/wonderforge/team/`, group-owned. Neither home is automatically shared.
- Root-owned app release: `/opt/wonderforge/`, replaceable by installing a compatible `.deb`; not part of personal-data backup.

## Backup on the Pi

Choose a physically separate **adult-controlled, encrypted mounted drive**. After reviewing the dry-run:

```bash
sudo bash /opt/wonderforge/scripts/backup-family.sh --dest=/media/YOUR_ENCRYPTED_DRIVE
sudo bash /opt/wonderforge/scripts/backup-family.sh --dest=/media/YOUR_ENCRYPTED_DRIVE --apply
```

The script refuses obvious destination symlinks and destinations beneath the backed-up paths, creates a private tar archive, audits member paths and writes a SHA-256 receipt. It does **not** encrypt the archive. **If the inspector rejects symlinks or unusual files in a home, the backup will fail safely rather than silently claim success**; the adult must choose an appropriate trusted archival procedure. Do not upload an unencrypted family archive into a publicly shared drive.

Verify integrity again without extracting:

```bash
sha256sum -c /media/YOUR_ENCRYPTED_DRIVE/wonderforge-family-YYYYMMDDTHHMMSSZ.tar.gz.sha256
python3 /opt/wonderforge/tools/inspect-backup.py /media/YOUR_ENCRYPTED_DRIVE/wonderforge-family-YYYYMMDDTHHMMSSZ.tar.gz
```

The inspector rejects traversal, absolute paths, device/special entries and symlinks; it gives an entry count and SHA digest. This is **only an archive-format and pathname check**, not proof of successful restoration or the full absence of malware.

## Recovery without overwriting the latest work

1. If the new OS does not boot, power off, remove the spare card, return the original unchanged card, and bring up the original OS.
2. If the new app fails but the OS works, stop the per-user service (`systemctl --user stop wonderforge.service`) and use the regular Raspberry Pi OS desktop. You can uninstall the `.deb` from the adult account without deleting homes.
3. If optional outbound blocking breaks intended networking, adult runs `sudo bash /opt/wonderforge/installer/offline-guard.sh --apply --remove` from the adult account.
4. **Do not extract an unfamiliar tar directly over `/home` or `/srv`.** Inspect its member list and integrity receipt first. Restore into a secured staging directory on a trusted, separately prepared Linux system and carefully copy only the verified needed files into the appropriate user's home, restoring ownership and mode. This requires human judgement and is deliberately not a one-click destructive script.
5. Before upgrading, export JSON from the Project Vault and copy private SQLite backups while WonderForge is stopped. Keep one older package copy for rollback.

## What the scripts do not cover

These tools do not snapshot a live filesystem atomically, encrypt backups, back up the operating system or restore system packages, recover a lost encryption key, resolve damaged flash storage, or provide a tested disaster-recovery service. They are safer building blocks pending real-device validation.
