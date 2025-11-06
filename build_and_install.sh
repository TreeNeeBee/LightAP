#!/bin/bash
#
# LightAP 构建和安装脚本
# 支持开发模式和生产模式
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 默认配置
BUILD_TYPE="Release"
INSTALL_PREFIX="${LAP_INSTALL_PREFIX:-$HOME/.local/lightap}"
BUILD_MODE="integrated"  # integrated 或 standalone
JOBS=$(nproc)
CLEAN_BUILD=false

# 使用说明
usage() {
    cat << EOF
${CYAN}LightAP 构建和安装脚本${NC}

用法: $0 [选项]

选项:
  -m, --mode MODE          构建模式: integrated (默认) 或 standalone
  -p, --prefix PREFIX      安装路径 (默认: \$HOME/.local/lightap)
  -t, --type TYPE          构建类型: Debug 或 Release (默认)
  -j, --jobs N             并行任务数 (默认: $(nproc))
  -c, --clean              清理构建目录后重新构建
  -h, --help               显示此帮助信息

构建模式说明:
  integrated   - 集成构建模式（开发推荐）
                 一次性构建所有模块，使用符号链接处理依赖
                 
  standalone   - 独立构建模式（生产推荐）
                 按依赖顺序逐个安装模块，使用 find_package
                 每个模块可独立更新和版本管理

示例:
  # 开发模式（快速迭代）
  $0 -m integrated
  
  # 生产模式（版本控制）
  $0 -m standalone -p /opt/lightap
  
  # 清理重新构建
  $0 -m integrated -c
  
  # Debug构建
  $0 -t Debug

EOF
    exit 0
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            BUILD_MODE="$2"
            shift 2
            ;;
        -p|--prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -j|--jobs)
            JOBS="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}错误: 未知选项 $1${NC}"
            usage
            ;;
    esac
done

# 验证构建模式
if [[ "$BUILD_MODE" != "integrated" && "$BUILD_MODE" != "standalone" ]]; then
    echo -e "${RED}错误: 无效的构建模式 '$BUILD_MODE'${NC}"
    echo "必须是 'integrated' 或 'standalone'"
    exit 1
fi

# 打印配置
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           LightAP 构建配置                                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo -e "${CYAN}构建模式:${NC}     $BUILD_MODE"
echo -e "${CYAN}构建类型:${NC}     $BUILD_TYPE"
echo -e "${CYAN}安装路径:${NC}     $INSTALL_PREFIX"
echo -e "${CYAN}并行任务:${NC}     $JOBS"
echo -e "${CYAN}清理构建:${NC}     $CLEAN_BUILD"
echo ""

# 创建安装目录
mkdir -p "$INSTALL_PREFIX"
echo -e "${GREEN}✓${NC} 创建安装目录: $INSTALL_PREFIX"

# 清理构建目录
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}清理构建目录...${NC}"
    rm -rf build
    echo -e "${GREEN}✓${NC} 构建目录已清理"
fi

