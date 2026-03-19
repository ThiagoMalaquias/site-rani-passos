class Cashback::ApplyToPaymentService
  class InsufficientCashbackError < StandardError; end

  def initialize(payment)
    @payment = payment
  end

  def call
    amount = @payment.cashback_applied_cents.to_i
    return if amount <= 0
  
    balance = @payment.user.cashback_balance_cents
    raise InsufficientCashbackError, "Saldo de cashback insuficiente" if amount > balance
  
    return if @payment.cashback_movements.where(kind: "used").exists?
  
    @payment.user.cashback_movements.create!(
      payment_id: @payment.id,
      amount_cents: -amount,
      kind: "used"
    )
  
    new_allowed = [@payment.user.cashback_allowed_cents.to_i - amount, 0].max
    @payment.user.update!(cashback_allowed_cents: new_allowed)
  end
end