import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="order"
export default class extends Controller {
  connect() {
    $('#user_cpf').mask('000.000.000-00');
    $('#user_phone').mask('(00) 00000-0000');
    $('#user_posta_code').mask('00000-000');

    this.toggleSenha();
  }

  async viacep(event) {
    const cep = event.target.value
    if (cep.length === 9) {

      const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`, {
        method: 'GET',
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        }
      })

      const data = await response.json();
      if (!data.erro) {
        document.querySelector("#user_street").value = data.logradouro
        document.querySelector("#user_neighborhood").value = data.bairro
        document.querySelector("#user_city").value = data.localidade
        document.querySelector("#user_uf").value = data.uf
      }

    } else {
      document.querySelector("#user_street").value = ""
      document.querySelector("#user_number").value = ""
      document.querySelector("#user_neighborhood").value = ""
      document.querySelector("#user_city").value = ""
      document.querySelector("#user_uf").value = ""
    }
  }

  toggleSenha() {
    const buttonPassword = document.querySelector('.btn-password');
    const senhaInput = buttonPassword.closest('.input-group').querySelector('input');
    const icon = buttonPassword.querySelector('i');

    if (senhaInput.type === 'password') {
      senhaInput.type = 'text';
      icon.classList.remove('fa-eye');
      icon.classList.add('fa-eye-slash');
    } else {
      senhaInput.type = 'password';
      icon.classList.remove('fa-eye-slash');
      icon.classList.add('fa-eye');
    }
  }
}
