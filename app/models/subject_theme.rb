class SubjectTheme < ApplicationRecord
  belongs_to :subject
  has_many :topics, class_name: :SubjectThemeTopic, dependent: :destroy
end
