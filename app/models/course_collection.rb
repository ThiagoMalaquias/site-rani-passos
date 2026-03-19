class CourseCollection < ApplicationRecord
  belongs_to :course
  belongs_to :promotion, polymorphic: true
end
