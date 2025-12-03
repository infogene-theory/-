<template>
  <div class="yinyang-diagram">
    <div class="title">阴阳相图诊断</div>
    <div class="controls">
      <button @click="increaseYang">增加阳</button>
      <button @click="increaseYin">增加阴</button>
      <button @click="reset">重置平衡</button>
    </div>
    <div class="diagram">
      <!-- 简单阴阳图实现 -->
      <div class="circle yang" :style="{ backgroundColor: yangColor }"></div>
      <div class="circle yin" :style="{ backgroundColor: yinColor }"></div>
      <div class="dot yang-dot" :style="{ backgroundColor: yangDotColor }"></div>
      <div class="dot yin-dot" :style="{ backgroundColor: yinDotColor }"></div>
    </div>
    <div class="status">
      <p><strong>当前状态：</strong>{{ diagnosis }}</p>
      <p><strong>建议：</strong>{{ advice }}</p>
      <div class="balance-info">
        <div class="balance-bar">
          <div class="balance-fill" :style="{ width: balancePercentage + '%' }"></div>
        </div>
        <div class="balance-labels">
          <span>阴 {{ yin }}%</span>
          <span>平衡</span>
          <span>阳 {{ yang }}%</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const yang = ref(50)
const yin = ref(50)

const yangColor = computed(() => `rgba(255, 100, 100, ${yang.value/100})`)
const yinColor = computed(() => `rgba(100, 100, 255, ${yin.value/100})`)
const yangDotColor = computed(() => `rgba(100, 100, 255, ${yin.value/100})`)
const yinDotColor = computed(() => `rgba(255, 100, 100, ${yang.value/100})`)

const balancePercentage = computed(() => {
  const diff = Math.abs(yang.value - yin.value)
  return 100 - diff
})

const diagnosis = computed(() => {
  const diff = Math.abs(yang.value - yin.value)
  if (diff < 15) return '平衡态（健康）'
  if (yang.value > yin.value) return '阳亢状态'
  return '阴盛状态'
})

const advice = computed(() => {
  if (yang.value > 70) return '建议降温，减少活动，增加休息'
  if (yin.value > 70) return '建议升温，增加活动，引入变化'
  return '保持当前平衡，维持稳定状态'
})

function increaseYang() {
  if (yang.value < 100) {
    yang.value += 10
    yin.value -= 10
  }
}

function increaseYin() {
  if (yin.value < 100) {
    yin.value += 10
    yang.value -= 10
  }
}

function reset() {
  yang.value = 50
  yin.value = 50
}
</script>

<style scoped>
.yinyang-diagram {
  border: 2px solid #ccc;
  border-radius: 10px;
  padding: 20px;
  margin: 20px 0;
  text-align: center;
  background: #f9f9f9;
}

.title {
  font-size: 1.5rem;
  font-weight: bold;
  margin-bottom: 15px;
  color: #667eea;
}

.controls {
  margin: 15px 0;
  display: flex;
  justify-content: center;
  gap: 10px;
  flex-wrap: wrap;
}

.controls button {
  margin: 0 5px;
  padding: 8px 16px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.controls button:hover {
  background: #764ba2;
  transform: translateY(-2px);
}

.diagram {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 20px 0;
  position: relative;
  height: 200px;
}

.circle {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  position: absolute;
  transition: all 0.5s ease;
}

.circle.yang {
  left: 50%;
  transform: translateX(-50%);
  clip-path: polygon(50% 0%, 100% 0%, 100% 100%, 50% 100%);
}

.circle.yin {
  left: 50%;
  transform: translateX(-50%);
  clip-path: polygon(0% 0%, 50% 0%, 50% 100%, 0% 100%);
}

.dot {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  position: absolute;
  transition: all 0.5s ease;
}

.dot.yang-dot {
  left: 50%;
  top: 25%;
  transform: translate(-50%, -50%);
}

.dot.yin-dot {
  left: 50%;
  bottom: 25%;
  transform: translate(-50%, 50%);
}

.status {
  background: rgba(102, 126, 234, 0.1);
  padding: 15px;
  border-radius: 8px;
  margin-top: 20px;
  text-align: left;
}

.status p {
  margin: 8px 0;
  line-height: 1.6;
}

.balance-info {
  margin-top: 15px;
}

.balance-bar {
  width: 100%;
  height: 20px;
  background: #e0e0e0;
  border-radius: 10px;
  overflow: hidden;
  margin-bottom: 8px;
}

.balance-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  transition: width 0.5s ease;
}

.balance-labels {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
  color: #666;
}

@media (max-width: 768px) {
  .diagram {
    height: 150px;
  }
  
  .circle {
    width: 120px;
    height: 120px;
  }
  
  .dot {
    width: 30px;
    height: 30px;
  }
  
  .title {
    font-size: 1.2rem;
  }
}
</style>