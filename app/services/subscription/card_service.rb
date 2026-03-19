class Subscription::CardService
  require 'uri'
  require 'net/http'
  require 'openssl'
  require 'i18n'

  attr_accessor :company, :courses, :user, :amount, :credit_card

  def initialize(company, courses, user, amount, subscription_params)
    @company = company
    @courses = courses
    @user = user
    @amount = amount
    @credit_card = JSON.parse(subscription_params[:credit_card])
  end

  def call!
    subscription_return = create_subscriptions(subscription_options)
    subscription = Subscription.create(company: company, user: user, amount: amount, status: :pending, log_return_transaction: subscription_return.to_json, method: "card", invoice_id: subscription_return["id"])
    subscription.create_user_course(courses)
    subscription_return_errors(subscription_return)

    subscription.status = :paid
    subscription.save!

    subscription
  rescue Exception => e
    subscription.save_error(e.message) if subscription.present?
    Rails.logger.info "=========[#{e.inspect}]=========="
    raise e.message
  end

  private

  def subscription_options
    address = user.addresses.last
    holder_name = I18n.transliterate(credit_card["holder_name"].strip)

    options = {
      payment_method: "credit_card",
      currency: "BRL",
      interval: "month",
      interval_count: 1,
      minimum_price: amount,
      billing_type: "prepaid",
      installments: 1,
      statement_descriptor: "Cursos"
    }
    options[:customer] = { name: user.name, email: user.email, document: user.without_mask("cpf"), document_type: "CPF", type: "individual" }
    options[:customer][:address] = { country: "BR", state: address.uf, city: address.city, zip_code: address.posta_code, line_1: "#{address.number}, #{address.street}, #{address.neighborhood}" }
    options[:customer][:phones] = { mobile_phone: { country_code: "55", area_code: user.without_mask("area_code").to_s,  number: user.without_mask("number").to_s } }
    options[:items] = [items]
    options[:card] = {
      number: credit_card["number"].strip,
      holder_name: holder_name,
      exp_month: credit_card["exp_month"].strip,
      exp_year: credit_card["exp_year"].strip,
      cvv: credit_card["cvv"].strip,
      billing_address: {
        line_1: address.street,
        zip_code: address.posta_code.delete("-"),
        city: address.city,
        state: address.uf,
        country: "BR"
      }
    }

    options
  end

  def items
    course_ids = courses.pluck("id")
    code = course_ids.join.to_i
    title = Course.where(id: course_ids).pick(:title)

    {
      name: title.to_s,
      description: "Plataforma Profº Rani Passos",
      quantity: 1,
      id: "pi_#{code}",
      pricing_scheme: {
        scheme_type: "Unit",
        price: amount
      }
    }
  end

  def create_subscriptions(options)
    url = URI("https://api.pagar.me/core/v5/subscriptions/")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["Authorization"] = "Basic #{ENV.fetch('PAGARME_TOKEN_PROD') { 'c2tfdGVzdF9NUUJZcUFCVUR5SWRZNXhkOg==' }}"
    request.body = options.to_json
    response = http.request(request)

    JSON.parse(response.read_body)
  end

  def subscription_return_errors(subscription_return)
    errors = subscription_return["errors"]
    raise "Mensagem: #{errors.to_json}" if errors.present?

    message = subscription_return["message"]
    raise "Mensagem: #{message}" if message.present?

    status = subscription_return["status"]
    return unless status == "failed"

    transaction_status = subscription_return["charges"][0]["last_transaction"]["status"]
    acquirer_message = subscription_return["charges"][0]["last_transaction"]["acquirer_message"]
    raise "Status: #{transaction_status} - Mensagem: #{acquirer_message}"
  end
end
