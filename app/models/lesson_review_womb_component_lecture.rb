class LessonReviewWombComponentLecture < ApplicationRecord
  belongs_to :lesson
  belongs_to :womb
  belongs_to :component
  belongs_to :lecture

  def videos=(value)
    super(Array(value).reject(&:blank?))
  end
end
