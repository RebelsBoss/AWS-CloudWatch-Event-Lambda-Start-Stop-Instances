#!/bin/bash
LOG_DIR="/var/log"
LOG_FILE="$LOG_DIR/session_count.log"
NGINX_PORT=8080

archive_log() {
    if [ -f "$LOG_FILE" ]; then
        CURRENT_DATE=$(date +'%Y-%m-%d')
        ARCHIVE_FILE="$LOG_DIR/session_count_$CURRENT_DATE.log.gz"
        gzip -c "$LOG_FILE" > "$ARCHIVE_FILE"
        > "$LOG_FILE"
        find "$LOG_DIR" -type f -name 'session_count_*.log.gz' -mtime +2 -delete
    fi
}

if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi

while true; do
    if [ "$(date +'%H%M')" == "0000" ]; then
        archive_log
    fi
    SESSION_COUNT=$(netstat -an | grep -c ":$NGINX_PORT.*ESTABLISHED")
    echo "$(date +'%Y-%m-%d %H:%M:%S') $SESSION_COUNT" >> "$LOG_FILE"
    sleep 5
done
