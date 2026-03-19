import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template", "item", "destroyField"]
  static values = { index: Number }

  connect() {
    // índice único para substituir "NEW_RECORD"
    if (this.indexValue == null) this.indexValue = Date.now()
  }

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.trim()
    const newId = `${this.indexValue++}`
    const html = content.replace(/NEW_RECORD/g, newId)

    // Insere no final da lista
    this.listTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.preventDefault()
    // encontra o wrapper mais próximo que representa um item
    const item = event.target.closest("[data-nested-form-target='item']")
    if (!item) return

    // Se tem campo hidden _destroy => marca como "1" e esconde
    const destroyField = item.querySelector("[data-nested-form-target='destroyField']")
    if (destroyField) {
      destroyField.value = "1"
      item.style.display = "none"
    } else {
      // para novos (sem id) apenas remove do DOM
      item.remove()
    }
  }
}
