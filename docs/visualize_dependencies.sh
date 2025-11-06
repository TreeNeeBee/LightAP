#!/bin/bash
#
# LightAP 模块依赖关系可视化
# 使用GraphViz生成依赖图
#

cat > /tmp/lightap_deps.dot << 'EOF'
digraph LightAP_Dependencies {
    rankdir=TB;
    node [shape=box, style=filled, fontname="Arial"];
    
    // 图例
    subgraph cluster_legend {
        label="依赖层级";
        style=dashed;
        
        legend_l1 [label="Layer 1: Foundation", fillcolor="#90EE90"];
        legend_l2 [label="Layer 2: Core Services", fillcolor="#87CEEB"];
        legend_l3 [label="Layer 3: Advanced Services", fillcolor="#FFB6C1"];
        legend_l4 [label="Layer 4: Platform Services", fillcolor="#DDA0DD"];
        
        legend_l1 -> legend_l2 -> legend_l3 -> legend_l4 [style=invis];
    }
    
    // 构建系统
    subgraph cluster_build {
        label="Build System";
        style=filled;
        fillcolor="#F0F0F0";
        
        BuildTemplate [label="BuildTemplate\nv1.1.0\n(CMake Templates)", fillcolor="#FFD700"];
    }
    
    // Layer 1: 基础层（无依赖）
    subgraph cluster_l1 {
        label="Layer 1: Foundation";
        style=filled;
        fillcolor="#E8F5E9";
        
        Core [label="Core\nv1.0.0\n• Memory Management\n• Configuration\n• AUTOSAR Types", fillcolor="#90EE90"];
    }
    
    // Layer 2: 核心服务（依赖Core）
    subgraph cluster_l2 {
        label="Layer 2: Core Services";
        style=filled;
        fillcolor="#E3F2FD";
        
        LogAndTrace [label="LogAndTrace\nv1.0.0\n• Logging Framework\n• DLT Integration\n• Multi-Sink Support", fillcolor="#87CEEB"];
    }
    
    // Layer 3: 高级服务（依赖Core + LogAndTrace）
    subgraph cluster_l3 {
        label="Layer 3: Advanced Services";
        style=filled;
        fillcolor="#FFF0F5";
        
        Com [label="Com\nv1.0.0\n• ara::com API\n• D-Bus/SOME/IP\n• IPC", fillcolor="#FFB6C1"];
        Persistency [label="Persistency\nv1.0.0\n• Key-Value Storage\n• File Storage\n• SQLite Backend", fillcolor="#FFB6C1"];
    }
    
    // Layer 4: 平台服务（依赖多个模块）
    subgraph cluster_l4 {
        label="Layer 4: Platform Services";
        style=filled;
        fillcolor="#F3E5F5";
        
        PHM [label="Platform Health\nManagement\nv1.0.0\n• Health Monitoring\n• Supervision", fillcolor="#DDA0DD"];
    }
    
    // 外部依赖
    subgraph cluster_external {
        label="External Dependencies";
        style=filled;
        fillcolor="#FFFACD";
        
        Boost [label="Boost", fillcolor="#FFFACD"];
        GTest [label="Google Test", fillcolor="#FFFACD"];
        DLT [label="DLT Daemon", fillcolor="#FFFACD"];
        sdbus [label="sdbus-c++", fillcolor="#FFFACD"];
        protobuf [label="Protobuf", fillcolor="#FFFACD"];
        sqlite [label="SQLite3", fillcolor="#FFFACD"];
    }
    
    // BuildTemplate 依赖关系
    BuildTemplate -> Core [label="build", style=dashed, color=blue];
    BuildTemplate -> LogAndTrace [label="build", style=dashed, color=blue];
    BuildTemplate -> Com [label="build", style=dashed, color=blue];
    BuildTemplate -> Persistency [label="build", style=dashed, color=blue];
    BuildTemplate -> PHM [label="build", style=dashed, color=blue];
    
    // 模块依赖关系（实线）
    Core -> LogAndTrace [label="required\nv1.0+", color=red, penwidth=2];
    Core -> Persistency [label="required\nv1.0+", color=red, penwidth=2];
    Core -> Com [label="required\nv1.0+", color=red, penwidth=2];
    
    LogAndTrace -> Persistency [label="required\nv1.0+", color=red, penwidth=2];
    LogAndTrace -> Com [label="required\nv1.0+", color=red, penwidth=2];
    LogAndTrace -> PHM [label="required\nv1.0+", color=red, penwidth=2];
    
    Core -> PHM [label="required\nv1.0+", color=red, penwidth=2];
    Com -> PHM [label="optional", color=orange, style=dashed];
    Persistency -> PHM [label="optional", color=orange, style=dashed];
    
    // 外部依赖
    Boost -> Core [color=gray];
    GTest -> Core [label="test only", style=dotted, color=gray];
    
    DLT -> LogAndTrace [color=gray];
    Boost -> LogAndTrace [color=gray];
    GTest -> LogAndTrace [label="test only", style=dotted, color=gray];
    
    sdbus -> Com [color=gray];
    protobuf -> Com [color=gray];
    Boost -> Com [color=gray];
    
    sqlite -> Persistency [color=gray];
    Boost -> Persistency [color=gray];
}
EOF

