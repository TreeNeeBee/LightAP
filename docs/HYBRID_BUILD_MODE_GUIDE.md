# 方案三：混合构建模式使用指南

## 📋 概述

方案三实现了**混合构建模式**，通过CMake选项在开发模式和生产模式之间灵活切换：

- **集成构建模式**（开发）：快速迭代，所有模块一次性构建
- **独立构建模式**（生产）：版本控制，模块独立安装和更新

## 🎯 核心特性

### ✅ 自动化功能

1. **自动安装管理**
   - 模块install时自动生成CMake Config文件
   - 自动导出目标（Targets）供其他项目使用
   - 自动配置环境变量脚本

2. **环境配置追加**
   - 自动生成 `setup_env.sh`
   - 自动配置 `LD_LIBRARY_PATH`、`CMAKE_PREFIX_PATH`、`PKG_CONFIG_PATH`
   - 自动生成 `pkg-config` 配置文件

3. **模块发现机制**
   - 支持 `find_package(Core 1.0 REQUIRED)`
   - 自动传递依赖关系
   - 版本兼容性检查

## 🚀 快速开始

### 1. 集成构建模式（推荐开发使用）

```bash
# 一键构建和安装所有模块
./build_and_install.sh -m integrated

# 或指定安装路径
./build_and_install.sh -m integrated -p /opt/lightap

# Debug构建
./build_and_install.sh -m integrated -t Debug

# 清理重新构建
./build_and_install.sh -m integrated -c
```

**特点：**
- ⚡ 快速：所有模块并行构建
- 🔗 符号链接：模块间使用symlink处理依赖
- 🔄 实时：源码修改立即生效
- 🎯 适合：快速开发和调试

### 2. 独立构建模式（推荐生产使用）

```bash
# 按依赖顺序逐个安装模块
./build_and_install.sh -m standalone -p /opt/lightap

# 只构建特定模块（需要先安装依赖）
cd modules/LogAndTrace
cmake -B build -DCMAKE_PREFIX_PATH=/opt/lightap
cmake --build build --target install
```

**特点：**
- 📦 独立：每个模块可单独更新
- 🔐 版本控制：严格的版本依赖管理
- 🎯 适合：生产部署和CI/CD

## 📁 安装目录结构

安装后的目录结构（默认：`$HOME/.local/lightap`）：

```
lightap/
├── bin/                           # 可执行文件
│   └── lap_config_editor
├── lib/                           # 库文件
│   ├── liblap_core.so.1.0.0
│   ├── liblap_core.so.1 -> liblap_core.so.1.0.0
│   ├── liblap_log.so.1.0.0
│   ├── liblap_log.so.1 -> liblap_log.so.1.0.0
│   ├── cmake/                     # CMake配置
│   │   ├── Core/
│   │   │   ├── CoreConfig.cmake
│   │   │   ├── CoreConfigVersion.cmake
│   │   │   └── CoreTargets.cmake
│   │   └── LogAndTrace/
│   │       ├── LogAndTraceConfig.cmake
│   │       ├── LogAndTraceConfigVersion.cmake
│   │       └── LogAndTraceTargets.cmake
│   └── pkgconfig/                 # pkg-config
│       └── lightap.pc
├── include/                       # 头文件
│   └── lap/
│       ├── core/
│       │   ├── CMemory.hpp
│       │   ├── CConfig.hpp
│       │   └── ...
│       └── log/
│           ├── CLog.hpp
│           ├── CLogger.hpp
│           └── ...
├── share/                         # 文档
│   └── doc/
│       ├── lap-core/
│       └── lap-log/
├── setup_env.sh                   # 环境配置脚本
└── build_info.txt                 # 构建信息
```

## 🔧 环境配置

### 配置环境变量

```bash
# 方式1：source环境脚本（推荐）
source $HOME/.local/lightap/setup_env.sh

# 方式2：手动设置
export LIGHTAP_INSTALL_DIR="$HOME/.local/lightap"
export LD_LIBRARY_PATH="$LIGHTAP_INSTALL_DIR/lib:$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$LIGHTAP_INSTALL_DIR:$CMAKE_PREFIX_PATH"
export PKG_CONFIG_PATH="$LIGHTAP_INSTALL_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="$LIGHTAP_INSTALL_DIR/bin:$PATH"
```

