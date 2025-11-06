#!/bin/bash
#
# 检查LightAP模块依赖是否满足
# Usage: ./check_dependencies.sh [module_name]
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MODULE_NAME="${1:-all}"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}LightAP 模块依赖检查${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# 检查系统依赖
check_system_dependency() {
    local dep=$1
    local package=$2
    
    if command -v "$dep" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $dep"
        return 0
    else
        echo -e "  ${RED}✗${NC} $dep ${YELLOW}(安装: $package)${NC}"
        return 1
    fi
}

# 检查库依赖
check_library() {
    local lib=$1
    local package=$2
    
    if ldconfig -p | grep -q "$lib" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $lib"
        return 0
    elif pkg-config --exists "$lib" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $lib ($(pkg-config --modversion $lib))"
        return 0
    else
        echo -e "  ${RED}✗${NC} $lib ${YELLOW}(安装: $package)${NC}"
        return 1
    fi
}

# 检查头文件
check_header() {
    local header=$1
    
    if [ -f "/usr/include/$header" ] || [ -f "/usr/local/include/$header" ]; then
        echo -e "  ${GREEN}✓${NC} $header"
        return 0
    else
        echo -e "  ${YELLOW}?${NC} $header (未找到，但可能不影响编译)"
        return 0
    fi
}

# 通用依赖（所有模块）
echo -e "${BLUE}[通用依赖]${NC}"
MISSING_GENERAL=0
check_system_dependency "cmake" "sudo apt install cmake" || ((MISSING_GENERAL++))
check_system_dependency "g++" "sudo apt install build-essential" || ((MISSING_GENERAL++))
check_system_dependency "git" "sudo apt install git" || ((MISSING_GENERAL++))
check_system_dependency "pkg-config" "sudo apt install pkg-config" || ((MISSING_GENERAL++))
echo ""

# Core模块依赖
if [ "$MODULE_NAME" = "all" ] || [ "$MODULE_NAME" = "Core" ]; then
    echo -e "${BLUE}[Core 模块依赖]${NC}"
    MISSING_CORE=0
    check_library "boost_system" "sudo apt install libboost-all-dev" || ((MISSING_CORE++))
    check_library "boost_filesystem" "sudo apt install libboost-filesystem-dev" || ((MISSING_CORE++))
    check_library "gtest" "sudo apt install libgtest-dev" || ((MISSING_CORE++))
    check_library "ssl" "sudo apt install libssl-dev" || ((MISSING_CORE++))
    check_library "z" "sudo apt install zlib1g-dev" || ((MISSING_CORE++))
    echo ""
fi

# LogAndTrace模块依赖
if [ "$MODULE_NAME" = "all" ] || [ "$MODULE_NAME" = "LogAndTrace" ]; then
    echo -e "${BLUE}[LogAndTrace 模块依赖]${NC}"
    MISSING_LOG=0
    echo -e "${YELLOW}  必需模块:${NC}"
    if [ -f "build/modules/Core/liblap_core.so.1" ]; then
        echo -e "    ${GREEN}✓${NC} Core (已构建)"
    else
        echo -e "    ${RED}✗${NC} Core (需要先构建Core模块)"
        ((MISSING_LOG++))
    fi
    
    echo -e "${YELLOW}  外部依赖:${NC}"
    check_library "dlt" "sudo apt install libdlt-dev" || ((MISSING_LOG++))
    check_library "boost_regex" "sudo apt install libboost-regex-dev" || ((MISSING_LOG++))
    echo ""
fi

# Com模块依赖
if [ "$MODULE_NAME" = "all" ] || [ "$MODULE_NAME" = "Com" ]; then
    echo -e "${BLUE}[Com 模块依赖]${NC}"
    MISSING_COM=0
    echo -e "${YELLOW}  必需模块:${NC}"
    if [ -f "build/modules/Core/liblap_core.so.1" ]; then
        echo -e "    ${GREEN}✓${NC} Core"
    else
        echo -e "    ${RED}✗${NC} Core"
        ((MISSING_COM++))
    fi
    if [ -f "build/modules/LogAndTrace/liblap_log.so.1" ]; then
        echo -e "    ${GREEN}✓${NC} LogAndTrace"
    else
        echo -e "    ${RED}✗${NC} LogAndTrace"
        ((MISSING_COM++))
    fi
    
    echo -e "${YELLOW}  外部依赖:${NC}"
    check_library "sdbus-c++" "sudo apt install libsdbus-c++-dev" || ((MISSING_COM++))
    check_library "protobuf" "sudo apt install libprotobuf-dev protobuf-compiler" || ((MISSING_COM++))
    check_header "nlohmann/json.hpp" || true
    echo ""
fi

# Persistency模块依赖
if [ "$MODULE_NAME" = "all" ] || [ "$MODULE_NAME" = "Persistency" ]; then
    echo -e "${BLUE}[Persistency 模块依赖]${NC}"
    MISSING_PER=0
    echo -e "${YELLOW}  必需模块:${NC}"
    if [ -f "build/modules/Core/liblap_core.so.1" ]; then
        echo -e "    ${GREEN}✓${NC} Core"
    else
        echo -e "    ${RED}✗${NC} Core"
        ((MISSING_PER++))
    fi
    if [ -f "build/modules/LogAndTrace/liblap_log.so.1" ]; then
        echo -e "    ${GREEN}✓${NC} LogAndTrace"
    else
        echo -e "    ${RED}✗${NC} LogAndTrace"
        ((MISSING_PER++))
    fi
    
    echo -e "${YELLOW}  外部依赖:${NC}"
    check_library "sqlite3" "sudo apt install libsqlite3-dev" || ((MISSING_PER++))
    check_library "boost_thread" "sudo apt install libboost-thread-dev" || ((MISSING_PER++))
    echo ""
fi

# PlatformHealthManagement模块依赖
if [ "$MODULE_NAME" = "all" ] || [ "$MODULE_NAME" = "PlatformHealthManagement" ]; then
    echo -e "${BLUE}[PlatformHealthManagement 模块依赖]${NC}"
    MISSING_PHM=0
    echo -e "${YELLOW}  必需模块:${NC}"
    if [ -f "build/modules/Core/liblap_core.so.1" ]; then
        echo -e "    ${GREEN}✓${NC} Core"
    else
        echo -e "    ${RED}✗${NC} Core"
        ((MISSING_PHM++))
    fi
    if [ -f "build/modules/LogAndTrace/liblap_log.so.1" ]; then
        echo -e "    ${GREEN}✓${NC} LogAndTrace"
    else
        echo -e "    ${RED}✗${NC} LogAndTrace"
        ((MISSING_PHM++))
    fi
    
    echo -e "${YELLOW}  可选模块:${NC}"
    [ -f "build/modules/Com/liblap_com.so" ] && echo -e "    ${GREEN}✓${NC} Com (可选)" || echo -e "    ${YELLOW}-${NC} Com (可选，未构建)"
    [ -f "build/modules/Persistency/liblap_persistency.so.1" ] && echo -e "    ${GREEN}✓${NC} Persistency (可选)" || echo -e "    ${YELLOW}-${NC} Persistency (可选，未构建)"
    echo ""
fi

# 总结
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}检查总结${NC}"
echo -e "${BLUE}======================================${NC}"

