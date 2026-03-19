class Participation < ApplicationRecord
  belongs_to :assessment
  belongs_to :user
  has_many :grades, dependent: :destroy
end