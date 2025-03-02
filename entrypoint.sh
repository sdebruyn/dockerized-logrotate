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

# Create a logrotate configuration file dynamically
cat <<EOF > /etc/logrotate.d/app_logrotate
${LOG_PATH}/*.log {
    ${LOGROTATE_INTERVAL}
    maxsize ${MAX_SIZE}
    rotate ${HISTORY}
    missingok
    notifempty
EOF

if [ "${COMPRESS}" = "true" ]; then
    echo "    compress" >> /etc/logrotate.d/app_logrotate
else
    echo "    nocompress" >> /etc/logrotate.d/app_logrotate
fi

if [ "${DATEEXT}" = "true" ]; then
    echo "    dateext" >> /etc/logrotate.d/app_logrotate
fi

cat <<EOF >> /etc/logrotate.d/app_logrotate
    create
}
EOF

echo "Using logrotate configuration:"
cat /etc/logrotate.d/app_logrotate

# Ensure the log directory exists
mkdir -p "${LOG_PATH}"

# Ensure the status directory exists for logrotate
mkdir -p /var/lib/logrotate

# Run logrotate at regular intervals
while true; do
    logrotate -s /var/lib/logrotate/status /etc/logrotate.d/app_logrotate
    sleep ${RUN_INTERVAL}
done

