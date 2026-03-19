class UserCourse < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :payment, optional: true
  belongs_to :subscription, optional: true

  after_commit :verify_tags, on: [:create, :update]
  after_commit :set_tag_with_lifetime, on: [:create, :update]
  has_many :free_link_user_courses, dependent: :destroy

  scope :access_actives, -> { where(status: 'active') }
  scope :authenticated, -> { where(authenticate: true) }
  scope :non_nil_amount, -> { where.not(amount: nil) }
  scope :non_nil_discount, -> { where.not(discount: "") }
  scope :non_lifetime, -> { where(lifetime: false) }
  scope :expired_accesses, ->(start_date, end_date) { access_actives.authenticated.non_lifetime.where("TO_CHAR(access_until::date, 'YYYY-MM-DD') >= ? and TO_CHAR(access_until::date,'YYYY-MM-DD') <= ?", start_date, end_date) }

  def self.titles
    non_nil_amount.map { |uc| uc.course.title }.join(", ")
  end

  def self.discounts
    non_nil_discount.map { |uc| "#{uc.course.title}: #{uc.discount}" }.join(", ")
  end

  def value_with_discount
    return 0 if discount.blank?

    value_cash_course - amount
  end

  def value_cash_course
    return amount if discount.blank?

    discount_course = Discount.find_by(title: discount)
    discount_course = CartDiscount.find_by(title: discount) if discount_course.nil?
    return (amount / 100) if discount_course.nil?

    low_discount = discount_course.value.to_f / 100
    amount / (1 - low_discount)
  end

  def confirm_status
    return status if status == "inactive"

    return "expired" if access_until.present? && access_until <= (Time.zone.now)
    return payment.status if payment.present?
    return subscription.status if subscription.present?

    status
  end

  def origin
    return "Link Gratuito" if free_link_user_courses.exists?
    return "Venda" if payment.present?
    return "Assinatura" if subscription.present?
    return "Pedido" if OrderInstallment.where.not(payment: nil).find_by(payment: payment).present?

    "Manual"
  end

  def self.send_message_finish_access(days)
    expiry_date = days.days.from_now.to_date
    user_courses = UserCourse.authenticated.non_lifetime.where(access_until: expiry_date)

    user_courses.reject do |user_course|
      future_access?(user_course, expiry_date) || user_course.free_link_user_courses.exists?
    end
  end

  def self.send_message_free_link
    expiry_date = 1.day.from_now.to_date
    user_courses = UserCourse.authenticated.non_lifetime.where(access_until: expiry_date)

    user_courses.reject do |user_course|
      future_access?(user_course, expiry_date) || !user_course.free_link_user_courses.exists?
    end
  end

  def self.future_access?(user_course, expiry_date)
    UserCourse.authenticated.non_lifetime
      .access_actives
      .where(user_id: user_course.user_id, course_id: user_course.course_id)
      .exists?(["access_until > ?", expiry_date])
  end

  private

  def verify_tags
    User::Tags::UserCourse.new(self).call!
  end

  def set_tag_with_lifetime
    tag = Tag.find_by(name: "Aluno-Vitalicio")

    if authenticate == true && lifetime == true
      UserTag.find_or_create_by(user: user, tag: tag)
      return
    end

    user_courses_lifetime = UserCourse.where(user: user, lifetime: true, authenticate: true)
    UserTag.find_by(user: user, tag: tag)&.destroy if user_courses_lifetime.count.zero?
  end
end
