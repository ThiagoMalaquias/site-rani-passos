class Question < ApplicationRecord
  belongs_to :subject
  belongs_to :stall
  belongs_to :exam
  belongs_to :position
  belongs_to :level

  has_many :alternatives, dependent: :destroy
  has_many :question_themes, dependent: :destroy
  has_many :question_topics, dependent: :destroy

  accepts_nested_attributes_for :alternatives, allow_destroy: true, update_only: false
  accepts_nested_attributes_for :question_themes, allow_destroy: true, update_only: false
  accepts_nested_attributes_for :question_topics, allow_destroy: true, update_only: false

  def themes
    subject.themes
  end

  def topics
    SubjectThemeTopic.where(subject_theme_id: question_themes.pluck(:subject_theme_id))
  end
end