# ============================================================================
# 集成构建模式
# ============================================================================
if [ "$BUILD_MODE" = "integrated" ]; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  集成构建模式 - 一次性构建所有模块${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    
    # 创建构建目录
    mkdir -p build
    cd build
    
    # CMake配置
    echo ""
    echo -e "${CYAN}[1/3] CMake 配置...${NC}"
    cmake .. \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
        -DLAP_STANDALONE_BUILD=OFF
    
    echo -e "${GREEN}✓${NC} CMake 配置完成"
    
    # 构建
    echo ""
    echo -e "${CYAN}[2/3] 编译所有模块...${NC}"
    cmake --build . -j"$JOBS"
    echo -e "${GREEN}✓${NC} 编译完成"
    
    # 测试
    echo ""
    echo -e "${CYAN}[3/3] 运行测试...${NC}"
    ctest --output-on-failure -j"$JOBS" || {
        echo -e "${YELLOW}⚠${NC}  部分测试失败，但继续安装"
    }
    
    # 安装
    echo ""
    echo -e "${CYAN}安装所有模块到 $INSTALL_PREFIX...${NC}"
    cmake --install .
    echo -e "${GREEN}✓${NC} 所有模块已安装"
    
    cd ..

# ============================================================================
# 独立构建模式
# ============================================================================
else
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  独立构建模式 - 按依赖顺序逐个安装${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    
    # 定义模块构建顺序（按依赖层级）
    declare -a MODULES=(
        "modules/Core"
        "modules/LogAndTrace"
        "modules/Persistency"
        "modules/Com"
        # "modules/PlatformHealthManagement"  # 可选
    )
    
    TOTAL=${#MODULES[@]}
    CURRENT=0
    
    for MODULE in "${MODULES[@]}"; do
        ((CURRENT++))
        MODULE_NAME=$(basename "$MODULE")
        
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}[$CURRENT/$TOTAL] 构建模块: ${MODULE_NAME}${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        if [ ! -d "$MODULE" ]; then
            echo -e "${RED}✗${NC} 模块目录不存在: $MODULE"
            continue
        fi
        
        cd "$MODULE"
        
        # 清理模块构建目录
        if [ "$CLEAN_BUILD" = true ]; then
            rm -rf build
        fi
        
        mkdir -p build
        cd build
        
        # CMake配置
        echo -e "${CYAN}  [1/4] CMake 配置...${NC}"
        cmake .. \
            -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
            -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
            -DCMAKE_PREFIX_PATH="$INSTALL_PREFIX" \
            -DLAP_STANDALONE_BUILD=ON
        
        # 构建
        echo -e "${CYAN}  [2/4] 编译...${NC}"
        cmake --build . -j"$JOBS"
        
        # 测试
        echo -e "${CYAN}  [3/4] 测试...${NC}"
        ctest --output-on-failure || {
            echo -e "${YELLOW}  ⚠${NC}  部分测试失败，但继续安装"
        }
        
        # 安装
        echo -e "${CYAN}  [4/4] 安装...${NC}"
        cmake --install .
        
        echo -e "${GREEN}  ✓${NC} ${MODULE_NAME} 安装完成"
        
        # 返回项目根目录
        cd ../..
    done
fi

# ============================================================================
# 配置环境变量
# ============================================================================
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  生成环境配置${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"

ENV_FILE="$INSTALL_PREFIX/setup_env.sh"

cat > "$ENV_FILE" << 'ENVEOF'
#!/bin/bash
# LightAP 环境配置文件
# 使用方法: source setup_env.sh

LIGHTAP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 添加库路径
export LD_LIBRARY_PATH="$LIGHTAP_ROOT/lib:${LD_LIBRARY_PATH}"

# 添加可执行文件路径
export PATH="$LIGHTAP_ROOT/bin:${PATH}"

# 添加CMake模块路径
export CMAKE_PREFIX_PATH="$LIGHTAP_ROOT:${CMAKE_PREFIX_PATH}"

# 添加pkg-config路径
export PKG_CONFIG_PATH="$LIGHTAP_ROOT/lib/pkgconfig:${PKG_CONFIG_PATH}"

# LightAP环境变量
export LIGHTAP_INSTALL_DIR="$LIGHTAP_ROOT"
export LIGHTAP_VERSION="1.0.0"

echo "LightAP 环境已配置:"
echo "  安装目录: $LIGHTAP_ROOT"
echo "  库路径:   $LIGHTAP_ROOT/lib"
echo "  头文件:   $LIGHTAP_ROOT/include"
echo ""
echo "使用示例:"
echo "  编译: g++ -I$LIGHTAP_ROOT/include -L$LIGHTAP_ROOT/lib -llap_core your_app.cpp"
echo "  CMake: cmake -DCMAKE_PREFIX_PATH=$LIGHTAP_ROOT .."
ENVEOF

chmod +x "$ENV_FILE"
echo -e "${GREEN}✓${NC} 环境配置文件已生成: $ENV_FILE"

# ============================================================================
# 生成 pkg-config 文件
# ============================================================================
PKG_CONFIG_DIR="$INSTALL_PREFIX/lib/pkgconfig"
mkdir -p "$PKG_CONFIG_DIR"

cat > "$PKG_CONFIG_DIR/lightap.pc" << EOF
prefix=$INSTALL_PREFIX
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: LightAP
Description: AUTOSAR Adaptive Platform Middleware
Version: 1.0.0
Requires: 
Libs: -L\${libdir} -llap_core -llap_log
Cflags: -I\${includedir}
EOF

echo -e "${GREEN}✓${NC} pkg-config 文件已生成: $PKG_CONFIG_DIR/lightap.pc"

# ============================================================================
# 完成总结
# ============================================================================
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✓ LightAP 构建和安装完成！                                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}安装位置:${NC}"
echo -e "  • 库文件:      $INSTALL_PREFIX/lib"
echo -e "  • 头文件:      $INSTALL_PREFIX/include"
echo -e "  • 可执行文件:  $INSTALL_PREFIX/bin"
echo -e "  • CMake配置:   $INSTALL_PREFIX/lib/cmake"
echo ""
echo -e "${CYAN}下一步:${NC}"
echo "  1. 配置环境变量:"
echo -e "     ${YELLOW}source $ENV_FILE${NC}"
echo ""
echo "  2. 验证安装:"
echo -e "     ${YELLOW}pkg-config --modversion lightap${NC}"
echo -e "     ${YELLOW}ls $INSTALL_PREFIX/lib/liblap_*.so*${NC}"
echo ""
echo "  3. 在新项目中使用:"
echo -e "     ${YELLOW}export CMAKE_PREFIX_PATH=$INSTALL_PREFIX${NC}"
echo -e "     ${YELLOW}find_package(Core 1.0 REQUIRED)${NC}"
echo ""

# 保存构建信息
BUILD_INFO="$INSTALL_PREFIX/build_info.txt"
cat > "$BUILD_INFO" << EOF
LightAP 构建信息
================
构建时间: $(date)
构建模式: $BUILD_MODE
构建类型: $BUILD_TYPE
安装路径: $INSTALL_PREFIX
系统信息: $(uname -a)
编译器:   $(g++ --version | head -n1)
CMake:    $(cmake --version | head -n1)
EOF

echo -e "${GREEN}✓${NC} 构建信息已保存: $BUILD_INFO"
