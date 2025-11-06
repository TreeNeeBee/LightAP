# LightAP Middleware Platform

LightAP is an AUTOSAR Adaptive Platform compliant middleware solution providing core services for automotive embedded systems.

## 📦 Project Structure

```
LightAP/
├── BuildTemplate/          # Build system templates (submodule)
├── modules/
│   ├── Core/              # Core services (submodule)
│   ├── Com/               # Communication module
│   ├── LogAndTrace/       # Logging and diagnostics
│   ├── Persistency/       # Data persistence
│   └── PlatformHealthManagement/  # Health monitoring
├── docs/                  # Documentation
├── examples/              # Usage examples
└── tests/                 # Integration tests
```

## 🚀 Quick Start

### Clone with Submodules

```bash
# Clone repository with all submodules
git clone --recursive git@10.80.105.120:ddk/LightAP.git
cd LightAP

# Or if already cloned without submodules:
git submodule update --init --recursive
```

### Build

```bash
# Create build directory
mkdir -p build && cd build

# Configure with CMake
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build all modules
cmake --build . -j$(nproc)

# Run tests
ctest --output-on-failure
```

## 📋 Submodules

| Module | Path | Repository | Description |
|--------|------|------------|-------------|
| **BuildTemplate** | `BuildTemplate/` | `git@10.80.105.120:ddk/BuildTemplate.git` | CMake build system templates |
| **Core** | `modules/Core/` | `git@10.80.105.120:ddk/Core.git` | Core services (memory, config, AUTOSAR types) |
| **Com** | `modules/Com/` | `git@10.80.105.120:ddk/Com.git` | Communication services (IPC, Service-Oriented Communication) |
| **LogAndTrace** | `modules/LogAndTrace/` | `git@10.80.105.120:ddk/LogAndTrace.git` | Logging and diagnostic services |
| **Persistency** | `modules/Persistency/` | `git@10.80.105.120:ddk/Persistency.git` | Key-value storage and data persistence |
| **PlatformHealthManagement** | `modules/PlatformHealthManagement/` | `git@10.80.105.120:ddk/PlatformHealthManagement.git` | Platform health monitoring and supervision |

### Working with Submodules

```bash
# Update all submodules to latest commits
git submodule update --remote

# Update specific submodule
git submodule update --remote modules/Core

# Check submodule status
git submodule status

# Enter submodule to make changes
cd modules/Core
git checkout master
# Make changes, commit, and push
git add .
git commit -m "your changes"
git push origin master

# Return to main repository and update reference
cd ../..
git add modules/Core
git commit -m "chore: update Core submodule"
git push origin master
```

## 🔧 Dependencies

### Build Requirements
- **CMake** ≥ 3.10.2
- **C++ Compiler** with C++17 support (GCC 7+, Clang 5+)
- **Git** for submodule management

### Module Dependency Chain

```
BuildTemplate (构建系统)
    ↓
Core (基础服务) - Layer 1
    ↓
LogAndTrace (日志服务) - Layer 2
    ↓
Persistency, Com (高级服务) - Layer 3
    ↓
PlatformHealthManagement (平台服务) - Layer 4
```

**📘 详细依赖管理文档**: [MODULE_DEPENDENCIES.md](docs/MODULE_DEPENDENCIES.md)
- 依赖关系组织方案（Symlink、CMake Export、混合方案）
- 版本管理最佳实践
- 独立构建vs集成构建
- 依赖可视化工具

**🔍 查看依赖图**:
```bash
./docs/visualize_dependencies.sh
# 生成: /tmp/lightap_dependencies.png
```

### Module-Specific Dependencies
See individual module READMEs for detailed dependency lists:
- [Core Module Dependencies](modules/Core/README.md#-dependencies)
- [LogAndTrace Module Dependencies](modules/LogAndTrace/README.md)
- [Com Module Dependencies](modules/Com/README.md)
- [Persistency Module Dependencies](modules/Persistency/README.md)

## 📚 Module Documentation

- **[Core](modules/Core/README.md)** - Memory management, configuration, AUTOSAR types
- **[Com](modules/Com/README.md)** - Communication middleware
- **[LogAndTrace](modules/LogAndTrace/README.md)** - Logging and DLT integration
- **[Persistency](modules/Persistency/README.md)** - Key-value storage
- **[PlatformHealthManagement](modules/PlatformHealthManagement/README.md)** - System health monitoring

## 🏗️ Development Workflow

### Adding New Features

1. **Work in submodule**:
   ```bash
   cd modules/Core
   git checkout -b feature/new-feature
   # Make changes
   git commit -m "feat: add new feature"
   git push origin feature/new-feature
   ```

2. **Update main repository**:
   ```bash
   cd ../..
   git add modules/Core
   git commit -m "feat: integrate new Core feature"
   git push origin master
   ```

### Syncing with Latest Changes

```bash
# Pull main repository changes
git pull origin master

# Update all submodules
git submodule update --init --recursive

# Or update to latest remote commits
git submodule update --remote
```

## 🧪 Testing

### Run All Tests
```bash
cd build
ctest --output-on-failure
```

### Run Module-Specific Tests
```bash
# Core module tests
cd build/modules/Core
./core_test

# Run with filters
./core_test --gtest_filter="*Memory*"
```

## 📝 Contributing

1. Fork the repository
2. Create feature branch in appropriate submodule
3. Make changes and add tests
4. Update documentation
5. Submit pull request

### Code Style
- Follow existing module conventions
- Use AUTOSAR coding guidelines where applicable
- Add unit tests for new features
- Update relevant README files

## 📄 License

Copyright © 2025 LightAP Project Contributors. All rights reserved.

This software is proprietary and confidential. Unauthorized copying, distribution, or modification is strictly prohibited.

## 📧 Support

- **Issue Tracker**: [Internal Tracker]
- **Email**: lightap-dev@yourcompany.com
- **Documentation**: See `docs/` directory

---

**Version**: 1.0.0  
**Last Updated**: November 3, 2025
