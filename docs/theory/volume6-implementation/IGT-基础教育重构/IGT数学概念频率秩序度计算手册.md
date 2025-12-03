# IGT数学概念频率秩序度计算手册

## 📊 理论基础

### 频率秩序度的数学定义

在信息基因论（IGT）框架下，数学概念的频率秩序度（Order Degree, OD）是衡量数学对象内在规律性和可预测性的量化指标。其定义为：

**OD = 1 - H_rel = 1 - (H / H_max)**

其中：
- **H** 为实际信息熵
- **H_max** 为最大可能熵值
- **H_rel** 为相对熵

### 核心计算公式

#### 1. 离散型数学对象的秩序度
对于离散数学对象（如整数、有限集合等）：

```
OD = 1 + Σ(p_i × log₂p_i) / log₂N
```

其中：
- **p_i** 为第i种状态出现的概率
- **N** 为可能状态的总数

#### 2. 连续型数学对象的秩序度
对于连续数学对象（如实数、函数等）：

```
OD = 1 - ∫f(x)log₂f(x)dx / log₂(b-a)
```

其中：
- **f(x)** 为概率密度函数
- **[a,b]** 为定义域

#### 3. 序列型数学对象的秩序度
对于数学序列（如数列、数字串等）：

```
OD = 1 - H_markov / log₂k
```

其中：
- **H_markov** 为马尔可夫链熵
- **k** 为符号集大小

---

## 🔢 数的频率秩序度计算

### 自然数的秩序度

#### 理论基础
自然数具有完全的频率秩序，因为每个自然数都有确定的位置和性质。

#### 计算公式
```
OD_natural(n) = 1.0
```

#### 计算示例
```python
def natural_number_order_degree(n):
    """
    计算自然数的秩序度
    
    参数:
        n: 自然数
        
    返回:
        秩序度 (自然数恒为1.0)
    """
    return 1.0

# 示例
print(f"数字7的秩序度: {natural_number_order_degree(7)}")
print(f"数字100的秩序度: {natural_number_order_degree(100)}")
```

### 整数的秩序度

#### 理论基础
整数包括正整数、负整数和零，需要考虑符号的秩序贡献。

#### 计算公式
```
OD_integer = w_pos × OD_positive + w_neg × OD_negative + w_zero × OD_zero
```

其中权重：
- **w_pos** = 正整数数量 / 总数量
- **w_neg** = 负整数数量 / 总数量  
- **w_zero** = 1 / 总数量

#### 计算示例
```python
def integer_order_degree(integers):
    """
    计算整数集合的秩序度
    
    参数:
        integers: 整数列表
        
    返回:
        综合秩序度
    """
    total = len(integers)
    
    # 分类统计
    positives = [x for x in integers if x > 0]
    negatives = [x for x in integers if x < 0]
    zeros = [x for x in integers if x == 0]
    
    # 计算各类别的秩序度
    od_positive = 1.0 if positives else 0.0
    od_negative = 1.0 if negatives else 0.0
    od_zero = 1.0 if zeros else 0.0
    
    # 计算权重
    w_pos = len(positives) / total
    w_neg = len(negatives) / total
    w_zero = len(zeros) / total
    
    # 综合秩序度
    od_total = w_pos * od_positive + w_neg * od_negative + w_zero * od_zero
    
    return {
        'total_order_degree': od_total,
        'components': {
            'positive': {'count': len(positives), 'order_degree': od_positive, 'weight': w_pos},
            'negative': {'count': len(negatives), 'order_degree': od_negative, 'weight': w_neg},
            'zero': {'count': len(zeros), 'order_degree': od_zero, 'weight': w_zero}
        }
    }

# 示例
integers = [-3, -1, 0, 2, 4, 7, 10]
result = integer_order_degree(integers)
print(f"整数集合 {integers} 的秩序度分析：")
print(f"综合秩序度: {result['total_order_degree']:.3f}")
for component, data in result['components'].items():
    print(f"{component}: 数量={data['count']}, 秩序度={data['order_degree']:.1f}, 权重={data['weight']:.3f}")
```

### 有理数的秩序度

#### 理论基础
有理数可以表示为分数形式，需要考虑分子和分母的秩序关系。

#### 计算公式
```
OD_rational = α × OD_numerator + β × OD_denominator + γ × OD_ratio
```

其中：
- **α, β, γ** 为权重系数（通常取1/3）
- **OD_numerator** 为分子的秩序度
- **OD_denominator** 为分母的秩序度
- **OD_ratio** 为比值关系的秩序度

