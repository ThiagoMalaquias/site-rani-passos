class InvoicesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    data = params['data']

    invoice_id = data['id']
    subscription_id = data['subscription']['id']
    amount = data['amount']
    status = data['status']
    created_at = data['created_at']

    invoice = Invoice.find_by(invoice_id: invoice_id)
    subscription = Subscription.find_by(invoice_id: subscription_id)

    if invoice.present?
      invoice.update(status: status, log_return_transaction: data.to_json) if status != "created"
    else
      Invoice.create(invoice_id: invoice_id, subscription: subscription, amount: amount, status: status, log_return_transaction: data.to_json, created_at: created_at)
    end

    subscription.user_courses.update_all(authenticate: status == "paid") if status != "created"
    subscription.update(status: status == "paid" ? :paid : :canceled) if status != "created"

    render json: { message: "Invoice created successfully" }, status: :ok
  rescue => e
    puts e.message
    render json: { message: "Invoice not created" }, status: :unprocessable_entity
  end
end