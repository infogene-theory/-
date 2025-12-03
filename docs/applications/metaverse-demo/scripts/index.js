// 简单动画效果
document.addEventListener('DOMContentLoaded', function() {
    // 获取所有节点和连接
    const nodes = document.querySelectorAll('.node');
    const p2pConnections = document.querySelectorAll('.p2p-connection');
    
    // 为节点添加动画
    nodes.forEach(function(node, index) {
        // 设置延迟动画
        setTimeout(function() {
            node.style.animation = 'pulse 2s infinite';
        }, index * 300);
    });
    
    // 为P2P连接添加动画
    p2pConnections.forEach(function(connection, index) {
        // 设置延迟动画
        setTimeout(function() {
            connection.style.animation = 'dash 5s infinite linear';
        }, index * 200 + 1000);
    });
});