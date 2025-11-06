# 使用已安装的LightAP模块

本示例展示如何在外部项目中使用已安装的LightAP模块。

## 前置条件

1. 已安装LightAP模块（通过 `build_and_install.sh` 脚本）
2. 设置了环境变量（`source setup_env.sh`）

## 构建步骤

```bash
# 1. 配置环境
source $HOME/.local/lightap/setup_env.sh

# 2. 构建项目
mkdir build && cd build
cmake ..
make

# 3. 运行
./my_app
```

## 或者手动指定安装路径

```bash
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=$HOME/.local/lightap ..
make
./my_app
```

## CMakeLists.txt 关键配置

```cmake
# 查找已安装的模块
find_package(Core 1.0 REQUIRED)
find_package(LogAndTrace 1.0 REQUIRED)

# 链接库（使用命名空间）
target_link_libraries(my_app
    PRIVATE
        LightAP::lap_core
        LightAP::lap_log
)
```

## 特性

- ✅ 使用CMake的 `find_package` 查找已安装模块
- ✅ 自动处理include路径
- ✅ 自动处理库链接
- ✅ 支持版本检查（Core 1.0+）
- ✅ 使用命名空间防止冲突（LightAP::）
