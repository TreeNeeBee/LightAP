# LightAP 模块依赖管理指南

## 📋 当前依赖关系

```
BuildTemplate (构建系统基础)
    ↓
Core (基础服务)
    ↓
LogAndTrace (日志服务，依赖 Core)
    ↓
Persistency (持久化，依赖 Core + LogAndTrace)
Com (通信，依赖 Core + LogAndTrace)
    ↓
PlatformHealthManagement (健康管理，依赖多个模块)
```

## 🎯 依赖管理方案对比

### 方案一：当前方案 - 符号链接（Symlink）✅ 推荐用于单体构建

**实现方式：**
```cmake
# 在依赖模块的 CMakeLists.txt 中
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)
file(CREATE_LINK ${CMAKE_SOURCE_DIR}/modules/Core/source/inc 
     ${CMAKE_CURRENT_BINARY_DIR}/include/core SYMBOLIC)
```

**优点：**
- ✅ 简单直接，无需额外配置
- ✅ 构建时立即生效
- ✅ 适合单体项目（所有模块在一个仓库）
- ✅ 开发时能立即看到依赖变化

**缺点：**
- ❌ 模块无法独立构建
- ❌ 无法控制版本依赖
- ❌ 跨平台兼容性问题（Windows需特殊处理）
- ❌ 不适合分布式开发

**适用场景：**
- 所有模块统一开发
- 单一代码库
- 开发阶段快速迭代

---

### 方案二：CMake导出目标（Export Targets）⭐ 推荐用于生产环境

**实现方式：**

#### 1. Core模块导出配置（被依赖方）

```cmake
# modules/Core/CMakeLists.txt
# 安装头文件
install(DIRECTORY source/inc/
    DESTINATION include/lap/core
    FILES_MATCHING PATTERN "*.h*"
)

# 安装库文件
install(TARGETS lap_core
    EXPORT CoreTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

# 导出目标
install(EXPORT CoreTargets
    FILE CoreTargets.cmake
    NAMESPACE LightAP::
    DESTINATION lib/cmake/Core
)

# 生成配置文件
include(CMakePackageConfigHelpers)
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/CoreConfig.cmake
    INSTALL_DESTINATION lib/cmake/Core
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/CoreConfigVersion.cmake
    VERSION ${MODULE_VERNO}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/CoreConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/CoreConfigVersion.cmake
    DESTINATION lib/cmake/Core
)
```

#### 2. CoreConfig.cmake.in（被依赖方）

```cmake
# modules/Core/CoreConfig.cmake.in
@PACKAGE_INIT@

include("${CMAKE_CURRENT_LIST_DIR}/CoreTargets.cmake")

check_required_components(Core)
```

#### 3. LogAndTrace模块使用（依赖方）

```cmake
# modules/LogAndTrace/CMakeLists.txt
# 查找依赖
find_package(Core 1.0 REQUIRED)

# 链接依赖
target_link_libraries(lap_log
    PRIVATE
        LightAP::lap_core
        dlt
        Threads::Threads
)

# 包含目录会自动传递
target_include_directories(lap_log
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/source/inc>
        $<INSTALL_INTERFACE:include/lap/log>
)
```

**优点：**
- ✅ 模块可独立构建和安装
- ✅ 明确的版本依赖管理
- ✅ 支持find_package标准查找
- ✅ 自动传递依赖关系
- ✅ 支持不同构建类型（Debug/Release）

**缺点：**
- ❌ 配置复杂度较高
- ❌ 需要先安装依赖模块
- ❌ 开发时需要频繁安装

**适用场景：**
- 生产环境部署
- 模块独立发布
- 版本化管理
- 跨项目复用

---

### 方案三：混合方案（开发+生产）⭐⭐ 最佳实践

结合方案一和方案二的优点，通过CMake选项控制：

