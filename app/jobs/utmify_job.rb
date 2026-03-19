class UtmifyJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    payment = Payment.find(payment_id)
    response = UtmifyService.new(payment).call!

    payment.utmifies.create(log_return: response.to_json, status: payment.status) if response.present?
  end
end