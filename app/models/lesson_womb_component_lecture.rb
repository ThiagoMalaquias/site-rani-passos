class LessonWombComponentLecture < ApplicationRecord
  belongs_to :lesson
  belongs_to :womb
  belongs_to :component
  belongs_to :lecture
end
