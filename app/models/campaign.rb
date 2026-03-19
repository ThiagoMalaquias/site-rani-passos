class Campaign < ApplicationRecord
  has_one_attached :image
  has_many :users, class_name: "CampaignUser", dependent: :destroy
end
