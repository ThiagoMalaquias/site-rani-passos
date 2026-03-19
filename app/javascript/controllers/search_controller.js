import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "loading"]

  connect() {
    this.timeout = null
  }

  perform() {
    clearTimeout(this.timeout)

    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = "block"
    }

    this.timeout = setTimeout(() => {
      this.search()
    }, 500)
  }

  search() {
    const query = this.inputTarget.value
    const url = `/admin/help_centers.json?search=${encodeURIComponent(query)}`

    fetch(url)
      .then(response => response.json())
      .then(data => {
        this.renderResults(data)

        if (this.hasLoadingTarget) {
          this.loadingTarget.style.display = "none"
        }

        // Atualiza a URL
        const newUrl = query ? `/admin/help_centers?search=${encodeURIComponent(query)}` : '/admin/help_centers'
        window.history.pushState({}, "", newUrl)
      })
      .catch(error => {
        console.error("Erro na busca:", error)

        if (this.hasLoadingTarget) {
          this.loadingTarget.style.display = "none"
        }
      })
  }

  renderResults(data) {
    if (data.length === 0) {
      this.resultsTarget.innerHTML = this.emptyState()
      return
    }

    const cardsHtml = data.map(helpCenter => this.cardTemplate(helpCenter)).join('')
    this.resultsTarget.innerHTML = cardsHtml
  }

  cardTemplate(helpCenter) {
    return `
      <div class="col-lg-6 col-xl-4 mb-4">
        <div class="card h-100 hover-shadow">
          <div class="card-body d-flex flex-column">
            <div class="d-flex align-items-start mb-3">
              <div class="icon icon-md bg-gradient-primary shadow text-center border-radius-md me-3">
                <i class="fas fa-question-circle text-white opacity-10"></i>
              </div>
              <h5 class="mb-0 flex-grow-1">
                ${helpCenter.title}
              </h5>
            </div>
            
            <p class="text-sm text-muted mb-4 flex-grow-1">
              ${this.formatPreview(helpCenter.content)}
            </p>
            
            <div class="mt-auto d-flex gap-2">
              <a href="/admin/help_centers/${helpCenter.id}" class="btn btn-sm btn-primary flex-fill">
                <i class="fas fa-eye me-1"></i> Ver
              </a>
            </div>
          </div>
        </div>
      </div>
    `
  }

  emptyState() {
    return `
      <div class="col-12">
        <div class="card mb-4">
          <div class="card-body text-center py-5">
            <i class="fas fa-search fa-3x text-secondary mb-3"></i>
            <h5 class="text-muted">Nenhum conteúdo encontrado</h5>
            <p class="text-sm text-muted">
              Tente ajustar sua busca ou 
              <a href="/admin/help_centers/new" class="text-primary">criar um novo conteúdo</a>
            </p>
          </div>
        </div>
      </div>
    `
  }

  // Equivalente ao strip_tags do Ruby
  stripTags(html) {
    const div = document.createElement('div')
    div.innerHTML = html
    return div.textContent || div.innerText || ''
  }

  // Equivalente ao truncate do Ruby
  truncate(text, length = 120, separator = ' ') {
    if (text.length <= length) return text

    // Remove espaços extras (equivalente ao .squish)
    const cleanText = text.replace(/\s+/g, ' ').trim()

    if (cleanText.length <= length) return cleanText

    // Corta no tamanho especificado
    let truncated = cleanText.substring(0, length)

    // Se tem separator, corta na última ocorrência dele
    if (separator) {
      const lastIndex = truncated.lastIndexOf(separator)
      if (lastIndex > 0) {
        truncated = truncated.substring(0, lastIndex)
      }
    }

    return truncated + '...'
  }

  // Função helper que combina strip_tags + truncate
  formatPreview(content, length = 120) {
    const cleaned = this.stripTags(content)
    return this.truncate(cleaned, length, ' ')
  }
}