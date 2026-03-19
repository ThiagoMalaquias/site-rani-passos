import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("🎃 Halloween Mode Ativado!")
    this.initializeHalloween()
  }

  disconnect() {
    console.log("🎃 Halloween Mode Desativado!")
    this.cleanup()
  }

  initializeHalloween() {
    // Adiciona classe ao body
    document.body.classList.add('halloween-active')
    document.documentElement.classList.add('halloween-active')

    // Inicia todas as funcionalidades
    this.addHalloweenDecorations()
    this.addFloatingElements()
    this.addHalloweenCursor()
    this.addFlyingBats()
    this.addParticleSystem()
    this.addSpiders()
    this.addFogEffect()
    this.addHalloweenSounds()
    this.addCoursesHoverEffect()
  }

  // ===== DECORAÇÕES FIXAS =====
  addHalloweenDecorations() {
    // Cantos da tela
    this.createDecoration('🎃', 'halloween-pumpkin', '20px', null, null, '20px')
    this.createDecoration('🎃', 'halloween-pumpkin', '20px', '20px', null, null)
    this.createDecoration('👻', 'halloween-ghost', null, '20px', '100px', null)
    this.createDecoration('👻', 'halloween-ghost', null, null, '100px', '20px')

    // Decorações adicionais
    if (window.innerWidth > 768) {
      this.createDecoration('🕷️', 'halloween-spider', '100px', null, null, '50%')
      this.createDecoration('🕸️', 'halloween-pumpkin', '150px', null, null, '100px')
      this.createDecoration('🕸️', 'halloween-pumpkin', '150px', '100px', null, null)
      this.createDecoration('💀', 'halloween-ghost', '50%', null, null, '50px')
      this.createDecoration('🍬', 'halloween-pumpkin', null, '100px', '200px', null)
    }
  }

  createDecoration(emoji, className, top, right, bottom, left) {
    const decoration = document.createElement('div')
    decoration.className = className
    decoration.textContent = emoji
    decoration.style.top = top || 'auto'
    decoration.style.right = right || 'auto'
    decoration.style.bottom = bottom || 'auto'
    decoration.style.left = left || 'auto'
    document.body.appendChild(decoration)

    // Adiciona interatividade
    decoration.addEventListener('click', () => {
      decoration.style.transform = 'scale(1.5) rotate(360deg)'
      setTimeout(() => {
        decoration.style.transform = ''
      }, 500)
    })
  }

  // ===== ELEMENTOS FLUTUANTES =====
  addFloatingElements() {
    this.floatingInterval = setInterval(() => {
      if (Math.random() > 0.6) {
        this.createFloatingElement()
      }
    }, 2000)
  }

  createFloatingElement() {
    const emojis = ['🎃', '👻', '🦇', '🕷️', '🍬', '💀', '🕸️', '🌙', '⭐']
    const emoji = emojis[Math.floor(Math.random() * emojis.length)]

    const element = document.createElement('div')
    element.textContent = emoji
    element.style.position = 'fixed'
    element.style.fontSize = (20 + Math.random() * 20) + 'px'
    element.style.left = Math.random() * window.innerWidth + 'px'
    element.style.top = '-50px'
    element.style.zIndex = '9998'
    element.style.pointerEvents = 'none'
    element.style.opacity = '0.6'
    element.style.transition = 'opacity 0.3s'

    document.body.appendChild(element)

    // Animação de queda com movimento lateral
    let top = -50
    let left = parseFloat(element.style.left)
    const speed = 1 + Math.random() * 2
    const sway = (Math.random() - 0.5) * 3

    const interval = setInterval(() => {
      top += speed
      left += sway
      element.style.top = top + 'px'
      element.style.left = left + 'px'
      element.style.transform = `rotate(${top}deg)`

      if (top > window.innerHeight + 50) {
        clearInterval(interval)
        element.remove()
      }
    }, 30)
  }

  // ===== MORCEGOS VOADORES =====
  addFlyingBats() {
    this.batInterval = setInterval(() => {
      if (Math.random() > 0.7) {
        this.createFlyingBat()
      }
    }, 5000)
  }

  createFlyingBat() {
    const bat = document.createElement('div')
    bat.textContent = '🦇'
    bat.className = 'halloween-bat'
    bat.style.top = (Math.random() * 50 + 10) + '%'
    bat.style.left = '-50px'

    document.body.appendChild(bat)

    setTimeout(() => {
      bat.remove()
    }, 15000)
  }

  // ===== ARANHAS CAINDO =====
  addSpiders() {
    this.spiderInterval = setInterval(() => {
      if (Math.random() > 0.8) {
        this.createSpider()
      }
    }, 4000)
  }

  createSpider() {
    const spider = document.createElement('div')
    spider.textContent = '🕷️'
    spider.className = 'halloween-spider'
    spider.style.left = (Math.random() * 90 + 5) + '%'
    spider.style.top = '-100px'

    document.body.appendChild(spider)

    setTimeout(() => {
      spider.remove()
    }, 8000)
  }

  // ===== SISTEMA DE PARTÍCULAS =====
  addParticleSystem() {
    const particlesContainer = document.createElement('div')
    particlesContainer.className = 'halloween-particles'
    document.body.appendChild(particlesContainer)

    for (let i = 0; i < 15; i++) {
      setTimeout(() => {
        this.createParticle(particlesContainer)
      }, i * 1000)
    }

    this.particleInterval = setInterval(() => {
      this.createParticle(particlesContainer)
    }, 2000)
  }

  createParticle(container) {
    const particles = ['✨', '🌟', '⭐', '💫', '🔮']
    const particle = document.createElement('div')
    particle.className = 'halloween-particle'
    particle.textContent = particles[Math.floor(Math.random() * particles.length)]
    particle.style.left = Math.random() * 100 + '%'
    particle.style.animationDelay = Math.random() * 5 + 's'
    particle.style.animationDuration = (15 + Math.random() * 10) + 's'

    container.appendChild(particle)

    setTimeout(() => {
      particle.remove()
    }, 25000)
  }

  // ===== EFEITO DE NÉVOA =====
  addFogEffect() {
    const fog = document.createElement('div')
    fog.className = 'halloween-fog'
    document.body.appendChild(fog)
  }

  // ===== CURSOR TRAIL =====
  addHalloweenCursor() {
    let throttle = 0
    document.addEventListener('mousemove', (e) => {
      throttle++
      if (throttle % 3 !== 0) return // Reduz frequência

      if (Math.random() > 0.85) {
        this.createCursorTrail(e.pageX, e.pageY)
      }
    })
  }

  createCursorTrail(x, y) {
    const trails = ['✨', '🔥', '💥', '⭐']
    const spark = document.createElement('div')
    spark.textContent = trails[Math.floor(Math.random() * trails.length)]
    spark.style.position = 'absolute'
    spark.style.left = x + 'px'
    spark.style.top = y + 'px'
    spark.style.fontSize = '16px'
    spark.style.pointerEvents = 'none'
    spark.style.zIndex = '9997'
    spark.style.animation = 'fadeInOut 1s ease-out'

    document.body.appendChild(spark)

    setTimeout(() => spark.remove(), 1000)
  }

  // ===== EFEITO HOVER NOS CURSOS =====
  addCoursesHoverEffect() {
    const courseBoxes = document.querySelectorAll('.coursebox')

    courseBoxes.forEach(box => {
      box.addEventListener('mouseenter', (e) => {
        this.createHoverExplosion(e.currentTarget)
      })
    })
  }

  createHoverExplosion(element) {
    const emojis = ['✨', '🎃', '⭐', '💫']
    const rect = element.getBoundingClientRect()

    for (let i = 0; i < 6; i++) {
      setTimeout(() => {
        const spark = document.createElement('div')
        spark.textContent = emojis[Math.floor(Math.random() * emojis.length)]
        spark.style.position = 'fixed'
        spark.style.left = (rect.left + rect.width / 2) + 'px'
        spark.style.top = (rect.top + rect.height / 2) + 'px'
        spark.style.fontSize = '20px'
        spark.style.pointerEvents = 'none'
        spark.style.zIndex = '9999'
        spark.style.transition = 'all 0.8s ease-out'

        document.body.appendChild(spark)

        const angle = (i / 6) * Math.PI * 2
        const distance = 50 + Math.random() * 30

        requestAnimationFrame(() => {
          spark.style.transform = `translate(${Math.cos(angle) * distance}px, ${Math.sin(angle) * distance}px) rotate(360deg)`
          spark.style.opacity = '0'
        })

        setTimeout(() => spark.remove(), 800)
      }, i * 50)
    }
  }

  // ===== SONS (OPCIONAL) =====
  addHalloweenSounds() {
    // Sons podem ser adicionados aqui se desejar
    // Exemplo: tocar sons ao clicar em elementos
    document.addEventListener('click', (e) => {
      if (e.target.closest('.coursebox') && Math.random() > 0.7) {
        // Aqui você pode adicionar Web Audio API ou sons
        console.log('🎵 Som de Halloween!')
      }
    })
  }

  // ===== LIMPEZA =====
  cleanup() {
    clearInterval(this.floatingInterval)
    clearInterval(this.batInterval)
    clearInterval(this.spiderInterval)
    clearInterval(this.particleInterval)

    document.body.classList.remove('halloween-active')
    document.documentElement.classList.remove('halloween-active')

    // Remove elementos criados dinamicamente
    document.querySelectorAll('.halloween-pumpkin, .halloween-ghost, .halloween-bat, .halloween-spider, .halloween-particles, .halloween-fog').forEach(el => el.remove())
  }
}