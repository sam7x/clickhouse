# Use the official Ubuntu base image
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add ClickHouse repository
RUN curl https://repo.clickhouse.com/CLICKHOUSE-KEY.GPG | tee /etc/apt/trusted.gpg.d/clickhouse.asc && \
    echo "deb https://packages.clickhouse.com/deb/dists/stable/InRelease main/" > /etc/apt/sources.list.d/clickhouse.list

# Install ClickHouse
RUN apt-get update && \
    apt-get install -y clickhouse-server clickhouse-client && \
    rm -rf /var/lib/apt/lists/*

# Expose ClickHouse ports
EXPOSE 8123 9000 9009

# Copy ClickHouse configuration files
COPY config.xml /etc/clickhouse-server/config.xml
COPY users.xml /etc/clickhouse-server/users.xml
COPY init-uptrace.sql /docker-entrypoint-initdb.d/

# Start ClickHouse
CMD ["clickhouse-server"]
