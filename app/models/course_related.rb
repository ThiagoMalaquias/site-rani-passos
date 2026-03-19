class CourseRelated < ApplicationRecord
  belongs_to :course
  belongs_to :linked, polymorphic: true
end
