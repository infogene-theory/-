# IGT工具与SDK

本目录包含信息基因论IGT v20的工具与SDK，用于支持理论的应用和扩展。

## 目录结构

### igt-sdk/
Python类库（v20.2），提供IGT理论的核心算法和功能实现。

### measurement-tools/
四维测量工具，用于测量和分析温度场的四维特性。

### visualization/
可视化组件，用于展示IGT理论中的各种概念和模型。

## 使用说明

### 安装

```bash
# 安装IGT-SDK
pip install igt-sdk
```

### 基本使用

```python
from igt_sdk import TemperatureField, RVSECycle

# 创建温度场对象
temp_field = TemperatureField()

# 计算相干度
coherence = temp_field.calculate_coherence()

# 运行RVSE循环
rvse = RVSECycle()
rvse.run()
```

## 开发指南

### 贡献流程

1. Fork本仓库
2. 创建特性分支
3. 提交更改
4. 推送分支
5. 创建Pull Request

### 编码规范

- 遵循PEP 8编码规范
- 提供完整的文档字符串
- 编写单元测试

## 版本历史

- v20.2: 初始版本，包含核心功能

## 许可证

本项目采用知识共享署名-相同方式共享4.0国际许可协议（CC BY-SA 4.0）。