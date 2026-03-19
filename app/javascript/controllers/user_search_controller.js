import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hiddenField"]

  connect() {
    console.log("UserSearchController connected")
    this.searchTimeout = null
    this.selectedIndex = -1
    this.results = []

    // Event listener para cliques nos resultados
    this.resultsTarget.addEventListener('click', (e) => {
      const item = e.target.closest('.search-result-item')
      if (item) {
        const userId = item.dataset.userId
        const userName = item.dataset.userName
        const userEmail = item.dataset.userEmail

        this.selectUser({
          id: userId,
          name: userName,
          email: userEmail
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
      const response = await fetch(`/admin/users.json?name=${encodeURIComponent(query)}`, {
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

    const resultsHtml = this.results.map((user, index) => `
      <div class="search-result-item p-2 border-bottom" 
           data-user-id="${user.id}" 
           data-user-name="${user.name}"
           data-user-email="${user.email}"
           data-index="${index}"
           style="cursor: pointer;">
        <div class="fw-bold">${user.name}</div>
        <div class="text-muted small">${user.email}</div>
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
      this.selectUser(this.results[this.selectedIndex])
    }
  }

  selectUser(user) {
    this.inputTarget.value = user.name
    this.hiddenFieldTarget.value = user.id
    this.hideResults()

    // Disparar evento para buscar dados do usuário
    this.getUserData(user.id)
  }

  async getUserData(userId) {
    try {
      const response = await fetch(`/admin/users/${userId}.json`, {
        method: 'GET',
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
      });

      if (!response.ok) {
        throw new Error('Falha ao buscar dados do usuário');
      }

      const user = await response.json();
      this.updateUserForm(user);
    } catch (error) {
      console.error('Erro ao obter usuário:', error);
    }
  }

  updateUserForm(user) {
    const { email, phone, cpf, address } = user;
    document.querySelector("#order_email").value = email || '';
    document.querySelector("#order_phone").value = phone || '';
    document.querySelector("#order_cpf").value = cpf || '';

    if (address) {
      const { posta_code, street, number, neighborhood, city, uf } = address;
      document.querySelector("#order_posta_code").value = posta_code || '';
      document.querySelector("#order_street").value = street || '';
      document.querySelector("#order_number").value = number || '';
      document.querySelector("#order_neighborhood").value = neighborhood || '';
      document.querySelector("#order_city").value = city || '';
      document.querySelector("#order_uf").value = uf || '';
    }
  }
}