#### 计算示例
```python
import math
from fractions import Fraction

def rational_number_order_degree(rational_str):
    """
    计算有理数的秩序度
    
    参数:
        rational_str: 有理数字符串表示（如"3/4"）
        
    返回:
        秩序度分析结果
    """
    # 解析分数
    frac = Fraction(rational_str)
    numerator = frac.numerator
    denominator = frac.denominator
    
    # 计算各部分的秩序度
    od_numerator = natural_number_order_degree(numerator)
    od_denominator = natural_number_order_degree(denominator)
    
    # 计算比值关系的秩序度（基于最简分数）
    gcd_val = math.gcd(numerator, denominator)
    if gcd_val == 1:
        od_ratio = 1.0  # 最简分数，秩序度最高
    else:
        od_ratio = 0.8  # 可约分，秩序度稍低
    
    # 综合计算（等权重）
    weights = {'numerator': 1/3, 'denominator': 1/3, 'ratio': 1/3}
    od_total = (weights['numerator'] * od_numerator + 
                weights['denominator'] * od_denominator + 
                weights['ratio'] * od_ratio)
    
    return {
        'rational': rational_str,
        'numerator': numerator,
        'denominator': denominator,
        'gcd': gcd_val,
        'order_degrees': {
            'numerator': od_numerator,
            'denominator': od_denominator,
            'ratio': od_ratio
        },
        'total_order_degree': od_total,
        'weights': weights
    }

# 示例
rationals = ["1/2", "3/4", "6/8", "22/7", "-5/3"]
for rational in rationals:
    result = rational_number_order_degree(rational)
    print(f"\n有理数 {rational} 的秩序度分析：")
    print(f"分子: {result['numerator']}, 秩序度: {result['order_degrees']['numerator']:.1f}")
    print(f"分母: {result['denominator']}, 秩序度: {result['order_degrees']['denominator']:.1f}")
    print(f"最大公约数: {result['gcd']}")
    print(f"比值关系秩序度: {result['order_degrees']['ratio']:.1f}")
    print(f"综合秩序度: {result['total_order_degree']:.3f}")
```

### 无理数的秩序度

#### 理论基础
无理数是无限不循环小数，具有较低的频率秩序度。

#### 计算公式
```
OD_irrational = lim(n→∞) [1 - H_n / log₂10]
```

其中 **H_n** 为前n位小数的熵。

#### 计算示例
```python
def irrational_number_order_degree(irrational_str, precision=100):
    """
    计算无理数的秩序度
    
    参数:
        irrational_str: 无理数近似值字符串
        precision: 计算精度（小数位数）
        
    返回:
        秩序度分析
    """
    # 提取小数部分
    if '.' in irrational_str:
        decimal_part = irrational_str.split('.')[1][:precision]
    else:
        decimal_part = irrational_str[:precision]
    
    # 统计数字频率
    digit_counts = {}
    for digit in decimal_part:
        if digit.isdigit():
            digit_counts[digit] = digit_counts.get(digit, 0) + 1
    
    total_digits = sum(digit_counts.values())
    
    # 计算熵
    entropy = 0
    for count in digit_counts.values():
        prob = count / total_digits
        if prob > 0:
            entropy -= prob * math.log2(prob)
    
    # 最大熵（均匀分布）
    max_entropy = math.log2(10)  # 10个数字
    
    # 秩序度
    order_degree = 1 - entropy / max_entropy
    
    return {
        'irrational': irrational_str,
        'decimal_part': decimal_part,
        'digit_counts': digit_counts,
        'entropy': entropy,
        'max_entropy': max_entropy,
        'order_degree': order_degree,
        'digit_distribution': {d: count/total_digits for d, count in digit_counts.items()}
    }

# 示例
irrationals = {
    "π": "3.14159265358979323846264338327950288419716939937510",
    "e": "2.71828182845904523536028747135266249775724709369995",
    "√2": "1.41421356237309504880168872420969807856967187537694",
    "φ": "1.61803398874989484820458683436563811772030917980576"
}

for name, value in irrationals.items():
    result = irrational_number_order_degree(value, 50)
    print(f"\n{name} ({value[:20]}...) 的秩序度分析：")
    print(f"小数位数: {len(result['decimal_part'])}")
    print(f"信息熵: {result['entropy']:.3f}")
    print(f"最大熵: {result['max_entropy']:.3f}")
    print(f"秩序度: {result['order_degree']:.3f}")
    print(f"数字分布: {dict(list(result['digit_distribution'].items())[:5])}")
```

---

## 📐 几何图形的频率秩序度

### 基础图形的秩序度

#### 理论基础
几何图形的秩序度取决于其对称性、规则性和复杂性。

#### 计算公式
```
OD_geometric = w_symmetry × OD_symmetry + w_regularity × OD_regularity + w_complexity × (1 - OD_complexity)
```

