module Admin::HomeHelper
  def period_is_select(period)
    period != "select_period"
  end

  def payment_method_pt(payment_method)
    case payment_method
    when 'billet'
      'Boleto Bancário'
    when 'card'
      'Cartão de Crédito'
    when 'pix'
      'Pix'
    end
  end
end
