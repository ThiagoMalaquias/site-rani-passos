class Invoice < ApplicationRecord
  belongs_to :subscription

  enum status: { paid: 0, canceled: 1, payment_failed: 2, failed: 3 }

  scope :paids, -> { where(status: 'paid') }
  scope :canceleds, -> { where(status: 'canceled') }
  scope :payment_faileds, -> { where(status: 'payment_failed') }

  def status_pt
    case status
    when 'paid'
      'Pago'
    when 'canceled'
      'Cancelado'
    when 'payment_failed'
      'Falha no pagamento'
    when 'failed'
      'Falha no pagamento'
    end
  end
end
