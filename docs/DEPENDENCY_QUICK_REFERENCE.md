# 🔗 LightAP 模块依赖快速参考

## 📊 依赖层次（4层架构）

```
┌─────────────────────────────────────────┐
│  BuildTemplate (构建系统基础)            │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Layer 1: Core (基础服务)               │
│  • 内存管理 • 配置 • AUTOSAR类型         │
│  依赖: 无                                │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Layer 2: LogAndTrace (日志服务)        │
│  • 日志框架 • DLT • 多Sink               │
│  依赖: Core >= 1.0                       │
└─────────────────────────────────────────┘
                  ↓
┌──────────────────────┬──────────────────┐
│  Layer 3: Com        │  Persistency     │
│  • ara::com          │  • KV存储        │
│  • D-Bus/SOME/IP     │  • SQLite        │
│  依赖: Core + Log    │  依赖: Core+Log  │
└──────────────────────┴──────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Layer 4: PlatformHealthManagement      │
│  • 健康监控 • 进程监管                   │
│  依赖: Core, Log (必需), Com/Per (可选)  │
└─────────────────────────────────────────┘
```

## 🛠️ 快速命令

### 检查依赖
```bash
./check_dependencies.sh           # 检查所有模块
./check_dependencies.sh Core      # 检查特定模块
```

### 查看依赖图
```bash
./docs/visualize_dependencies.sh  # 生成PNG/SVG图
# 输出: /tmp/lightap_dependencies.png
```

### 构建顺序
```bash
# 开发模式（一次性构建所有模块）
mkdir build && cd build
cmake ..
make -j$(nproc)

# 按层次构建（调试依赖问题时）
make lap_core                      # Layer 1
make lap_log                       # Layer 2
make lap_com lap_persistency       # Layer 3 (可并行)
make phm                          # Layer 4
```

### 独立构建某个模块
```bash
# 1. 先安装依赖模块
cd modules/Core
cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/lightap
sudo cmake --build build --target install

# 2. 构建目标模块
cd ../LogAndTrace
cmake -B build \
  -DLAP_STANDALONE_BUILD=ON \
  -DCMAKE_PREFIX_PATH=/opt/lightap
cmake --build build
```

## 📦 依赖管理方案对比

| 方案 | 适用场景 | 优点 | 缺点 |
|------|---------|------|------|
| **Symlink** (当前) | 开发阶段 | 简单、快速迭代 | 无法独立构建 |
| **CMake Export** | 生产部署 | 版本控制、独立发布 | 配置复杂 |
| **混合方案** ⭐ | 通用 | 兼顾开发和生产 | 需要维护两套逻辑 |
| **嵌套Submodule** | 分布式开发 | 完全独立 | 管理复杂 |

**推荐**: 开发用Symlink，生产用混合方案（CMake选项控制）

## 🔍 常见问题

### Q: 如何添加新模块依赖？

```cmake
# 1. 在CMakeLists.txt中添加find_package
find_package(Core 1.0 REQUIRED)

# 2. 链接依赖库
target_link_libraries(my_module PRIVATE LightAP::lap_core)

# 3. 在主CMakeLists.txt中调整构建顺序
add_subdirectory(modules/Core)        # 先构建依赖
add_subdirectory(modules/MyModule)    # 后构建当前模块
```

### Q: 模块间出现循环依赖怎么办？

**禁止！** 重新设计架构：
- 提取公共代码到Core
- 使用接口解耦
- 考虑消息传递替代直接依赖

### Q: 如何固定依赖版本？

```bash
# 方式1: 使用Git标签
cd modules/Core
git checkout v1.0.5
cd ../..
git add modules/Core
git commit -m "chore: lock Core to v1.0.5"

# 方式2: 在CMakeLists.txt中指定版本
find_package(Core 1.0.5 EXACT REQUIRED)
```

### Q: 开发时频繁修改依赖模块如何处理？

```bash
# 方式1: 使用集成构建（推荐）
mkdir build && cd build
cmake ..  # 所有模块都在同一构建树中

# 方式2: 开发模式安装
cd modules/Core
cmake -B build -DCMAKE_INSTALL_PREFIX=$HOME/.local
cmake --build build --target install
export CMAKE_PREFIX_PATH=$HOME/.local
```

### Q: 如何查看运行时依赖？

```bash
# 查看动态链接库依赖
ldd build/modules/LogAndTrace/liblap_log.so.1

# 查看RPATH配置
readelf -d build/modules/LogAndTrace/liblap_log.so.1 | grep PATH

# 调试库加载
LD_DEBUG=libs ./build/modules/LogAndTrace/log_test 2>&1 | grep lap_
```

## 📚 详细文档

- **完整指南**: [docs/MODULE_DEPENDENCIES.md](docs/MODULE_DEPENDENCIES.md)
- **主项目文档**: [README.md](README.md)
- **模块文档**:
  - [Core](modules/Core/README.md)
  - [LogAndTrace](modules/LogAndTrace/README.md)
  - [Com](modules/Com/README.md)
  - [Persistency](modules/Persistency/README.md)

## 🎯 最佳实践速查

✅ **DO (推荐)**
- 明确依赖层次，避免循环
- 使用语义化版本 (v1.2.3)
- 文档化依赖关系
- 定期运行 `./check_dependencies.sh`
- 使用命名空间 `lap::core::`, `lap::log::`

❌ **DON'T (避免)**
- 循环依赖 (A→B→A)
- 硬编码路径 (/usr/local/lib)
- 暴露内部实现细节
- 跨层级跳跃依赖 (Layer4直接依赖Layer1的内部类)
- 不声明依赖版本

## 🚀 一键安装所有依赖

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y \
  build-essential cmake git pkg-config \
  libboost-all-dev libgtest-dev \
  libssl-dev zlib1g-dev \
  libdlt-dev libsdbus-c++-dev \
  libprotobuf-dev protobuf-compiler \
  libsqlite3-dev nlohmann-json3-dev

# 验证安装
./check_dependencies.sh
```

---

**最后更新**: 2024-11-03  
**维护者**: LightAP Team  
**问题反馈**: git@10.80.105.120:ddk/LightAP.git
