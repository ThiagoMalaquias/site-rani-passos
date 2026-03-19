class OrderInstallment < ApplicationRecord
  belongs_to :order
  belongs_to :payment, optional: true

  after_update :remove_payment, if: -> { saved_change_to_date_generate_payment? }
  after_update :alter_access_until_course, if: -> { saved_change_to_payment_id? }

  scope :average_amount, -> { average(:amount) }

  scope :average_per_order, -> {
    joins(:order)
      .group('orders.id')
      .count
      .values
      .instance_eval { sum.to_f / size }
      .round(1)
  }

  def status
    return payment.status_pt if payment.present?

    "Não Lançado"
  end

  def viwer_link_payment?
    return false if payment.blank?
    return false if order.payment_method == "card"
    return false if error.present?

    payment.status_pt == "Pendente"
  end

  def viwer_link_new_payment?
    return false if order.payment_method == "card"
    return false if error.blank?

    true
  end

  def viwer_link_edit?
    return false if order.payment_method == "card"
    return false unless ["Não Lançado", "Vencido"].include?(status)

    true
  end

  def create_installment_payment
    company = Company.first
    user = order.user
    courses = order.courses

    price = (amount * 100).to_i
    formated_courses = courses.map { |course| { "id" => course.id } }

    Payment.call!(company, formated_courses, user, price, payment_params)
  end

  private

  def payment_params
    case order.payment_method
    when "card"
      credit_card = {
        holder_name: order.card_name,
        number: order.card_number,
        exp_month: order.card_expiry.split("/").first,
        exp_year: order.card_expiry.split("/").last,
        cvv: order.card_cvv
      }

      payment_installments = order.payment_installments
      date_overdue = ""
      order.update(card_cvv: "")

      if order.payment_installments == "recorrente"
        payment_installments = 1
        date_overdue = (date_generate_payment + 34.days)
      end

      {
        method: order.payment_method,
        credit_card: credit_card.to_json,
        installments: payment_installments,
        date_overdue: date_overdue
      }
    when "pix", "billet"
      { method: order.payment_method, date_overdue: date_overdue_payment }
    end
  end

  def date_overdue_payment
    markers = order.order_installments.pluck(:marker).sort
    date_generate = date_generate_payment + 34.days
    return date_generate if order.payment_installments == "recorrente" || markers.last != marker
    return nil if order.lifetime

    if order.additional_time.zero?
      return (order.created_at + 1.year)
    else
      time = order.additional_time
      return (order.created_at + 1.year + time.months)
    end
  end

  def remove_payment
    self.payment = nil
    save
  end

  def alter_access_until_course
    return if payment_id.nil?

    user_courses = UserCourse.where(payment_id: payment_id)
    user_courses.each do |user_course|
      course = user_course.course
      order_created_at = order.created_at
      order_additional_time = order.additional_time

      user_course.access_start = order_created_at
      user_course.access_until = access_until(order_created_at, order_additional_time, course)
      user_course.lifetime = order.lifetime
      user_course.save
    end
  end

  def access_until(order_created_at, order_additional_time, course)
    return nil if order.lifetime || course.lifetime
    return order_created_at + course.period_access.months if order_additional_time.zero?

    order_created_at + course.period_access.months + order_additional_time.months
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
    attributes.except("updated_at", "created_at")
  end
end
