// 奖励计算功能
function calculateReward() {
    const storage = parseFloat(document.getElementById('storage').value);
    const bandwidth = parseFloat(document.getElementById('bandwidth').value);
    const compute = parseFloat(document.getElementById('compute').value);
    
    // 简单的奖励计算公式
    const storageReward = storage * 0.1; // 每GB 0.1个信息币
    const bandwidthReward = bandwidth * 0.05; // 每Mbps 0.05个信息币
    const computeReward = compute * 1; // 每核心1个信息币
    
    const totalReward = storageReward + bandwidthReward + computeReward;
    document.getElementById('rewardResult').textContent = totalReward.toFixed(2);
}

// 资源利用率图表
function drawUtilizationChart() {
    const svg = document.getElementById('utilizationChart');
    if (!svg) return; // 如果找不到SVG元素，则退出
    const width = 600;
    const height = 200;
    const margin = {top: 20, right: 20, bottom: 30, left: 40};
    const chartWidth = width - margin.left - margin.right;
    const chartHeight = height - margin.top - margin.bottom;

    // 模拟数据
    const data = [
        {resource: '存储', utilization: 75},
        {resource: '带宽', utilization: 60},
        {resource: '计算', utilization: 85}
    ];

    // 清空SVG
    svg.innerHTML = '';

    // 绘制柱状图
    const barWidth = chartWidth / data.length - 20;

    data.forEach((d, i) => {
        const barHeight = (d.utilization / 100) * chartHeight;
        const x = margin.left + i * (chartWidth / data.length);
        const y = height - margin.bottom - barHeight;

        // 创建柱子
        const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
        rect.setAttribute('x', x);
        rect.setAttribute('y', y);
        rect.setAttribute('width', barWidth);
        rect.setAttribute('height', barHeight);
        rect.setAttribute('fill', '#4a90e2');
        svg.appendChild(rect);

        // 添加数值标签
        const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        text.setAttribute('x', x + barWidth / 2);
        text.setAttribute('y', y - 5);
        text.setAttribute('text-anchor', 'middle');
        text.textContent = d.utilization + '%';
        svg.appendChild(text);

        // 添加资源名称
        const label = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        label.setAttribute('x', x + barWidth / 2);
        label.setAttribute('y', height - margin.bottom + 20);
        label.setAttribute('text-anchor', 'middle');
        label.textContent = d.resource;
        svg.appendChild(label);
    });
}

// 更新在线时长
function updateUptime() {
    const uptimeElement = document.getElementById('uptime');
    if (!uptimeElement) return; // 如果找不到元素，则退出
    const days = Math.floor(Math.random() * 30);
    const hours = Math.floor(Math.random() * 24);
    uptimeElement.textContent = `${days}天${hours}小时`;
}

// 页面加载时初始化
window.addEventListener('load', () => {
    // 确保 calculateReward 函数在按钮存在时才绑定
    const calculateButton = document.querySelector('.resource-input button');
    if (calculateButton) {
        calculateButton.onclick = calculateReward; 
    }
    drawUtilizationChart();
    updateUptime();
});