class LinkUserCourse < ApplicationRecord
  belongs_to :course_link
  belongs_to :user_course
end