#### 计算示例
```python
import numpy as np
import matplotlib.pyplot as plt

def geometric_shape_order_degree(shape_type, **kwargs):
    """
    计算几何图形的秩序度
    
    参数:
        shape_type: 图形类型 ('circle', 'square', 'triangle', 'rectangle')
        **kwargs: 图形参数
        
    返回:
        秩序度分析
    """
    
    # 对称性秩序度（基于对称轴数量）
    symmetry_axes = {
        'circle': float('inf'),  # 无限对称轴
        'square': 4,
        'equilateral_triangle': 3,
        'isosceles_triangle': 1,
        'scalene_triangle': 0,
        'rectangle': 2,
        'parallelogram': 0
    }
    
    # 规则性秩序度（基于角度和边长关系）
    regularity_scores = {
        'circle': 1.0,      # 完全规则
        'square': 1.0,      # 完全规则
        'equilateral_triangle': 1.0,  # 完全规则
        'isosceles_triangle': 0.7,   # 部分规则
        'scalene_triangle': 0.3,     # 不规则
        'rectangle': 0.8,    # 部分规则
        'parallelogram': 0.6         # 部分规则
    }
    
    # 复杂性秩序度（基于参数数量）
    complexity_scores = {
        'circle': 0.2,      # 仅需半径
        'square': 0.3,      # 需边长
        'triangle': 0.6,    # 需三边或三角
        'rectangle': 0.4,   # 需长和宽
        'polygon': 0.8       # 需多个参数
    }
    
    # 获取具体参数
    if shape_type == 'circle':
        radius = kwargs.get('radius', 1)
        actual_type = 'circle'
    elif shape_type == 'square':
        side = kwargs.get('side', 1)
        actual_type = 'square'
    elif shape_type == 'triangle':
        triangle_type = kwargs.get('type', 'equilateral')
        actual_type = f"{triangle_type}_triangle"
    elif shape_type == 'rectangle':
        length = kwargs.get('length', 2)
        width = kwargs.get('width', 1)
        actual_type = 'rectangle'
    else:
        actual_type = shape_type
    
    # 计算各维度秩序度
    # 对称性
    axes = symmetry_axes.get(actual_type, 0)
    if axes == float('inf'):
        od_symmetry = 1.0
    else:
        od_symmetry = min(axes / 4, 1.0)  # 以正方形为基准
    
    # 规则性
    od_regularity = regularity_scores.get(actual_type, 0.5)
    
    # 复杂性（反向计算，复杂性越高秩序度越低）
    complexity = complexity_scores.get(shape_type, 0.5)
    od_complexity = 1 - complexity
    
    # 综合计算（等权重）
    weights = {'symmetry': 1/3, 'regularity': 1/3, 'complexity': 1/3}
    od_total = (weights['symmetry'] * od_symmetry + 
                weights['regularity'] * od_regularity + 
                weights['complexity'] * od_complexity)
    
    return {
        'shape': shape_type,
        'parameters': kwargs,
        'order_degrees': {
            'symmetry': od_symmetry,
            'regularity': od_regularity,
            'complexity': od_complexity
        },
        'total_order_degree': od_total,
        'weights': weights,
        'symmetry_axes': axes
    }

# 示例
shapes = [
    {'type': 'circle', 'params': {'radius': 5}},
    {'type': 'square', 'params': {'side': 4}},
    {'type': 'triangle', 'params': {'type': 'equilateral'}},
    {'type': 'triangle', 'params': {'type': 'isosceles'}},
    {'type': 'triangle', 'params': {'type': 'scalene'}},
    {'type': 'rectangle', 'params': {'length': 6, 'width': 3}}
]

print("几何图形的频率秩序度分析：")
for shape in shapes:
    result = geometric_shape_order_degree(shape['type'], **shape['params'])
    print(f"\n{result['shape'].title()}:")
    print(f"  对称性秩序度: {result['order_degrees']['symmetry']:.3f}")
    print(f"  规则性秩序度: {result['order_degrees']['regularity']:.3f}")
    print(f"  复杂性秩序度: {result['order_degrees']['complexity']:.3f}")
    print(f"  综合秩序度: {result['total_order_degree']:.3f}")
    if result['symmetry_axes'] != float('inf'):
        print(f"  对称轴数量: {result['symmetry_axes']}")
    else:
        print(f"  对称轴数量: 无限")
```

### 复杂几何图形的秩序度

#### 理论基础
复杂几何图形需要考虑分形维数、自相似性和拓扑性质。

