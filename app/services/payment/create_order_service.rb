class Payment::CreateOrderService
  Result = Struct.new(:success?, :payment, :error, keyword_init: true)

  def initialize(company:, cookies_course:, user_id:, payment_params:, cashback_applied:, utm_cookies:, site:)
    @company = company
    @cookies_course = cookies_course
    @user_id = user_id
    @payment_params = payment_params
    @cashback_applied = cashback_applied.to_f
    @utm_cookies = utm_cookies
    @site = site
  end

  def call
    return failure("Usuário não encontrado.") unless user.present?
    return failure("Carrinho inválido.") if total_amount.blank? || total_amount <= 0

    if @cashback_applied.negative?
      return failure("Valor de cashback inválido.")
    end

    if @cashback_applied > total_amount
      return failure("O valor de cashback não pode ser maior que o total do pedido.")
    end

    if @cashback_applied > (@user.cashback_balance_cents / 100.0)
      return failure("O valor de cashback não pode ser maior que o saldo de cashback disponível.")
    end

    total_with_cashback = total_amount - @cashback_applied
    price = cart.total_amount_with_installment(total_with_cashback, @payment_params[:installments])
    amount_cents = (price * 100).to_i

    payment = Payment.call!(
      @company,
      @cookies_course,
      user,
      amount_cents,
      @payment_params
    )

    payment.update(
      utm_source: @utm_cookies[:utm_source],
      utm_medium: @utm_cookies[:utm_medium],
      utm_campaign: @utm_cookies[:utm_campaign],
      cashback_applied_cents: cashback_applied_cents
    )

    if cashback_applied_cents.positive?
      apply_cashback(payment)
      return failure(@cashback_error) if @cashback_error
    end

    Result.new(success?: true, payment: payment)
  rescue StandardError => e
    Rails.logger.error("[Payments::CreateOrderService] #{e.message}\n#{e.backtrace.first(10).join("\n")}")
    Result.new(success?: false, error: "Não foi possível processar seu pagamento. Tente novamente ou entre em contato.")
  end

  private

  def user
    @user ||= User.find_by(id: @user_id)
  end

  def cart
    @cart ||= Cart.new(@cookies_course)
  end

  def total_amount
    @total_amount ||= cart.total_amount
  end

  def cashback_applied_cents
    @cashback_applied_cents ||= (@cashback_applied * 100).round
  end

  def apply_cashback(payment)
    Cashback::ApplyToPaymentService.new(payment).call
  rescue Cashback::ApplyToPaymentService::InsufficientCashbackError => e
    Rails.logger.warn("[Payments::CreateOrderService] Cashback: #{e.message}")
    @cashback_error = "Saldo de cashback insuficiente. Ajuste o valor e tente novamente."
  end

  def failure(message)
    Result.new(success?: false, error: message)
  end
end