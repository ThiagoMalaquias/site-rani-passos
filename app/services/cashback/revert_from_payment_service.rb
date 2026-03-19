# frozen_string_literal: true

module Cashback
  class RevertFromPaymentService
    def initialize(payment)
      @payment = payment
    end

    def call
      revert_earned
      revert_used
    end

    private

    def revert_earned
      earned = @payment.cashback_movements.find_by(kind: "earned")
      return unless earned

      return if @payment.cashback_movements.exists?(kind: "reverted_earned")

      @payment.user.cashback_movements.create!(
        payment_id: @payment.id,
        amount_cents: -earned.amount_cents,
        kind: "reverted_earned"
      )
    end

    def revert_used
      return if @payment.cashback_applied_cents.to_i <= 0
      return if @payment.cashback_movements.exists?(kind: "reverted_used")

      @payment.user.cashback_movements.create!(
        payment_id: @payment.id,
        amount_cents: @payment.cashback_applied_cents,
        kind: "reverted_used"
      )
    end
  end
end