#### 计算公式
```python
def complex_geometric_order_degree(shape_type, complexity_level='medium', **kwargs):
    """
    计算复杂几何图形的秩序度
    
    参数:
        shape_type: 复杂图形类型
        complexity_level: 复杂度级别 ('simple', 'medium', 'complex')
        **kwargs: 具体参数
        
    返回:
        秩序度分析
    """
    
    # 分形图形的秩序度计算
    def fractal_order_degree(iterations, dimension):
        """分形图形的秩序度"""
        # 自相似性贡献
        self_similarity = 1 - 1/iterations
        
        # 分形维数贡献（越接近整数越有序）
        fractal_integer_part = int(dimension)
        fractal_decimal_part = dimension - fractal_integer_part
        dimension_order = 1 - fractal_decimal_part
        
        # 迭代稳定性贡献
        stability = 1 - 0.1 * math.log10(iterations + 1)
        
        return (self_similarity + dimension_order + stability) / 3
    
    # 组合图形的秩序度计算
    def composite_order_degree(components, connections):
        """组合图形的秩序度"""
        # 组件秩序度平均值
        component_od = np.mean([comp['order_degree'] for comp in components])
        
        # 连接关系秩序度
        if connections > 0:
            connection_od = 1 - 1/(connections + 1)
        else:
            connection_od = 0.5
        
        # 整体协调性（基于组件数量）
        coordination = 1 - len(components) * 0.05
        coordination = max(coordination, 0.3)
        
        return (component_od + connection_od + coordination) / 3
    
    # 拓扑变形图形的秩序度
    def topological_order_degree(original_od, deformation_level, invariants):
        """拓扑变形图形的秩序度"""
        # 不变量保持度
        invariant_preservation = len(invariants) / 3  # 假设3个基本不变量
        
        # 变形程度影响
        deformation_penalty = deformation_level * 0.2
        
        # 拓扑秩序度
        topological_od = invariant_preservation - deformation_penalty
        topological_od = max(topological_od, 0.1)
        
        # 综合原始秩序度和拓扑秩序度
        return (original_od + topological_od) / 2
    
    if shape_type == 'fractal':
        iterations = kwargs.get('iterations', 5)
        dimension = kwargs.get('dimension', 1.5)
        od_total = fractal_order_degree(iterations, dimension)
        
        return {
            'shape_type': 'fractal',
            'order_degree': od_total,
            'details': {
                'iterations': iterations,
                'fractal_dimension': dimension,
                'self_similarity': 1 - 1/iterations,
                'dimension_order': 1 - (dimension - int(dimension))
            }
        }
    
    elif shape_type == 'composite':
        components = kwargs.get('components', [])
        connections = kwargs.get('connections', 0)
        od_total = composite_order_degree(components, connections)
        
        return {
            'shape_type': 'composite',
            'order_degree': od_total,
            'details': {
                'component_count': len(components),
                'connections': connections,
                'average_component_od': np.mean([comp['order_degree'] for comp in components]) if components else 0
            }
        }
    
    elif shape_type == 'topological':
        original_od = kwargs.get('original_order_degree', 0.8)
        deformation_level = kwargs.get('deformation_level', 0.3)
        invariants = kwargs.get('invariants', [])
        od_total = topological_order_degree(original_od, deformation_level, invariants)
        
        return {
            'shape_type': 'topological',
            'order_degree': od_total,
            'details': {
                'original_order_degree': original_od,
                'deformation_level': deformation_level,
                'preserved_invariants': len(invariants),
                'invariant_list': invariants
            }
        }
    
    else:
        return {'shape_type': shape_type, 'order_degree': 0.5, 'error': 'Unknown shape type'}

# 示例
print("\n复杂几何图形的频率秩序度：")

# 分形示例
fractal_result = complex_geometric_order_degree('fractal', iterations=7, dimension=1.618)
print(f"\n分形图形:")
print(f"  秩序度: {fractal_result['order_degree']:.3f}")
print(f"  迭代次数: {fractal_result['details']['iterations']}")
print(f"  分形维数: {fractal_result['details']['fractal_dimension']}")

# 组合图形示例
components = [
    {'order_degree': 0.9},  # 正方形
    {'order_degree': 0.8},  # 圆形
    {'order_degree': 0.7}   # 三角形
]
composite_result = complex_geometric_order_degree('composite', components=components, connections=2)
print(f"\n组合图形:")
print(f"  秩序度: {composite_result['order_degree']:.3f}")
print(f"  组件数量: {composite_result['details']['component_count']}")
print(f"  连接数: {composite_result['details']['connections']}")

# 拓扑变形示例
topological_result = complex_geometric_order_degree(
    'topological', 
    original_order_degree=0.85,
    deformation_level=0.2,
    invariants=['连通性', '孔洞数']
)
print(f"\n拓扑变形图形:")
print(f"  秩序度: {topological_result['order_degree']:.3f}")
print(f"  原始秩序度: {topological_result['details']['original_order_degree']}")
print(f"  保持的不变量: {topological_result['details']['invariant_list']}")
```

