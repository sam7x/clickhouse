# Use a minimal base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and install the ClickHouse standalone binary
RUN curl https://clickhouse.com/ | sh

# Set up a working directory
WORKDIR /clickhouse

# Expose ClickHouse ports (optional, for clickhouse-server)
EXPOSE 8123 9000 9009

# Default command: run clickhouse-local
CMD ["./clickhouse", "local"]
