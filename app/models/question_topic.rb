class QuestionTopic < ApplicationRecord
  belongs_to :question
  belongs_to :subject_theme_topic
end
