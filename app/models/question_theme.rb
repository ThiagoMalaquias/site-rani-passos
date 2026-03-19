class QuestionTheme < ApplicationRecord
  belongs_to :question
  belongs_to :subject_theme
end
