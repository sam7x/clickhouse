# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for building ClickHouse
RUN apt-get update && \
    apt-get install -y \
    git \
    cmake \
    ninja-build \
    gcc \
    g++ \
    clang \
    lld \
    llvm \
    libicu-dev \
    libreadline-dev \
    libssl-dev \
    libtool \
    libltdl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libbz2-dev \
    liblz4-dev \
    libzstd-dev \
    libdouble-conversion-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-regex-dev \
    libboost-thread-dev \
    libboost-context-dev \
    libboost-iostreams-dev \
    libboost-locale-dev \
    libboost-date-time-dev \
    libboost-atomic-dev \
    libboost-chrono-dev \
    libboost-log-dev \
    libpoco-dev \
    libcapnp-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libcctz-dev \
    libgtest-dev \
    libgmock-dev \
    libhyperscan-dev \
    libre2-dev \
    libzookeeper-mt-dev \
    librdkafka-dev \
    libavro-dev \
    libsnappy-dev \
    liblzma-dev \
    libpq-dev \
    libmysqlclient-dev \
    libodbc-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install AARCH64 cross-compilation toolchain
RUN apt-get update && \
    apt-get install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

# Clone the ClickHouse repository
RUN git clone https://github.com/ClickHouse/ClickHouse.git /clickhouse
WORKDIR /clickhouse

# Build ClickHouse for AARCH64
RUN mkdir build && \
    cd build && \
    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE=cmake/linux/toolchain-aarch64.cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_TESTS=0 && \
    make -j$(nproc)

# Expose ClickHouse ports
EXPOSE 8123 9000 9009

# Copy custom configuration files (optional)
COPY config.xml /clickhouse/build/programs/server/config.xml
COPY users.xml /clickhouse/build/programs/server/users.xml

# Copy SQL script to initialize database (optional)
COPY init-uptrace.sql /docker-entrypoint-initdb.d/

# Set the working directory to the ClickHouse build directory
WORKDIR /clickhouse/build/programs

# Start ClickHouse server
CMD ["./clickhouse-server"]
