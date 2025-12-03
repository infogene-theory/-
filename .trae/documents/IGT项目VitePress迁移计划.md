# IGT项目VitePress迁移计划

## 项目现状分析

当前项目结构清晰，以Markdown文档为核心，主要包含以下目录：
- `theory/` - 理论文档（6卷完整内容）
- `applications/` - 应用实现
- `tools/` - 工具与SDK
- `case-studies/` - 案例研究
- `community/` - 社区贡献

## 迁移核心原则

1. **最少改动**：保持现有Markdown文档结构不变
2. **最大收益**：利用VitePress提升开发体验和网站性能
3. **平滑过渡**：保持Cloudflare Pages部署和GitHub版本控制
4. **渐进式升级**：先实现基础功能，再逐步增强交互

## 详细迁移步骤

### 1. 初始化VitePress项目

- **目标**：在现有项目中添加VitePress配置，不影响现有结构
- **操作**：
  - 在项目根目录初始化npm项目
  - 安装VitePress和Vue
  - 创建基础VitePress配置文件

### 2. 迁移现有文档

- **目标**：将现有Markdown文档迁移到VitePress结构
- **操作**：
  - 创建`docs/`目录结构，映射现有内容
  - 复制现有Markdown文件到对应位置
  - 保持文档相对路径不变

### 3. 配置VitePress

- **目标**：配置VitePress主题和导航
- **操作**：
  - 设置网站标题、描述和Logo
  - 配置导航栏（理论体系、应用工具、案例研究、社区）
  - 配置侧边栏，对应现有文档结构
  - 优化移动端体验

### 4. 添加交互组件

- **目标**：添加轻量级交互工具，增强用户体验
- **操作**：
  - 创建Vue组件目录
  - 添加阴阳相图交互组件
  - 添加温控模拟器组件
  - 在Markdown中嵌入交互组件

### 5. 配置开发与部署

- **目标**：优化开发体验，配置部署流程
- **操作**：
  - 添加package.json脚本（dev、build、preview）
  - 配置Cloudflare Pages构建命令
  - 测试本地开发和构建流程

## 目录结构设计

```
docs/
├── index.md                 # 首页（映射根目录index.html）
├── .vitepress/
│   ├── config.js           # 配置文件
│   └── components/         # 交互组件
│       ├── YinYangDiagram.vue
│       └── TemperatureSimulator.vue
├── theory/                 # 理论文档（保持现有结构）
│   ├── volume1-foundation/
│   ├── volume2-dynamics/
│   └── ...
├── applications/           # 应用文档
├── tools/                  # 工具文档
├── case-studies/           # 案例研究
├── community/              # 社区内容
└── public/                 # 静态资源（图片等）
```

## 关键配置要点

### VitePress配置（.vitepress/config.js）

- **网站信息**：设置标题为"信息基因论 IGT"，描述为"基于阴阳调和的宇宙温控动力学"
- **导航栏**：配置主要导航链接，对应现有文档结构
- **侧边栏**：根据不同目录自动生成侧边栏
- **社交链接**：添加GitHub链接
- **页脚**：显示版本信息和版权

### 交互组件设计

- **阴阳相图诊断**：实现简单的交互演示，让用户理解阴阳平衡概念
- **温控模拟器**：可视化展示RVSE热力学循环
- **相干度计算器**：允许用户输入参数计算相干度

## 开发与部署配置

### package.json脚本

```json
{
  "scripts": {
    "dev": "vitepress dev docs",
    "build": "vitepress build docs",
    "preview": "vitepress preview docs"
  }
}
```

### Cloudflare Pages部署

- **构建命令**：`npm run build`
- **构建输出目录**：`docs/.vitepress/dist`
- **环境变量**：无需特殊配置

## 迁移后收益

1. **开发体验提升**：VitePress极速启动和热更新
2. **网站性能优化**：静态生成，加载速度快
3. **更好的SEO**：支持自动生成sitemap和meta标签
4. **增强的文档功能**：支持Markdown扩展语法、代码高亮、数学公式等
5. **轻量级交互**：可以在Markdown中嵌入Vue组件
6. **响应式设计**：默认主题适配移动端

## 风险评估与应对

1. **文档格式兼容性**：VitePress完全兼容标准Markdown，现有文档无需修改
2. **链接失效风险**：保持相对路径不变，避免链接失效
3. **部署配置变化**：Cloudflare Pages支持静态生成网站，配置简单
4. **学习曲线**：VitePress配置简单，学习成本低

## 预期成果

- 基于VitePress的现代化静态网站
- 保持现有文档结构和内容不变
- 提升开发体验和网站性能
- 支持轻量级交互组件
- 与现有部署流程兼容

## 下一步行动

1. 初始化VitePress项目
2. 迁移现有文档到docs目录
3. 配置VitePress主题和导航
4. 添加基础交互组件
5. 测试开发和构建流程
6. 更新Cloudflare Pages配置
7. 部署上线

通过以上计划，我们可以在2小时内完成基础迁移，快速看到效果，同时保留未来扩展的可能性。