class OrdersController < ApplicationController
  before_action :set_order, only: [:update]

  def complete_payment
    @order = Order.find_by(code: params[:code])
    @installment_amount = (@order.amount / @order.payment_installments.to_i).round(2)
  end

  def update
    @order.update({ card_number: params[:number], card_name: params[:name], card_expiry: params[:expiry], card_cvv: params[:cvc] })

    order_installment = @order.order_installments.last
    order_installment.payment = order_installment.create_installment_payment
    order_installment.error = ""
    order_installment.save

    redirect_to "/payments/thanks/#{order_installment.payment.code}"
  rescue StandardError => e
    order_installment.error = e.message
    order_installment.save

    WhatsappMessage.send_text(@order.user, "purchase_cancelled_status") if WhatsappSendRule.first.purchase_cancelled_status
    flash[:error] = "Tivemos um problema com seus dados. Por favor, clique no botão do WhatsApp para que possamos te ajudar."
    redirect_to "/orders/complete-payment/#{@order.code}"
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
