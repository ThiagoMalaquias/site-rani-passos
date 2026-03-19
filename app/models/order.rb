class Order < ApplicationRecord
  belongs_to :user
  belongs_to :manager

  has_many :order_installments, dependent: :destroy
  has_many :order_courses, dependent: :destroy
  has_many :courses, through: :order_courses

  before_create :set_code
  after_create :generate_order_installments

  accepts_nested_attributes_for :order_courses, allow_destroy: true, update_only: false, reject_if: :should_reject_order_course?

  scope :paids, -> { where(status: 'Pago') }
  scope :active, -> { where(canceled_at: nil) }
  scope :recurrent, -> { where(payment_installments: "recorrente") }
  scope :not_recurrent, -> { where.not(payment_installments: "recorrente") }
  scope :period_date, ->(start_date, end_date) { where("TO_CHAR(orders.created_at - interval '3 hour','YYYY-MM-DD') >= ? and TO_CHAR(orders.created_at - interval '3 hour','YYYY-MM-DD') <= ?", start_date, end_date) }

  scope :total_received, -> {
    paids
      .joins(order_installments: :payment)
      .where(payments: { status: 'paid' })
      .sum('payments.amount')
  }

  scope :most_used_payment_method, -> {
    group(:payment_method)
      .order(Arel.sql('COUNT(*) DESC'))
      .limit(1)
      .pluck(:payment_method)
      .first
  }

  scope :per_month, -> {
    group("DATE_TRUNC('month', created_at)").count
  }

  def set_code
    self.code = SecureRandom.uuid
  end

  def canceled!(name_system)
    self.canceled_at = Time.zone.now
    self.canceled_name = name_system
    save
    update_status!
  end

  def un_cancel!
    self.canceled_at = nil
    self.canceled_name = nil
    save
    update_status!
  end

  def payment_method_pt
    case payment_method
    when 'card'
      return 'Cartão de Crédito'
    when 'billet'
      return "Boleto Bancário"
    when 'pix'
      return "Pix"
    end
  end

  def installments
    total_amount = amount

    (1..13).map do |installment|
      if installment == 1
        { key: 1, value: total_amount }
      elsif installment >= 2 && installment <= 6
        unic = total_amount / installment
        { key: installment, value: unic.round(2) }
      elsif installment == 13
        { key: "recorrente", value: "recorrente" }
      else
        interest_real = total_amount * Course::INTEREST / 100
        unic = (total_amount / installment) + interest_real
        { key: installment, value: unic.round(2) }
      end
    end
  end

  def subtotal
    order_courses.sum { |oc| Convert.convert_comma_to_float(oc.value_cash) }
  end

  def total_amount_without_interest
    subtotal - discount
  end

  def paid_installments
    return order_installments.joins(:payment).where(payment: { status: :paid }).count if payment_method != "card"
    return calculate_paid_installments if status == "Pago" && payment_method == "card"

    0
  end

  def invalid_first_installment_amount?
    first_installment_amount.nil? || first_installment_amount.zero?
  end

  def amount_per_installment
    installments = payment_installments.to_i
    return amount / installments if invalid_first_installment_amount?

    total = amount - first_installment_amount
    total / (installments - 1)
  end

  def amount_installment(installment)
    return first_installment_amount if first_installment_amount.positive? && installment.zero?

    return amount_per_installment
  end

  def generate_order_installments
    new_order_installment = { marker: order_installments.count + 1, amount: amount, date_generate_payment: Time.zone.now }

    case payment_method
    when "card"
      order_installment = order_installments.create(new_order_installment)
      handle_payment(order_installment) if card_cvv.present?
    when "pix", "billet"
      if payment_installments == "recorrente"
        order_installment = order_installments.create(new_order_installment)
        handle_payment(order_installment)
      else
        generate_non_recurrent_installments
      end
    end
  end

  def generate_non_recurrent_installments
    payment_installments.to_i.times do |installment|
      date_generate_payment = Time.zone.now + (installment * 30).days
      order_installments.create(marker: (installment + 1), amount: amount_installment(installment), date_generate_payment: date_generate_payment)
    end

    handle_payment(order_installments.first)
  end

  def handle_payment(order_installment)
    order_installment.payment = order_installment.create_installment_payment
    order_installment.error = ""
    order_installment.save

    send_messages(order_installment)
  rescue
    WhatsappMessage.send_text(user, "purchase_cancelled_status") if WhatsappSendRule.first.purchase_cancelled_status
    order_installment.error = "Error ao efetuar pagamento"
    order_installment.save
  end

  def update_status!
    Orders::StatusManager.new(self).update!
  end

  private

  def should_reject_order_course?(attributes)
    attributes['course_id'].blank?
  end

  def send_messages(order_installment)
    case payment_method
    when "card"
      text = "https://ranipassos.com.br/orders/complete-payment/#{code}"
    when "pix", "billet"
      return if order_installment.payment.nil?

      text = "https://ranipassos.com.br/payments/thanks/#{order_installment.payment.code}"
    end

    substitutions = [{ name: "{{order_link}}", text: text }]

    table_column = order_installment.marker == 1 ? "order_generated_successfully" : "new_installment_order_generated"
    WhatsappMessage.send_text(user, table_column, Company.first, substitutions) if table_column == "order_generated_successfully" && WhatsappSendRule.first.order_generated_successfully
    WhatsappMessage.send_text(user, table_column, Company.first, substitutions) if table_column == "new_installment_order_generated" && WhatsappSendRule.first.new_installment_order_generated
  end

  def calculate_paid_installments
    purchase_date = created_at
    current_date = Time.zone.now

    years_difference = current_date.year - purchase_date.year
    months_difference = current_date.month - purchase_date.month
    total_months = (years_difference * 12) + months_difference

    total_months += 1 if current_date.day >= purchase_date.day

    [total_months, payment_installments.to_i].min
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
    attributes.except("updated_at", "created_at", "card_cvv")
  end
end