---

## 📈 函数的频率秩序度

### 基础函数的秩序度

#### 理论基础
函数的秩序度取决于其规律性、周期性和复杂性。

#### 计算公式
```python
def function_order_degree(func_type, domain=(-10, 10), **kwargs):
    """
    计算函数的秩序度
    
    参数:
        func_type: 函数类型
        domain: 定义域
        **kwargs: 函数参数
        
    返回:
        秩序度分析
    """
    
    def linear_function_order(slope, intercept):
        """线性函数的秩序度"""
        # 线性函数具有完全的秩序（一次函数）
        linearity = 1.0
        
        # 斜率的秩序贡献
        slope_order = 1.0 if slope != 0 else 0.8  # 水平线稍低
        
        # 截距的秩序贡献
        intercept_order = 1.0
        
        return (linearity + slope_order + intercept_order) / 3
    
    def quadratic_function_order(a, b, c):
        """二次函数的秩序度"""
        # 抛物线的基本秩序
        parabola_order = 0.9
        
        # 开口方向的秩序
        direction_order = 1.0 if a != 0 else 0.5
        
        # 顶点位置的秩序
        if b == 0:  # 顶点在y轴
            vertex_order = 1.0
        else:  # 顶点偏移
            vertex_order = 0.9
        
        return (parabola_order + direction_order + vertex_order) / 3
    
    def trigonometric_function_order(amplitude, frequency, phase):
        """三角函数的秩序度"""
        # 周期性秩序
        periodicity = 1.0
        
        # 频率秩序（整数频率更有序）
        if frequency == int(frequency):
            freq_order = 1.0
        else:
            freq_order = 0.8
        
        # 相位秩序（零相位更有序）
        phase_order = 1.0 if phase == 0 else 0.9
        
        return (periodicity + freq_order + phase_order) / 3
    
    def exponential_function_order(base, coefficient):
        """指数函数的秩序度"""
        # 指数增长/衰减的基本秩序
        exp_order = 0.85
        
        # 底数的秩序（特殊底数更有序）
        special_bases = [2, 10, math.e]
        if base in special_bases:
            base_order = 1.0
        else:
            base_order = 0.8
        
        # 系数的秩序
        coeff_order = 1.0 if coefficient != 0 else 0.5
        
        return (exp_order + base_order + coeff_order) / 3
    
    def logarithmic_function_order(base, argument_coeff, base_coeff):
        """对数函数的秩序度"""
        # 对数函数的基本秩序
        log_order = 0.8
        
        # 底数的秩序
        if base == 10 or base == math.e:
            base_order = 1.0
        else:
            base_order = 0.7
        
        # 定义域限制的影响
        domain_order = 0.9  # 定义域受限但明确
        
        return (log_order + base_order + domain_order) / 3
    
    # 根据函数类型计算秩序度
    if func_type == 'linear':
        slope = kwargs.get('slope', 1)
        intercept = kwargs.get('intercept', 0)
        od_total = linear_function_order(slope, intercept)
        
        return {
            'function_type': 'linear',
            'order_degree': od_total,
            'parameters': {'slope': slope, 'intercept': intercept},
            'formula': f"y = {slope}x + {intercept}"
        }
    
    elif func_type == 'quadratic':
        a = kwargs.get('a', 1)
        b = kwargs.get('b', 0)
        c = kwargs.get('c', 0)
        od_total = quadratic_function_order(a, b, c)
        
        return {
            'function_type': 'quadratic',
            'order_degree': od_total,
            'parameters': {'a': a, 'b': b, 'c': c},
            'formula': f"y = {a}x² + {b}x + {c}"
        }
    
    elif func_type == 'trigonometric':
        amplitude = kwargs.get('amplitude', 1)
        frequency = kwargs.get('frequency', 1)
        phase = kwargs.get('phase', 0)
        od_total = trigonometric_function_order(amplitude, frequency, phase)
        
        return {
            'function_type': 'trigonometric',
            'order_degree': od_total,
            'parameters': {'amplitude': amplitude, 'frequency': frequency, 'phase': phase},
            'formula': f"y = {amplitude}sin({frequency}x + {phase})"
        }
    
    elif func_type == 'exponential':
        base = kwargs.get('base', math.e)
        coefficient = kwargs.get('coefficient', 1)
        od_total = exponential_function_order(base, coefficient)
        
        return {
            'function_type': 'exponential',
            'order_degree': od_total,
            'parameters': {'base': base, 'coefficient': coefficient},
            'formula': f"y = {coefficient} × {base}^x"
        }
    
    elif func_type == 'logarithmic':
        base = kwargs.get('base', 10)
        argument_coeff = kwargs.get('argument_coeff', 1)
        base_coeff = kwargs.get('base_coeff', 1)
        od_total = logarithmic_function_order(base, argument_coeff, base_coeff)
        
        return {
            'function_type': 'logarithmic',
            'order_degree': od_total,
            'parameters': {'base': base, 'argument_coeff': argument_coeff, 'base_coeff': base_coeff},
            'formula': f"y = {base_coeff} × log_{base}({argument_coeff}x)"
        }
    
    else:
        return {'function_type': func_type, 'order_degree': 0.5, 'error': 'Unknown function type'}

# 示例
print("基础函数的频率秩序度：")

functions = [
    {'type': 'linear', 'params': {'slope': 2, 'intercept': 3}},
    {'type': 'quadratic', 'params': {'a': 1, 'b': 0, 'c': -4}},
    {'type': 'trigonometric', 'params': {'amplitude': 1, 'frequency': 1, 'phase': 0}},
    {'type': 'exponential', 'params': {'base': 2, 'coefficient': 1}},
    {'type': 'logarithmic', 'params': {'base': 10, 'argument_coeff': 1, 'base_coeff': 1}}
]

for func in functions:
    result = function_order_degree(func['type'], **func['params'])
    print(f"\n{result['function_type'].title()}函数:")
    print(f"  秩序度: {result['order_degree']:.3f}")
    print(f"  公式: {result['formula']}")
```

