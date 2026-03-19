import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delayMs: { type: Number, default: 0 },
    showOnceKey: { type: String, default: "exit_intent_shown" },
    threshold: { type: Number, default: 8 },
    videoId: String,
    autoplayMuted: { type: Boolean, default: true },
    showOnceKeyModalDiscount: { type: Number, default: 0 },
  }

  connect() {
    this.$ = window.jQuery || window.$
    if (!this.$) { console.warn("jQuery ausente (necessário p/ Bootstrap 4)."); return }

    this.$(this.element).modal({ show: false, backdrop: true, keyboard: true, focus: true })

    this.$(this.element).on("shown.bs.modal", () => this._loadVideo())
    this.$(this.element).on("hidden.bs.modal", () => this._unloadVideo())

    if (!(sessionStorage.getItem(this.showOnceKeyValue) == "1")) {
      if (this.showOnceKeyModalDiscountValue == 1) {
        sessionStorage.setItem(this.showOnceKeyValue, "1")
      } else {
        this.log("já exibido na sessão; abortando")
        return
      }
    }

    this._onMouseMove = this.handleMouseMove.bind(this)
    this._onMouseLeave = this.handleMouseLeave.bind(this)

    window.addEventListener("mousemove", this._onMouseMove, { passive: true })
    window.addEventListener("mouseleave", this._onMouseLeave, { passive: true })

    this.readyAt = Date.now() + 2000
  }

  disconnect() {
    window.removeEventListener("mousemove", this._onMouseMove)
    window.removeEventListener("mouseleave", this._onMouseLeave)
    this.$ && this.$(this.element).off("shown.bs.modal hidden.bs.modal")
  }

  handleMouseMove(e) {
    if (Date.now() < this.readyAt) return
    if (e.clientY <= this.thresholdValue) this.showOnce()
  }

  handleMouseLeave() {
    if (Date.now() < this.readyAt) return
    this.showOnce()
  }

  showOnce() {
    if (this._shown) return
    this._shown = true
    sessionStorage.removeItem(this.showOnceKeyValue)

    const open = () => this.$(this.element).modal("show")
    this.delayMsValue > 0 ? setTimeout(open, this.delayMsValue) : open()
  }

  close(e) {
    if (e) e.preventDefault()
    this.$ && this.$(this.element).modal("hide")
  }

  // --- Controle do player ---
  _loadVideo() {
    const iframe = this.element.querySelector("#exitIntentVideo")
    if (!iframe) return

    const vid = this.videoIdValue || "wZwRFLIdCf0"

    // Parâmetros do player
    const params = new URLSearchParams({
      autoplay: "1",          // inicia automaticamente
      mute: "1",              // autoplay confiável (desmutamos no gesto)
      playsinline: "1",       // iOS inline
      rel: "0",
      modestbranding: "1",
      iv_load_policy: "3",
      color: "white",
      enablejsapi: "1",       // necessário p/ postMessage (play/unMute/…)
      origin: window.location.origin // recomendado com youtube-nocookie
    })

    const src = `https://www.youtube-nocookie.com/embed/${vid}?${params.toString()}`
    if (iframe.src !== src) iframe.src = src

    // Gesto do usuário dentro do modal => desmuta e garante o play
    this._bindUnmuteOnce = (ev) => {
      try {
        const msg = (fn, args = []) =>
          iframe.contentWindow?.postMessage(
            JSON.stringify({ event: "command", func: fn, args }),
            "*"
          )
        // Ordem segura: play -> unMute -> volume (alguns browsers/situações preferem assim)
        msg("playVideo")
        msg("unMute")
        msg("setVolume", [100])
      } catch (e) {
        console.warn("Falha ao enviar comandos para o player:", e)
      }
    }

    // Usa { once: true } + capture para garantir que conta como “primeiro gesto”
    this.element.addEventListener("pointerdown", this._bindUnmuteOnce, { once: true, capture: true })
  }


  _unloadVideo() {
    const iframe = this.element.querySelector("#exitIntentVideo")
    if (!iframe) return
    // Resetar o src para parar o vídeo imediatamente
    iframe.src = ""
  }

  log(message) {
    console.log(message)
  }
}