### 验证安装

```bash
# 检查库文件
ls -lh $HOME/.local/lightap/lib/liblap_*.so*

# 检查CMake配置
ls -lh $HOME/.local/lightap/lib/cmake/*/

# 使用pkg-config
pkg-config --modversion lightap
pkg-config --cflags --libs lightap

# 查看构建信息
cat $HOME/.local/lightap/build_info.txt
```

## 📝 在新项目中使用

### CMakeLists.txt 配置

```cmake
cmake_minimum_required(VERSION 3.10.2)
project(MyApp)

set(CMAKE_CXX_STANDARD 17)

# 查找LightAP模块
find_package(Core 1.0 REQUIRED)
find_package(LogAndTrace 1.0 REQUIRED)

# 创建可执行文件
add_executable(myapp main.cpp)

# 链接LightAP库（使用命名空间）
target_link_libraries(myapp
    PRIVATE
        LightAP::lap_core
        LightAP::lap_log
)
```

### 构建项目

```bash
# 配置环境
source $HOME/.local/lightap/setup_env.sh

# 构建
mkdir build && cd build
cmake ..
make

# 或手动指定路径
cmake -DCMAKE_PREFIX_PATH=$HOME/.local/lightap ..
```

### C++ 代码

```cpp
#include <lap/core/CMemory.hpp>
#include <lap/log/CLogger.hpp>

using namespace lap::core;
using namespace lap::log;

int main() {
    // 使用Core模块
    // ...
    
    // 使用Log模块
    // ...
    
    return 0;
}
```

完整示例见：`examples/using_installed_modules/`

## 🔄 工作流程

### 开发流程（集成模式）

```bash
# 1. 克隆项目
git clone --recursive git@10.80.105.120:ddk/LightAP.git
cd LightAP

# 2. 构建和安装
./build_and_install.sh -m integrated

# 3. 开发和测试
# 修改源码
vim modules/Core/source/src/CMemory.cpp

# 重新构建
cd build
make -j$(nproc)

# 运行测试
ctest --output-on-failure

# 重新安装
make install

# 4. 提交更改
git add .
git commit -m "your changes"
git push
```

### 生产发布流程（独立模式）

```bash
# 1. 准备发布环境
RELEASE_PREFIX="/opt/lightap-1.0.0"

# 2. 按顺序构建和安装
./build_and_install.sh -m standalone -p "$RELEASE_PREFIX"

# 3. 打包（可选）
cd "$RELEASE_PREFIX"
tar -czf lightap-1.0.0-$(uname -m).tar.gz *

# 4. 或创建DEB/RPM包
cd build
cpack -G DEB
# or
cpack -G RPM

# 5. 部署到目标系统
scp lightap-*.tar.gz user@target:/tmp/
ssh user@target "cd /tmp && tar -xzf lightap-*.tar.gz -C /opt/"
```

### 模块单独更新

```bash
# 场景：只更新LogAndTrace模块

# 1. 确保依赖已安装
# Core模块应该已在 /opt/lightap 中

# 2. 构建新版本的LogAndTrace
cd modules/LogAndTrace
git pull  # 获取最新代码

cmake -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/lightap \
    -DCMAKE_PREFIX_PATH=/opt/lightap \
    -DLAP_STANDALONE_BUILD=ON

cmake --build build -j$(nproc)
cmake --build build --target install

# 3. 验证
ldd /opt/lightap/lib/liblap_log.so.1
```

## 📊 构建选项

### build_and_install.sh 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-m, --mode` | 构建模式：`integrated` 或 `standalone` | `integrated` |
| `-p, --prefix` | 安装路径 | `$HOME/.local/lightap` |
| `-t, --type` | 构建类型：`Debug` 或 `Release` | `Release` |
| `-j, --jobs` | 并行任务数 | `$(nproc)` |
| `-c, --clean` | 清理构建目录 | 不清理 |
| `-h, --help` | 显示帮助 | - |

