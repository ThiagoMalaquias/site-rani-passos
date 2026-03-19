import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "selectedDiscounts", "hiddenField"]

  connect() {
    console.log("DiscountSearchController connected")
    this.searchTimeout = null
    this.selectedIndex = -1
    this.results = []
    this.selectedDiscounts = new Set()

    // Event listener para cliques nos resultados
    this.resultsTarget.addEventListener('click', (e) => {
      const item = e.target.closest('.search-result-item')
      if (item) {
        const discountId = item.dataset.discountId
        const discountTitle = item.dataset.discountTitle
        const discountValue = item.dataset.discountValue

        this.selectDiscount({
          id: discountId,
          title: discountTitle,
          value: discountValue
        })
      }
    })
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.hideResults()
      return
    }

    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.performSearch(query)
    }, 300)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`/admin/discounts.json?title=${encodeURIComponent(query)}&active=true`, {
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        }
      })

      if (response.ok) {
        this.results = await response.json()
        this.displayResults()
      }
    } catch (error) {
      console.error('Erro na busca:', error)
    }
  }

  displayResults() {
    if (this.results.length === 0) {
      this.hideResults()
      return
    }

    const resultsHtml = this.results.map((discount, index) => `
      <div class="search-result-item p-2 border-bottom" 
           data-discount-id="${discount.id}" 
           data-discount-title="${discount.title}"
           data-discount-value="${discount.value}"
           data-index="${index}"
           style="cursor: pointer;">
        <div class="fw-bold">${discount.title}</div>
        <div class="text-muted small">${discount.value}%</div>
      </div>
    `).join('')

    this.resultsTarget.innerHTML = resultsHtml
    this.resultsTarget.style.display = 'block'
    this.selectedIndex = -1
  }

  hideResults() {
    this.resultsTarget.style.display = 'none'
  }

  handleKeyup(event) {
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.selectNext()
        break
      case 'ArrowUp':
        event.preventDefault()
        this.selectPrevious()
        break
      case 'Enter':
        event.preventDefault()
        this.selectCurrent()
        break
      case 'Escape':
        this.hideResults()
        break
    }
  }

  selectNext() {
    if (this.selectedIndex < this.results.length - 1) {
      this.selectedIndex++
      this.highlightSelected()
    }
  }

  selectPrevious() {
    if (this.selectedIndex > 0) {
      this.selectedIndex--
      this.highlightSelected()
    }
  }

  highlightSelected() {
    const items = this.resultsTarget.querySelectorAll('.search-result-item')
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add('bg-primary', 'text-white')
      } else {
        item.classList.remove('bg-primary', 'text-white')
      }
    })
  }

  selectCurrent() {
    if (this.selectedIndex >= 0 && this.results[this.selectedIndex]) {
      this.selectDiscount(this.results[this.selectedIndex])
    }
  }

  selectDiscount(discount) {
    if (this.selectedDiscounts.has(discount.id)) {
      return // Já está selecionado
    }

    this.selectedDiscounts.add(discount.id)
    this.addDiscountToSelected(discount)
    this.hideResults()
    this.inputTarget.value = ''
  }

  addDiscountToSelected(discount) {
    const discountHtml = `
      <div class="col-md-3">
        <div class="selected-discount-item d-flex align-items-center justify-content-between p-2 mb-2 bg-light rounded" 
            data-discount-id="${discount.id}">
          <div>
            <span class="fw-bold">${discount.title}</span>
            <span class="text-muted ms-2">${discount.value}%</span>
          </div>
          <button type="button" 
                  class="btn btn-sm btn-outline-danger" 
                  data-action="click->discount-search#removeDiscount"
                  data-discount-id="${discount.id}">
            <i class="fas fa-times"></i>
          </button>
          <input type="hidden" 
                name="course[course_discounts_attributes][][discount_id]" 
                value="${discount.id}">
        </div>
      </div>
    `
    this.selectedDiscountsTarget.insertAdjacentHTML('beforeend', discountHtml)
  }

  removeDiscount(event) {
    const discountId = event.currentTarget.dataset.discountId
    const discountItem = event.currentTarget.closest('.col-md-3')

    if (discountItem) {
      discountItem.remove()
      this.selectedDiscounts.delete(discountId)
    }
  }

  // Método para carregar descontos já selecionados (para edição)
  loadSelectedDiscounts(discounts) {
    discounts.forEach(discount => {
      this.selectedDiscounts.add(discount.id)
      this.addDiscountToSelected(discount)
    })
  }
} 