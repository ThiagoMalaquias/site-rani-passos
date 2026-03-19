class UserCoursePopup < ApplicationRecord
  belongs_to :user
  belongs_to :course_popup
end
