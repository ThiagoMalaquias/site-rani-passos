class CartDiscount < ApplicationRecord
  belongs_to :company

  scope :actives, -> { where(status: 'active') }

  def qtt_payments
    UserCourse.where(discount: title, authenticate: true).count
  end
end
