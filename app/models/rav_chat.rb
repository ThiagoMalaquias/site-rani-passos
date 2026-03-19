class RavChat < ApplicationRecord
  belongs_to :user
  has_many :rav_chat_messages, dependent: :destroy
end
