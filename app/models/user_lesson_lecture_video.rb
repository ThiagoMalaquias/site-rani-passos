class UserLessonLectureVideo < ApplicationRecord
  belongs_to :user
  belongs_to :lesson_lecture_video
end
