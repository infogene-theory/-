// Supabase配置文件
// 注意：实际部署时应使用环境变量存储这些敏感信息

export const supabaseConfig = {
  url: 'https://your-project.supabase.co',
  anonKey: 'your-anon-key'
}

// 导入Supabase客户端
import { createClient } from '@supabase/supabase-js'

// 创建Supabase客户端实例
export const supabase = createClient(supabaseConfig.url, supabaseConfig.anonKey)

// 认证相关功能
export const auth = {
  // 登录
  async signIn(email, password) {
    return await supabase.auth.signInWithPassword({ email, password })
  },
  
  // 注册
  async signUp(email, password) {
    return await supabase.auth.signUp({ email, password })
  },
  
  // 登出
  async signOut() {
    return await supabase.auth.signOut()
  },
  
  // 获取当前用户
  async getCurrentUser() {
    const { data } = await supabase.auth.getSession()
    return data.session?.user || null
  }
}

// 数据存储相关功能
export const db = {
  // 获取案例库数据
  async getCaseStudies(category) {
    let query = supabase.from('case_studies').select('*')
    if (category) {
      query = query.eq('category', category)
    }
    return await query.order('created_at', { ascending: false })
  },
  
  // 获取应用工具数据
  async getApplications() {
    return await supabase.from('applications').select('*').order('priority', { ascending: true })
  },
  
  // 提交反馈
  async submitFeedback(data) {
    return await supabase.from('feedback').insert([data])
  }
}
