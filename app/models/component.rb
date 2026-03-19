class Component < ApplicationRecord
  belongs_to :womb

  has_many :lectures, dependent: :destroy
end
