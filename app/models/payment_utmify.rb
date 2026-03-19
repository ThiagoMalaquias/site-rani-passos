class PaymentUtmify < ApplicationRecord
  belongs_to :payment

  def status_pt
    case status
    when 'pending'
      return 'Pendente'
    when 'canceled'
      return "Cancelado"
    when 'paid'
      return "Pago"
    when 'refunded'
      return "Reembolsado"
    when 'closed'
      return "Fechado"
    when 'expired'
      return "Vencido"
    end
  end
end
