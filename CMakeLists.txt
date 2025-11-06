cmake_minimum_required(VERSION 3.20)
project(LightAP LANGUAGES CXX)

# ============================================================================
# C++ Standard Configuration (C++17 with C++14 fallback)
# ============================================================================
if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Detect C++17 compiler support
include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-std=c++17" COMPILER_SUPPORTS_CXX17)
if(COMPILER_SUPPORTS_CXX17)
    message(STATUS "C++17 support detected")
else()
    set(CMAKE_CXX_STANDARD 14)
    message(STATUS "C++17 not available, falling back to C++14")
endif()

message(STATUS "[LightAP] Using C++ standard: ${CMAKE_CXX_STANDARD}")

# ============================================================================
# Dependencies
# ============================================================================
set(CMAKE_THREAD_PREFER_PTHREAD OFF)
if(APPLE)
    set(CMAKE_THREAD_LIBS_INIT "")
    set(CMAKE_USE_PTHREADS_INIT 1)
    set(Threads_FOUND TRUE)
endif()
find_package(Threads REQUIRED)

find_package(Boost REQUIRED COMPONENTS filesystem regex system) 

find_package(GTest REQUIRED)

find_package(OpenSSL REQUIRED)

find_package(ZLIB REQUIRED)

# ============================================================================
# Testing
# ============================================================================
enable_testing()

# ============================================================================
# Build Mode Configuration
# ============================================================================
option(LAP_STANDALONE_BUILD "Build modules independently using find_package" OFF)

# 设置默认安装前缀（如果用户未指定）
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/.local/lightap" CACHE PATH "Install prefix" FORCE)
    message(STATUS "[LightAP] Using default install prefix: ${CMAKE_INSTALL_PREFIX}")
endif()

if(LAP_STANDALONE_BUILD)
    message(STATUS "[LightAP] Standalone build mode: using installed dependencies")
    
    # Find installed module dependencies
    find_package(Core 1.0 REQUIRED)
    find_package(LogAndTrace 1.0 REQUIRED)
    # Add other modules as needed
    
    message(STATUS "[LightAP] Found Core: ${Core_DIR}")
    message(STATUS "[LightAP] Found LogAndTrace: ${LogAndTrace_DIR}")
    
else()
    message(STATUS "[LightAP] Integrated build mode: building all modules together")
    message(STATUS "[LightAP] Install prefix: ${CMAKE_INSTALL_PREFIX}")
endif()

# ============================================================================
# Modules (Build Order Follows Dependency Chain)
# ============================================================================
# Layer 1: Foundation (no dependencies)
add_subdirectory(modules/Core)

# Layer 2: Core services (depends on Core)
add_subdirectory(modules/LogAndTrace)

# Layer 3: Advanced services (depends on Core + LogAndTrace)
# add_subdirectory(modules/Persistency)  # Temporarily disabled - source directory issue
# add_subdirectory(modules/Com)  # Temporarily disabled

# Layer 4: Platform services (depends on multiple modules)
# add_subdirectory(modules/PlatformHealthManagement)
