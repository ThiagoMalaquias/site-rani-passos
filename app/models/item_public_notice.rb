class ItemPublicNotice < ApplicationRecord
  belongs_to :stall
  belongs_to :subject

  has_many :item_topics, dependent: :destroy
  has_many :item_themes, dependent: :destroy

  accepts_nested_attributes_for :item_topics, allow_destroy: true, update_only: false
  accepts_nested_attributes_for :item_themes, allow_destroy: true, update_only: false

  def themes
    subject.themes
  end

  def topics
    SubjectThemeTopic.where(subject_theme_id: item_themes.pluck(:subject_theme_id))
  end
end