### 复合函数的秩序度

#### 理论基础
复合函数的秩序度需要考虑函数组合的复杂性和内在逻辑。

#### 计算示例
```python
def composite_function_order_degree(functions, composition_type='sequential'):
    """
    计算复合函数的秩序度
    
    参数:
        functions: 函数列表，每个元素是(function_type, parameters)元组
        composition_type: 组合类型 ('sequential', 'parallel', 'nested')
        
    返回:
        秩序度分析
    """
    
    def sequential_composition_order(function_orders):
        """顺序组合的秩序度"""
        # 基础秩序度（平均值）
        base_order = np.mean(function_orders)
        
        # 组合复杂性惩罚
        complexity_penalty = len(function_orders) * 0.05
        
        # 信息传递效率
        information_transfer = 1 - complexity_penalty
        
        return base_order * information_transfer
    
    def parallel_composition_order(function_orders):
        """并行组合的秩序度"""
        # 并行系统的秩序度（取最小值，受最弱环节影响）
        min_order = min(function_orders)
        
        # 并行协调性奖励
        coordination_bonus = 1 - np.std(function_orders) * 0.3
        
        return min_order * coordination_bonus
    
    def nested_composition_order(function_orders):
        """嵌套组合的秩序度"""
        # 嵌套深度影响
        depth_factor = 1 / (1 + len(function_orders) * 0.1)
        
        # 内外层函数秩序度的综合
        if len(function_orders) >= 2:
            outer_order = function_orders[0]
            inner_order = function_orders[-1]
            nested_order = (outer_order + inner_order) / 2 * depth_factor
        else:
            nested_order = function_orders[0] * depth_factor
        
        return nested_order
    
    # 计算各个基础函数的秩序度
    individual_orders = []
    function_details = []
    
    for func_type, params in functions:
        result = function_order_degree(func_type, **params)
        individual_orders.append(result['order_degree'])
        function_details.append(result)
    
    # 根据组合类型计算综合秩序度
    if composition_type == 'sequential':
        composite_order = sequential_composition_order(individual_orders)
        composition_formula = "f₁ → f₂ → ... → fₙ"
        
    elif composition_type == 'parallel':
        composite_order = parallel_composition_order(individual_orders)
        composition_formula = "f₁ ‖ f₂ ‖ ... ‖ fₙ"
        
    elif composition_type == 'nested':
        composite_order = nested_composition_order(individual_orders)
        composition_formula = "f₁(f₂(...fₙ(x)...))"
        
    else:
        composite_order = np.mean(individual_orders)
        composition_formula = "unknown composition"
    
    return {
        'composition_type': composition_type,
        'individual_functions': function_details,
        'individual_orders': individual_orders,
        'composite_order_degree': composite_order,
        'composition_formula': composition_formula,
        'function_count': len(functions)
    }

# 示例
print("\n复合函数的频率秩序度：")

# 顺序组合示例
sequential_functions = [
    ('linear', {'slope': 2, 'intercept': 1}),
    ('quadratic', {'a': 1, 'b': 0, 'c': -3}),
    ('trigonometric', {'amplitude': 1, 'frequency': 2, 'phase': 0})
]

sequential_result = composite_function_order_degree(sequential_functions, 'sequential')
print(f"\n顺序组合:")
print(f"  综合秩序度: {sequential_result['composite_order_degree']:.3f}")
print(f"  组合方式: {sequential_result['composition_formula']}")
print(f"  各函数秩序度: {[f'{od:.3f}' for od in sequential_result['individual_orders']]}")

# 嵌套组合示例
nested_functions = [
    ('trigonometric', {'amplitude': 1, 'frequency': 1, 'phase': 0}),
    ('exponential', {'base': 2, 'coefficient': 1}),
    ('logarithmic', {'base': 10, 'argument_coeff': 1, 'base_coeff': 1})
]

nested_result = composite_function_order_degree(nested_functions, 'nested')
print(f"\n嵌套组合:")
print(f"  综合秩序度: {nested_result['composite_order_degree']:.3f}")
print(f"  组合方式: {nested_result['composition_formula']}")
```

