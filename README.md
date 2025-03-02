# Dockerized Logrotate

This container runs logrotate to manage your log files, with behavior fully configurable via environment variables.

## Configuration

Set the following environment variables to customize the container:

- **LOGROTATE_INTERVAL:** Rotation frequency (e.g., `daily`, `weekly`). Default: `daily`
- **LOG_PATH:** Directory containing log files. Default: `/logs`
- **MAX_SIZE:** Maximum file size before rotation (e.g., `10M`). Default: `10M`
- **HISTORY:** Number of rotated files to keep. Default: `7`
- **COMPRESS:** Enable compression (`true` or `false`). Default: `true`
- **DATEEXT:** Append dates to rotated filenames (`true` or `false`). Default: `true`
- **RUN_INTERVAL:** Interval in seconds between logrotate executions. Default: `60`

See [Docker Composer file](docker-compose.yml) for an example configuration.
