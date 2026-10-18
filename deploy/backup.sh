#!/bin/sh
# Consistent SQLite snapshot while the CRM keeps running (VACUUM INTO); 14 days kept in /opt/glebgrshncrm/backups.
# Cron: /etc/cron.d/glebgrshncrm-backup runs it daily at 03:15.
set -e
umask 077
name="crm-$(date +%Y-%m-%d_%H%M%S).sqlite"
docker exec glebgrshncrm node -e "new (require('node:sqlite').DatabaseSync)(process.env.DB_PATH).exec(\"VACUUM INTO '/app/data/$name'\")" 2>/dev/null
mkdir -p /opt/glebgrshncrm/backups
docker cp "glebgrshncrm:/app/data/$name" "/opt/glebgrshncrm/backups/$name"
docker exec glebgrshncrm rm -f "/app/data/$name"
gzip -f "/opt/glebgrshncrm/backups/$name"
find /opt/glebgrshncrm/backups -name 'crm-*.sqlite.gz' -mtime +14 -delete
echo "$(date -Is) backup /opt/glebgrshncrm/backups/$name.gz"