---

## 📊 统计与概率的秩序度

### 概率分布的秩序度

#### 理论基础
概率分布的秩序度反映其偏离均匀分布的程度。

#### 计算公式
```python
def probability_distribution_order_degree(dist_type, **params):
    """
    计算概率分布的秩序度
    
    参数:
        dist_type: 分布类型
        **params: 分布参数
        
    返回:
        秩序度分析
    """
    
    def uniform_distribution_order(a, b):
        """均匀分布的秩序度"""
        # 均匀分布具有最高的无序性
        return 0.0
    
    def normal_distribution_order(mean, std):
        """正态分布的秩序度"""
        # 标准差越小，秩序度越高
        std_order = 1 / (1 + std * 0.1)
        
        # 均值位置不影响秩序度
        mean_order = 1.0
        
        return (std_order + mean_order) / 2
    
    def exponential_distribution_order(rate):
        """指数分布的秩序度"""
        # 率参数越大，分布越集中，秩序度越高
        rate_order = 1 - 1/(rate + 1)
        
        return rate_order
    
    def binomial_distribution_order(n, p):
        """二项分布的秩序度"""
        # p=0.5时最无序，偏离0.5更有序
        p_deviation = abs(p - 0.5)
        p_order = p_deviation * 2  # 归一化到[0,1]
        
        # n越大，分布越有序（趋近正态）
        n_order = 1 - 1/(n + 1)
        
        return (p_order + n_order) / 2
    
    def poisson_distribution_order(rate):
        """泊松分布的秩序度"""
        # 率参数越大，分布越对称，秩序度越高
        rate_order = 1 - 1/(rate + 1)
        
        return rate_order
    
    # 根据分布类型计算秩序度
    if dist_type == 'uniform':
        a = params.get('a', 0)
        b = params.get('b', 1)
        od_total = uniform_distribution_order(a, b)
        
        return {
            'distribution_type': 'uniform',
            'order_degree': od_total,
            'parameters': {'a': a, 'b': b},
            'formula': f"U({a}, {b})"
        }
    
    elif dist_type == 'normal':
        mean = params.get('mean', 0)
        std = params.get('std', 1)
        od_total = normal_distribution_order(mean, std)
        
        return {
            'distribution_type': 'normal',
            'order_degree': od_total,
            'parameters': {'mean': mean, 'std': std},
            'formula': f"N({mean}, {std}²)"
        }
    
    elif dist_type == 'exponential':
        rate = params.get('rate', 1)
        od_total = exponential_distribution_order(rate)
        
        return {
            'distribution_type': 'exponential',
            'order_degree': od_total,
            'parameters': {'rate': rate},
            'formula': f"Exp({rate})"
        }
    
    elif dist_type == 'binomial':
        n = params.get('n', 10)
        p = params.get('p', 0.5)
        od_total = binomial_distribution_order(n, p)
        
        return {
            'distribution_type': 'binomial',
            'order_degree': od_total,
            'parameters': {'n': n, 'p': p},
            'formula': f"B({n}, {p})"
        }
    
    elif dist_type == 'poisson':
        rate = params.get('rate', 1)
        od_total = poisson_distribution_order(rate)
        
        return {
            'distribution_type': 'poisson',
            'order_degree': od_total,
            'parameters': {'rate': rate},
            'formula': f"Pois({rate})"
        }
    
    else:
        return {'distribution_type': dist_type, 'order_degree': 0.5, 'error': 'Unknown distribution type'}

# 示例
print("概率分布的频率秩序度：")

distributions = [
    {'type': 'uniform', 'params': {'a': 0, 'b': 1}},
    {'type': 'normal', 'params': {'mean': 0, 'std': 1}},
    {'type': 'normal', 'params': {'mean': 0, 'std': 0.5}},
    {'type': 'exponential', 'params': {'rate': 2}},
    {'type': 'binomial', 'params': {'n': 20, 'p': 0.3}},
    {'type': 'poisson', 'params': {'rate': 5}}
]

for dist in distributions:
    result = probability_distribution_order_degree(dist['type'], **dist['params'])
    print(f"\n{result['distribution_type'].title()}分布 {result['formula']}:")
    print(f"  秩序度: {result['order_degree']:.3f}")
```

