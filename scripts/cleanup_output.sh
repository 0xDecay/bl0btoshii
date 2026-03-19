#!/bin/bash
# Cron safety net: delete episode output directories older than 24 hours.
# Catches anything the pipeline cleanup missed (crashes, partial runs).
#
# Install on VPS:
#   crontab -e
#   0 4 * * * /opt/mootoshi/scripts/cleanup_output.sh >> /var/log/mootoshi-cleanup.log 2>&1

OUTPUT_DIR="/opt/mootoshi/output"

if [ ! -d "$OUTPUT_DIR" ]; then
    exit 0
fi

# Find and delete directories older than 24 hours that contain .mp4 or audio/
deleted=0
for dir in "$OUTPUT_DIR"/*/; do
    [ -d "$dir" ] || continue

    # Check if directory is older than 24 hours
    if [ "$(find "$dir" -maxdepth 0 -mmin +1440 -print 2>/dev/null)" ]; then
        rm -rf "$dir"
        echo "$(date -u '+%Y-%m-%d %H:%M:%S UTC') [Cleanup] Deleted: $(basename "$dir")"
        deleted=$((deleted + 1))
    fi
done

if [ "$deleted" -gt 0 ]; then
    echo "$(date -u '+%Y-%m-%d %H:%M:%S UTC') [Cleanup] Total deleted: $deleted directories"
fi
