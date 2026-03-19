class Pagarme::BilletService
  require 'uri'
  require 'net/http'
  require 'openssl'

  attr_accessor :company, :courses, :user, :amount

  def initialize(company, courses, user, amount, payment_params)
    @company = company
    @courses = courses
    @user = user
    @amount = amount
    @discount = payment_params[:discount]
    @date_overdue = payment_params[:date_overdue]
  end

  def call!
    payment_return = create_order(payment_options)
    payment = Payment.create(company: company, user: user, amount: amount, status: :pending, log_return_transaction: payment_return.to_json, method: "billet", date_overdue: @date_overdue)
    payment.create_user_course(courses)
    payment_return_errors(payment_return)

    payment.invoice_id = payment_return["id"]
    payment.charge_id = payment_return["charges"][0]["id"]
    payment.billet_pdf = payment_return["charges"][0]["last_transaction"]["pdf"]
    payment.billet_line = payment_return["charges"][0]["last_transaction"]["line"]
    payment.billet_barcode = payment_return["charges"][0]["last_transaction"]["barcode"]
    payment.billet_qr_code = payment_return["charges"][0]["last_transaction"]["qr_code"]
    payment.billet_expiry_date = payment_return["charges"][0]["last_transaction"]["due_at"].to_datetime - 3.hours
    payment.save!

    WhatsappMessage.send_text(user, "billet_generated_site") if WhatsappSendRule.first.billet_generated_site

    payment
  rescue Exception => e
    payment.save_error(e.message) if payment.present?
    Rails.logger.info "=========[#{e.inspect}]=========="
    Rails.logger.info "=========#{e.backtrace}============"
    raise e.message
  end

  private

  def payment_options
    address = user.addresses.last

    options = {}
    options[:items] = [items]
    options[:customer] = { name: user.name, email: user.email, document: user.without_mask("cpf"), document_type: "CPF", type: "individual" }
    options[:customer][:address] = { country: "BR", state: address.uf, city: address.city, zip_code: address.posta_code, line_1: "#{address.number}, #{address.street}, #{address.neighborhood}" }
    options[:customer][:phones] = { mobile_phone: { country_code: "55", area_code: user.without_mask("area_code").to_s,  number: user.without_mask("number").to_s } }
    options[:payments] = [{ payment_method: "boleto", boleto: { bank: "033", instructions: "Pagar em Até 3 dias" }, amount: amount }]

    options
  end

  def items
    course_ids = courses.pluck("id")
    code = course_ids.join.to_i

    { amount: amount, description: "Cursos do Profº #{Teacher.first.name}", quantity: 1, code: code }
  end

  def create_order(options)
    url = URI("https://api.pagar.me/core/v5/orders/")

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

  def payment_return_errors(payment_return)
    errors = payment_return["errors"]
    raise "Mensagem: #{errors.to_json}" if errors.present?

    message = payment_return["message"]
    raise "Mensagem: #{message}" if message.present?

    status = payment_return["status"]
    return unless status == "failed"

    transaction_status = payment_return["charges"][0]["last_transaction"]["status"]
    gateway_response = payment_return["charges"][0]["last_transaction"]["gateway_response"]["errors"].to_json
    raise "Status: #{transaction_status} - Mensagem: #{gateway_response}"
  end
end
