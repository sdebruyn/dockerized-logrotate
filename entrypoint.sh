#!/bin/bash
set -e

# Set default values if environment variables are not provided
LOGROTATE_INTERVAL="${LOGROTATE_INTERVAL:-daily}"
LOG_PATH="${LOG_PATH:-/logs}"
MAX_SIZE="${MAX_SIZE:-10M}"
HISTORY="${HISTORY:-7}"
COMPRESS="${COMPRESS:-true}"
DATEEXT="${DATEEXT:-true}"
RUN_INTERVAL="${RUN_INTERVAL:-60}"
RUN_AS_USER="${RUN_AS_USER:-0}"
RUN_AS_GROUP="${RUN_AS_GROUP:-0}"

# Create user if it doesn't exist
if ! id -u loguser >/dev/null 2>&1; then
    echo "Creating loguser with UID:${RUN_AS_USER} GID:${RUN_AS_GROUP}"
    addgroup -g $RUN_AS_GROUP loguser 2>/dev/null || echo "Group already exists or couldn't be created"
    adduser -D -u $RUN_AS_USER -G loguser loguser 2>/dev/null || echo "User already exists or couldn't be created"
else
    echo "User loguser already exists"
fi

# Create config directory in user-writable location
CONFIG_DIR="/tmp/logrotate"
mkdir -p "${CONFIG_DIR}"

# Create a logrotate configuration file dynamically
cat <<EOF > ${CONFIG_DIR}/app_logrotate
${LOG_PATH}/*.log {
    ${LOGROTATE_INTERVAL}
    maxsize ${MAX_SIZE}
    rotate ${HISTORY}
    missingok
    notifempty
    copytruncate
    su loguser loguser
    nocreate
    sharedscripts
EOF

if [ "${COMPRESS}" = "true" ]; then
    echo "    compress" >> ${CONFIG_DIR}/app_logrotate
else
    echo "    nocompress" >> ${CONFIG_DIR}/app_logrotate
fi

if [ "${DATEEXT}" = "true" ]; then
    echo "    dateext" >> ${CONFIG_DIR}/app_logrotate
    echo "    dateformat -%Y%m%d-%H%M%S" >> ${CONFIG_DIR}/app_logrotate
fi

echo "Using logrotate configuration:"
cat ${CONFIG_DIR}/app_logrotate

# Ensure the log directory exists
mkdir -p "${LOG_PATH}"

# Ensure the status directory exists for logrotate
mkdir -p /tmp/logrotate-status

# Run logrotate at regular intervals
while true; do
    echo "Running logrotate at $(date)"
    
    # Run logrotate with force option only if debug mode is enabled, otherwise use normal mode
    if [ "${DEBUG:-false}" = "true" ]; then
        logrotate -d -v -s /tmp/logrotate-status/status ${CONFIG_DIR}/app_logrotate
    else
        logrotate -v -s /tmp/logrotate-status/status ${CONFIG_DIR}/app_logrotate
    fi
    
    echo "Logrotate completed. Sleeping for ${RUN_INTERVAL} seconds..."
    sleep ${RUN_INTERVAL}
done
