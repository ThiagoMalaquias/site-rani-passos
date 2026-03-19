import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "fileInput", "submitButton", "importForm"]

  connect() {
    this.originalButtonText = this.submitButtonTarget.value
  }

  importFile() {
    // Clica diretamente no input de arquivo para abrir o seletor
    this.fileInputTarget.click()
  }

  cancelImport() {
    this.importFormTarget.style.display = 'none'
    this.fileInputTarget.value = ''
  }

  validateFile(event) {
    const file = event.target.files[0]
    if (file) {
      const fileName = file.name.toLowerCase()
      if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
        alert('Por favor, selecione apenas arquivos XLSX ou XLS')
        this.fileInputTarget.value = ''
        return false
      }

      // Se o arquivo for válido, mostra o formulário e submete automaticamente
      this.showFormAndSubmit()
    }
  }

  showFormAndSubmit() {
    // Mostra o formulário
    this.importFormTarget.style.display = 'block'

    // Submete o formulário automaticamente após um pequeno delay
    setTimeout(() => {
      this.formTarget.submit()
    }, 500)
  }

  submitForm(event) {
    if (!this.fileInputTarget.files[0]) {
      event.preventDefault()
      alert('Por favor, selecione um arquivo antes de importar')
      return
    }

    // Mostra loading no botão
    this.submitButtonTarget.value = 'Importando...'
    this.submitButtonTarget.disabled = true

    // Reabilita o botão após 5 segundos (caso haja erro)
    setTimeout(() => {
      this.submitButtonTarget.value = this.originalButtonText
      this.submitButtonTarget.disabled = false
    }, 5000)
  }
}
