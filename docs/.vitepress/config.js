export default {
  title: '信息基因论 IGT',
  description: '基于"阴阳调和"的宇宙温控动力学',
  ignoreDeadLinks: true,
  themeConfig: {
    nav: [
      { text: '首页', link: '/' },
      { text: '理论体系', link: '/theory/' },
      { text: '应用工具', link: '/applications/' },
      { text: '案例研究', link: '/case-studies/' },
      { text: '社区贡献', link: '/community/' }
    ],
    
    sidebar: {
      '/theory/': [
        {
          text: '理论基础',
          collapsible: true,
          items: [
            { text: '理论基础', link: '/theory/' }
          ]
        }
      ],
      
      '/applications/': [
        {
          text: '应用工具',
          items: [
            { text: '应用工具', link: '/applications/' }
          ]
        }
      ],
      
      '/tools/': [
        {
          text: '工具与SDK',
          items: [
            { text: 'IGT-SDK', link: '/tools/' }
          ]
        }
      ],
      
      '/case-studies/': [
        {
          text: '案例研究',
          items: [
            { text: '案例研究库', link: '/case-studies/' }
          ]
        }
      ],
      
      '/community/': [
        {
          text: '社区贡献',
          items: [
            { text: '社区贡献', link: '/community/' }
          ]
        }
      ]
    },
    
    socialLinks: [
      { icon: 'github', link: 'https://github.com/infogene-theory/igt-website' }
    ],
    
    footer: {
      message: 'IGT v20.2 | 基于阴阳调和的宇宙温控动力学',
      copyright: 'Copyright © 2025 元衍智库'
    }
  }
}