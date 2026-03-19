class CourseNotification < ApplicationRecord
  belongs_to :course
  has_many :user_vieweds, class_name: "UserCourseNotification", dependent: :destroy
end
