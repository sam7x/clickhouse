# Use an official CentOS base image
FROM centos:8

# Set the maintainer label
LABEL maintainer="your-email@example.com"

# Install dependencies
RUN yum update -y && \
    yum install -y \
    curl \
    gnupg2 \
    ca-certificates \
    && rm -rf /var/cache/yum/*

# Add the ClickHouse RPM repository
RUN curl -fsSL https://packages.clickhouse.com/rpm/clickhouse.repo | tee /etc/yum.repos.d/clickhouse.repo

# Install ClickHouse server and client
RUN yum install -y clickhouse-server clickhouse-client

# Expose ClickHouse ports
EXPOSE 8123 9000 9009

# Set up ClickHouse configuration (optional)
COPY config.xml /etc/clickhouse-server/config.xml
COPY users.xml /etc/clickhouse-server/users.xml

# Copy SQL script to initialize database
COPY init-uptrace.sql /docker-entrypoint-initdb.d/

# Start ClickHouse server
CMD ["clickhouse-server"]
