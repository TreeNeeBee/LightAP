#!/bin/bash
#
# 快速测试构建脚本 - 验证方案三的配置
#

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  LightAP 方案三快速验证                                   ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

INSTALL_PREFIX="$HOME/.local/lightap-test"

echo "📍 测试安装路径: $INSTALL_PREFIX"
echo ""

# 清理之前的安装
if [ -d "$INSTALL_PREFIX" ]; then
    echo "🧹 清理旧安装..."
    rm -rf "$INSTALL_PREFIX"
fi

# 测试集成构建模式
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "测试 1: 集成构建模式（Integrated Build）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./build_and_install.sh \
    -m integrated \
    -p "$INSTALL_PREFIX" \
    -t Release \
    -j 4

echo ""
echo "✅ 集成构建完成"
echo ""

# 验证安装
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "验证安装结果"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "$INSTALL_PREFIX/lib/liblap_core.so.1" ]; then
    echo "✓ Core库已安装"
else
    echo "✗ Core库未找到"
fi

if [ -f "$INSTALL_PREFIX/lib/liblap_log.so.1" ]; then
    echo "✓ LogAndTrace库已安装"
else
    echo "✗ LogAndTrace库未找到"
fi

if [ -d "$INSTALL_PREFIX/include/lap/core" ]; then
    echo "✓ Core头文件已安装"
else
    echo "✗ Core头文件未找到"
fi

if [ -f "$INSTALL_PREFIX/lib/cmake/Core/CoreConfig.cmake" ]; then
    echo "✓ Core CMake配置已安装"
else
    echo "✗ Core CMake配置未找到"
fi

if [ -f "$INSTALL_PREFIX/setup_env.sh" ]; then
    echo "✓ 环境配置脚本已生成"
else
    echo "✗ 环境配置脚本未找到"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "安装目录结构"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
tree -L 3 -I 'CMakeFiles' "$INSTALL_PREFIX" || ls -lR "$INSTALL_PREFIX"

echo ""
echo "✅ 验证完成！"
echo ""
echo "下一步："
echo "  source $INSTALL_PREFIX/setup_env.sh"
echo "  pkg-config --modversion lightap"
