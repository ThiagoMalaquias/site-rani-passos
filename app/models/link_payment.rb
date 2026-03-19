class LinkPayment < ApplicationRecord
  belongs_to :course_link
  belongs_to :payment
end