echo "==================================="
echo "LightAP 模块依赖关系可视化"
echo "==================================="
echo ""

# 检查GraphViz是否安装
if command -v dot &> /dev/null; then
    # 生成PNG图片
    dot -Tpng /tmp/lightap_deps.dot -o /tmp/lightap_dependencies.png
    echo "✅ 依赖图已生成: /tmp/lightap_dependencies.png"
    
    # 生成SVG（更适合网页查看）
    dot -Tsvg /tmp/lightap_deps.dot -o /tmp/lightap_dependencies.svg
    echo "✅ SVG版本: /tmp/lightap_dependencies.svg"
    
    # 如果在图形环境，尝试打开
    if [ -n "$DISPLAY" ]; then
        xdg-open /tmp/lightap_dependencies.png 2>/dev/null || \
        eog /tmp/lightap_dependencies.png 2>/dev/null || \
        echo "ℹ️  请手动打开 /tmp/lightap_dependencies.png"
    fi
else
    echo "⚠️  GraphViz (dot) 未安装"
    echo ""
    echo "安装方法："
    echo "  Ubuntu/Debian: sudo apt install graphviz"
    echo "  RHEL/CentOS:   sudo yum install graphviz"
    echo "  macOS:         brew install graphviz"
    echo ""
    echo "DOT源文件已保存到: /tmp/lightap_deps.dot"
    echo "可以使用在线工具查看: http://www.webgraphviz.com/"
fi

echo ""
echo "==================================="
echo "依赖层级说明"
echo "==================================="
cat << 'DEPS'

Layer 1 (Foundation) - 无依赖
├── Core v1.0.0
│   ├── 内存管理 (CMemory, MemoryPool)
│   ├── 配置管理 (CConfig)
│   ├── AUTOSAR基础类型 (Result, Optional, Span)
│   └── 错误处理 (ErrorDomain)

Layer 2 (Core Services) - 依赖 Core
├── LogAndTrace v1.0.0
│   ├── 依赖: Core >= 1.0.0
│   ├── 日志框架 (CLogger, CLogStream)
│   ├── DLT集成 (CDLTSink)
│   └── 多Sink支持 (Console, File, Syslog)

Layer 3 (Advanced Services) - 依赖 Core + LogAndTrace
├── Com v1.0.0
│   ├── 依赖: Core >= 1.0.0, LogAndTrace >= 1.0.0
│   ├── ara::com API (Proxy, Skeleton)
│   ├── D-Bus绑定 (sdbus-c++)
│   ├── SOME/IP绑定
│   └── Socket通信 (Protobuf)
│
└── Persistency v1.0.0
    ├── 依赖: Core >= 1.0.0, LogAndTrace >= 1.0.0
    ├── Key-Value存储 (CKeyValueStorage)
    ├── 文件存储 (CFileStorage)
    ├── SQLite后端 (CKvsSqliteBackend)
    └── Property后端 (CKvsPropertyBackend)

Layer 4 (Platform Services) - 依赖多个模块
└── PlatformHealthManagement v1.0.0
    ├── 必需依赖: Core >= 1.0.0, LogAndTrace >= 1.0.0
    ├── 可选依赖: Com, Persistency
    ├── 健康监控
    └── 进程监管

构建顺序：
  1. BuildTemplate (所有模块的基础)
  2. Core
  3. LogAndTrace
  4. Com, Persistency (并行构建)
  5. PlatformHealthManagement

DEPS

echo ""
echo "==================================="
echo "依赖关系快速检查"
echo "==================================="

# 检查实际的库依赖
if [ -f "build/modules/LogAndTrace/liblap_log.so.1" ]; then
    echo ""
    echo "LogAndTrace 运行时依赖:"
    ldd build/modules/LogAndTrace/liblap_log.so.1 | grep -E "(lap_|dlt)" || echo "  无LightAP模块依赖"
fi

if [ -f "build/modules/Com/liblap_com.so" ]; then
    echo ""
    echo "Com 运行时依赖:"
    ldd build/modules/Com/liblap_com.so | grep -E "(lap_|sdbus)" | head -5 || echo "  无LightAP模块依赖"
fi

if [ -f "build/modules/Persistency/liblap_persistency.so.1" ]; then
    echo ""
    echo "Persistency 运行时依赖:"
    ldd build/modules/Persistency/liblap_persistency.so.1 | grep -E "(lap_|sqlite)" || echo "  无LightAP模块依赖"
fi

echo ""
echo "✅ 完成！"