```cmake
# 主 CMakeLists.txt
option(LAP_STANDALONE_BUILD "Build modules independently" OFF)

if(LAP_STANDALONE_BUILD)
    # 生产模式：使用find_package
    find_package(Core 1.0 REQUIRED)
    find_package(LogAndTrace 1.0 REQUIRED)
else()
    # 开发模式：使用add_subdirectory + 符号链接
    add_subdirectory(modules/Core)
    add_subdirectory(modules/LogAndTrace)
    add_subdirectory(modules/Persistency)
    add_subdirectory(modules/Com)
endif()
```

**使用方式：**

开发阶段（快速迭代）：
```bash
# 所有模块一起构建
cmake -B build
cmake --build build
```

生产部署（版本控制）：
```bash
# 1. 先构建并安装依赖
cd modules/Core
cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/lightap
cmake --build build --target install

# 2. 构建依赖它的模块
cd ../LogAndTrace
cmake -B build -DLAP_STANDALONE_BUILD=ON \
    -DCMAKE_PREFIX_PATH=/opt/lightap
cmake --build build --target install
```

---

### 方案四：Git Submodule嵌套 🔧 当前架构扩展

既然已经使用了Git Submodule，可以进一步优化：

#### 1. 让依赖模块也包含BuildTemplate

```bash
# 在Core模块中
cd modules/Core
git submodule add git@10.80.105.120:ddk/BuildTemplate.git BuildTemplate
```

#### 2. 模块独立构建支持

```cmake
# modules/Core/CMakeLists.txt
cmake_minimum_required(VERSION 3.10.2)

# 自动检测是否为独立构建
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    # 独立构建模式
    set(STANDALONE_BUILD ON)
    include(BuildTemplate/Config.cmake.in)
else()
    # 作为子模块构建
    set(STANDALONE_BUILD OFF)
    include(../../BuildTemplate/Config.cmake.in)
endif()

project(Core)
# ... 其余配置
```

#### 3. 依赖模块配置

```cmake
# modules/LogAndTrace/CMakeLists.txt
if(STANDALONE_BUILD)
    # 独立构建时查找已安装的Core
    find_package(Core 1.0 REQUIRED)
    set(CORE_INCLUDE_DIR ${Core_INCLUDE_DIRS})
    set(CORE_LIBRARIES LightAP::lap_core)
else()
    # 集成构建时使用符号链接
    file(CREATE_LINK ${CMAKE_SOURCE_DIR}/modules/Core/source/inc 
         ${CMAKE_CURRENT_BINARY_DIR}/include/core SYMBOLIC)
    set(CORE_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/include)
    set(CORE_LIBRARIES lap_core)
endif()

target_link_libraries(lap_log PRIVATE ${CORE_LIBRARIES})
```

---

## 📦 依赖版本管理

### 在主项目中固定依赖版本

```bash
# .gitmodules
[submodule "modules/Core"]
    path = modules/Core
    url = git@10.80.105.120:ddk/Core.git
    branch = v1.0-stable  # 使用稳定分支而非master

# 或使用特定commit
cd modules/Core
git checkout v1.0.5  # 固定到特定版本
cd ../..
git add modules/Core
git commit -m "chore: lock Core to v1.0.5"
```

### 依赖版本声明

```cmake
# modules/LogAndTrace/CMakeLists.txt
find_package(Core 1.0.5 REQUIRED)  # 要求特定版本

if(Core_VERSION VERSION_LESS "1.0.5")
    message(FATAL_ERROR "LogAndTrace requires Core >= 1.0.5")
endif()
```

---

## 🔄 推荐工作流程

### 开发阶段（所有团队成员）

```bash
# 1. 克隆包含所有submodules
git clone --recursive git@10.80.105.120:ddk/LightAP.git
cd LightAP

# 2. 统一构建所有模块
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
cmake --build . -j$(nproc)

# 3. 运行测试
ctest --output-on-failure
```

### 独立模块开发（专注单一模块）

```bash
# 1. 克隆单个模块
git clone --recursive git@10.80.105.120:ddk/LogAndTrace.git
cd LogAndTrace

# 2. 安装依赖（Core）
# 方式A：从包管理器安装
sudo apt install lightap-core-dev

# 方式B：手动构建安装
git clone --recursive git@10.80.105.120:ddk/Core.git /tmp/core
cd /tmp/core
cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/lightap
sudo cmake --build build --target install

# 3. 构建当前模块
cd /path/to/LogAndTrace
cmake -B build -DCMAKE_PREFIX_PATH=/opt/lightap
cmake --build build
```

