// app/javascript/controllers/payment_controller.js
import { Controller } from "@hotwired/stimulus"

// Conecta com data-controller="payment"
export default class extends Controller {
  connect() {
    this.setupFormSubmit()
  }

  async applyCashbackValue() {
    const maxCashback = document.getElementById("max_cashback").textContent
    const maxCashbackFloat = this.valorFloat(maxCashback)

    const cashbackInput = document.getElementById("cashback_to_use")
    const cashbackValue = cashbackInput.value
    const cashbackValueFloat = this.valorFloat(cashbackValue)

    const totalAmount = document.getElementById("total_amount_imutable").textContent
    const totalAmountFloat = this.valorFloat(totalAmount)
    const totalAmountWithCashback = totalAmountFloat - cashbackValueFloat

    if (isNaN(totalAmountWithCashback)) {
      this.swalError("O valor do cashback não é válido")
      return
    }

    if (cashbackValueFloat > maxCashbackFloat) {
      this.swalError(`O valor do cashback não pode ser maior que o saldo disponível: R$ ${this.valorPtBr(maxCashbackFloat)}`)
      return
    }

    const response = await fetch(`/cart/all_installments?total_with_cashback=${totalAmountWithCashback}`)
    const data = await response.json()
    this.installments = data.installments
    this.displayInstallments()

    document.getElementById("total_amount").innerHTML = `R$ ${this.valorPtBr(totalAmountWithCashback)}`
    document.getElementById("cashback_applied").value = cashbackValueFloat
    swal("Sucesso", "Cashback aplicado com sucesso", "success")
  }

  displayInstallments() {
    const installmentSelect = document.getElementById("installment")
    if (!installmentSelect) return

    installmentSelect.innerHTML = this.installments.map(({ key, value }) => {
      if (key < 7) {
        return `<option value="${key}" data-js-installment-value="${value}">${key} x de ${this.valorPtBr(value)}</option>`
      } else {
        return `<option value="${key}" data-js-installment-value="${value}">${key} x de ${this.valorPtBr(value)}*</option>`
      }
    }).join("")

    document.getElementById("installments").value = 1
  }

  setInstallment(event) {
    const select = event.target
    const option = select.selectedOptions[0]
    if (!option) return

    const installments = parseInt(option.value, 10) || 1

    const perInstallmentStr = option.dataset.jsInstallmentValue || "0"
    const perInstallment = parseFloat(perInstallmentStr) || 0

    const total = installments * perInstallment

    const totalAmountEl = document.getElementById("total_amount")
    if (!totalAmountEl) return

    totalAmountEl.textContent = `R$ ${this.valorPtBr(total)}`
    document.getElementById("installments").value = installments
  }

  setValueImutable() {
    const totalAmount = document.getElementById("total_amount_imutable").textContent
    const installments = document.getElementById("installments").value
    const totalAmountFloat = this.valorFloat(totalAmount)
    const cashbackApplied = document.getElementById("cashback_applied").value
    const cashbackValueFloat = parseFloat(cashbackApplied || 0)
    const totalAmountWithCashback = totalAmountFloat - cashbackValueFloat

    if (installments && +installments > 1) {
      document.getElementById("total_amount").innerHTML = `R$ ${this.valorPtBr(totalAmountWithCashback)}`
      document.getElementById("installments").value = 1
    }
  }

  setupFormSubmit() {
    const formPayments = document.querySelector("#payments")
    if (!formPayments) return

    formPayments.addEventListener("submit", (e) => {
      e.preventDefault()
      if (typeof $ !== "undefined") {
        $(".btn-payment-send").prop("disabled", true)
      }

      const pillsOption = document.querySelector(".nav-link.active")
      if (!pillsOption) {
        this.swalError("Selecione uma forma de pagamento")
        return
      }

      const method = pillsOption.dataset.paymentMethod
      $("#method").val(method)
      $("#installments").val($("#installment").val())

      // === Cartão de crédito ===
      if (method === "card") {
        const number = $("#cnumber").val().replace(/\s/g, "")
        const name = $("#cname").val()
        const expiry = $("#cexpiry").val()
        const cvc = $("#ccvc").val()
        const [exp_month, exp_year] = expiry.split("/")

        if (!number || !name || !expiry || !cvc || !exp_month || !exp_year) {
          this.swalError(
            "Tivemos um Problema ao validar seu cartão. Entre em contato com o suporte"
          )
          return
        }

        $("#credit_card").val(
          JSON.stringify({
            number: number,
            holder_name: name,
            exp_month: exp_month,
            exp_year: exp_year,
            cvv: cvc,
          })
        )
      }

      formPayments.submit()
    })
  }

  formatarValorRetornado(valor) {
    valor = valor.toFixed(2)
    return valor.toString().replace(".", ",")
  }

  valorFloat(valor) {
    return parseFloat(valor.replace("R$", "").replace(".", "").replace(",", "."))
  }

  valorPtBr(valor) {
    return valor.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  swalError(error) {
    if (typeof $ !== "undefined") {
      $(".btn-payment-send").prop("disabled", false)
      $("#btnApply").prop("disabled", false)
    }
    if (typeof swal !== "undefined") {
      swal("Atenção!", `${error}`, "error")
    } else {
      alert(error)
    }
  }
}