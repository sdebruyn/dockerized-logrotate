FROM alpine:latest

# Install logrotate and bash
RUN apk update && apk add --no-cache logrotate bash

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
