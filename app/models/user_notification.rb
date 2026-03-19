class UserNotification < ApplicationRecord
  belongs_to :user

  scope :not_viewed, -> { where(viewed: false) }
end
