class CoursePopup < ApplicationRecord
  belongs_to :course

  has_one_attached :image
  has_one_attached :image_mobile

  has_many :user_course_popups, dependent: :destroy
end
