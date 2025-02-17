# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Add the ClickHouse repository
RUN curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg && \
    ARCH=$(dpkg --print-architecture) && \
    echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=${ARCH}] https://packages.clickhouse.com/deb stable main" | tee /etc/apt/sources.list.d/clickhouse.list && \
    apt-get update

# Install ClickHouse server and client
RUN apt-get install -y clickhouse-server clickhouse-client

# Optionally install ClickHouse Keeper (uncomment if needed)
# RUN apt-get install -y clickhouse-keeper

# Expose ClickHouse ports
EXPOSE 8123 9000 9009

# Copy custom configuration files (optional)
COPY config.xml /etc/clickhouse-server/config.xml
COPY users.xml /etc/clickhouse-server/users.xml

# Copy SQL script to initialize database (optional)
COPY init-uptrace.sql /docker-entrypoint-initdb.d/

# Start ClickHouse server
CMD ["clickhouse-server"]