### CMake 选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `LAP_STANDALONE_BUILD` | 启用独立构建模式 | `OFF` |
| `CMAKE_INSTALL_PREFIX` | 安装路径 | `$HOME/.local/lightap` |
| `CMAKE_BUILD_TYPE` | 构建类型 | `Release` |
| `CMAKE_PREFIX_PATH` | 依赖搜索路径 | - |

## 🔍 常见问题

### Q1: 找不到已安装的模块？

```bash
# 检查CMAKE_PREFIX_PATH
echo $CMAKE_PREFIX_PATH

# 手动指定
cmake -DCMAKE_PREFIX_PATH=/path/to/lightap ..

# 或使用环境脚本
source /path/to/lightap/setup_env.sh
```

### Q2: 运行时找不到.so文件？

```bash
# 检查LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH

# 手动添加
export LD_LIBRARY_PATH="/path/to/lightap/lib:$LD_LIBRARY_PATH"

# 或使用环境脚本
source /path/to/lightap/setup_env.sh

# 或配置ldconfig（需要root）
echo "/path/to/lightap/lib" | sudo tee /etc/ld.so.conf.d/lightap.conf
sudo ldconfig
```

### Q3: 版本冲突？

```bash
# 查看已安装版本
cat /path/to/lightap/lib/cmake/Core/CoreConfigVersion.cmake

# 指定版本要求
find_package(Core 1.0.5 EXACT REQUIRED)

# 使用特定版本
cmake -DCMAKE_PREFIX_PATH=/opt/lightap-1.0.5 ..
```

### Q4: 如何卸载？

```bash
# 删除安装目录即可
rm -rf $HOME/.local/lightap

# 如果使用了系统路径，需要清理ldconfig
sudo rm /etc/ld.so.conf.d/lightap.conf
sudo ldconfig
```

## 📈 最佳实践

### ✅ DO（推荐）

1. **开发阶段使用集成模式**
   ```bash
   ./build_and_install.sh -m integrated
   ```

2. **生产环境使用独立模式**
   ```bash
   ./build_and_install.sh -m standalone -p /opt/lightap
   ```

3. **使用环境脚本**
   ```bash
   source $LIGHTAP_INSTALL_DIR/setup_env.sh
   ```

4. **在CMake中使用命名空间**
   ```cmake
   target_link_libraries(myapp PRIVATE LightAP::lap_core)
   ```

5. **指定版本要求**
   ```cmake
   find_package(Core 1.0 REQUIRED)
   ```

### ❌ DON'T（避免）

1. **不要混用两种模式的安装**
   ```bash
   # ✗ 错误
   ./build_and_install.sh -m integrated -p /opt/lightap
   cd modules/Core && make install  # 单独安装
   ```

2. **不要硬编码路径**
   ```cmake
   # ✗ 错误
   include_directories(/opt/lightap/include)
   link_directories(/opt/lightap/lib)
   
   # ✓ 正确
   find_package(Core 1.0 REQUIRED)
   target_link_libraries(myapp PRIVATE LightAP::lap_core)
   ```

3. **不要忘记设置环境变量**
   ```bash
   # ✗ 错误：直接运行可能找不到库
   ./myapp
   
   # ✓ 正确：先配置环境
   source $LIGHTAP_INSTALL_DIR/setup_env.sh
   ./myapp
   ```

## 🎯 总结

方案三混合模式的优势：

- ✅ **灵活性**：一套代码，两种模式
- ✅ **自动化**：install自动配置环境
- ✅ **标准化**：遵循CMake最佳实践
- ✅ **可维护**：清晰的依赖关系
- ✅ **易部署**：简单的安装流程

适用场景：

| 场景 | 模式 | 原因 |
|------|------|------|
| 日常开发 | 集成模式 | 快速迭代 |
| 单元测试 | 集成模式 | 测试方便 |
| 生产部署 | 独立模式 | 版本控制 |
| CI/CD | 独立模式 | 独立验证 |
| 库复用 | 独立模式 | 跨项目使用 |

---

**相关文档**：
- [依赖管理完整指南](../../docs/MODULE_DEPENDENCIES.md)
- [快速参考](../../docs/DEPENDENCY_QUICK_REFERENCE.md)
- [使用示例](../using_installed_modules/)

**维护**: LightAP Team  
**更新**: 2024-11-03
