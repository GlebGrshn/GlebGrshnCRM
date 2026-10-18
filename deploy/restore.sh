#!/bin/sh
# Usage: /opt/glebgrshncrm/restore.sh /opt/glebgrshncrm/backups/crm-YYYY-MM-DD_HHMMSS.sqlite.gz
# Replaces the live database with the backup; the current state is backed up first.
set -e
[ -f "$1" ] || { echo "usage: $0 /opt/glebgrshncrm/backups/crm-....sqlite.gz" >&2; exit 1; }
/opt/glebgrshncrm/backup.sh
docker stop glebgrshncrm >/dev/null
gunzip -c "$1" | docker run --rm -i --user root -v glebgrshncrm-data:/data glebgrshncrm:latest \
  sh -c 'cat > /data/crm.sqlite && rm -f /data/crm.sqlite-wal /data/crm.sqlite-shm && chown node:node /data/crm.sqlite'
docker start glebgrshncrm >/dev/null
echo "restored from $1"
