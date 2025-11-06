# Example CMakeLists.txt for using installed LightAP modules
# 演示如何在外部项目中使用已安装的LightAP模块

cmake_minimum_required(VERSION 3.10.2)
project(MyLightAPApp VERSION 1.0.0 LANGUAGES CXX)

# C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 如果设置了LightAP安装路径，添加到CMAKE_PREFIX_PATH
if(DEFINED ENV{LIGHTAP_INSTALL_DIR})
    list(APPEND CMAKE_PREFIX_PATH "$ENV{LIGHTAP_INSTALL_DIR}")
    message(STATUS "Using LIGHTAP_INSTALL_DIR: $ENV{LIGHTAP_INSTALL_DIR}")
endif()

# 查找LightAP模块
find_package(Core 1.0 REQUIRED)
find_package(LogAndTrace 1.0 REQUIRED)

message(STATUS "Found LightAP Core: ${Core_VERSION}")
message(STATUS "Found LightAP LogAndTrace: ${LogAndTrace_VERSION}")

# 创建示例应用
add_executable(my_app
    main.cpp
)

# 链接LightAP库
target_link_libraries(my_app
    PRIVATE
        LightAP::lap_core
        LightAP::lap_log
)

# 输出信息
message(STATUS "")
message(STATUS "==============================================================================")
message(STATUS "MyLightAPApp Configuration")
message(STATUS "==============================================================================")
message(STATUS "  Build type:        ${CMAKE_BUILD_TYPE}")
message(STATUS "  C++ standard:      C++${CMAKE_CXX_STANDARD}")
message(STATUS "  Core library:      ${Core_LIBRARIES}")
message(STATUS "  Log library:       ${LogAndTrace_LIBRARIES}")
message(STATUS "==============================================================================")