TOTAL_MISSING=$((MISSING_GENERAL + MISSING_CORE + MISSING_LOG + MISSING_COM + MISSING_PER + MISSING_PHM))

if [ $TOTAL_MISSING -eq 0 ]; then
    echo -e "${GREEN}✅ 所有依赖都已满足！${NC}"
    echo ""
    echo "可以开始构建："
    echo "  mkdir -p build && cd build"
    echo "  cmake .."
    echo "  cmake --build . -j\$(nproc)"
    exit 0
else
    echo -e "${RED}❌ 缺少 $TOTAL_MISSING 个依赖${NC}"
    echo ""
    echo -e "${YELLOW}建议操作：${NC}"
    echo ""
    
    if [ $MISSING_GENERAL -gt 0 ]; then
        echo "1. 安装通用构建工具："
        echo "   sudo apt update"
        echo "   sudo apt install build-essential cmake git pkg-config"
        echo ""
    fi
    
    if [ $MISSING_CORE -gt 0 ] || [ $MISSING_LOG -gt 0 ] || [ $MISSING_COM -gt 0 ] || [ $MISSING_PER -gt 0 ]; then
        echo "2. 安装所有外部依赖（一次性）："
        echo "   sudo apt install \\"
        echo "     libboost-all-dev \\"
        echo "     libgtest-dev \\"
        echo "     libssl-dev \\"
        echo "     zlib1g-dev \\"
        echo "     libdlt-dev \\"
        echo "     libsdbus-c++-dev \\"
        echo "     libprotobuf-dev protobuf-compiler \\"
        echo "     libsqlite3-dev \\"
        echo "     nlohmann-json3-dev"
        echo ""
    fi
    
    echo "3. 按依赖顺序构建模块："
    echo "   mkdir -p build && cd build"
    echo "   cmake .."
    echo "   make lap_core          # Layer 1"
    echo "   make lap_log           # Layer 2"
    echo "   make lap_com lap_persistency  # Layer 3 (可并行)"
    echo ""
    
    exit 1
fi
