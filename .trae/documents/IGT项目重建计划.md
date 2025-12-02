# IGT项目重建计划

## 1. 项目结构分析

根据README.md，项目应该有以下结构：
```
/
├── index.html                    # 主站首页（IGT理论体系总览）
├── theory/                       # 理论文档（六卷完整内容）
│   ├── volume1-foundation/       # 第一卷：理论基础
│   ├── volume2-dynamics/         # 第二卷：演化动力学
│   ├── volume3-measurement/      # 第三卷：测量系统
│   ├── volume4-execution/        # 第四卷：执行引擎
│   ├── volume5-cosmology/        # 第五卷：宇宙哲学
│   └── volume6-implementation/   # 第六卷：实施指南
├── applications/                 # 应用实现
│   ├── frequency-modulation/     # 个性化调频系统
│   ├── ai-rvs-system/           # AI自演化体系
│   ├── yinyang-diagnosis/       # 阴阳相图诊断
│   └── nested-universe/         # 嵌套宇宙模拟
├── tools/                        # 工具与SDK
│   ├── igt-sdk/                 # Python类库（v20.2）
│   ├── measurement-tools/       # 四维测量工具
│   └── visualization/           # 可视化组件
├── case-studies/                # 案例研究库
└── community/                   # 社区贡献
```

## 2. 现有文件分析

当前项目中已经存在以下相关文件：
- index.html（主站首页）
- ai-rvs-system.html（AI自演化体系）
- frequency-modulation.html（个性化调频系统）
- 信息基因论 v20.md（理论文档）
- 信息基因论 IGT v19.5 融合版.md（理论文档）
- 各种IGT相关的文档和文件夹

## 3. 重建计划

### 3.1 创建目录结构

1. 创建理论文档目录结构：
   - theory/
   - theory/volume1-foundation/
   - theory/volume2-dynamics/
   - theory/volume3-measurement/
   - theory/volume4-execution/
   - theory/volume5-cosmology/
   - theory/volume6-implementation/

2. 创建应用实现目录结构：
   - applications/
   - applications/frequency-modulation/
   - applications/ai-rvs-system/
   - applications/yinyang-diagnosis/
   - applications/nested-universe/

3. 创建工具目录结构：
   - tools/
   - tools/igt-sdk/
   - tools/measurement-tools/
   - tools/visualization/

4. 创建其他目录：
   - case-studies/
   - community/

### 3.2 移动现有文件到相应位置

1. 将理论文档移动到theory目录：
   - 将"信息基因论 v20.md"移动到theory/目录
   - 将"信息基因论 IGT v19.5 融合版.md"移动到theory/目录
   - 将"IGT 国家级 Ω 相干度分析协议 (v5.0 - 进化路径版).md"移动到theory/目录

2. 将应用文件移动到applications目录：
   - 将"frequency-modulation.html"移动到applications/frequency-modulation/目录
   - 将"ai-rvs-system.html"移动到applications/ai-rvs-system/目录

3. 将现有的demo目录整合到applications目录：
   - 将"metaverse-demo"目录移动到applications/目录
   - 将"基于信息基因论的新信息元宇宙demo"目录移动到applications/目录

4. 将其他相关文件夹整合到合适的位置：
   - 将"IGT-人工智能方向"目录移动到applications/ai-rvs-system/目录
   - 将"IGT-基础教育重构"目录移动到theory/volume6-implementation/目录
   - 将"IGT探索短文"目录移动到theory/目录
   - 将"空间调频"目录移动到applications/frequency-modulation/目录
   - 将"信息基因论历史版本"目录移动到theory/目录
   - 将"信息元宇宙平台"和"信息元宇宙平台（正式项目）"目录移动到applications/目录
   - 将"游戏式AI成长伙伴APP"目录移动到applications/目录
   - 将"作者Damon专栏"目录移动到community/目录

### 3.3 更新主站首页

更新index.html文件，使其符合README.md中描述的IGT理论体系总览，并添加指向各个理论卷和应用的链接。

### 3.4 创建缺失的文件

1. 创建理论文档各卷的索引文件
2. 创建应用实现各模块的索引文件
3. 创建工具目录的README文件
4. 创建案例研究库和社区贡献的README文件

## 4. 注意事项

- 不删除任何现有的文档和文件夹
- 保持文件的完整性和可读性
- 确保所有链接都能正常工作
- 保持目录结构清晰，便于维护和扩展

## 5. 预期结果

通过重建项目结构，使项目符合README.md中的描述，便于用户理解和使用IGT理论体系，同时保持现有文档和文件夹的完整性。