class ItemTopic < ApplicationRecord
  belongs_to :item_public_notice
  belongs_to :subject_theme_topic
end
