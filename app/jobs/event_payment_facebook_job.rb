class EventPaymentFacebookJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    payment = Payment.find(payment_id)
    EventPaymentFacebookService.new(payment).call
  end
end