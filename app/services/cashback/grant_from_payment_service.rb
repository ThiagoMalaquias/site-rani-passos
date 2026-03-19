class Cashback::GrantFromPaymentService
  LIMIT_CENTS = 25_000 # R$ 250,00

  def initialize(payment)
    @payment = payment
  end

  def call
    return if skip_grant?

    amount_cents = @payment.amount.to_i
    return if amount_cents <= 0

    user = @payment.user

    # Quanto ainda cabe dentro do limite vitalício de 250?
    remaining_allowed = LIMIT_CENTS - user.cashback_allowed_cents.to_i
    return if remaining_allowed <= 0 # já bateu o teto, tudo novo é queimado

    # Só credita o que ainda cabe no limite; o resto é queimado
    credit_cents = [amount_cents, remaining_allowed].min
    return if credit_cents <= 0

    user.cashback_movements.create!(
      payment_id: @payment.id,
      amount_cents: credit_cents,
      kind: "earned"
    )

    # Atualiza o total já liberado vitalício
    user.update!(cashback_allowed_cents: user.cashback_allowed_cents.to_i + credit_cents)
  end

  private

  def skip_grant?
    @payment.method == "bonus" ||
      @payment.cashback_movements.where(kind: "earned").exists?
  end
end