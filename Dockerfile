# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Add the LLVM repository for Clang 18
RUN apt-get update && \
    apt-get install -y \
    wget \
    gnupg \
    software-properties-common && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" | tee /etc/apt/sources.list.d/llvm.list && \
    apt-get update

# Install dependencies for building ClickHouse
RUN apt-get install -y \
    git \
    ninja-build \
    clang-18 \
    lld-18 \
    llvm-18 \
    libicu-dev \
    libssl-dev \
    libboost-dev \
    binutils-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu && \
    rm -rf /var/lib/apt/lists/*

# Install a newer version of CMake (3.25 or higher)
RUN wget -qO- https://github.com/Kitware/CMake/releases/download/v3.27.7/cmake-3.27.7-linux-x86_64.tar.gz | tar -xz --strip-components=1 -C /usr/local

# Clone the ClickHouse repository and initialize submodules
RUN git clone --recursive https://github.com/ClickHouse/ClickHouse.git /clickhouse
WORKDIR /clickhouse

# Ensure submodules are fully updated
RUN git submodule update --init --recursive

# Copy the toolchain file
COPY toolchain-aarch64.cmake cmake/linux/toolchain-aarch64.cmake

# Build ClickHouse for AARCH64
RUN mkdir build && \
    cd build && \
    cmake .. \
        -DCMAKE_TOOLCHAIN_FILE=cmake/linux/toolchain-aarch64.cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_TESTS=0 && \
    make -j1  # Further reduced parallelism

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
