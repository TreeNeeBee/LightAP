# 📚 LightAP 文档中心

欢迎来到 LightAP 中间件平台文档中心！

## 🎯 快速导航

### 入门文档
- **[主 README](../README.md)** - 项目概述、快速开始、Submodule使用
- **[依赖快速参考](DEPENDENCY_QUICK_REFERENCE.md)** ⭐ 推荐新手阅读
  - 4层架构一览
  - 常用命令速查
  - 常见问题解答

### 核心文档
- **[模块依赖管理指南](MODULE_DEPENDENCIES.md)** - 完整的依赖管理策略
  - 4种依赖管理方案对比
  - 开发vs生产工作流
  - 版本管理最佳实践
  - 详细的示例代码

### 模块文档
- **[Core 模块](../modules/Core/README.md)** - 基础服务
- **[LogAndTrace 模块](../modules/LogAndTrace/README.md)** - 日志服务
- **[Com 模块](../modules/Com/README.md)** - 通信服务
- **[Persistency 模块](../modules/Persistency/README.md)** - 持久化服务
- **[PlatformHealthManagement 模块](../modules/PlatformHealthManagement/README.md)** - 健康监控

## 🛠️ 工具脚本

### 依赖管理
```bash
# 检查所有依赖
./check_dependencies.sh

# 检查特定模块
./check_dependencies.sh Core
./check_dependencies.sh LogAndTrace

# 生成依赖关系图
./docs/visualize_dependencies.sh
# 输出: /tmp/lightap_dependencies.png
```

### 构建相关
```bash
# 标准构建（所有模块）
mkdir build && cd build
cmake ..
make -j$(nproc)

# 独立模块构建
cmake -B build -DLAP_STANDALONE_BUILD=ON
```

## 📖 文档结构

```
LightAP/
├── README.md                           # 主文档（入口）
├── check_dependencies.sh               # 依赖检查工具
├── docs/
│   ├── INDEX.md                        # 本文档（文档索引）
│   ├── DEPENDENCY_QUICK_REFERENCE.md   # 依赖快速参考 ⭐
│   ├── MODULE_DEPENDENCIES.md          # 完整依赖管理指南 📚
│   └── visualize_dependencies.sh       # 依赖可视化工具
├── modules/
│   ├── Core/README.md                  # Core模块文档
│   ├── LogAndTrace/README.md          # Log模块文档
│   ├── Com/README.md                  # Com模块文档
│   ├── Persistency/README.md          # Persistency模块文档
│   └── PlatformHealthManagement/README.md
└── BuildTemplate/README.md             # 构建系统文档
```

## 🎓 学习路径

### 1️⃣ 新手入门（1小时）
1. 阅读 [主 README](../README.md) - 了解项目结构
2. 运行 `./check_dependencies.sh` - 检查环境
3. 浏览 [依赖快速参考](DEPENDENCY_QUICK_REFERENCE.md) - 理解架构

### 2️⃣ 开发上手（半天）
1. 克隆并构建项目
   ```bash
   git clone --recursive git@10.80.105.120:ddk/LightAP.git
   cd LightAP
   mkdir build && cd build
   cmake .. && make -j$(nproc)
   ```
2. 阅读 [Core模块文档](../modules/Core/README.md)
3. 运行示例程序和测试

### 3️⃣ 深入理解（1周）
1. 学习 [模块依赖管理指南](MODULE_DEPENDENCIES.md)
2. 阅读所有模块的README
3. 查看 [BuildTemplate文档](../BuildTemplate/README.md)
4. 理解4层依赖架构

### 4️⃣ 高级应用（持续）
1. 独立模块开发与发布
2. 定制化构建流程
3. 跨项目集成
4. 性能优化和调优

## ❓ 常见场景

### 场景1: 我想快速开始开发
👉 阅读顺序：
1. [主 README](../README.md) → 快速开始部分
2. [依赖快速参考](DEPENDENCY_QUICK_REFERENCE.md) → 构建顺序
3. [Core模块文档](../modules/Core/README.md) → 使用示例

### 场景2: 我只需要使用某个模块
👉 阅读顺序：
1. [依赖快速参考](DEPENDENCY_QUICK_REFERENCE.md) → 独立构建
2. [模块依赖管理指南](MODULE_DEPENDENCIES.md) → 方案二
3. 目标模块的 README

### 场景3: 我要添加新模块或修改依赖
👉 阅读顺序：
1. [模块依赖管理指南](MODULE_DEPENDENCIES.md) → 完整阅读
2. [依赖快速参考](DEPENDENCY_QUICK_REFERENCE.md) → Q&A部分
3. 运行 `./docs/visualize_dependencies.sh` 查看现有架构

### 场景4: 构建出错或依赖问题
👉 诊断步骤：
1. 运行 `./check_dependencies.sh` 检查依赖
2. 查看 [依赖快速参考](DEPENDENCY_QUICK_REFERENCE.md) → 常见问题
3. 检查构建顺序是否正确（Layer 1→2→3→4）
4. 查看相关模块的README了解具体要求

### 场景5: 生产环境部署
👉 阅读顺序：
1. [模块依赖管理指南](MODULE_DEPENDENCIES.md) → 方案三（混合方案）
2. [模块依赖管理指南](MODULE_DEPENDENCIES.md) → 生产发布章节
3. 各模块README中的安装说明

## 🔗 外部参考

### CMake相关
- [CMake官方文档](https://cmake.org/documentation/)
- [find_package使用指南](https://cmake.org/cmake/help/latest/command/find_package.html)
- [CMake Export教程](https://cmake.org/cmake/help/latest/guide/importing-exporting/index.html)

### Git Submodule
- [Git Submodule官方文档](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Submodule最佳实践](https://git-scm.com/docs/gitsubmodules)

### AUTOSAR Adaptive Platform
- [AUTOSAR官网](https://www.autosar.org/)
- AUTOSAR AP规范文档（模块README中有链接）

## 📝 文档贡献

### 文档风格指南
- 使用Markdown格式
- 包含可执行的代码示例
- 添加清晰的章节标题和导航
- 使用emoji增强可读性 🎯

### 如何更新文档
```bash
# 1. 编辑文档
vim docs/MODULE_DEPENDENCIES.md

# 2. 验证Markdown格式
markdownlint docs/MODULE_DEPENDENCIES.md

# 3. 提交更改
git add docs/
git commit -m "docs: update dependency management guide"
git push origin master
```

## 🆘 获取帮助

### 问题反馈
- **Git仓库**: git@10.80.105.120:ddk/LightAP.git
- **问题追踪**: 在相应的Git仓库提issue

### 联系方式
- **团队**: LightAP Development Team
- **维护者**: 查看各模块README中的维护者信息

---

**最后更新**: 2024-11-03  
**文档版本**: 1.0  
**LightAP版本**: 各模块独立版本管理

## 📊 文档更新日志

### 2024-11-03
- ✅ 创建文档中心索引页
- ✅ 添加模块依赖管理完整指南
- ✅ 添加依赖快速参考
- ✅ 提供依赖检查和可视化工具
- ✅ 更新主README添加依赖架构说明

### 2024-10-XX
- 初始文档版本
- 各模块README创建
