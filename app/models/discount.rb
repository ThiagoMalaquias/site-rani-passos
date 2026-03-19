class Discount < ApplicationRecord
  belongs_to :company
  has_many :course_discounts, dependent: :destroy

  validates :title, :value, presence: true

  scope :actives, -> { where(status: 'active') }

  def full_payments
    Payment
      .where(payments: { status: 'paid' })
      .joins(:user_courses)
      .where(user_courses: { discount: title })
      .distinct
      .count
  end

  private

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
    attributes.except("company_id", "updated_at", "created_at")
  end
end
