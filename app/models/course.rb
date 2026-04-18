class Course < ApplicationRecord
  has_one_attached :image
  has_one_attached :banner
  has_one_attached :image_mobile

  belongs_to :company
  belongs_to :tag, optional: true

  has_many :capsules, dependent: :destroy
  has_many :matters, dependent: :destroy
  has_many :order_courses, dependent: :destroy
  has_many :course_categories, dependent: :destroy
  has_many :categories, through: :course_categories
  has_many :course_discounts, dependent: :destroy
  has_many :discounts, through: :course_discounts
  has_many :user_courses, dependent: :destroy
  has_many :users, through: :user_courses
  has_many :user_open_carts, dependent: :destroy
  has_many :user_tracks, dependent: :destroy
  has_many :warranties, class_name: :CourseWarranty, dependent: :destroy
  has_many :links, class_name: :CourseLink, dependent: :destroy
  has_many :free_links, class_name: :CourseFreeLink, dependent: :destroy
  has_many :essays, class_name: :CourseEssay, dependent: :destroy
  has_many :announcements, class_name: :CourseAnnouncement, dependent: :destroy
  has_many :collections, class_name: :CourseCollection, dependent: :destroy
  has_many :relateds, class_name: :CourseRelated, dependent: :destroy
  has_many :related_student_areas, class_name: :CourseRelatedStudentArea, dependent: :destroy
  has_many :user_favorites, class_name: :UserFavoriteCourse, dependent: :destroy
  has_many :promotions, class_name: :CourseCollection, foreign_key: "promotion_id", dependent: :destroy

  accepts_nested_attributes_for :course_categories, :course_discounts

  after_save :verify_slug

  scope :featureds, -> { where(featured: 'yes') }
  scope :disclosure_actives, -> { where(status_disclosure: 'active') }
  scope :disclosure_inactives, -> { where(status_disclosure: 'inactive') }
  scope :access_actives, -> { where(status_access: 'active') }
  scope :not_signature, -> { where(signature: false) }
  scope :recurrents, -> { where(recurrent: true) }
  scope :not_recurrents, -> { where(recurrent: false) }
  scope :free, -> { where(nature: 'free') }
  scope :paids, -> { where(nature: 'paid') }
  scope :usuals, -> { where(kind: 'usual') }
  scope :simulateds, -> { where(kind: 'simulated') }
  scope :mentorings, -> { where(essay_mentoring: 'yes') }
  scope :rani_passos, -> { where(site: ['all', 'rani_passos']) }

  INTEREST = 1.67

  def discount_percentage
    cash = Convert.convert_comma_to_float(value_cash)
    of = Convert.convert_comma_to_float(value_of)
    (100 - (cash.to_f * 100 / of.to_f)).to_i rescue 0
  end

  def total_price(course_in_cookies = {})
    price = Convert.convert_comma_to_float(value_cash)
    return price if course_in_cookies.blank?

    discount = percentage_discount_applied(course_in_cookies)
    return price if discount.zero? || discount == -1

    price - ((price * discount) / 100)
  end

  def checkout_discount_title(course_in_cookies)
    return if course_in_cookies.blank?

    code = course_in_cookies["code"].to_i
    if code.positive?
      CartDiscount.find_by(id: code)&.title
    else
      course_in_cookies["discount"].to_s.strip.presence
    end
  end

  def checkout_discount_amount(course_in_cookies)
    return 0.0 if course_in_cookies.blank?

    pct = percentage_discount_applied(course_in_cookies)
    return 0.0 if pct.zero? || pct == -1

    base = Convert.convert_comma_to_float(value_cash)
    (base - total_price(course_in_cookies)).round(2)
  end

  def percentage_discount_applied(course_in_cookies)
    code = course_in_cookies["code"].to_i
    title_discount = course_in_cookies["discount"]

    if code.positive?
      discount = CartDiscount.find(code)
      return discount.value
    end

    discount = Discount.find_by(title: title_discount)
    course_discount = course_discounts.find_by(discount_id: discount.id) if discount.present?
    return course_discount.discount.value if course_discount.present?

    -1
  end

  def all_installments
    total_amount = Convert.convert_comma_to_float(value_cash)

    (1..installments.to_i).map do |installment|
      if installment == 1
        { key: 1, value: format('%.2f', total_amount).tr('.', ',') }
      elsif installment >= 2 && installment <= 6
        unic = total_amount / installment
        { key: installment, value: format('%.2f', unic).tr('.', ',') }
      else
        interest_real = total_amount * INTEREST / 100
        unic = (total_amount / installment) + interest_real
        { key: installment, value: format('%.2f', unic).tr('.', ',') }
      end
    end
  end

  def total_amount_with_installment(installment = "")
    total_amount = Convert.convert_comma_to_float(value_cash)

    if installment.present?
      value_installment = all_installments.find { |i| i[:key] == installment.to_i }[:value]
      value = Convert.convert_comma_to_float(value_installment) * installment.to_i
      return format('%.2f', value).to_f
    end

    total_amount
  end

  def last_installment
    return "" if installments.to_i == 0

    cash = Convert.convert_comma_to_float(value_cash)
    return cash if installments.to_i == 1

    cash = (cash / installments.to_i) + (cash * INTEREST / 100)
    cash.to_f
  end

  def duplicate
    Course::Duplicate.new(self).call
  end

  def lesson_count
    total = Lesson.where(capsule: capsules).count rescue 0
    return 120 if total.zero?

    total
  end

  def self.courses_bind_signature(course)
    hash_categories = course.categories.to_h { |cat| [cat.title, cat.id] }
    hash_categories.delete("Assinaturas")
    Course
      .distinct
      .joins(:course_categories)
      .where(signature: false)
      .access_actives.where("course_categories.category_id in (#{hash_categories.map { |_k, v| v }.join(',')})")
  end

  private

  def verify_slug
    return if slug.present?

    self.slug = "#{title.parameterize}-#{id}"
    save
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
