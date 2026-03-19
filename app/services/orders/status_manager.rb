module Orders
  class StatusManager
    STATUSES = {
      canceled: "Cancelado",
      not_started: "Não Iniciado",
      refunded: "Reembolsado",
      defaulter: "Inadimplente"
    }.freeze

    VALID_PAYMENT_STATUSES = %w[paid pending refunded].freeze

    def initialize(order)
      @order = order
    end

    def update!
      @order.update!(status: determine_status)
    end

    private

    def determine_status
      return STATUSES[:canceled] if canceled?
      return STATUSES[:not_started] if not_started?
      return STATUSES[:refunded] if refunded?
      return payment_status_pt if active_payment?

      STATUSES[:defaulter]
    end

    def canceled?
      @order.canceled_at.present?
    end

    def not_started?
      return true if installments.blank?

      first_installment = installments.first
      first_installment.nil? || VALID_PAYMENT_STATUSES.exclude?(first_installment.payment.status)
    end

    def refunded?
      first_installment&.payment&.status == "refunded"
    end

    def active_payment?
      last_installment && ["paid", "pending"].include?(last_installment.payment.status)
    end

    def payment_status_pt
      last_installment.payment.status_pt
    end

    def installments
      @installments ||= @order.order_installments
                              .where.not(payment_id: nil)
                              .order(marker: :asc)
                              .includes(:payment)
    end

    def first_installment
      installments.first
    end

    def last_installment
      installments.last
    end
  end
end
