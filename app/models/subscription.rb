class Subscription < ApplicationRecord
  belongs_to :company
  belongs_to :user

  has_many :user_courses, dependent: :destroy
  has_many :invoices, dependent: :destroy

  before_create :set_code

  after_save :verify_status

  enum status: { pending: 0, paid: 1, canceled: 2, closed: 3, refunded: 4, expired: 5 }

  scope :paids, -> { where(status: 'paid') }
  scope :pendings, -> { where(status: 'pending') }
  scope :canceleds, -> { where(status: 'canceled') }
  scope :closeds, -> { where(status: 'closed') }
  scope :refundeds, -> { where(status: 'refunded') }
  scope :method_card, -> { where(method: "card") }
  scope :method_bonus, -> { where(method: "bonus") }
  scope :period_date, ->(start_date, end_date) { where("TO_CHAR(subscriptions.created_at - interval '3 hour','YYYY-MM-DD') >= ? and TO_CHAR(subscriptions.created_at - interval '3 hour','YYYY-MM-DD') <= ?", start_date, end_date) }

  def set_code
    self.code = SecureRandom.uuid
  end

  def self.call!(company, courses, user, amount, subscription_params)
    service = Subscription::CardService.new(company, courses, user, amount, subscription_params)

    service.call!
  rescue Exception => e
    Rails.logger.info "=========[#{e.inspect}]=========="
    raise "Dados não autorizados, confira e tente novamente"
  end

  def save_error(message)
    self.status = :canceled if status != "paid"

    self.error = message
    save!
  end

  def self.status_webhook(data)
    return false if data["id"].blank?

    subscription = Subscription.find_by(invoice_id: data["id"])
    return true unless subscription && !subscription.paid?

    status_map = {
      "paid" => "paid",
      "activated" => "paid",
      "canceled" => "refunded",
      "closed" => "closed",
      "expired" => "expired"
    }

    subscription.update(status: status_map[data["status"]])
  end

  def method_pt
    case method
    when 'card'
      return 'Cartão de Crédito'
    end
  end

  def status_pt
    case status
    when 'pending'
      return 'Pendente'
    when 'canceled'
      return "Cancelado"
    when 'paid'
      return "Ativo"
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
      amount = (self.amount / 100)

      user_course_params = { subscription: self, user: user, status: "active", access_start: created_at, lifetime: true, authenticate: false }

      UserCourse.create(user_course_params.merge!(course: course, amount: amount, discount: cookies_in_course["discount"]))
      course.collections.each do |collection|
        UserCourse.create(user_course_params.merge!(course: collection.promotion, amount: nil, discount: nil))
      end
    end
  end

  private

  def verify_status
    case status
    when "paid"
      user_courses.update_all(authenticate: true)

      WhatsappMessage.send_text(user, "purchase_completed") if WhatsappSendRule.first.purchase_completed_subscription
      EmailsMailer.purchase_course(self).deliver
      tag = Tag.find_by(name: "Aluno-Pago")
      UserTag.find_or_create_by(user: user, tag: Tag.find_by(name: "Aluno-Pago")) if tag.present?
    else
      user_courses.update_all(authenticate: false) if user_courses.present?
    end
  end

  after_create do
    LogChange.save_log("Inclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  before_update do
    LogChange.save_log("Alteração de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  before_destroy do
    LogChange.save_log("Exclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  def atributos_log
    attributes.except("updated_at", "created_at", "log_return_transaction", "billet_line", "billet_barcode", "billet_qr_code", "billet_pdf", "billet_expiry_date", "pix_qrcode", "pix_qrcode_text", "pix_expires_at")
  end
end
