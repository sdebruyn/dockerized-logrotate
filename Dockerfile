FROM alpine:latest

# Install logrotate and bash
RUN apk update && apk add --no-cache logrotate bash coreutils

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create directories that logrotate will need
RUN mkdir -p /tmp/logrotate /tmp/logrotate-status

CMD ["/entrypoint.sh"]
