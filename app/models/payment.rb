class Payment < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :course, optional: true

  has_many :user_courses, dependent: :destroy
  has_many :utmifies, class_name: "PaymentUtmify", dependent: :destroy
  has_many :email_logs, dependent: :destroy
  has_many :cashback_movements, dependent: :nullify
  has_one :order_installment, dependent: :destroy

  before_create :set_code
  after_create :send_to_utmify
  after_save :verify_status, :send_to_utmify, if: -> { saved_change_to_status? || saved_change_to_closed? }
  after_save :revert_cashback_on_cancel_or_refund, if: -> { saved_change_to_status? }

  enum status: { pending: 0, paid: 1, canceled: 2, closed: 3, refunded: 4, expired: 5 }

  scope :paids, -> { where(status: 'paid') }
  scope :pendings, -> { where(status: 'pending') }
  scope :canceleds, -> { where(status: 'canceled') }
  scope :closeds, -> { where(status: 'closed') }
  scope :refundeds, -> { where(status: 'refunded') }
  scope :method_card, -> { where(method: "card") }
  scope :method_pix, -> { where(method: "pix") }
  scope :method_billet, -> { where(method: "billet") }
  scope :method_bonus, -> { where(method: "bonus") }
  scope :not_order_installment, -> { where.missing(:order_installment) }
  scope :period_date, ->(start_date, end_date) { where("TO_CHAR(payments.created_at - interval '3 hour','YYYY-MM-DD') >= ? and TO_CHAR(payments.created_at - interval '3 hour','YYYY-MM-DD') <= ?", start_date, end_date) }
  
  scope :by_course, ->(course_id) {
    joins(:user_courses)
      .where(user_courses: { course_id: course_id })
      .where.not(user_courses: { amount: nil })
      .distinct
  }

  def set_code
    self.code = SecureRandom.uuid
  end

  def self.call!(company, courses, user, amount, payment_params)
    method = payment_params[:method]
    service = payment_service_for(method).new(company, courses, user, amount, payment_params)

    service.call!
  rescue StandardError => e
    Rails.logger.info "=========[#{e.inspect}]=========="
    raise "Dados não autorizados, confira e tente novamente"
  end

  def self.payment_service_for(method)
    case method
    when 'card'
      Pagarme::CardService
    when 'billet'
      Pagarme::BilletService
    else
      Pagarme::PixService
    end
  end

  def self.status_webhook(data)
    return false if data["id"].blank?

    payment = Payment.find_by(invoice_id: data["id"])
    return true unless payment && !payment.paid?

    status_map = {
      "paid" => "paid",
      "canceled" => "refunded",
      "closed" => "closed"
    }

    payment.update(status: status_map[data["status"]])
  end

  def save_error(message)
    self.status = :canceled if status != "paid"

    self.error = message
    save!
  end

  def location_genereted
    return "Pedido" if OrderInstallment.find_by(payment: self).present?

    "Venda"
  end

  def attendent_order
    return "" if location_genereted != "Pedido"

    OrderInstallment.find_by(payment: self).order.manager.name
  end

  def number_installment_in_order
    return "" if location_genereted != "Pedido"

    OrderInstallment.find_by(payment: self).marker
  end

  def total_order_installments
    return "" if location_genereted != "Pedido"

    OrderInstallment.find_by(payment: self).order.order_installments.count
  end

  def order
    return "" if location_genereted != "Pedido"

    OrderInstallment.find_by(payment: self).order
  end

  def value_tax
    return 0 if installments.blank?

    amount_course = user_courses.non_nil_amount.sum(:amount)

    total = (amount / 100) - amount_course
    return total if order.blank?

    total + order.discount
  end

  def method_pt
    case method
    when 'card'
      return 'Cartão de Crédito'
    when 'billet'
      return "Boleto Bancário"
    when 'pix'
      return "Pix"
    when 'bonus'
      return "Bônus"
    end
  end

  def status_pt
    case status
    when 'pending'
      return 'Pendente'
    when 'canceled'
      return "Cancelado"
    when 'paid'
      return "Pago"
    when 'refunded'
      return "Reembolsado"
    when 'closed'
      return "Fechado"
    when 'expired'
      return "Vencido"
    end
  end

  def create_user_course(courses)
    courses.each do |cookies_in_course|
      next if cookies_in_course["id"].blank?

      course = Course.find(cookies_in_course["id"])
      amount = course.total_price(cookies_in_course)

      access_until = period_access_course(course)
      user_course_params = { payment: self, user: user, status: "active", access_start: created_at, access_until: access_until, authenticate: false, lifetime: course.lifetime }

      UserCourse.create(user_course_params.merge!(course: course, amount: amount, discount: cookies_in_course["discount"]))
      course.collections.each do |collection|
        UserCourse.create(user_course_params.merge!(course: collection.promotion, amount: nil, discount: nil))
      end
    end
  end

  def purchase_email_sent?
    email_logs.purchase_emails.successful.exists?
  end

  def purchase_email_failed?
    email_logs.purchase_emails.failed.exists?
  end

  def last_purchase_email_log
    email_logs.purchase_emails.recent.first
  end

  def self.permit_courses_cashback(courses)
    courses.any? { |course| [48, 504, 433].include?(course.id) }
  end

  private

  def verify_status
    if status == "paid" && closed == false
      ucourses = UserCourse.where(payment: self)
      ucourses.each { |uc| uc.update(authenticate: true) }
      course_ids = ucourses.map(&:course_id)

      UserOpenCart.where(user_id: user, course_id: course_ids).find_each(&:destroy)
      EventPaymentFacebookJob.perform_later(self.id)
      WhatsappMessage.send_text(user, "purchase_completed") if WhatsappSendRule.first.purchase_completed_payment
      EmailsJob.set(wait: 1.minutes).perform_later(self.id)

      tag_pago = Tag.find_by(name: "Aluno-Pago")
      UserTag.find_or_create_by(user: user, tag: tag_pago) if tag_pago.present?

      tag_expirado = Tag.find_by(name: "AcessoExpirado")
      UserTag.find_by(user: user, tag: tag_expirado)&.destroy if tag_expirado.present?
      Cashback::GrantFromPaymentService.new(self).call
      return
    end

    user_courses.each { |uc| uc.update(authenticate: false) } if user_courses.present?
  end

  def revert_cashback_on_cancel_or_refund
    return unless %w[canceled refunded].include?(status)
    Cashback::RevertFromPaymentService.new(self).call
  end

  def send_to_utmify
    return if ['bonus'].include?(method)
    return if status == "pending" && utmifies.last&.status == "paid"

    UtmifyJob.perform_later(id)
  end

  def period_access_course(course)
    return nil if course.lifetime

    created_at + course.period_access.months
  end

  after_create do
    LogChange.save_log("Inclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  before_update do
    LogChange.save_log("Alteração de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at)) unless saved_change_to_status?
  end

  before_destroy do
    LogChange.save_log("Exclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  def atributos_log
    attributes.except("updated_at", "created_at", "log_return_transaction", "billet_line", "billet_barcode", "billet_qr_code", "billet_pdf", "billet_expiry_date", "pix_qrcode", "pix_qrcode_text", "pix_expires_at")
  end
end
