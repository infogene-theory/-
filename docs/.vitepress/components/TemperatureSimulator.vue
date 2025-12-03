<template>
  <div class="temperature-simulator">
    <div class="title">温控模拟器 - RVSE热力学循环</div>
    <div class="controls">
      <button @click="startSimulation" :disabled="isRunning">开始模拟</button>
      <button @click="pauseSimulation" :disabled="!isRunning">暂停模拟</button>
      <button @click="resetSimulation">重置</button>
    </div>
    
    <div class="simulation-container">
      <div class="cycle-diagram">
        <h3>RVSE热力学循环</h3>
        <div class="cycle-stages">
          <div class="stage" :class="{ active: currentStage === 'Ω' }">
            <div class="stage-name">Ω (点火)</div>
            <div class="stage-temp">T = T₀</div>
          </div>
          <div class="stage-arrow">→</div>
          <div class="stage" :class="{ active: currentStage === 'R' }">
            <div class="stage-name">R (等温扩张)</div>
            <div class="stage-temp">T ≈ T₀</div>
          </div>
          <div class="stage-arrow">→</div>
          <div class="stage" :class="{ active: currentStage === 'V' }">
            <div class="stage-name">V (临界探索)</div>
            <div class="stage-temp">T → T_critical</div>
          </div>
          <div class="stage-arrow">→</div>
          <div class="stage" :class="{ active: currentStage === 'S' }">
            <div class="stage-name">S (选择性冷却)</div>
            <div class="stage-temp">T ↓</div>
          </div>
          <div class="stage-arrow">→</div>
          <div class="stage" :class="{ active: currentStage === 'E' }">
            <div class="stage-name">E (温度跃迁)</div>
            <div class="stage-temp">T_new = λ·T_old</div>
          </div>
          <div class="stage-arrow">→</div>
          <div class="stage" :class="{ active: currentStage === 'Ω₀' }">
            <div class="stage-name">Ω₀ (平衡态)</div>
            <div class="stage-temp">T = T_equilibrium</div>
          </div>
        </div>
      </div>
      
      <div class="temperature-graph">
        <h3>温度变化曲线</h3>
        <div class="graph-container">
          <div class="graph">
            <div class="temperature-line" :style="{ height: temperatureHeight + '%' }"></div>
          </div>
          <div class="temp-labels">
            <span>T_max</span>
            <span>T_opt</span>
            <span>T_min</span>
          </div>
          <div class="current-temp">当前温度: {{ currentTemperature.toFixed(1) }}°C</div>
        </div>
      </div>
      
      <div class="parameters">
        <h3>系统参数</h3>
        <div class="param-item">
          <label for="temperature">温度</label>
          <input 
            type="range" 
            id="temperature" 
            v-model.number="currentTemperature" 
            min="0" 
            max="100" 
            step="0.5" 
            :disabled="isRunning"
          >
          <span>{{ currentTemperature.toFixed(1) }}°C</span>
        </div>
        <div class="param-item">
          <label for="coherence">相干度</label>
          <div class="coherence-bar">
            <div class="coherence-fill" :style="{ width: coherencePercentage + '%' }"></div>
          </div>
          <span>{{ coherencePercentage }}%</span>
        </div>
        <div class="param-item">
          <label for="dtr">动态温度范围</label>
          <span>{{ dtr }}°C</span>
        </div>
        <div class="param-item">
          <label>系统状态</label>
          <span class="system-status">{{ systemStatus }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const currentTemperature = ref(37)
const isRunning = ref(false)
const currentStage = ref('Ω')
const stages = ['Ω', 'R', 'V', 'S', 'E', 'Ω₀']
const stageIndex = ref(0)
let simulationInterval = null

const temperatureHeight = computed(() => {
  return (currentTemperature.value / 100) * 100
})

const coherencePercentage = computed(() => {
  // 相干度与温度的关系：中间温度相干度最高
  const optimalTemp = 50
  const distance = Math.abs(currentTemperature.value - optimalTemp)
  return Math.max(0, 100 - (distance / optimalTemp) * 100)
})

const dtr = computed(() => {
  // 动态温度范围计算
  return 80 // 简化示例，实际应基于系统参数
})

const systemStatus = computed(() => {
  if (currentTemperature.value < 20) return '冷僵化'
  if (currentTemperature.value > 80) return '热混乱'
  if (coherencePercentage.value > 70) return '健康涌现'
  return '稳定状态'
})

const startSimulation = () => {
  if (!isRunning.value) {
    isRunning.value = true
    simulationInterval = setInterval(() => {
      // 模拟温度变化
      if (currentStage.value === 'Ω' || currentStage.value === 'R') {
        currentTemperature.value += 1
      } else if (currentStage.value === 'V') {
        currentTemperature.value += 0.5
      } else if (currentStage.value === 'S') {
        currentTemperature.value -= 1.5
      } else if (currentStage.value === 'E') {
        currentTemperature.value = Math.random() * 30 + 40
      } else if (currentStage.value === 'Ω₀') {
        currentTemperature.value = 37
      }
      
      // 切换阶段
      if (currentTemperature.value > 95 || currentTemperature.value < 20) {
        nextStage()
      }
    }, 500)
  }
}

const pauseSimulation = () => {
  if (isRunning.value) {
    isRunning.value = false
    clearInterval(simulationInterval)
  }
}

const resetSimulation = () => {
  pauseSimulation()
  currentTemperature.value = 37
  stageIndex.value = 0
  currentStage.value = stages[stageIndex.value]
}

const nextStage = () => {
  stageIndex.value = (stageIndex.value + 1) % stages.length
  currentStage.value = stages[stageIndex.value]
}

onUnmounted(() => {
  clearInterval(simulationInterval)
})
</script>

<style scoped>
.temperature-simulator {
  border: 2px solid #ccc;
  border-radius: 10px;
  padding: 20px;
  margin: 20px 0;
  background: #f9f9f9;
}

.title {
  font-size: 1.5rem;
  font-weight: bold;
  margin-bottom: 15px;
  color: #667eea;
  text-align: center;
}

.controls {
  display: flex;
  justify-content: center;
  gap: 10px;
  margin: 15px 0;
  flex-wrap: wrap;
}

.controls button {
  padding: 8px 16px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.controls button:hover:not(:disabled) {
  background: #764ba2;
  transform: translateY(-2px);
}

.controls button:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.simulation-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-template-rows: auto auto;
  gap: 20px;
  margin-top: 20px;
}

.cycle-diagram {
  grid-column: 1 / -1;
  background: white;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.cycle-diagram h3 {
  margin-top: 0;
  color: #2c3e50;
  text-align: center;
}

.cycle-stages {
  display: flex;
  justify-content: space-around;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 15px;
}

.stage {
  background: #f0f0f0;
  padding: 10px 15px;
  border-radius: 6px;
  text-align: center;
  min-width: 100px;
  transition: all 0.3s ease;
}

.stage.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  transform: translateY(-5px);
  box-shadow: 0 4px 15px rgba(0,0,0,0.2);
}

.stage-name {
  font-weight: bold;
  margin-bottom: 5px;
}

.stage-temp {
  font-size: 0.9rem;
  opacity: 0.8;
}

.stage-arrow {
  font-size: 1.5rem;
  font-weight: bold;
  color: #667eea;
}

.temperature-graph, .parameters {
  background: white;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.temperature-graph h3, .parameters h3 {
  margin-top: 0;
  color: #2c3e50;
  text-align: center;
}

.graph-container {
  margin-top: 15px;
}

.graph {
  background: #f0f0f0;
  border-radius: 6px;
  height: 200px;
  position: relative;
  margin-bottom: 10px;
}

.temperature-line {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(to top, #667eea 0%, #764ba2 100%);
  transition: height 0.5s ease;
}

.temp-labels {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
  color: #666;
}

.current-temp {
  text-align: center;
  margin-top: 10px;
  font-weight: bold;
  color: #667eea;
}

.parameters h3 {
  margin-bottom: 15px;
}

.param-item {
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.param-item label {
  width: 120px;
  font-weight: 500;
  color: #2c3e50;
}

.param-item input[type="range"] {
  flex: 1;
  min-width: 150px;
}

.coherence-bar {
  flex: 1;
  height: 15px;
  background: #f0f0f0;
  border-radius: 8px;
  overflow: hidden;
  min-width: 150px;
}

.coherence-fill {
  height: 100%;
  background: linear-gradient(90deg, #e74c3c 0%, #f39c12 50%, #2ecc71 100%);
  transition: width 0.3s ease;
}

.system-status {
  padding: 5px 10px;
  border-radius: 15px;
  font-weight: bold;
  background: #2ecc71;
  color: white;
}

@media (max-width: 768px) {
  .simulation-container {
    grid-template-columns: 1fr;
  }
  
  .cycle-stages {
    flex-direction: column;
    gap: 15px;
  }
  
  .stage-arrow {
    transform: rotate(90deg);
  }
  
  .param-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .param-item label {
    width: auto;
  }
  
  .param-item input[type="range"],
  .coherence-bar {
    width: 100%;
  }
}
</style>