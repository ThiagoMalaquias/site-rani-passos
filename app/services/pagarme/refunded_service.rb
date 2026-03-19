class Pagarme::RefundedService
  require 'uri'
  require 'net/http'
  require 'openssl'

  attr_accessor :payment

  def initialize(payment)
    @payment = payment
  end

  def call!
    payment_return = change_order
    payment_return_errors(payment_return)

    payment.status = "refunded"
    payment.save!

    payment
  rescue Exception => e
    Rails.logger.info "=========[#{e.inspect}]=========="
    Rails.logger.info "=========#{e.backtrace}============"
    raise e.message
  end

  private

  def change_order
    url = URI("https://api.pagar.me/core/v5/charges/#{payment.charge_id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Delete.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["Authorization"] = "Basic #{ENV.fetch('PAGARME_TOKEN_PROD') { 'c2tfdGVzdF9NUUJZcUFCVUR5SWRZNXhkOg==' }}"
    response = http.request(request)

    JSON.parse(response.read_body)
  end

  def payment_return_errors(payment_return)
    error = payment_return["error"]
    raise error if error.present?

    message = payment_return["message"]
    raise message if message.present?

    status = payment_return["status"]
    return unless status == "failed"

    raise payment_return["charges"][0]["last_transaction"]["gateway_response"]["errors"][0]["message"]
  end
end
