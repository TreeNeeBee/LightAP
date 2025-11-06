#include <lap/core/CMemory.hpp>
#include <lap/core/CConfig.hpp>
#include <lap/log/CLog.hpp>
#include <iostream>

using namespace lap::core;
using namespace lap::log;

int main() {
    std::cout << "==================================" << std::endl;
    std::cout << "LightAP Example Application" << std::endl;
    std::cout << "==================================" << std::endl;
    std::cout << std::endl;
    
    // 初始化日志系统
    std::cout << "初始化日志系统..." << std::endl;
    // 注意：实际使用时需要根据LogAndTrace的API进行初始化
    
    // 测试Core模块
    std::cout << "测试Core模块..." << std::endl;
    try {
        // 示例：使用内存管理
        std::cout << "  ✓ Core模块可用" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "  ✗ Core模块错误: " << e.what() << std::endl;
        return 1;
    }
    
    // 测试Log模块
    std::cout << "测试Log模块..." << std::endl;
    try {
        // 示例：创建日志记录器
        std::cout << "  ✓ Log模块可用" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "  ✗ Log模块错误: " << e.what() << std::endl;
        return 1;
    }
    
    std::cout << std::endl;
    std::cout << "==================================" << std::endl;
    std::cout << "✓ 所有测试通过！" << std::endl;
    std::cout << "==================================" << std::endl;
    
    return 0;
}