### 生产发布

```bash
# 1. 按依赖顺序构建和打包
declare -a modules=("Core" "LogAndTrace" "Persistency" "Com" "PlatformHealthManagement")

for module in "${modules[@]}"; do
    cd modules/$module
    
    # 构建
    cmake -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/opt/lightap \
        -DLAP_STANDALONE_BUILD=ON
    
    cmake --build build -j$(nproc)
    
    # 打包
    cd build
    cpack -G DEB
    
    # 安装到系统（下一模块需要）
    sudo dpkg -i *.deb
    
    cd ../..
done
```

---

## 🎨 最佳实践总结

### ✅ DO（推荐做法）

1. **明确依赖层次**
   - Core: 无依赖（基础层）
   - LogAndTrace: 依赖Core
   - Persistency/Com: 依赖Core + LogAndTrace
   - 避免循环依赖

2. **使用命名空间**
   ```cpp
   // 清晰的模块归属
   #include <lap/core/CMemory.hpp>
   #include <lap/log/CLogger.hpp>
   ```

3. **版本化发布**
   - 使用语义化版本（SemVer）: v1.0.5
   - 维护CHANGELOG.md
   - Git标签标记发布版本

4. **头文件隔离**
   ```cmake
   # 只导出公共API
   install(DIRECTORY source/inc/
       DESTINATION include/lap/core
       FILES_MATCHING PATTERN "*.hpp"
       PATTERN "internal" EXCLUDE  # 排除内部头文件
   )
   ```

5. **依赖文档化**
   ```markdown
   # 模块README.md
   ## Dependencies
   - Core >= 1.0.0 (required)
   - LogAndTrace >= 1.2.0 (optional)
   ```

### ❌ DON'T（避免做法）

1. ❌ 循环依赖
   ```
   Core → LogAndTrace → Core  # 禁止！
   ```

2. ❌ 硬编码路径
   ```cmake
   include_directories(/usr/local/include)  # 不可移植
   ```

3. ❌ 暴露内部实现
   ```cpp
   #include <lap/core/internal/CMemoryImpl.hpp>  # 不应被外部使用
   ```

4. ❌ 版本不匹配
   ```
   Com v2.0 依赖 Core v1.0，但系统安装的是 Core v3.0  # 可能不兼容
   ```

---

## 🚀 快速参考

### 添加新模块依赖

```cmake
# 1. 在新模块的CMakeLists.txt中
find_package(Core 1.0 REQUIRED)
find_package(LogAndTrace 1.0 REQUIRED)

# 2. 链接依赖
target_link_libraries(my_new_module
    PRIVATE
        LightAP::lap_core
        LightAP::lap_log
)

# 3. 在主CMakeLists.txt中调整构建顺序
add_subdirectory(modules/Core)          # 先构建Core
add_subdirectory(modules/LogAndTrace)   # 再构建LogAndTrace
add_subdirectory(modules/MyNewModule)   # 最后构建新模块
```

### 检查依赖版本

```bash
# 查看已安装的模块版本
cmake --find-package -DNAME=Core -DCOMPILER_ID=GNU -DLANGUAGE=CXX -DMODE=EXIST

# 查看模块依赖树
ldd build/modules/LogAndTrace/liblap_log.so
```

### 更新子模块依赖

```bash
# 更新到最新稳定版
cd modules/Core
git checkout v1.1-stable
git pull origin v1.1-stable

# 回到主仓库记录更新
cd ../..
git add modules/Core
git commit -m "chore: update Core to v1.1.3"
```

---

## 📚 相关文档

- [LightAP主文档](../README.md)
- [BuildTemplate使用指南](../BuildTemplate/README.md)
- [Core模块文档](../modules/Core/README.md)
- [CMake官方文档 - find_package](https://cmake.org/cmake/help/latest/command/find_package.html)
- [Git Submodule最佳实践](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