### 随机过程的秩序度

#### 理论基础
随机过程的秩序度取决于其马尔可夫性、平稳性和可预测性。

#### 计算示例
```python
def stochastic_process_order_degree(process_type, **params):
    """
    计算随机过程的秩序度
    
    参数:
        process_type: 过程类型
        **params: 过程参数
        
    返回:
        秩序度分析
    """
    
    def markov_chain_order(transition_matrix):
        """马尔可夫链的秩序度"""
        matrix = np.array(transition_matrix)
        n_states = matrix.shape[0]
        
        # 计算稳态分布
        eigenvals, eigenvecs = np.linalg.eig(matrix.T)
        steady_state_idx = np.argmin(np.abs(eigenvals - 1))
        steady_state = np.real(eigenvecs[:, steady_state_idx])
        steady_state = steady_state / np.sum(steady_state)
        
        # 基于稳态分布的熵计算秩序度
        entropy = -np.sum(steady_state * np.log2(steady_state + 1e-12))
        max_entropy = math.log2(n_states)
        order_degree = 1 - entropy / max_entropy
        
        return order_degree
    
    def random_walk_order(step_probabilities, boundary_conditions):
        """随机游走的秩序度"""
        # 步长概率的有序性
        prob_variance = np.var(step_probabilities)
        prob_order = 1 - prob_variance  # 方差越小越有序
        
        # 边界条件的有序性
        if boundary_conditions == 'absorbing':
            boundary_order = 0.9
        elif boundary_conditions == 'reflecting':
            boundary_order = 0.8
        else:  # 无边界
            boundary_order = 0.6
        
        # 位置分布的有序性（假设已知）
        position_order = 0.7
        
        return (prob_order + boundary_order + position_order) / 3
    
    def poisson_process_order(rate, time_homogeneous):
        """泊松过程的秩序度"""
        # 率参数的时间齐性
        if time_homogeneous:
            rate_order = 1.0
        else:
            rate_order = 0.7
        
        # 事件间隔的有序性（指数分布）
        interval_order = exponential_distribution_order(rate)
        
        # 独立增量性质
        independent_increment_order = 1.0
        
        return (rate_order + interval_order + independent_increment_order) / 3
    
    # 根据过程类型计算秩序度
    if process_type == 'markov_chain':
        transition_matrix = params.get('transition_matrix', [[0.7, 0.3], [0.4, 0.6]])
        od_total = markov_chain_order(transition_matrix)
        
        return {
            'process_type': 'markov_chain',
            'order_degree': od_total,
            'parameters': {'transition_matrix': transition_matrix},
            'states': len(transition_matrix)
        }
    
    elif process_type == 'random_walk':
        step_probs = params.get('step_probabilities', [0.5, 0.5])
        boundary = params.get('boundary_conditions', 'absorbing')
        od_total = random_walk_order(step_probs, boundary)
        
        return {
            'process_type': 'random_walk',
            'order_degree': od_total,
            'parameters': {
                'step_probabilities': step_probs,
                'boundary_conditions': boundary
            }
        }
    
    elif process_type == 'poisson_process':
        rate = params.get('rate', 1.0)
        homogeneous = params.get('time_homogeneous', True)
        od_total = poisson_process_order(rate, homogeneous)
        
        return {
            'process_type': 'poisson_process',
            'order_degree': od_total,
            'parameters': {'rate': rate, 'time_homogeneous': homogeneous}
        }
    
    else:
        return {'process_type': process_type, 'order_degree': 0.5, 'error': 'Unknown process type'}

# 示例
print("\n随机过程的频率秩序度：")

processes = [
    {'type': 'markov_chain', 'params': {'transition_matrix': [[0.9, 0.1], [0.2, 0.8]]}},
    {'type': 'markov_chain', 'params': {'transition_matrix': [[0.5, 0.5], [0.5, 0.5]]}},
    {'type': 'random_walk', 'params': {'step_probabilities': [0.6, 0.4], 'boundary_conditions': 'absorbing'}},
    {'type': 'poisson_process', 'params': {'rate': 2.0, 'time_homogeneous': True}}
]

for process in processes:
    result = stochastic_process_order_degree(process['type'], **process['params'])
    print(f"\n{result['process_type'].replace('_', ' '