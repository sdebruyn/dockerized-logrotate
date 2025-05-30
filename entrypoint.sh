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
EOF

if [ "${COMPRESS}" = "true" ]; then
    echo "    compress" >> ${CONFIG_DIR}/app_logrotate
else
    echo "    nocompress" >> ${CONFIG_DIR}/app_logrotate
fi

if [ "${DATEEXT}" = "true" ]; then
    echo "    dateext" >> ${CONFIG_DIR}/app_logrotate
fi

cat <<EOF >> ${CONFIG_DIR}/app_logrotate
    nocreate
}
EOF

echo "Using logrotate configuration:"
cat ${CONFIG_DIR}/app_logrotate

# Ensure the log directory exists
mkdir -p "${LOG_PATH}"

# Ensure the status directory exists for logrotate
mkdir -p /tmp/logrotate-status

# Run logrotate at regular intervals
while true; do
    logrotate -v -s /tmp/logrotate-status/status ${CONFIG_DIR}/app_logrotate
    sleep ${RUN_INTERVAL}
done
