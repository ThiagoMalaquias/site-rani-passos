class OrderCourse < ApplicationRecord
  belongs_to :order
  belongs_to :course
end
