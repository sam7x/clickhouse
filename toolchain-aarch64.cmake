# Set the target system and architecture
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Specify the cross-compiler (Clang)
set(CMAKE_C_COMPILER clang-18)
set(CMAKE_CXX_COMPILER clang++-18)

# Specify the target triple for Clang
set(CMAKE_C_COMPILER_TARGET aarch64-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET aarch64-linux-gnu)

# Specify the root file system for the target (if needed)
# set(CMAKE_FIND_ROOT_PATH /path/to/aarch64/sysroot)

# Adjust the behavior of find_* commands
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
