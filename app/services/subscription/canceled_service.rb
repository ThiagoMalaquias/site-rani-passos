class Subscription::CanceledService
  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'i18n'

  attr_accessor :subscription

  def initialize(subscription)
    @subscription = subscription
  end

  def call!
    subscription_return = create_subscriptions
    subscription_return_errors(subscription_return)

    subscription.status = "canceled"
    subscription.save!

    subscription
   rescue Exception => e
     Rails.logger.info "=========[#{e.inspect}]=========="
     Rails.logger.info "=========#{e.backtrace}============"
     raise e.message
  end

  private

  def create_subscriptions
    url = URI("https://api.pagar.me/core/v5/subscriptions/#{subscription.invoice_id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Delete.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["Authorization"] = "Basic #{ENV.fetch('PAGARME_TOKEN_PROD') { 'c2tfdGVzdF9NUUJZcUFCVUR5SWRZNXhkOg==' }}"
    request.body = { cancel_pending_invoices: true }.to_json
    response = http.request(request)

    JSON.parse(response.read_body)
  end

  def subscription_return_errors(subscription_return)
    errors = subscription_return["errors"]
    raise "Mensagem: #{errors.to_json}" if errors.present?

    status = subscription_return["status"]
    return unless status == "failed"

    transaction_status = subscription_return["charges"][0]["last_transaction"]["status"]
    acquirer_message = subscription_return["charges"][0]["last_transaction"]["acquirer_message"]
    raise "Status: #{transaction_status} - Mensagem: #{acquirer_message}"
  end
end
