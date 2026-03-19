class UtmifyService
  attr_reader :payment

  def initialize(payment)
    @payment = payment
  end

  def call!
    return if ['closed', 'expired'].include?(payment.status)
    return if ['bonus'].include?(payment.method)
    return if payment.location_genereted != "Venda"

    url = URI("https://api.utmify.com.br/api-credentials/orders/")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["x-api-token"] = Rails.application.credentials.utmify_token_prod
    request.body = params_body.to_json
    response = http.request(request)

    JSON.parse(response.read_body)
  end

  private

  def params_body
    order = {
      orderId: payment.id,
      platform: "RaniPassos",
      paymentMethod: payment_method,
      status: status,
      createdAt: payment.created_at.strftime("%Y-%m-%d %H:%M:%S"),
      approvedDate: nil,
      refundedAt: nil,
      isTest: false
    }

    order[:approvedDate] = payment.updated_at.strftime("%Y-%m-%d %H:%M:%S") if status == 'paid'
    order[:refundedAt] = payment.updated_at.strftime("%Y-%m-%d %H:%M:%S") if status == 'refunded'

    order[:customer] = {
      name: payment.user.name,
      email: payment.user.email,
      phone: payment.user.without_mask("total_number"),
      document: payment.user.without_mask("cpf"),
      country: "BR",
      ip: payment.user.last_ip
    }

    order[:products] = payment.user_courses.non_nil_amount.map do |user_course|
      {
        id: user_course.course.id,
        name: user_course.course.title,
        planId: nil,
        planName: nil,
        quantity: 1,
        priceInCents: format_cents(user_course.amount)
      }
    end

    order[:trackingParameters] = {
      utm_source: nil,
      utm_medium: nil,
      utm_campaign: nil,
      utm_content: nil,
      utm_term: nil
    }

    order[:commission] = {
      totalPriceInCents: payment.amount.to_i,
      gatewayFeeInCents: gateway_fee_in_cents.to_i,
      userCommissionInCents: user_commission_in_cents.to_i
    }

    order
  end

  def gateway_fee_in_cents
    payment.amount - format_cents(payment.user_courses.non_nil_amount.sum(:amount))
  end

  def user_commission_in_cents
    format_cents(payment.user_courses.non_nil_amount.sum(:amount))
  end

  def format_cents(amount)
    (amount * 100).to_i
  end

  def payment_method
    case payment.method
    when 'card'
      return 'credit_card'
    when 'billet'
      return 'boleto'
    when 'pix'
      return 'pix'
    end
  end

  def status
    case payment.status
    when 'pending'
      return 'waiting_payment'
    when 'canceled'
      return 'refused'
    when 'paid'
      return 'paid'
    when 'refunded'
      return 'refunded'
    end
  end
end
