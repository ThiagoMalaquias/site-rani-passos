class UserCourseNotification < ApplicationRecord
  belongs_to :user
  belongs_to :course_notification
end
