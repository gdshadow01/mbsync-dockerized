FROM debian:bookworm-slim

# Install mbsync (isync package) and other necessary tools
RUN apt-get update && apt-get install -y \
    isync \
    ca-certificates \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Create directories for config and mail storage
RUN mkdir -p /config /Mail /scripts && \
    chmod 700 -R /Mail

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh 
  
# Volumes for persistence
VOLUME ["/config", "/Mail"]

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
