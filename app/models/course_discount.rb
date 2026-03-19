class CourseDiscount < ApplicationRecord
  belongs_to :course
  belongs_to :discount
end
