import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="order"
export default class extends Controller {
  connect() {
    $('#order_cpf').mask('000.000.000-00');
    $('#order_posta_code').mask('00000-000');
    $('#order_phone').mask('(00) 00000-0000');

    $('#user_cpf').mask('000.000.000-00');
    $('#user_phone').mask('(00) 00000-0000');

    $('#order_card_number').mask('0000 0000 0000 0000');
    $('#order_card_expiry').mask('00/00');


    $('.js-example-basic-single').select2();

    this.disabledInstalments()
    this.calculoValorCursos()
  }

  async viacep(event) {
    const cep = event.target.value
    const userId = document.querySelector("#order_user_id").value;
    if (!userId) return

    if (cep.length === 9) {

      const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`, {
        method: 'GET',
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        }
      })

      const data = await response.json();
      if (!data.erro) {
        document.querySelector("#order_street").value = data.logradouro
        document.querySelector("#order_neighborhood").value = data.bairro
        document.querySelector("#order_city").value = data.localidade
        document.querySelector("#order_uf").value = data.uf
      }

    } else {
      document.querySelector("#order_street").value = ""
      document.querySelector("#order_number").value = ""
      document.querySelector("#order_neighborhood").value = ""
      document.querySelector("#order_city").value = ""
      document.querySelector("#order_uf").value = ""
    }
  }

  orderDiscount() {
    this.calculoTotal()
  }

  addCurso() {
    var lastDiv = $('.all-cursos div.col-md-4:last');
    var clonedDiv = lastDiv.clone();
    $('.all-cursos').append(clonedDiv);
  }

  disabledInstalments() {
    const method = document.querySelector("#order_payment_method").value

    if (method == 'card') {
      $(".dados-cartao").show()
    } else {
      $(".dados-cartao").hide()
    }

    this.verifyFirstInstallment()
  }

  verifyFirstInstallment() {
    const method = document.querySelector("#order_payment_method").value
    const installments = document.querySelector("#order_payment_installments").value
    const first_installment_amount = document.querySelector("#order_first_installment_amount")

    const shouldDisableFirstInstallment = method === "card" || installments === "1" || installments === "" || installments === "recorrente";

    if (shouldDisableFirstInstallment) {
      first_installment_amount.value = ""
      first_installment_amount.disabled = true
    } else {
      first_installment_amount.disabled = false
    }
  }

  calculoValorCursos() {
    let totalValue = 0;
    const fetchPromises = [];

    $(".select-course").each(function (index, element) {
      if (element.value) {
        fetchPromises.push(
          fetch(`/courses/${element.value}.json`, {
            method: 'GET',
            headers: { 'Content-type': 'application/json; charset=UTF-8' }
          })
            .then(async (res) => {
              const course = JSON.parse(await res.text());
              totalValue += Number(course.value_cash.replace('.', '').replace(',', '.'))
            })
        );
      }
    });

    Promise.all(fetchPromises).then(() => {
      $(`.subtotal`).html(`R$ ${this.valor_string(totalValue)}`);
      $(`.total`).html(`R$ ${this.valor_string(totalValue)}`);
      this.calculoTotal()
    });
  }

  calculoTotal() {
    const discount = Number($("#order_discount").val().replace('.', '').replace(',', '.'))
    const subtotal = Number($(`.subtotal`).html().replace('R$', '').replace('.', '').replace(',', '.'))

    const total = subtotal - discount
    $(`.total`).html(`R$ ${this.valor_string(total)}`);
    $(`#order_amount`).val(this.valor_string(total));
    this.parcelas(total)
  }

  async parcelas(total) {
    let res = await fetch(`/admin/orders/installments.json?amount=${total}`, {
      method: 'GET',
      headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    })

    const installments = JSON.parse(await res.text());

    const formatedInstallments = installments.map(({ key, value }) => {
      if (key < 7) {
        return `<option value="${key}">${key} x de R$ ${this.valor_string(value)}</option>`
      } else if (key == 'recorrente') {
        return `<option value="${key}">${key}</option>`
      } else {
        return `<option value="${key}">${key} x de R$ ${this.valor_string(value)}*</option>`
      }
    })

    $('#order_payment_installments').html(formatedInstallments)
  }

  valor_string(valor) {
    return valor.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
